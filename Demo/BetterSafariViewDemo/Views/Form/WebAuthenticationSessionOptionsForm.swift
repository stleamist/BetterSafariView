import SwiftUI
import BetterSafariView

struct WebAuthenticationSessionOptionsForm: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var options: WebAuthenticationSessionOptions
    @State private var temporaryOptions: WebAuthenticationSessionOptions
    
    private var urlIsInvalid: Bool {
        (temporaryOptions.url == nil) || !["http", "https"].contains(temporaryOptions.url?.scheme)
    }
    
    init(options: Binding<WebAuthenticationSessionOptions>) {
        self._options = options
        self._temporaryOptions = State(wrappedValue: options.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("URL")) {
                    TextField(gitHubAuthorizationURLString, text: $temporaryOptions.urlString)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Callback URL Scheme")) {
                    TextField(gitHubCallbackURLScheme, text: $temporaryOptions.callbackURLScheme)
                        .textContentType(.URL)
                        .keyboardType(.asciiCapable)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Modifiers")) {
                    Toggle("Ephemeral Session", isOn: $temporaryOptions.prefersEphemeralWebBrowserSession)
                }
            }
            .navigationTitle(Text("Session Options"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        options = temporaryOptions
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct WebAuthenticationSessionOptionsForm_Previews: PreviewProvider {
    static var previews: some View {
        WebAuthenticationSessionOptionsForm(options: .constant(.init()))
    }
}
