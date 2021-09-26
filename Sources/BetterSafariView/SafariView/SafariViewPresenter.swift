#if os(iOS)

import SwiftUI
import SafariServices

struct SafariViewPresenter<Item: Identifiable>: UIViewRepresentable {
    
    // MARK: Representation
    
    @Binding var item: Item?
    var onDismiss: (() -> Void)? = nil
    var representationBuilder: (Item) -> SafariView
    
    // MARK: UIViewRepresentable
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UIView {
        return context.coordinator.uiView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
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
        
        let uiView = UIView()
        private weak var safariViewController: SFSafariViewController?
        
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
            let representation = parent.representationBuilder(item)
            let safariViewController = SFSafariViewController(url: representation.url, configuration: representation.configuration)
            safariViewController.delegate = self
            safariViewController.applyModification(representation, withInheritedTintColor: uiView.tintColor)
            
            // Present a Safari view controller from the `viewController` of `UIViewRepresentable`, instead of `UIViewControllerRepresentable`.
            // This fixes an issue where the Safari view controller is not presented properly
            // when the `UIViewControllerRepresentable` is detached from the root view controller (e.g. `UIViewController` contained in `UITableViewCell`)
            // while allowing it to be presented even on the modal sheets.
            // Thanks to: Bohdan Hernandez Navia (@boherna)
            guard let presentingViewController = uiView.viewController else {
                self.resetItemBinding()
                return
            }
            
            presentingViewController.present(safariViewController, animated: true)
            
            self.safariViewController = safariViewController
        }
        
        private func updateSafariViewController(with item: Item) {
            guard let safariViewController = safariViewController else {
                return
            }
            let representation = parent.representationBuilder(item)
            safariViewController.applyModification(representation, withInheritedTintColor: uiView.tintColor)
        }
        
        private func dismissSafariViewController(completion: (() -> Void)? = nil) {
            guard let safariViewController = safariViewController else {
                return
            }
            
            safariViewController.dismiss(animated: true) {
                self.handleDismissal()
                completion?()
            }
        }
        
        // MARK: Dismissal Handlers
        
        // Used when the `viewController` of `uiView` does not exist during the preparation of presentation.
        private func resetItemBinding() {
            parent.item = nil
        }
        
        // Used when the Safari view controller is finished by an item change during view update.
        private func handleDismissal() {
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

extension SFSafariViewController {
    func applyModification(_ modification: SafariView, withInheritedTintColor inheritedTintColor: UIColor?) {
        self.preferredBarTintColor = modification.preferredBarTintColor?.resolvedUIColor(withInheritedTintColor: inheritedTintColor)
        self.preferredControlTintColor = modification.preferredControlTintColor?.resolvedUIColor(withInheritedTintColor: inheritedTintColor)
        self.dismissButtonStyle = modification.dismissButtonStyle
    }
}

#endif
