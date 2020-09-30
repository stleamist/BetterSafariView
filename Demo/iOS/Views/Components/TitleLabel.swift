import SwiftUI

struct TitleLabel: View {
    
    var title: String
    var subtitle: String
    
    @ScaledMetric private var verticalPaddingLength: CGFloat = 3
    
    init(_ title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, verticalPaddingLength)
    }
}

struct TitleLabel_Previews: PreviewProvider {
    static var previews: some View {
        TitleLabel("Title", subtitle: "Subtitle")
    }
}
