import SwiftUI
import BetterSafariView

struct RootView: View {
    
    @State private var safariViewOptions = SafariViewOptions()
    @State private var webAuthenticationSessionOptions = WebAuthenticationSessionOptions()
    
    @State private var showingSafariView = false
    @State private var showingWebAuthenticationSession = false
    
    @State private var showingNaiveSafariViewSheet = false
    @State private var showingNaiveSafariViewFullScreenCover = false
    
    @State private var showingSafariViewOptionsForm = false
    @State private var showingWebAuthenticationSessionOptionsForm = false
    
    @State private var webAuthenticationSessionCallbackURL: URL? = nil
    
    @State private var showAnotherSheet = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("BetterSafariView").textCase(nil)) {
                    Button(action: { showingSafariView = true }) {
                        HStack {
                            TitleLabel("SafariView", subtitle: ".safariView()")
                            Spacer()
                            DetailButton(action: { showingSafariViewOptionsForm = true })
                            DisclosureIndicator()
                        }
                    }
                    .safariView(isPresented: $showingSafariView) {
                        SafariView(
                            url: safariViewOptions.url!,
                            configuration: SafariView.Configuration(
                                entersReaderIfAvailable: safariViewOptions.entersReaderIfAvailable,
                                barCollapsingEnabled: safariViewOptions.barCollapsingEnabled
                            )
                        )
                        .preferredBarAccentColor(safariViewOptions.preferredBarAccentColor)
                        .preferredControlAccentColor(safariViewOptions.preferredControlAccentColor)
                        .dismissButtonStyle(safariViewOptions.dismissButtonStyle)
                    }
                    .sheet(isPresented: $showingSafariViewOptionsForm) {
                        SafariViewOptionsForm(options: $safariViewOptions)
                    }
                    
                    Button(action: { showingWebAuthenticationSession = true }) {
                        HStack {
                            TitleLabel("WebAuthenticationSession", subtitle: ".webAuthenticationSession()")
                            Spacer()
                            DetailButton(action: { showingWebAuthenticationSessionOptionsForm = true })
                            DisclosureIndicator()
                        }
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
                    .sheet(isPresented: $showingWebAuthenticationSessionOptionsForm) {
                        WebAuthenticationSessionOptionsForm(options: $webAuthenticationSessionOptions)
                    }
                }
                
                Section(header: Text("NaiveSafariView" + "\n" + "(Just for comparison. Do not use in practice.)").textCase(nil)) {
                    Button(action: { showingNaiveSafariViewSheet = true }) {
                        HStack {
                            TitleLabel("NaiveSafariView", subtitle: ".sheet()")
                            Spacer()
                            DisclosureIndicator()
                        }
                    }
                    .sheet(isPresented: $showingNaiveSafariViewSheet) {
                        NaiveSafariView(url: swiftUIViewPresentationDocumentationURL)
                    }
                    
                    Button(action: { showingNaiveSafariViewFullScreenCover = true }) {
                        HStack {
                            TitleLabel("NaiveSafariView", subtitle: ".fullScreenCover()")
                            Spacer()
                            DisclosureIndicator()
                        }
                    }
                    .fullScreenCover(isPresented: $showingNaiveSafariViewFullScreenCover) {
                        NaiveSafariView(url: swiftUIViewPresentationDocumentationURL)
                    }
                    
                    NavigationLink(destination: NaiveSafariView(url: swiftUIViewPresentationDocumentationURL)) {
                        TitleLabel("NaiveSafariView", subtitle: "NavigationLink")
                    }
                }
                
                Button("Show this view in another sheet", action: {
                    self.showAnotherSheet.toggle()
                }).sheet(isPresented: $showAnotherSheet, content: {
                    RootView()
                })
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("BetterSafariViewDemo")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
