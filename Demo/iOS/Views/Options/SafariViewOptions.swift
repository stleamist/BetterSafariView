import Foundation
import SwiftUI
import BetterSafariView

struct SafariViewOptions {
    
    // MARK: URL
    var urlString: String = gitHubRepositoryURLString
    var url: URL? { URL(string: urlString) }
    
    // MARK: Configurations
    var entersReaderIfAvailable: Bool = false
    var barCollapsingEnabled: Bool = true
    
    // MARK: Modifiers
    var usePreferredBarTintColor: Bool = false
    var usePreferredControlTintColor: Bool = false
    var preferredBarTintColorInUse: Color = .clear
    var preferredControlTintColorInUse: Color = .accentColor
    var preferredBarTintColor: Color? { usePreferredBarTintColor ? preferredBarTintColorInUse : nil }
    var preferredControlTintColor: Color? { usePreferredControlTintColor ? preferredControlTintColorInUse : nil }
    var dismissButtonStyle: SafariView.DismissButtonStyle = .done
}
