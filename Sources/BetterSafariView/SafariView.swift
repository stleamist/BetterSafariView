import SwiftUI
import SafariServices

/// A view that displays a visible standard interface for browsing the web.
///
/// The view controller includes Safari features such as Reader, AutoFill, Fraudulent Website Detection, and content blocking.
/// In iOS 9 and 10, it shares cookies and other website data with Safari.
/// The user's activity and interaction with `SafariView` are not visible to your app,
/// which cannot access AutoFill data, browsing history, or website data.
/// You do not need to secure data between your app and Safari.
/// If you would like to share data between your app and Safari in iOS 11 and later,
/// so it is easier for a user to log in only one time, use `WebAuthenticationSession` instead.
///
/// - Important:
///     In accordance with [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/), this view controller must be used to visibly present information to users; the controller may not be hidden or obscured by other views or layers. Additionally, an app may not use `SafariView` to track users without their knowledge and consent.
///
///     UI features include the following:
///     - A read-only address field with a security indicator and a Reader button
///     - An Action button that invokes an activity view controller offering custom services from your app, and activities, such as messaging, from the system and other extensions
///     - A Done button, back and forward navigation buttons, and a button to open the page directly in Safari
///     - On devices that support 3D Touch, automatic Peek and Pop for links and detected data
///
///     To learn about 3D Touch, see [3D Touch](https://developer.apple.com/ios/human-interface-guidelines/interaction/3d-touch/) in [iOS Human Interface Guidelines](https://developer.apple.com/ios/human-interface-guidelines/) and [Adopting 3D Touch on iPhone](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/Adopting3DTouchOniPhone/index.html#//apple_ref/doc/uid/TP40016543).
///
/// - Note:
///     In Mac apps built with Mac Catalyst, `SafariView` launches the default web browser instead of displaying a modal window.
///
public struct SafariView {
    
    public typealias Configuration = SFSafariViewController.Configuration
    
    // MARK: Representation Properties
    
    let url: URL
    let configuration: Configuration
    
    /// Creates and configures a Safari view that loads the specified URL.
    ///
    /// Use `init(url:)` to initialize an instance with the default configuration.
    /// The initializer copies the specified [SFSafariViewController.Configuration](apple-reference-documentation://ls%2Fdocumentation%2Fsafariservices%2Fsfsafariviewcontroller%2Fconfiguration) object,
    /// so mutating the configuration after invoking the initializer has no effect on the view controller.
    ///
    /// - Parameters:
    ///     - url: The URL to navigate to. The URL must use the http or https scheme.
    ///     - configuration: The configuration for the new view controller.
    ///
    public init(url: URL, configuration: SFSafariViewController.Configuration = .init()) {
        self.url = url
        self.configuration = configuration
    }
    
    // MARK: Modifiers
    
    var preferredBarTintColor: UIColor?
    var preferredControlTintColor: UIColor?
    var dismissButtonStyle: SFSafariViewController.DismissButtonStyle = .done
    
    /// Sets the accent color for the background of the navigation bar and the toolbar.
    ///
    /// This color preference is ignored if the view controller is in Private Browsing mode or displaying an antiphishing warning.
    /// After the view controller is presented, changes made are not reflected.
    ///
    /// - Parameters:
    ///     - color: The color to use as a bar accent color. If `nil`, the tint color continues to be inherited.
    ///
    @available(iOS 14.0, *)
    public func preferredBarAccentColor(_ color: Color?) -> Self {
        var modified = self
        if let color = color {
            modified.preferredBarTintColor = UIColor(color)
        } else {
            modified.preferredBarTintColor = nil
        }
        return modified
    }
    
    /// Sets the accent color for the control buttons on the navigation bar and the toolbar.
    ///
    /// This color preference is ignored if the view controller is in Private Browsing mode or displaying an antiphishing warning.
    /// After the view controller is presented, changes made are not reflected.
    /// Use `preferredControlAccentColor(_:)` instead of using the view’s [accentColor(_:)](apple-reference-documentation://ls%2Fdocumentation%2Fswiftui%2Fview%2Faccentcolor(_%3A)) method.
    ///
    /// - Parameters:
    ///     - color: The color to use as a control accent tint color. If `nil`, the tint color continues to be inherited.
    ///
    @available(iOS 14.0, *)
    public func preferredControlAccentColor(_ color: Color?) -> Self {
        var modified = self
        if let color = color {
            modified.preferredControlTintColor = UIColor(color)
        } else {
            modified.preferredControlTintColor = nil
        }
        return modified
    }
    
    /// Sets the color to tint the background of the navigation bar and the toolbar.
    ///
    /// This color preference is ignored if the view controller is in Private Browsing mode or displaying an antiphishing warning.
    /// After the view controller is presented, changes made are not reflected.
    ///
    /// - Parameters:
    ///     - color: The color to use as a bar tint color. If `nil`, the tint color continues to be inherited.
    ///
    @available(iOS, introduced: 13.0, deprecated: 14.0, renamed: "preferredBarAccentColor(_:)")
    public func preferredBarTintColor(_ color: UIColor?) -> Self {
        var modified = self
        modified.preferredBarTintColor = color
        return modified
    }
    
    /// Sets the color to tint the control buttons on the navigation bar and the toolbar.
    ///
    /// This color preference is ignored if the view controller is in Private Browsing mode or displaying an antiphishing warning.
    /// After the view controller is presented, changes made are not reflected.
    /// Use `preferredControlTintColor(_:)` instead of using the view’s [accentColor(_:)](apple-reference-documentation://ls%2Fdocumentation%2Fswiftui%2Fview%2Faccentcolor(_%3A)) method.
    ///
    /// - Parameters:
    ///     - color: The color to use as a control tint color. If `nil`, the tint color continues to be inherited.
    ///
    @available(iOS, introduced: 13.0, deprecated: 14.0, renamed: "preferredControlAccentColor(_:)")
    public func preferredControlTintColor(_ color: UIColor?) -> Self {
        var modified = self
        modified.preferredControlTintColor = color
        return modified
    }
    
    /// Sets the style of dismiss button to use in the navigation bar to close `SafariView`.
    ///
    /// The default value is `.done`, which makes the button title the localized
    /// string "Done". You can use other values such as "Close" to provide consistency with your app. "Cancel" is
    /// ideal when using `SafariView` to log in to an external service. All values will show a string localized
    /// to the user's locale. Changing this property after `SafariView` is presented will animate the change.
    ///
    /// - Parameters:
    ///     - style: The style of dismiss button to use in the navigation bar.
    ///
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
        // Ensure the following statements are executed once only after the `item` is changed
        // by comparing current item to old one during frequent view updates.
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
    ///
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
    ///
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
