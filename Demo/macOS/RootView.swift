import SwiftUI

struct RootView: View {
    
    @State private var webAuthenticationSessionOptions = WebAuthenticationSessionOptions()
    @State private var showingWebAuthenticationSession = false
    @State private var webAuthenticationSessionCallbackURL: URL? = nil
    
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
