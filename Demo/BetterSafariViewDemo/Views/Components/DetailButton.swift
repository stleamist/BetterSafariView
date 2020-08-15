import SwiftUI

struct DetailButton: View {
    
    var action: () -> Void
    
    @ScaledMetric private var frameLength: CGFloat = 44
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "info.circle")
                .imageScale(.large)
                .frame(width: frameLength, height: frameLength)
        }
        
    }
}

struct DetailButton_Previews: PreviewProvider {
    static var previews: some View {
        DetailButton(action: {})
    }
}
