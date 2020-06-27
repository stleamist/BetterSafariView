import SwiftUI
import SafariServices

public struct SafariView {
    
    public typealias Configuration = SFSafariViewController.Configuration
    
    // MARK: Representation Properties
    
    let url: URL
    let configuration: Configuration
    
    public init(url: URL, configuration: SFSafariViewController.Configuration = .init()) {
        self.url = url
        self.configuration = configuration
    }
    
    // MARK: Modifiers
    
    var preferredBarTintColor: UIColor?
    var preferredControlTintColor: UIColor?
    var dismissButtonStyle: SFSafariViewController.DismissButtonStyle = .done
    
    public func preferredBarTintColor(_ color: UIColor?) -> Self {
        var modified = self
        modified.preferredBarTintColor = color
        return modified
    }
    
    public func preferredControlTintColor(_ color: UIColor?) -> Self {
        var modified = self
        modified.preferredControlTintColor = color
        return modified
    }
    
    public func dismissButtonStyle(_ style: SFSafariViewController.DismissButtonStyle) -> Self {
        var modified = self
        modified.dismissButtonStyle = style
        return modified
    }
    
    // MARK: Modification Applier
    
    func applyModification(to safariViewController: SFSafariViewController) {
        safariViewController.preferredBarTintColor = self.preferredBarTintColor
        safariViewController.preferredControlTintColor = self.preferredControlTintColor
        safariViewController.dismissButtonStyle = self.dismissButtonStyle
    }
}

public extension SafariView.Configuration {
    convenience init(entersReaderIfAvailable: Bool = false, barCollapsingEnabled: Bool = true) {
        self.init()
        self.entersReaderIfAvailable = entersReaderIfAvailable
        self.barCollapsingEnabled = barCollapsingEnabled
    }
}

struct SafariViewHosting<Item: Identifiable>: UIViewControllerRepresentable {
    
    // MARK: Representation
    
    @Binding var item: Item?
    var onDismiss: (() -> Void)? = nil
    var representationBuilder: (Item) -> SafariView
    
    // MARK: UIViewControllerRepresentable
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        let itemUpdateChange = context.coordinator.itemStorage.updateItem(item)
        
        switch itemUpdateChange { // (oldItem, newItem)
        case (.none, .none):
            ()
        case let (.none, .some(newItem)):
            presentSafariViewController(from: uiViewController, in: context, using: newItem)
        case let (.some(oldItem), .some(newItem)) where oldItem.id != newItem.id:
            dismissSafariViewController(from: uiViewController) {
                self.presentSafariViewController(from: uiViewController, in: context, using: newItem)
            }
        case let (.some, .some(newItem)):
            updateSafariViewController(presentedBy: uiViewController, using: newItem)
        case (.some, .none):
            dismissSafariViewController(from: uiViewController)
        }
    }
    
    // MARK: Update Handlers
    
    private func presentSafariViewController(from uiViewController: UIViewController, in context: Context, using item: Item) {
        let representation = representationBuilder(item)
        let safariViewController = SFSafariViewController(url: representation.url, configuration: representation.configuration)
        safariViewController.delegate = context.coordinator.safariViewControllerFinishDelegate
        representation.applyModification(to: safariViewController)
        uiViewController.present(safariViewController, animated: true)
    }
    
    private func updateSafariViewController(presentedBy uiViewController: UIViewController, using item: Item) {
        guard let safariViewController = uiViewController.presentedViewController as? SFSafariViewController else {
            return
        }
        let representation = representationBuilder(item)
        representation.applyModification(to: safariViewController)
    }
    
    private func dismissSafariViewController(from uiViewController: UIViewController, completion: (() -> Void)? = nil) {
        
        // Check if the `uiViewController` is a instance of the `SFSafariViewController`
        // to prevent other controllers presented by the container view from being dismissed unintentionally.
        guard uiViewController.presentedViewController is SFSafariViewController else {
            return
        }
        uiViewController.dismiss(animated: true) {
            self.handleDismissalWithoutResettingItemBinding()
            completion?()
        }
    }
    
    // MARK: Dismissal Handlers
    
    // Used when the Safari view controller is finished by an item change during view update.
    private func handleDismissalWithoutResettingItemBinding() {
        self.onDismiss?()
    }
    
    // Used when the Safari view controller is finished by a user interaction.
    private func resetItemBindingAndHandleDismissal() {
        self.item = nil
        self.onDismiss?()
    }
    
    // MARK: Coordinator
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onFinished: resetItemBindingAndHandleDismissal)
    }
    
    class Coordinator {
        
        var itemStorage: ItemStorage<Item>
        let safariViewControllerFinishDelegate: SafariViewControllerFinishDelegate
        
        init(onFinished: @escaping () -> Void) {
            self.itemStorage = ItemStorage()
            self.safariViewControllerFinishDelegate = SafariViewControllerFinishDelegate(onFinished: onFinished)
        }
    }
    
    class SafariViewControllerFinishDelegate: NSObject, SFSafariViewControllerDelegate {
        
        private let onFinished: () -> Void
        
        init(onFinished: @escaping () -> Void) {
            self.onFinished = onFinished
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            onFinished()
        }
    }
}

