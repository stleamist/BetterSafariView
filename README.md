<p align="center">
    <img src="/Docs/Images/BetterSafariView-Icon.svg">
    <img src="/Docs/Images/BetterSafariView-Logotype.svg">
</p>

<p align="center">
    <a href="https://github.com/stleamist/BetterSafariView/releases/latest">
        <img src="https://img.shields.io/github/v/release/stleamist/BetterSafariView?label=version&labelColor=303840" alt="version">
    </a>
    <a href="https://swift.org/">
        <img src="https://img.shields.io/badge/Swift-5.1+-F05138?labelColor=303840" alt="Swift: 5.1+">
    </a>
    <a href="https://www.apple.com/ios/">
        <img src="https://img.shields.io/badge/iOS-13.0+-007AFF?labelColor=303840" alt="iOS: 13.0+">
    </a>
    <a href="https://www.apple.com/macos/">
        <img src="https://img.shields.io/badge/macOS-10.15+-007AFF?labelColor=303840" alt="macOS: 10.15+">
    </a>
    <a href="https://www.apple.com/watchos/">
        <img src="https://img.shields.io/badge/watchOS-6.2+-007AFF?labelColor=303840" alt="watchOS: 6.2+">
    </a>
    <br>
    <a href="https://swift.org/package-manager/">
        <img src="https://img.shields.io/badge/SwiftPM-compatible-29CC52?labelColor=303840" alt="SwiftPM: compatible">
    </a>
    <a href="/LICENSE">
        <img src="https://img.shields.io/github/license/stleamist/BetterSafariView?color=blue&labelColor=303840" alt="license">
    </a>
    <a href="https://twitter.com/stleamist">
        <img src="https://img.shields.io/badge/contact-@stleamist-1DA1F2?labelColor=303840" alt="contact: @stleamist">
    </a>
</p>

# BetterSafariView
A better way to present a SFSafariViewController or start a ASWebAuthenticationSession in SwiftUI.

<img src="/Docs/Images/BetterSafariView-Cover.png" width="375">

