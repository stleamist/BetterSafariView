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
        
        if let item = self.item {
            let representation = representationBuilder(item)
            
            /// Fix an issue where a new view controller is instantiated in duplicate
            /// whenever `updateUIViewController(_:context:)` is called.
            ///
            /// Also, fix an issue where a new view controller is presented and dismissed immediately
            /// because `updateUIViewController(_:context:)` is called
            /// before the `item` is changed to `nil` in `safariViewControllerDidFinish(_:)`
            /// when the existing view controller is dismissed using a swipe gesture, not the dismiss button.
            ///
            if let safariViewController = uiViewController.presentedViewController as? SFSafariViewController {
                updateSafariViewController(safariViewController, for: representation)
                return
            }
            
            let safariViewController = SFSafariViewController(url: representation.url, configuration: representation.configuration)
            safariViewController.delegate = context.coordinator
            updateSafariViewController(safariViewController, for: representation)
            uiViewController.present(safariViewController, animated: true)
        } else {
            /// Check if the `uiViewController` is a instance of the `SFSafariViewController`
            /// to prevent other controllers presented by the container view from being dismissed unintentionally.
            if uiViewController.presentedViewController is SFSafariViewController {
                uiViewController.dismiss(animated: true)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func updateSafariViewController(_ safariViewController: SFSafariViewController, for representation: SafariView) {
        safariViewController.preferredBarTintColor = representation.preferredBarTintColor
        safariViewController.preferredControlTintColor = representation.preferredControlTintColor
        safariViewController.dismissButtonStyle = representation.dismissButtonStyle
    }
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let parent: SafariViewHosting

        init(_ parent: SafariViewHosting) {
            self.parent = parent
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            parent.item = nil
            parent.onDismiss?()
        }
    }
}

struct SafariViewPresentationModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    var onDismiss: (() -> Void)? = nil
    var representationBuilder: () -> SafariView
    
    private var item: Binding<Bool?> {
        .init(
            get: { isPresented ? true : nil },
            set: { isPresented = ($0 != nil) }
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
    ///   - item: A binding to an optional source of truth for the alert.
    ///     When representing a non-`nil` item, the system uses `content` to
    ///     create an `SafariView` of the item.
    ///     If the identity changes, the system dismisses a
    ///     currently-presented Safari view and replace it by a new Safari view.
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
