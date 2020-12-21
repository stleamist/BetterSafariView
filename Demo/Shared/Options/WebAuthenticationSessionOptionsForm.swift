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
                        .modify {
                            #if os(iOS)
                            $0
                                .textContentType(.URL)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                            #endif
                        }
                        .modify {
                            #if os(watchOS)
                            $0
                                .textContentType(.URL)
                            #endif
                        }
                }
                
                Section(header: Text("Callback URL Scheme")) {
                    TextField(gitHubCallbackURLScheme, text: $temporaryOptions.callbackURLScheme)
                        .modify {
                            #if os(iOS)
                            $0
                                .textContentType(.URL)
                                .keyboardType(.asciiCapable)
                                .autocapitalization(.none)
                            #endif
                        }
                        .modify {
                            #if os(watchOS)
                            $0
                                .textContentType(.URL)
                            #endif
                        }
                }
                
                Section(header: Text("Modifiers")) {
                    Toggle("Ephemeral Session", isOn: $temporaryOptions.prefersEphemeralWebBrowserSession)
                }
            }
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
                    .disabled(urlIsInvalid)
                }
            }
            .modify {
                #if os(iOS)
                $0
                    .navigationTitle(Text("Session Options"))
                    .navigationBarTitleDisplayMode(.inline)
                #endif
            }
        }
    }
}

struct WebAuthenticationSessionOptionsForm_Previews: PreviewProvider {
    static var previews: some View {
        WebAuthenticationSessionOptionsForm(options: .constant(.init()))
    }
}
