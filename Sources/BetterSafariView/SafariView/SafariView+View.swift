import SwiftUI
import SafariServices

// A `View` conformance for the advanced usage.
extension SafariView: View {
    
    // To apply `ignoresSafeArea(_:edges:)` modifier to the `UIViewRepresentable`,
    // define nested `Representable` struct and wrap it with `View`.
    public var body: some View {
        if #available(iOS 14.0, *) {
            Representable(parent: self)
                .ignoresSafeArea(.container, edges: .all)
        } else {
            Representable(parent: self)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

extension SafariView {
    
    struct Representable: UIViewControllerRepresentable {
        
        // MARK: Parent Copying
        
        private var parent: SafariView
        
        init(parent: SafariView) {
            self.parent = parent
        }
        
        // MARK: UIViewControllerRepresentable
        
        func makeUIViewController(context: Context) -> SFSafariViewController {
            let safariViewController = SFSafariViewController(
                url: parent.url,
                configuration: parent.configuration
            )
            // Disable interactive pop gesture recognizer
            safariViewController.modalPresentationStyle = .none
            parent.applyModification(to: safariViewController)
            return safariViewController
        }
        
        func updateUIViewController(_ safariViewController: SFSafariViewController, context: Context) {
            parent.applyModification(to: safariViewController)
        }
    }
}
