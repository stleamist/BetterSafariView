import SwiftUI
import SafariServices
import AuthenticationServices

// 완료 핸들러에 item을 nil로 재설정하는 코드를 주입하기 위해 커스텀 구조체 WebAuthenticationSession을 사용한다.
// ASWebAuthenticationSession 인스턴스는 퍼블릭 게터 / 세터가 없어 완료 핸들러에 접근할 수 없다.
public struct WebAuthenticationSession {
    
    public typealias CompletionHandler = ASWebAuthenticationSession.CompletionHandler
    
    // MARK: Representation Properties
    
    let url: URL
    let callbackURLScheme: String?
    let completionHandler: CompletionHandler
    
    public init(
        url: URL,
        callbackURLScheme: String?,
        completionHandler: @escaping CompletionHandler
    ) {
        self.url = url
        self.callbackURLScheme = callbackURLScheme
        self.completionHandler = completionHandler
    }
    
    // MARK: Modifiers
    
    var prefersEphemeralWebBrowserSession: Bool = false
    
    public func prefersEphemeralWebBrowserSession(_ prefersEphemeralWebBrowserSession: Bool) -> Self {
        var modified = self
        modified.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
        return modified
    }
    
    // MARK: Modification Applier
    
    func applyModification(to webAuthenticationSession: ASWebAuthenticationSession) {
        webAuthenticationSession.prefersEphemeralWebBrowserSession = self.prefersEphemeralWebBrowserSession
    }
}

// ASWebAuthenticationSession 시작에 필수적인 presentationContextProvider를 구현하기 위해 커스텀 뷰 컨트롤러 WebAuthenticationSessionViewController를 사용한다.
// ASWebAuthenticationPresentationContextProviding는 SFAuthenticationViewController를 띄울 윈도우를 반환하며,
// 일반적으로 해당 윈도우의 루트 뷰 컨트롤러에서 present(_:animated:completion:)을 호출해 SFAuthenticationViewController를 띄운다.
class WebAuthenticationSessionViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {
    
    // MARK: ASWebAuthenticationPresentationContextProviding
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
}

struct WebAuthenticationSessionHosting<Item: Identifiable>: UIViewControllerRepresentable {
    
    // MARK: Representation
    
    @Binding var item: Item?
    var representationBuilder: (Item) -> WebAuthenticationSession
    
    // MARK: UIViewControllerRepresentable
    
    func makeUIViewController(context: Context) -> WebAuthenticationSessionViewController {
        return WebAuthenticationSessionViewController()
    }
    
    func updateUIViewController(_ uiViewController: WebAuthenticationSessionViewController, context: Context) {
        
        // SFAuthenticationViewController의 프레젠테이션 컨트롤러 델리게이트 지정을 위해
        // 뷰가 업데이트될 때마다 뷰가 띄우고 있는 뷰 컨트롤러를 매번 확인하여
        // 세션 시작 직후 최대한 빨리 델리게이트를 지정하도록 한다.
        // SFAuthenticationViewController는 SFSafariViewController의 비공개 서브클래스이다.
        setInteractiveDismissalDelegateToSafariViewController(presentedBy: uiViewController, in: context)
        
        let itemUpdateChange = context.coordinator.itemStorage.updateItem(item)
        
        switch itemUpdateChange { // (oldItem, newItem)
        case (.none, .none):
            ()
        case let (.none, .some(newItem)):
            startWebAuthenticationSession(on: uiViewController, in: context, using: newItem)
        case (.some, .some):
            ()
        case (.some, .none):
            cancelWebAuthenticationSession(in: context)
        }
    }
    
    // MARK: Update Handlers
    
    // 모달 시트를 풀 다운으로 내렸을 때 완료 핸들러가 실행되지 않아 item이 nil로 재설정되지 않는 문제가 있다.
    // SFAuthenticationViewController의 프레젠테이션 컨트롤러 델리게이트로 Coordinator의 PresentationControllerDismissalDelegate를 설정하여
    // 뷰 컨트롤러가 dismiss되었을 때 item이 nil로 재설정되도록 한다.
    private func setInteractiveDismissalDelegateToSafariViewController(presentedBy uiViewController: UIViewController, in context: Context) {
        guard let safariViewController = uiViewController.presentedViewController as? SFSafariViewController else {
            return
        }
        safariViewController.presentationController?.delegate = context.coordinator.interactiveDismissalDelegate
    }
    
