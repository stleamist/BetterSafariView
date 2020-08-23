import SwiftUI
import SafariServices
import AuthenticationServices

public typealias WebAuthenticationSessionError = ASWebAuthenticationSessionError

// Used for getting a public completion handler to inject an assignment that sets `item` to `nil`.
// INFO: It's not possible to access a completion handler from an `ASWebAuthenticationSession` instance
// because it has no public getter and setter for that.
//
/// A session that an app uses to authenticate a user through a web service.
///
/// Use a `WebAuthenticationSession` instance to authenticate a user through a web service, including one run by a third party. Initialize the session with a URL that points to the authentication webpage. A browser loads and displays the page, from which the user can authenticate. In iOS, the browser is a secure, embedded web view. In macOS, the system opens the user’s default browser if it supports web authentication sessions, or Safari otherwise.
///
/// On completion, the service sends a callback URL to the session with an authentication token, and the session passes this URL back to the app through a completion handler.
///
/// For more details, see [Authenticating a User Through a Web Service](https://developer.apple.com/documentation/authenticationservices/authenticating_a_user_through_a_web_service).
///
public struct WebAuthenticationSession {
    
    public typealias CompletionHandler = ASWebAuthenticationSession.CompletionHandler
    
    // MARK: Representation Properties
    
    let url: URL
    let callbackURLScheme: String?
    let completionHandler: CompletionHandler
    
    /// Creates a web authentication session instance.
    ///
    /// - Parameters:
    ///   - URL: A URL with the `http` or `https` scheme pointing to the authentication webpage.
    ///   - callbackURLScheme: The custom URL scheme that the app expects in the callback URL.
    ///   - completionHandler: A completion handler the session calls when it completes successfully, or when the user cancels the session.
    ///
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
    
    /// Configures whether the session should ask the browser for a private authentication session.
    ///
    /// Use `prefersEphemeralWebBrowserSession` to request that the browser doesn’t share cookies or other browsing data between the authentication session and the user’s normal browser session. Whether the request is honored depends on the user’s default web browser. Safari always honors the request.
    ///
    /// - Parameters:
    ///     - prefersEphemeralWebBrowserSession: A Boolean value that indicates whether the session should ask the browser for a private authentication session.
    ///
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

struct WebAuthenticationPresenter<Item: Identifiable>: UIViewControllerRepresentable {
    
    // MARK: Representation
    
    @Binding var item: Item?
    var representationBuilder: (Item) -> WebAuthenticationSession
    
    // MARK: UIViewControllerRepresentable
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        return context.coordinator.uiViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
        // To set a delegate for the presentation controller of an `SFAuthenticationViewController` as soon as possible,
        // check the view controller presented by `uiViewController` then set it as a delegate on every view updates.
        // INFO: `SFAuthenticationViewController` is a private subclass of `SFSafariViewController`.
        context.coordinator.setInteractiveDismissalDelegateIfPossible()
        
        context.coordinator.item = item
    }
    
    // MARK: Coordinator
    
    class Coordinator: NSObject, ASWebAuthenticationPresentationContextProviding, UIAdaptivePresentationControllerDelegate {
        
        // MARK: Parent Copying
        
        private var parent: WebAuthenticationPresenter
        
        init(parent: WebAuthenticationPresenter) {
            self.parent = parent
        }
        
        // MARK: View Controller Holding
        
        let uiViewController = UIViewController()
        private var session: ASWebAuthenticationSession?
        
        // MARK: Item Handling
        
        var item: Item? {
            didSet(oldItem) {
                handleItemChange(from: oldItem, to: item)
            }
        }
        
        // Ensure the proper presentation handler is executed only once
        // during a one SwiftUI view update life cycle.
        private func handleItemChange(from oldItem: Item?, to newItem: Item?) {
            switch (oldItem, newItem) {
            case (.none, .none):
                ()
            case let (.none, .some(newItem)):
                startWebAuthenticationSession(with: newItem)
            case (.some, .some):
                ()
            case (.some, .none):
                cancelWebAuthenticationSession()
            }
        }
        
        // MARK: Presentation Handlers
        
        private func startWebAuthenticationSession(with item: Item) {
            let representation = parent.representationBuilder(item)
            let session = ASWebAuthenticationSession(
                url: representation.url,
                callbackURLScheme: representation.callbackURLScheme,
                completionHandler: { (callbackURL, error) in
                    self.resetItemBinding()
                    representation.completionHandler(callbackURL, error)
                }
            )
            session.presentationContextProvider = self
            representation.applyModification(to: session)
            
            self.session = session
            session.start()
        }
        
        private func cancelWebAuthenticationSession() {
            session?.cancel()
            session = nil
        }
        
        // MARK: Dismissal Handlers
        
        private func resetItemBinding() {
            parent.item = nil
        }
        
        // MARK: ASWebAuthenticationPresentationContextProviding
        
        // INFO: `ASWebAuthenticationPresentationContextProviding` provides an window
        // to present an `SFAuthenticationViewController`, and usually presents the `SFAuthenticationViewController`
        // by calling `present(_:animated:completion:)` method from a root view controller of the window.
        
        func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
            return uiViewController.view.window!
        }
        
        // MARK: UIAdaptivePresentationControllerDelegate
        
        // There is a problem that `item` is not set to `nil` after the sheet is dismissed with pulling down
        // because the completion handler is not called on this case due to a system bug.
        // To resolve this issue, set `Coordinator` as a presentation controller delegate of `SFAuthenticationViewController`
        // so that ensures the completion handler is always called.
        
        func setInteractiveDismissalDelegateIfPossible() {
            guard let safariViewController = uiViewController.presentedViewController as? SFSafariViewController else {
                return
            }
            safariViewController.presentationController?.delegate = self
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            resetItemBinding()
        }
    }
}

struct WebAuthenticationPresentationModifier: ViewModifier {
    
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
            WebAuthenticationPresenter(
                item: item,
                representationBuilder: itemRepresentationBuilder
            )
        )
    }
}

struct ItemWebAuthenticationPresentationModifier<Item: Identifiable>: ViewModifier {
    
    @Binding var item: Item?
    var representationBuilder: (Item) -> WebAuthenticationSession
    
    func body(content: Content) -> some View {
        content.background(
            WebAuthenticationPresenter(
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
    ///
    func webAuthenticationSession(
        isPresented: Binding<Bool>,
        content representationBuilder: @escaping () -> WebAuthenticationSession
    ) -> some View {
        self.modifier(
            WebAuthenticationPresentationModifier(
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
    ///
    /// - Experiment:
    ///     The functionality that replaces a session on the `item`'s identity change is **not implemented**,
    ///     as there is no non-hacky way to be notified when the session's dismissal animation is completed.
    ///
    func webAuthenticationSession<Item: Identifiable>(
        item: Binding<Item?>,
        content representationBuilder: @escaping (Item) -> WebAuthenticationSession
    ) -> some View {
        self.modifier(
            ItemWebAuthenticationPresentationModifier(
                item: item,
                representationBuilder: representationBuilder
            )
        )
    }
}
