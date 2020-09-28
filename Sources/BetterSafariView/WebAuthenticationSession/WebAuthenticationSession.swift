import SwiftUI
import AuthenticationServices

// Used for getting a public completion handler to inject an assignment that sets `item` to `nil`.
// INFO: It's not possible to access a completion handler from an `ASWebAuthenticationSession` instance
// because it has no public getter and setter for that.
//
/// A session that an app uses to authenticate a user through a web service.
///
/// Use a `WebAuthenticationSession` instance to authenticate a user through a web service, including one run by a third party. Initialize the session with a URL that points to the authentication webpage. A browser loads and displays the page, from which the user can authenticate. In iOS, the browser is a secure, embedded web view. In macOS, the system opens the user’s default browser if it supports web authentication sessions, or Safari otherwise.
///
/// On completion, the service sends a callback URL to the session with an authentication token, and the session passes this URL back to the app through a completion handler.
///
/// For more details, see [Authenticating a User Through a Web Service](https://developer.apple.com/documentation/authenticationservices/authenticating_a_user_through_a_web_service).
///
public struct WebAuthenticationSession {
    
    /// A completion handler for the web authentication session.
    public typealias CompletionHandler = ASWebAuthenticationSession.CompletionHandler
    
    /// A completion handler for the web authentication session.
    public typealias OnCompletion = (_ result: Result<URL, Error>) -> Void
    
    // MARK: Representation Properties
    
    let url: URL
    let callbackURLScheme: String?
    let completionHandler: CompletionHandler
    
    /// Creates a web authentication session instance.
    ///
    /// - Parameters:
    ///   - url: A URL with the `http` or `https` scheme pointing to the authentication webpage.
    ///   - callbackURLScheme: The custom URL scheme that the app expects in the callback URL.
    ///   - completionHandler: A completion handler the session calls when it completes successfully, or when the user cancels the session.
    ///   - callbackURL: A URL using the scheme indicated by the `callbackURLScheme` parameter that indicates the outcome of the authentication attempt.
    ///   - error: An error that indicates the reason for the cancelation.
    ///
    public init(
        url: URL,
        callbackURLScheme: String?,
        completionHandler: @escaping (_ callbackURL: URL?, _ error: Error?) -> Void // Replaced from WebAuthenticationSession.CompletionHandler for the completion suggestion.
    ) {
        self.url = url
        self.callbackURLScheme = callbackURLScheme
        self.completionHandler = completionHandler
    }
    
    /// Creates a web authentication session instance.
    ///
    /// - Parameters:
    ///   - url: A URL with the `http` or `https` scheme pointing to the authentication webpage.
    ///   - callbackURLScheme: The custom URL scheme that the app expects in the callback URL.
    ///   - onCompletion: A completion handler the session calls when it completes successfully, or when the user cancels the session.
    ///   - result: A `Result` indicating whether the operation succeeded or failed.
    ///
    public init(
        url: URL,
        callbackURLScheme: String?,
        onCompletion: @escaping (_ result: Result<URL, Error>) -> Void // Replaced from WebAuthenticationSession.OnCompletion for the completion suggestion.
    ) {
        self.url = url
        self.callbackURLScheme = callbackURLScheme
        self.completionHandler = { callbackURL, error in
            if let callbackURL = callbackURL {
                onCompletion(.success(callbackURL))
            } else if let error = error {
                onCompletion(.failure(error))
            } else {
                assertionFailure("Both callbackURL and error are nil.")
            }
        }
    }
    
    // MARK: Modifiers
    
    var prefersEphemeralWebBrowserSession: Bool = false
    
    /// Configures whether the session should ask the browser for a private authentication session.
    ///
    /// Use `prefersEphemeralWebBrowserSession` to request that the browser doesn’t share cookies or other browsing data between the authentication session and the user’s normal browser session. Whether the request is honored depends on the user’s default web browser. Safari always honors the request.
    ///
    /// - Parameters:
    ///     - prefersEphemeralWebBrowserSession: A Boolean value that indicates whether the session should ask the browser for a private authentication session.
    ///
    public func prefersEphemeralWebBrowserSession(_ prefersEphemeralWebBrowserSession: Bool) -> Self {
        var modified = self
        modified.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
        return modified
    }
    
    // MARK: Modification Applier
    
    func applyModification(to webAuthenticationSession: ASWebAuthenticationSession) {
        webAuthenticationSession.prefersEphemeralWebBrowserSession = self.prefersEphemeralWebBrowserSession
    }
}

public typealias WebAuthenticationSessionError = ASWebAuthenticationSessionError
public let WebAuthenticationSessionErrorDomain = ASWebAuthenticationSessionErrorDomain