struct SafariViewPresentationModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    var onDismiss: (() -> Void)? = nil
    var representationBuilder: () -> SafariView
    
    private var item: Binding<Bool?> {
        .init(
            get: { self.isPresented ? true : nil },
            set: { self.isPresented = ($0 != nil) }
        )
    }
    
    // Converts `() -> Void` closure to `(Bool) -> Void`
    private func itemRepresentationBuilder(bool: Bool) -> SafariView {
        return representationBuilder()
    }
    
    func body(content: Content) -> some View {
        content.background(
            SafariViewHosting(
                item: item,
                onDismiss: onDismiss,
                representationBuilder: itemRepresentationBuilder
            )
        )
    }
}

struct ItemSafariViewPresentationModifier<Item: Identifiable>: ViewModifier {
    
    @Binding var item: Item?
    var onDismiss: (() -> Void)? = nil
    var representationBuilder: (Item) -> SafariView
    
    func body(content: Content) -> some View {
        content.background(
            SafariViewHosting(
                item: $item,
                onDismiss: onDismiss,
                representationBuilder: representationBuilder
            )
        )
    }
}

public extension View {
    
    /// Presents a Safari view when a given condition is true.
    ///
    /// - Parameters:
    ///   - isPresented: A binding to whether the Safari view is presented.
    ///   - onDismiss: A closure executed when the Safari view dismisses.
    ///   - content: A closure returning the `SafariView` to present.
    func safariView(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        content representationBuilder: @escaping () -> SafariView
    ) -> some View {
        self.modifier(
            SafariViewPresentationModifier(
                isPresented: isPresented,
                onDismiss: onDismiss,
                representationBuilder: representationBuilder
            )
        )
    }
    
    /// Presents a Safari view using the given item as a data source
    /// for the `SafariView` to present.
    ///
    /// - Parameters:
    ///   - item: A binding to an optional source of truth for the Safari view.
    ///     When representing a non-`nil` item, the system uses `content` to
    ///     create a `SafariView` of the item.
    ///     If the identity changes, the system dismisses a
    ///     currently-presented Safari view and replace it by a new Safari view.
    ///   - onDismiss: A closure executed when the Safari view dismisses.
    ///   - content: A closure returning the `SafariView` to present.
    func safariView<Item: Identifiable>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        content representationBuilder: @escaping (Item) -> SafariView
    ) -> some View {
        self.modifier(
            ItemSafariViewPresentationModifier(
                item: item,
                onDismiss: onDismiss,
                representationBuilder: representationBuilder
            )
        )
    }
}
