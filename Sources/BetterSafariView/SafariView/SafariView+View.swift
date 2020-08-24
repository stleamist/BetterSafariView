import SwiftUI
import SafariServices

extension SafariView: View {
    
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
            safariViewController.modalPresentationStyle = .none
            parent.applyModification(to: safariViewController)
            return safariViewController
        }
        
        func updateUIViewController(_ safariViewController: SFSafariViewController, context: Context) {
            parent.applyModification(to: safariViewController)
        }
    }
}
