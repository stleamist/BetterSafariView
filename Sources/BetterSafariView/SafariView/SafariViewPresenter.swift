#if os(iOS)

import SwiftUI
import SafariServices

struct SafariViewPresenter<Item: Identifiable>: UIViewControllerRepresentable {
    
    // MARK: Representation
    
    @Binding var item: Item?
    var onDismiss: (() -> Void)? = nil
    var representationBuilder: (Item) -> SafariView
    
    // MARK: UIViewControllerRepresentable
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        return context.coordinator.uiViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
        // Keep the coordinator updated with a new presenter struct.
        context.coordinator.parent = self
        context.coordinator.item = item
    }
}

extension SafariViewPresenter {
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        
        // MARK: Parent Copying
        
        var parent: SafariViewPresenter
        
        init(parent: SafariViewPresenter) {
            self.parent = parent
        }
        
        // MARK: View Controller Holding
        
        let uiViewController = UIViewController()
        
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
                presentSafariViewController(with: newItem)
            case let (.some(oldItem), .some(newItem)) where oldItem.id != newItem.id:
                dismissSafariViewController() {
                    self.presentSafariViewController(with: newItem)
                }
            case let (.some, .some(newItem)):
                updateSafariViewController(with: newItem)
            case (.some, .none):
                dismissSafariViewController()
            }
        }
        
        // MARK: Presentation Handlers
        
        private func presentSafariViewController(with item: Item) {
            guard uiViewController.presentedViewController == nil else {
                return
            }
            
            let representation = parent.representationBuilder(item)
            let safariViewController = SFSafariViewController(url: representation.url, configuration: representation.configuration)
            safariViewController.delegate = self
            representation.applyModification(to: safariViewController)
            
            // There is a problem that page loading and parallel push animation are not working when a modifier is attached to the view in a `List`.
            // As a workaround, use a `rootViewController` of the `window` for presenting.
            // (Unlike the other view controllers, a view controller hosted by a cell doesn't have a parent, but has the same window.)
            uiViewController.view.window?.topViewController?.present(safariViewController, animated: true)
        }
        
        private func updateSafariViewController(with item: Item) {
            guard let safariViewController = uiViewController.presentedViewController as? SFSafariViewController else {
                return
            }
            let representation = parent.representationBuilder(item)
            representation.applyModification(to: safariViewController)
        }
        
        private func dismissSafariViewController(completion: (() -> Void)? = nil) {
            let dismissCompletion: () -> Void = {
                self.handleDismissalWithoutResettingItemBinding()
                completion?()
            }
            
            guard uiViewController.presentedViewController != nil else {
                dismissCompletion()
                return
            }
            
            // Check if the `uiViewController` is a instance of the `SFSafariViewController`
            // to prevent other controllers presented by the container view from being dismissed unintentionally.
            guard let safariViewController = uiViewController.presentedViewController as? SFSafariViewController else {
                return
            }
            safariViewController.dismiss(animated: true, completion: dismissCompletion)
        }
        
        // MARK: Dismissal Handlers
        
        // Used when the Safari view controller is finished by an item change during view update.
        private func handleDismissalWithoutResettingItemBinding() {
            parent.onDismiss?()
        }
        
        // Used when the Safari view controller is finished by a user interaction.
        private func resetItemBindingAndHandleDismissal() {
            parent.item = nil
            parent.onDismiss?()
        }
        
        // MARK: SFSafariViewControllerDelegate
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            resetItemBindingAndHandleDismissal()
        }
    }
}

#endif
