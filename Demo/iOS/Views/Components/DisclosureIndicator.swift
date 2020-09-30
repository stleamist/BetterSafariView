import SwiftUI

struct DisclosureIndicator: View {
    
    @ScaledMetric private var size: CGFloat = 13.5
    
    var body: some View {
        Image(systemName: "chevron.right")
            .foregroundColor(Color(.tertiaryLabel))
            .font(.system(size: size, weight: .semibold))
    }
}

struct DisclosureIndicator_Previews: PreviewProvider {
    static var previews: some View {
        DisclosureIndicator()
    }
}
