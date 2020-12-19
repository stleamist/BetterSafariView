import SwiftUI

extension HorizontalAlignment {
    private enum PreferenceLabelAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[HorizontalAlignment.center]
        }
    }

    static let preferenceLabel = HorizontalAlignment(PreferenceLabelAlignment.self)
}
