import SwiftUI
import BetterSafariView

struct RootView: View {
    
    @State private var webAuthenticationSessionOptions = WebAuthenticationSessionOptions()
    @State private var showingWebAuthenticationSession = false
    @State private var showingWebAuthenticationSessionOptionsForm = false
    @State private var webAuthenticationSessionCallbackURL: URL? = nil
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("WebAuthenticationSession").textCase(nil)) {
                    Button(action: { showingWebAuthenticationSession = true }) {
                        Text("Start Session")
                    }
                    .webAuthenticationSession(isPresented: $showingWebAuthenticationSession) {
                        WebAuthenticationSession(
                            url: webAuthenticationSessionOptions.url!,
                            callbackURLScheme: webAuthenticationSessionOptions.callbackURLScheme
                        ) { callbackURL, error in
                            webAuthenticationSessionCallbackURL = callbackURL
                        }
                        .prefersEphemeralWebBrowserSession(webAuthenticationSessionOptions.prefersEphemeralWebBrowserSession)
                    }
                    .alert(item: $webAuthenticationSessionCallbackURL) { callbackURL in
                        Alert(
                            title: Text("Session Completed with Callback URL"),
                            message: Text(callbackURL.absoluteString),
                            dismissButton: nil
                        )
                    }
                    
                    Button(action: { showingWebAuthenticationSessionOptionsForm = true }) {
                        Text("Options")
                    }
                    .sheet(isPresented: $showingWebAuthenticationSessionOptionsForm) {
                        WebAuthenticationSessionOptionsForm(options: $webAuthenticationSessionOptions)
                    }
                }
            }
            .navigationTitle(Text("BetterSafari"))
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
