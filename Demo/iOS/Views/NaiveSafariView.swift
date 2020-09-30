import SwiftUI
import SafariServices

struct NaiveSafariView: UIViewControllerRepresentable {
    
    var url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
}

struct NaiveSafariView_Previews: PreviewProvider {
    static var previews: some View {
        NaiveSafariView(url: URL(string: "https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller")!)
    }
}
