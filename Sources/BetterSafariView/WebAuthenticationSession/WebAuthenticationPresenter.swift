#if os(iOS) || os(macOS) || os(watchOS)

import SwiftUI
import SafariServices
import AuthenticationServices

#if os(iOS)
typealias ViewController = UIViewController
typealias ViewControllerRepresentable = UIViewControllerRepresentable
#elseif os(macOS)
typealias ViewController = NSViewController
typealias ViewControllerRepresentable = NSViewControllerRepresentable
#endif

struct WebAuthenticationPresenter<Item: Identifiable>: ViewControllerRepresentable {
    
    // MARK: Representation
    
    @Binding var item: Item?
    var representationBuilder: (Item) -> WebAuthenticationSession
    
    // MARK: ViewControllerRepresentable
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    #if os(iOS)
    
    func makeUIViewController(context: Context) -> UIViewController {
        return makeViewController(context: context)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
        updateViewController(uiViewController, context: context)
        
        // To set a delegate for the presentation controller of an `SFAuthenticationViewController` as soon as possible,
        // check the view controller presented by `uiViewController` then set it as a delegate on every view updates.
        // INFO: `SFAuthenticationViewController` is a private subclass of `SFSafariViewController`.
        guard #available(iOS 14.0, *) else {
            context.coordinator.setInteractiveDismissalDelegateIfPossible()
            return
        }
    }
    
    #elseif os(macOS)
    
    func makeNSViewController(context: Context) -> NSViewController {
        return makeViewController(context: context)
    }
    
    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {
        updateViewController(nsViewController, context: context)
    }
    
    #endif
    
    private func makeViewController(context: Context) -> ViewController {
        return context.coordinator.viewController
    }
    
    private func updateViewController(_ viewController: ViewController, context: Context) {
        // Keep the coordinator updated with a new presenter struct.
        context.coordinator.parent = self
        context.coordinator.item = item
    }
}

extension WebAuthenticationPresenter {
    
    class Coordinator: NSObject, ASWebAuthenticationPresentationContextProviding {
        
        // MARK: Parent Copying
        
        var parent: WebAuthenticationPresenter
        
        init(parent: WebAuthenticationPresenter) {
            self.parent = parent
        }
        
        // MARK: View Controller Holding
        
        let viewController = ViewController()
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
            return viewController.view.window!
        }
        
        #if os(iOS)
        
        // MARK: InteractiveDismissalDelegate
        
        // There is a problem that `item` is not set to `nil` after the sheet is dismissed with pulling down
        // because the completion handler is not called on this case due to a system bug on iOS 13.
        // To resolve this issue, set `interactiveDismissalDelegate` as a presentation controller delegate of `SFAuthenticationViewController`
        // so that ensures the completion handler is always called.
        
        @available(iOS, introduced: 13.0, deprecated: 14.0)
        private lazy var interactiveDismissalDelegate = InteractiveDismissalDelegate(coordinator: self)
        
        @available(iOS, introduced: 13.0, deprecated: 14.0)
        func setInteractiveDismissalDelegateIfPossible() {
            guard let safariViewController = viewController.presentedViewController as? SFSafariViewController else {
                return
            }
            safariViewController.presentationController?.delegate = interactiveDismissalDelegate
        }
        
        @available(iOS, introduced: 13.0, deprecated: 14.0)
        class InteractiveDismissalDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
            
            weak var coordinator: WebAuthenticationPresenter.Coordinator?
            
            init(coordinator: WebAuthenticationPresenter.Coordinator) {
                self.coordinator = coordinator
            }
            
            // MARK: UIAdaptivePresentationControllerDelegate
            
            func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
                coordinator?.resetItemBinding()
            }
        }
        
        #endif
    }
}

#endif
