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
    var usePreferredBarAccentColor: Bool = false
    var usePreferredControlAccentColor: Bool = false
    var preferredBarAccentColorInUse: Color = .clear
    var preferredControlAccentColorInUse: Color = .accentColor
    var preferredBarAccentColor: Color? { usePreferredBarAccentColor ? preferredBarAccentColorInUse : nil }
    var preferredControlAccentColor: Color? { usePreferredControlAccentColor ? preferredControlAccentColorInUse : nil }
    var dismissButtonStyle: SafariView.DismissButtonStyle = .done
}
