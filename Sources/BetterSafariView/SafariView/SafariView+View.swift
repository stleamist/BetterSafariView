import SwiftUI
import SafariServices

// A `View` conformance for the advanced usage.
extension SafariView: View {
    
    #if compiler(>=5.3)
    
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
    
    /// Sets the accent color for the control buttons on the navigation bar and the toolbar.
    ///
    /// This color preference is ignored if the view controller is in Private Browsing mode or displaying an antiphishing warning.
    /// After the view controller is presented, changes made are not reflected.
    ///
    /// - Note:
    ///     This modifier is a convenience method of `preferredControlAccentColor(_:)`.
    ///
    /// - Parameters:
    ///     - accentColor: The color to use as a control accent color. If `nil`, the accent color continues to be inherited.
    ///
    @available(iOS 14.0, *)
    public func accentColor(_ accentColor: Color?) -> Self {
        return self.preferredControlAccentColor(accentColor)
    }
    
    #else
    
    // To apply `ignoresSafeArea(_:edges:)` modifier to the `UIViewRepresentable`,
    // define nested `Representable` struct and wrap it with `View`.
    public var body: some View {
        Representable(parent: self)
            .edgesIgnoringSafeArea(.all)
    }
    
    #endif
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
