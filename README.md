<p align="center">
    <img src="/Docs/Images/BetterSafariView-Icon.svg">
    <img src="/Docs/Images/BetterSafariView-Logotype.svg">
</p>

<p align="center">
    <a href="https://github.com/stleamist/BetterSafariView/releases/latest">
        <img src="https://img.shields.io/github/v/release/stleamist/BetterSafariView?label=version" alt="version">
    </a>
    <a href="https://swift.org/">
        <img src="https://img.shields.io/badge/Swift-5.1+-f05138" alt="Swift: 5.1+">
    </a>
    <a href="https://www.apple.com/ios/">
        <img src="https://img.shields.io/badge/iOS-13.0+-f05138" alt="iOS: 13.0+">
    </a>
    <a href="https://swift.org/package-manager/">
        <img src="https://img.shields.io/badge/SwiftPM-compatible-brightgreen" alt="SwiftPM: compatible">
    </a>
    <a href="/LICENSE">
        <img src="https://img.shields.io/github/license/stleamist/BetterSafariView" alt="license">
    </a>
    <a href="https://twitter.com/stleamist">
        <img src="https://img.shields.io/badge/contact-@stleamist-1da1f2" alt="contact: @stleamist">
    </a>
</p>

# BetterSafariView
A better way to present a SFSafariViewController or start a ASWebAuthenticationSession in SwiftUI.

<img src="/Docs/Images/BetterSafariView-Cover.png" width="375">

## Navigate
- [Motivation](#motivation)
- [Usage](#usage)
    - [SafariView](#safariview)
    - [WebAuthenticationSession](#webauthenticationsession)
- [Known Issues](#known-issues)
- [Requirements](#requirements)
- [Installation](#installation)
    - [Swift Package Manager](#swift-package-manager)
    - [Xcode](#xcode)
- [Demo](#demo)
- [License](#license)

## Motivation
<img src="/Docs/Images/BetterSafariView-Comparison.svg">

SwiftUI is a strong, intuitive way to build user interfaces, but was released with some part of existing elements missing. One example of those missing elements is the [`SFSafariViewController`](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller).

Fortunately, Apple provides a way to wrap UIKit elements into SwiftUI views. A common approach to place the `SFSafariViewController` inside SwiftUI is to create [a simple view representing a `SFSafariViewController`](/Demo/BetterSafariViewDemo/NaiveSafariView.swift), then present it with a [`sheet(isPresented:onDismiss:content:)`](https://developer.apple.com/documentation/swiftui/view/3352791-sheet) modifier or a [`NavigationLink`](https://developer.apple.com/documentation/swiftui/navigationlink) button (See [`ContentView.swift`](/Demo/BetterSafariViewDemo/ContentView.swift) in the demo project).

However, there’s a problem in this approach: it can’t present the `SFSafariViewController` with its default presentation style — a push transition covers full screen. A sheet modifier can present the view only in a modal sheet, and a navigation link shows the two navigation bars at the top so we have to deal with them. This comes down to the conclusion that there’s no option to present it the right way except for using [`present(_:animated:completion:)`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621380-present) method of a [`UIViewController`](https://developer.apple.com/documentation/uikit/uiviewcontroller) instance, but it is prohibited and not a good design to access the [`UIHostingController`](https://developer.apple.com/documentation/swiftui/uihostingcontroller) directly from the SwiftUI view.

`BetterSafariView` clearly achieves this goal by hosting a simple `UIViewController` to present a `SFSafariViewController` as a view’s background. In this way, a [`ASWebAuthenticationSession`](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession) is also able to be started without any issue in SwiftUI.

## Usage
You can use it easily with the following modifiers in a similar way to presenting a sheet.

### SafariView
#### Modifiers
```swift
.safariView(isPresented:onDismiss:content)
```

```swift
.safariView(item:onDismiss:content)
```

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

### WebAuthenticationSession
#### Modifiers
```swift
.webAuthenticationSession(isPresented:content)
```

```swift
.webAuthenticationSession(item:content)
```

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

## Known Issues
- In `.webAuthenticationSession(item:content:)` modifier, the functionality that replaces a session on the `item`'s identity change is not implemented, as there is no non-hacky way to be notified when the session's dismissal animation is completed.

## Requirements
- Swift 5.1+
- iOS 13.0+

## Installation
### Swift Package Manager
Add the following line to the `dependencies` in your [`Package.swift`](https://developer.apple.com/documentation/swift_packages/package) file:

```swift
.package(url: "https://github.com/stleamist/BetterSafariView.git", .upToNextMajor(from: "2.0.0"))
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
        .package(url: "https://github.com/stleamist/BetterSafariView.git", .upToNextMajor(from: "2.0.0"))
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
<img src="/Docs/Images/BetterSafariViewDemo-RootView.png" width="375">

You can compare the behavior of BetterSafariView with the other ways above in the demo project. Check out the demo app by opening BetterSafariView.xcworkspace.

**NOTE:** This demo project is designed for iOS 14.0+, though the package is compatible with iOS 13.0+.

## License
BetterSafariView is released under the MIT license. See [LICENSE](/LICENSE) for details.
