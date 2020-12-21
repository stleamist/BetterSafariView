import SwiftUI
import BetterSafariView

struct RootView: View {
    
    @State private var webAuthenticationSessionOptions = WebAuthenticationSessionOptions()
    @State private var showingWebAuthenticationSession = false
    @State private var webAuthenticationSessionCallbackURL: URL? = nil
    
    private var urlIsInvalid: Bool {
        (webAuthenticationSessionOptions.url == nil) || !["http", "https"].contains(webAuthenticationSessionOptions.url?.scheme)
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            GroupBox(label: Text("WebAuthenticationSession")) {
                VStack(alignment: .preferenceLabel) {
                    HStack {
                        Text("URL:")
                        TextField(gitHubAuthorizationURLString, text: $webAuthenticationSessionOptions.urlString)
                            .frame(maxWidth: 240)
                            .alignmentGuide(.preferenceLabel, computeValue: { $0[.leading] })
                    }
                    HStack {
                        Text("Callback URL Scheme:")
                        TextField(gitHubAuthorizationURLString, text: $webAuthenticationSessionOptions.callbackURLScheme)
                            .frame(maxWidth: 240)
                            .alignmentGuide(.preferenceLabel, computeValue: { $0[.leading] })
                    }
                    HStack {
                        Text("Modifiers:")
                        Toggle("Ephemeral Session", isOn: $webAuthenticationSessionOptions.prefersEphemeralWebBrowserSession)
                            .alignmentGuide(.preferenceLabel, computeValue: { $0[.leading] })
                    }
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            Button(action: { showingWebAuthenticationSession = true }) {
                Text("Start Session")
            }
            .keyboardShortcut(.defaultAction)
            .disabled(urlIsInvalid)
            // Capture `webAuthenticationSessionOptions` to fix an issue
            // where SwiftUI doesn't pass the latest value to the modifier.
            // https://developer.apple.com/documentation/swiftui/view/onchange(of:perform:)
            .webAuthenticationSession(
                isPresented: $showingWebAuthenticationSession
            ) { [webAuthenticationSessionOptions] in
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
        }
        .padding()
        .frame(width: 480, height: 320)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Spacer()
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
