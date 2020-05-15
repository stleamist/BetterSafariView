import SwiftUI
import SafariServices

struct FullScreenSafariView {}

struct SafariViewHosting: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    var url: URL
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
        if isPresented {
            /// Fix an issue where a new view controller is instantiated in duplicate
            /// whenever `updateUIViewController(_:context:)` is called.
            ///
            /// Also, fix an issue where a new view controller is presented and dismissed immediately
            /// because `updateUIViewController(_:context:)` is called
            /// before the `isPresented` is changed to `false` in `safariViewControllerDidFinish(_:)`
            /// when the existing view controller is dismissed using a swipe gesture, not the dismiss button.
            ///
            if uiViewController.presentedViewController is SFSafariViewController {
                return
            }
            
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.delegate = context.coordinator
            uiViewController.present(safariViewController, animated: true)
        } else {
            uiViewController.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let parent: SafariViewHosting

        init(_ parent: SafariViewHosting) {
            self.parent = parent
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            parent.isPresented = false
        }
    }
}

struct SafariViewModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    var url: URL
    
    func body(content: Content) -> some View {
        content
            .background(SafariViewHosting(isPresented: $isPresented, url: url))
    }
}

extension View {
    
    func safariView(isPresented: Binding<Bool>, content: () -> URL) -> some View {
        let url = content()
        return self.modifier(SafariViewModifier(isPresented: isPresented, url: url))
    }
}