## Contents
- [Motivation](#motivation)
- [Requirements](#requirements)
- [Usage](#usage)
    - [SafariView](#safariview)
    - [WebAuthenticationSession](#webauthenticationsession)
- [Known Issues](#known-issues)
- [Installation](#installation)
    - [Swift Package Manager](#swift-package-manager)
    - [Xcode](#xcode)
- [Demo](#demo)
- [License](#license)

## Motivation
<img src="/Docs/Images/BetterSafariView-Comparison.svg">

SwiftUI is a strong, intuitive way to build user interfaces, but was released with some part of existing elements missing. One example of those missing elements is the [`SFSafariViewController`](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller).

Fortunately, Apple provides a way to wrap UIKit elements into SwiftUI views. A common approach to place the `SFSafariViewController` inside SwiftUI is to create [a simple view representing a `SFSafariViewController`](/Demo/BetterSafariViewDemo/NaiveSafariView.swift), then present it with a [`sheet(isPresented:onDismiss:content:)`](https://developer.apple.com/documentation/swiftui/view/3352791-sheet) modifier or a [`NavigationLink`](https://developer.apple.com/documentation/swiftui/navigationlink) button (See [`RootView.swift`](/Demo/BetterSafariViewDemo/Views/RootView.swift) in the demo project).

However, there’s a problem in this approach: it can’t present the `SFSafariViewController` with its default presentation style — a push transition covers full screen. A sheet modifier can present the view only in a modal sheet, and a navigation link shows the two navigation bars at the top so we have to deal with them. This comes down to the conclusion that there’s no option to present it the right way except for using [`present(_:animated:completion:)`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621380-present) method of a [`UIViewController`](https://developer.apple.com/documentation/uikit/uiviewcontroller) instance, but it is prohibited and not a good design to access the [`UIHostingController`](https://developer.apple.com/documentation/swiftui/uihostingcontroller) directly from the SwiftUI view.

`BetterSafariView` clearly achieves this goal by hosting a simple `UIViewController` to present a `SFSafariViewController` as a view’s background. In this way, a [`ASWebAuthenticationSession`](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession) is also able to be started without any issue in SwiftUI.

## Requirements
- Xcode 11.0+
- Swift 5.1+

#### SafariView
- iOS 13.0+
- Mac Catalyst 13.0+

#### WebAuthenticationSession
- iOS 13.0+
- Mac Catalyst 13.0+
- macOS 10.15+
- watchOS 6.2+

## Usage
With the following modifiers, you can use it in a similar way to present a sheet.

### SafariView
#### Example
```swift
import SwiftUI
import BetterSafariView

struct ContentView: View {
    
    @State private var presentingSafariView = false
    
    var body: some View {
        Button(action: {
            self.presentingSafariView = true
        }) {
            Text("Present SafariView")
        }
        .safariView(isPresented: $presentingSafariView) {
            SafariView(
                url: URL(string: "https://github.com/")!,
                configuration: SafariView.Configuration(
                    entersReaderIfAvailable: false,
                    barCollapsingEnabled: true
                )
            )
            .preferredBarAccentColor(.clear)
            .preferredControlAccentColor(.accentColor)
            .dismissButtonStyle(.done)
        }
    }
}
```

#### `View` Modifiers
<details>
<summary><code>safariView(isPresented:onDismiss:content:)</code></summary>

```swift
/// Presents a Safari view when a given condition is true.
func safariView(
    isPresented: Binding<Bool>,
    onDismiss: (() -> Void)? = nil,
    content: @escaping () -> SafariView
) -> some View
```
</details>

<details>
<summary><code>safariView(item:onDismiss:content:)</code></summary>

```swift
/// Presents a Safari view using the given item as a data source for the `SafariView` to present.
func safariView<Item: Identifiable>(
    item: Binding<Item?>,
    onDismiss: (() -> Void)? = nil,
    content: @escaping (Item) -> SafariView
) -> some View
```
</details>

#### `SafariView` Initializers
<details>
<summary><code>init(url:)</code></summary>

```swift
/// Creates a Safari view that loads the specified URL.
init(url: URL)
```
</details>

<details>
<summary><code>init(url:configuration:)</code></summary>
    
```swift
/// Creates and configures a Safari view that loads the specified URL.
init(url: URL, configuration: SafariView.Configuration)
```
</details>

#### `SafariView` Modifiers
<details>
<summary><code>preferredBarAccentColor(_:)</code></summary>

```swift
/// Sets the accent color for the background of the navigation bar and the toolbar.
func preferredBarAccentColor(_ color: Color?) -> SafariView
```
</details>

<details>
<summary><code>preferredControlAccentColor(_:)</code></summary>

```swift
/// Sets the accent color for the control buttons on the navigation bar and the toolbar.
func preferredControlAccentColor(_ color: Color?) -> SafariView
```
</details>

<details>
<summary><code>dismissButtonStyle(_:)</code></summary>

```swift
/// Sets the style of dismiss button to use in the navigation bar to close `SafariView`.
func dismissButtonStyle(_ style: SafariView.DismissButtonStyle) -> SafariView
```
</details>

### WebAuthenticationSession
#### Example
```swift
import SwiftUI
import BetterSafariView

struct ContentView: View {
    
    @State private var startingWebAuthenticationSession = false
    
    var body: some View {
        Button(action: {
            self.startingWebAuthenticationSession = true
        }) {
            Text("Start WebAuthenticationSession")
        }
        .webAuthenticationSession(isPresented: $startingWebAuthenticationSession) {
            WebAuthenticationSession(
                url: URL(string: "https://github.com/login/oauth/authorize")!,
                callbackURLScheme: "github"
            ) { callbackURL, error in
                print(callbackURL, error)
            }
            .prefersEphemeralWebBrowserSession(false)
        }
    }
}
```

#### `View` Modifiers
<details>
<summary><code>webAuthenticationSession(isPresented:content:)</code></summary>

```swift
/// Starts a web authentication session when a given condition is true.
func webAuthenticationSession(
    isPresented: Binding<Bool>,
    content: @escaping () -> WebAuthenticationSession
) -> some View
```
</details>

<details>
<summary><code>webAuthenticationSession(item:content:)</code></summary>

```swift
/// Starts a web authentication session using the given item as a data source for the `WebAuthenticationSession` to start.
func webAuthenticationSession<Item: Identifiable>(
    item: Binding<Item?>,
    content: @escaping (Item) -> WebAuthenticationSession
) -> some View
```
</details>

#### `WebAuthenticationSession` Initializers
<details>
<summary><code>init(url:callbackURLScheme:completionHandler:)</code></summary>

```swift
/// Creates a web authentication session instance.
init(
    url: URL,
    callbackURLScheme: String?,
    completionHandler: @escaping (URL?, Error?) -> Void
)
```
</details>

<details>
<summary><code>init(url:callbackURLScheme:onCompletion:)</code></summary>

```swift
/// Creates a web authentication session instance.
init(
    url: URL,
    callbackURLScheme: String?,
    onCompletion: @escaping (Result<URL, Error>) -> Void
)
```
</details>

#### `WebAuthenticationSession` Modifier
<details>
<summary><code>prefersEphemeralWebBrowserSession(_:)</code></summary>

```swift
/// Configures whether the session should ask the browser for a private authentication session.
func prefersEphemeralWebBrowserSession(_ prefersEphemeralWebBrowserSession: Bool) -> WebAuthenticationSession
```
</details>

## Known Issues
- In `.webAuthenticationSession(item:content:)` modifier, the functionality that replaces a session on the `item`'s identity change is not implemented, as there is no non-hacky way to be notified when the session's dismissal animation is completed.

## Installation
### Swift Package Manager
Add the following line to the `dependencies` in your [`Package.swift`](https://developer.apple.com/documentation/swift_packages/package) file:

```swift
.package(url: "https://github.com/stleamist/BetterSafariView.git", .upToNextMajor(from: "2.3.1"))
```

Next, add `BetterSafariView` as a dependency for your targets:

```swift
.target(name: "MyTarget", dependencies: ["BetterSafariView"])
```

Your completed description may look like this:

```swift
// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "MyPackage",
    dependencies: [
        .package(url: "https://github.com/stleamist/BetterSafariView.git", .upToNextMajor(from: "2.3.1"))
    ],
    targets: [
        .target(name: "MyTarget", dependencies: ["BetterSafariView"])
    ]
)

```

### Xcode
Select File \> Swift Packages \> Add Package Dependency, then enter the following URL:

```
https://github.com/stleamist/BetterSafariView.git
```

For more details, see [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

## Demo
<p>
    <img src="/Docs/Images/BetterSafariViewDemo-iOS.png" width="275">
    <img src="/Docs/Images/BetterSafariViewDemo-macOS.png" width="275">
    <img src="/Docs/Images/BetterSafariViewDemo-watchOS.png" width="275">
</p>

You can see how it works on each platform and compare it with the other naive implementations in the demo project. Check out the demo app by opening BetterSafariView.xcworkspace.

**NOTE:** This demo project is available for iOS 14.0+, macOS 11.0+, and watchOS 7.0+, while the package is compatible with iOS 13.0+, macOS 10.15+, and watchOS 6.2+.

## License
BetterSafariView is released under the MIT license. See [LICENSE](/LICENSE) for details.
