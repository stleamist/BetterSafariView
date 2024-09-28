//
import AuthenticationServices
import BetterSafariView
import SwiftUI

struct ContentView: View {
  @State private var webAuthenticationSessionOptions = WebAuthenticationSessionOptions()
  @State private var showingWebAuthenticationSession = false
  @State private var webAuthenticationSessionCallbackURL: URL? = nil

  private var urlIsInvalid: Bool {
    (webAuthenticationSessionOptions.url == nil) || !["http", "https"].contains(webAuthenticationSessionOptions.url?.scheme)
  }

  var body: some View {
    VStack(alignment: .trailing) {
      GroupBox(label: Text("WebAuthenticationSession")) {
        VStack {
          HStack {
            Text("URL:")
            TextField(gitHubAuthorizationURLString, text: $webAuthenticationSessionOptions.urlString)
          }
          HStack {
            Text("Callback URL Scheme:")
            TextField(gitHubAuthorizationURLString, text: $webAuthenticationSessionOptions.callbackURLScheme)
          }
          HStack {
            Text("Modifiers:")
            Toggle("Ephemeral Session", isOn: $webAuthenticationSessionOptions.prefersEphemeralWebBrowserSession)
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
    .padding(40)
    .toolbar {
      ToolbarItem(placement: .automatic) {
        Spacer()
      }
    }
  }
}
