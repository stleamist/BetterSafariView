#if os(iOS)

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
    
    /// A configuration object that defines how a Safari view controller should be initialized.
    public typealias Configuration = SFSafariViewController.Configuration
    public typealias DismissButtonStyle = SFSafariViewController.DismissButtonStyle
    
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
    public init(url: URL, configuration: Configuration = .init()) {
        self.url = url
        self.configuration = configuration
    }
    
    // MARK: Modifiers
    
    var preferredBarTintColor: TintColor?
    var preferredControlTintColor: TintColor?
    var dismissButtonStyle: DismissButtonStyle = .done
    
    #if compiler(>=5.3)
    
    /// Sets the color to tint the background of the navigation bar and the toolbar.
    ///
    /// This color preference is ignored if the view controller is in Private Browsing mode or displaying an antiphishing warning.
    /// After the view controller is presented, changes made are not reflected.
    ///
    /// - Parameters:
    ///     - tint: The color to use as a bar tint color. If `nil`, the tint color continues to be inherited.
    ///
    @available(iOS 15.0, *)
    public func preferredBarTint(_ tint: Color?) -> Self {
        var modified = self
        modified.preferredBarTintColor = tint.flatMap(TintColor.color)
        return modified
    }
    
    /// Sets the color to tint the control buttons on the navigation bar and the toolbar.
    ///
    /// This color preference is ignored if the view controller is in Private Browsing mode or displaying an antiphishing warning.
    /// After the view controller is presented, changes made are not reflected.
    ///
    /// - Parameters:
    ///     - tint: The color to use as a control tint color. If `nil`, the tint color continues to be inherited.
    ///
    @available(iOS 15.0, *)
    public func preferredControlTint(_ tint: Color?) -> Self {
        var modified = self
        modified.preferredControlTintColor = tint.flatMap(TintColor.color)
        return modified
    }
    
    /// Sets the accent color for the background of the navigation bar and the toolbar.
    ///
    /// This color preference is ignored if the view controller is in Private Browsing mode or displaying an antiphishing warning.
    /// After the view controller is presented, changes made are not reflected.
    ///
    /// - Parameters:
    ///     - color: The color to use as a bar accent color. If `nil`, the accent color continues to be inherited.
    ///
    @available(iOS, introduced: 14.0, deprecated: 100000.0, renamed: "preferredBarTint(_:)")
    public func preferredBarAccentColor(_ color: Color?) -> Self {
        var modified = self
        modified.preferredBarTintColor = color.flatMap(TintColor.color)
        return modified
    }
    
    /// Sets the accent color for the control buttons on the navigation bar and the toolbar.
    ///
    /// This color preference is ignored if the view controller is in Private Browsing mode or displaying an antiphishing warning.
    /// After the view controller is presented, changes made are not reflected.
    ///
    /// - Parameters:
    ///     - color: The color to use as a control accent color. If `nil`, the accent color continues to be inherited.
    ///
    @available(iOS, introduced: 14.0, deprecated: 100000.0, renamed: "preferredControlTint(_:)")
    public func preferredControlAccentColor(_ color: Color?) -> Self {
        var modified = self
        modified.preferredControlTintColor = color.flatMap(TintColor.color)
        return modified
    }
    
    #endif
    
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
        modified.preferredBarTintColor = color.flatMap(TintColor.uiColor)
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
        modified.preferredControlTintColor = color.flatMap(TintColor.uiColor)
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
    public func dismissButtonStyle(_ style: DismissButtonStyle) -> Self {
        var modified = self
        modified.dismissButtonStyle = style
        return modified
    }
}

extension SafariView {
    
    struct TintColor {
        
        private enum AnyColor {
            case uiColor(UIColor)
            case color(Color)
        }
        
        static func uiColor(_ uiColor: UIColor) -> Self {
            return .init(anyColor: .uiColor(uiColor))
        }
        
        #if compiler(>=5.3)
        
        @available(iOS 14.0, *)
        static func color(_ color: Color) -> Self {
            return .init(anyColor: .color(color))
        }
        
        #endif
        
        private var anyColor: AnyColor
        
        func resolvedUIColor(withInheritedTintColor inheritedTintColor: UIColor?) -> UIColor? {
            switch self.anyColor {
            case .uiColor(let uiColor): return uiColor
            case .color(.accentColor): return inheritedTintColor
            case .color(let color):
                #if compiler(>=5.3)
                if #available(iOS 14.0, *) {
                    return UIColor(color)
                } else {
                    assertionFailure()
                    return nil
                }
                #else
                return nil
                #endif
            }
        }
    }
}

public extension SafariView.Configuration {
    convenience init(entersReaderIfAvailable: Bool = false, barCollapsingEnabled: Bool = true) {
        self.init()
        self.entersReaderIfAvailable = entersReaderIfAvailable
        self.barCollapsingEnabled = barCollapsingEnabled
    }
}

#endif
