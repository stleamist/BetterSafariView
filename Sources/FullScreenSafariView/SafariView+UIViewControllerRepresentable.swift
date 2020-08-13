import SwiftUI
import SafariServices

// TODO: Decide whether to add a `UIViewControllerRepresentable` conformance or not

// NOTE:
// A `UIViewControllerRepresentable` conformance for an advanced usage.
// However, using this directly as a View is NOT RECOMMENDED; sometimes its interface and interactions can look broken.
// Please use this just for a representation to present with `.safariView(isPresented:onDismiss:content:)` modifier.

extension SafariView: UIViewControllerRepresentable {
    
    public func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url, configuration: configuration)
    }
    
    public func updateUIViewController(_ safariViewController: SFSafariViewController, context: Context) {
        self.applyModification(to: safariViewController)
    }
}
