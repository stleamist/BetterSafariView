import SwiftUI
import SafariServices

struct FullScreenSafariView {}

struct SafariViewHosting<Item: Identifiable>: UIViewControllerRepresentable {
    
    @Binding var item: Item?
    var onDismiss: (() -> Void)? = nil
    var urlBuilder: (Item) -> URL
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
        if let item = self.item {
            /// Fix an issue where a new view controller is instantiated in duplicate
            /// whenever `updateUIViewController(_:context:)` is called.
            ///
            /// Also, fix an issue where a new view controller is presented and dismissed immediately
            /// because `updateUIViewController(_:context:)` is called
            /// before the `item` is changed to `nil` in `safariViewControllerDidFinish(_:)`
            /// when the existing view controller is dismissed using a swipe gesture, not the dismiss button.
            ///
            if uiViewController.presentedViewController is SFSafariViewController {
                return
            }
            
            let url = urlBuilder(item)
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.delegate = context.coordinator
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
    var urlBuilder: () -> URL
    
    private var item: Binding<Bool?> {
        .init(
            get: { isPresented ? true : nil },
            set: { isPresented = ($0 != nil) }
        )
    }
    
    private func itemURLBuilder(bool: Bool) -> URL {
        return urlBuilder()
    }
    
    func body(content: Content) -> some View {
        content.background(
            SafariViewHosting(
                item: item,
                onDismiss: onDismiss,
                urlBuilder: itemURLBuilder
            )
        )
    }
}

struct ItemSafariViewPresentationModifier<Item: Identifiable>: ViewModifier {
    
    @Binding var item: Item?
    var onDismiss: (() -> Void)? = nil
    var urlBuilder: (Item) -> URL
    
    func body(content: Content) -> some View {
        content.background(
            SafariViewHosting(
                item: $item,
                onDismiss: onDismiss,
                urlBuilder: urlBuilder
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
    ///   - content: A closure returning the `URL` to load.
    func safariView(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        urlBuilder: @escaping () -> URL
    ) -> some View {
        self.modifier(
            SafariViewPresentationModifier(
                isPresented: isPresented,
                onDismiss: onDismiss,
                urlBuilder: urlBuilder
            )
        )
    }
    
    // FIXME: Dismiss and replace the view if the identity changes
    
    /// Presents a Safari view using the given item as a data source
    /// for the `URL` to load.
    ///
    /// - Parameters:
    ///   - item: A binding to an optional source of truth for the alert.
    ///     When representing a non-`nil` item, the system uses `urlBuilder` to
    ///     create an `URL` of the item.
    ///     If the identity changes, the system dismisses a
    ///     currently-presented Safari view and replace it by a new Safari view.
    ///   - content: A closure returning the `URL` to load.
    func safariView<Item: Identifiable>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        urlBuilder: @escaping (Item) -> URL
    ) -> some View {
        self.modifier(
            ItemSafariViewPresentationModifier(
                item: item,
                onDismiss: onDismiss,
                urlBuilder: urlBuilder
            )
        )
    }
}