    private func startWebAuthenticationSession(on presentationContextProvider: ASWebAuthenticationPresentationContextProviding, in context: Context, using item: Item) {
        let representation = representationBuilder(item)
        let session = ASWebAuthenticationSession(
            url: representation.url,
            callbackURLScheme: representation.callbackURLScheme,
            completionHandler: { (callbackURL, error) in
                self.resetItemBinding()
                representation.completionHandler(callbackURL, error)
            }
        )
        representation.applyModification(to: session)
        session.presentationContextProvider = presentationContextProvider
        
        context.coordinator.session = session
        session.start()
    }
    
    private func cancelWebAuthenticationSession(in context: Context) {
        context.coordinator.session?.cancel()
        context.coordinator.session = nil
    }
    
    // MARK: Dismissal Handlers
    
    private func resetItemBinding() {
        self.item = nil
    }
    
    // MARK: Coordinator
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onInteractiveDismiss: resetItemBinding)
    }
    
    class Coordinator {
        
        var session: ASWebAuthenticationSession?
        var itemStorage: ItemStorage<Item>
        let interactiveDismissalDelegate: InteractiveDismissalDelegate
        
        init(onInteractiveDismiss: @escaping () -> Void) {
            self.itemStorage = ItemStorage()
            self.interactiveDismissalDelegate = InteractiveDismissalDelegate(onInteractiveDismiss: onInteractiveDismiss)
        }
    }
    
    class InteractiveDismissalDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
        
        private let onInteractiveDismiss: () -> Void
        
        init(onInteractiveDismiss: @escaping () -> Void) {
            self.onInteractiveDismiss = onInteractiveDismiss
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            onInteractiveDismiss()
        }
    }
}

struct WebAuthenticationSessionPresentationModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    var representationBuilder: () -> WebAuthenticationSession
    
    private var item: Binding<Bool?> {
        .init(
            get: { self.isPresented ? true : nil },
            set: { self.isPresented = ($0 != nil) }
        )
    }
    
    // Converts `() -> Void` closure to `(Bool) -> Void`
    private func itemRepresentationBuilder(bool: Bool) -> WebAuthenticationSession {
        return representationBuilder()
    }
    
    func body(content: Content) -> some View {
        content.background(
            WebAuthenticationSessionHosting(
                item: item,
                representationBuilder: itemRepresentationBuilder
            )
        )
    }
}

struct ItemWebAuthenticationSessionPresentationModifier<Item: Identifiable>: ViewModifier {
    
    @Binding var item: Item?
    var representationBuilder: (Item) -> WebAuthenticationSession
    
    func body(content: Content) -> some View {
        content.background(
            WebAuthenticationSessionHosting(
                item: $item,
                representationBuilder: representationBuilder
            )
        )
    }
}

public extension View {
    
    /// Starts a web authentication session when a given condition is true.
    ///
    /// - Parameters:
    ///   - isPresented: A binding to whether the web authentication session should be started.
    ///   - content: A closure returning the `WebAuthenticationSession` to start.
    func webAuthenticationSession(
        isPresented: Binding<Bool>,
        content representationBuilder: @escaping () -> WebAuthenticationSession
    ) -> some View {
        self.modifier(
            WebAuthenticationSessionPresentationModifier(
                isPresented: isPresented,
                representationBuilder: representationBuilder
            )
        )
    }
    
    // FIXME: Dismiss and replace the view if the identity changes
    
    /// Starts a web authentication session using the given item as a data source
    /// for the `WebAuthenticationSession` to start.
    ///
    /// - Parameters:
    ///   - item: A binding to an optional source of truth for the web authentication session.
    ///     When representing a non-`nil` item, the system uses `content` to
    ///     create a session representation of the item.
    ///     If the identity changes, the system cancels a
    ///     currently-started session and replace it by a new session.
    ///   - content: A closure returning the `WebAuthenticationSession` to start.
    func webAuthenticationSession<Item: Identifiable>(
        item: Binding<Item?>,
        content representationBuilder: @escaping (Item) -> WebAuthenticationSession
    ) -> some View {
        self.modifier(
            ItemWebAuthenticationSessionPresentationModifier(
                item: item,
                representationBuilder: representationBuilder
            )
        )
    }
}
