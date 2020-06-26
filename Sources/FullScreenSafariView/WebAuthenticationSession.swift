import SwiftUI
import SafariServices
import AuthenticationServices

public struct WebAuthenticationSession {
    
    let url: URL
    let callbackURLScheme: String?
    let completionHandler: ASWebAuthenticationSession.CompletionHandler
    
    var prefersEphemeralWebBrowserSession: Bool = false
    
    public init(
        url: URL,
        callbackURLScheme: String?,
        completionHandler: @escaping ASWebAuthenticationSession.CompletionHandler
    ) {
        self.url = url
        self.callbackURLScheme = callbackURLScheme
        self.completionHandler = completionHandler
    }
    
    public func prefersEphemeralWebBrowserSession(_ prefersEphemeralWebBrowserSession: Bool) -> Self {
        var modified = self
        modified.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
        return modified
    }
}

class WebAuthenticationSessionViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {
    
    // MARK: ASWebAuthenticationPresentationContextProviding
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
}

struct WebAuthenticationSessionHosting<Item: Identifiable>: UIViewControllerRepresentable {
    
    @Binding var item: Item?
    var representationBuilder: (Item) -> WebAuthenticationSession
    
    func makeUIViewController(context: Context) -> WebAuthenticationSessionViewController {
        return WebAuthenticationSessionViewController()
    }
    
    func updateUIViewController(_ uiViewController: WebAuthenticationSessionViewController, context: Context) {
        
        setPresentationControllerDismissalDelegateToSafariViewController(presentedBy: uiViewController, in: context)
        
        let itemUpdateChange = context.coordinator.itemStorage.updateItem(item)
        
        switch itemUpdateChange { // (oldItem, newItem)
        case (.none, .none):
            ()
        case let (.none, .some(newItem)):
            startWebAuthenticationSession(on: uiViewController, in: context, using: newItem)
        case (.some, .some):
            ()
        case (.some, .none):
            cancelWebAuthenticationSession(from: uiViewController, in: context)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onDismissed: resetItemBinding)
    }
    
    private func setPresentationControllerDismissalDelegateToSafariViewController(presentedBy uiViewController: UIViewController, in context: Context) {
        guard let safariViewController = uiViewController.presentedViewController as? SFSafariViewController else {
            return
        }
        safariViewController.presentationController?.delegate = context.coordinator.presentationControllerDismissalDelegate
    }
    
    private func startWebAuthenticationSession(on webAuthenticationSessionViewController: WebAuthenticationSessionViewController, in context: Context, using item: Item) {
        let representation = representationBuilder(item)
        let session = ASWebAuthenticationSession(
            url: representation.url,
            callbackURLScheme: representation.callbackURLScheme,
            completionHandler: { (callbackURL, error) in
                resetItemBinding()
                representation.completionHandler(callbackURL, error)
            }
        )
        applyRepresentation(representation, to: session)
        session.presentationContextProvider = webAuthenticationSessionViewController
        
        context.coordinator.session = session
        session.start()
    }
    
    private func cancelWebAuthenticationSession(from uiViewController: UIViewController, in context: Context) {
        context.coordinator.session?.cancel()
        context.coordinator.session = nil
    }
    
    private func applyRepresentation(_ representation: WebAuthenticationSession, to session: ASWebAuthenticationSession) {
        session.prefersEphemeralWebBrowserSession = representation.prefersEphemeralWebBrowserSession
    }
    
    private func resetItemBinding() {
        self.item = nil
    }
    
    class Coordinator {
        
        var session: ASWebAuthenticationSession?
        var itemStorage: ItemStorage
        let presentationControllerDismissalDelegate: PresentationControllerDismissalDelegate
        
        init(onDismissed: @escaping () -> Void) {
            self.itemStorage = ItemStorage()
            self.presentationControllerDismissalDelegate = PresentationControllerDismissalDelegate(onDismissed: onDismissed)
        }
        
        struct ItemStorage {
            
            private var item: Item?
            
            mutating func updateItem(_ newItem: Item?) -> (oldItem: Item?, newItem: Item?) {
                let oldItem = self.item
                self.item = newItem
                return (oldItem: oldItem, newItem: newItem)
            }
        }
        
        class PresentationControllerDismissalDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
            
            private let onDismissed: () -> Void
            
            init(onDismissed: @escaping () -> Void) {
                self.onDismissed = onDismissed
            }
            
            func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
                onDismissed()
            }
        }
    }
}

struct WebAuthenticationSessionPresentationModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    var onDismiss: (() -> Void)? = nil
    var representationBuilder: () -> WebAuthenticationSession
    
    private var item: Binding<Bool?> {
        .init(
            get: { self.isPresented ? true : nil },
            set: { self.isPresented = ($0 != nil) }
        )
    }
    
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
    var onDismiss: (() -> Void)? = nil
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
        onDismiss: (() -> Void)? = nil,
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
