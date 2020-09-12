import SwiftUI
import SafariServices
import AuthenticationServices

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
        
        // Keep the coordinator updated with a new presenter struct.
        context.coordinator.parent = self
        context.coordinator.item = item
    }
}

extension WebAuthenticationPresenter {
    
    class Coordinator: NSObject, ASWebAuthenticationPresentationContextProviding, UIAdaptivePresentationControllerDelegate {
        
        // MARK: Parent Copying
        
        var parent: WebAuthenticationPresenter
        
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
