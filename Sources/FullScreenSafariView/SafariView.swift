import SwiftUI
import SafariServices

public struct SafariView {
    
    public typealias Configuration = SFSafariViewController.Configuration
    
    let url: URL
    let configuration: Configuration
    
    var preferredBarTintColor: UIColor?
    var preferredControlTintColor: UIColor?
    var dismissButtonStyle: SFSafariViewController.DismissButtonStyle = .done
    
    public init(url: URL, configuration: SFSafariViewController.Configuration = .init()) {
        self.url = url
        self.configuration = configuration
    }
    
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
}

public extension SafariView.Configuration {
    convenience init(entersReaderIfAvailable: Bool = false, barCollapsingEnabled: Bool = true) {
        self.init()
        self.entersReaderIfAvailable = entersReaderIfAvailable
        self.barCollapsingEnabled = barCollapsingEnabled
    }
}

struct SafariViewHosting<Item: Identifiable>: UIViewControllerRepresentable {
    
    @Binding var item: Item?
    var onDismiss: (() -> Void)? = nil
    var representationBuilder: (Item) -> SafariView
    
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
        case let (.some, .some(newItem)):
            updateSafariViewController(presentedBy: uiViewController, using: newItem)
        case (.some, .none):
            dismissSafariViewController(from: uiViewController)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onFinished: resetItemBindingAndExecuteDismissalHandler)
    }
    
    private func presentSafariViewController(from uiViewController: UIViewController, in context: Context, using item: Item) {
        let representation = representationBuilder(item)
        let safariViewController = SFSafariViewController(url: representation.url, configuration: representation.configuration)
        safariViewController.delegate = context.coordinator.safariViewControllerFinishDelegate
        applyRepresentation(representation, to: safariViewController)
        uiViewController.present(safariViewController, animated: true)
    }
    
    private func updateSafariViewController(presentedBy uiViewController: UIViewController, using item: Item) {
        guard let safariViewController = uiViewController.presentedViewController as? SFSafariViewController else {
            return
        }
        let representation = representationBuilder(item)
        applyRepresentation(representation, to: safariViewController)
    }
    
    private func dismissSafariViewController(from uiViewController: UIViewController) {
        guard uiViewController.presentedViewController is SFSafariViewController else {
            return
        }
        uiViewController.dismiss(animated: true)
    }
    
    private func applyRepresentation(_ representation: SafariView, to safariViewController: SFSafariViewController) {
        safariViewController.preferredBarTintColor = representation.preferredBarTintColor
        safariViewController.preferredControlTintColor = representation.preferredControlTintColor
        safariViewController.dismissButtonStyle = representation.dismissButtonStyle
    }
    
    private func resetItemBindingAndExecuteDismissalHandler() {
        self.item = nil
        self.onDismiss?()
    }
    
    class Coordinator {
        
        var itemStorage: ItemStorage
        let safariViewControllerFinishDelegate: SafariViewControllerFinishDelegate
        
        init(onFinished: @escaping () -> Void) {
            self.itemStorage = ItemStorage()
            self.safariViewControllerFinishDelegate = SafariViewControllerFinishDelegate(onFinished: onFinished)
        }
        
        struct ItemStorage {
            
            private var item: Item?
            
            mutating func updateItem(_ newItem: Item?) -> (oldItem: Item?, newItem: Item?) {
                let oldItem = self.item
                self.item = newItem
                return (oldItem: oldItem, newItem: newItem)
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
    
    // FIXME: Dismiss and replace the view if the identity changes
    
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
