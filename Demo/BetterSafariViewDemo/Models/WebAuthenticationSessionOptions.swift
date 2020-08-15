import Foundation

struct WebAuthenticationSessionOptions {
    
    // MARK: URL
    var urlString: String = gitHubAuthorizationURLString
    var url: URL? { URL(string: urlString) }
    
    // MARK: Callbacks
    var callbackURLScheme: String = gitHubCallbackURLScheme
    
    // MARK: Modifiers
    var prefersEphemeralWebBrowserSession: Bool = true
}
