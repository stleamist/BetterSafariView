<p align="center">
    <img src="/Docs/Images/FullScreenSafariView-Icon.svg">
    <img src="/Docs/Images/FullScreenSafariView-Logotype.svg">
</p>

# FullScreenSafariView
FullScreenSafariView is a clean way to present a full-screen SFSafariViewController with a push transition in SwiftUI.

<img src="/Docs/Images/FullScreenSafariView-Cover.png" width="375">

## Motivation
![](/Docs/Images/FullScreenSafariView-Comparison.svg)
SwiftUI is a strong, intuitive way to build user interfaces, but was released with some part of existing elements missing. One example of those missing elements is the [`SFSafariViewController`](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller).

Fortunately, Apple provides a way to wrap UIKit elements into SwiftUI views. A common approach to place the `SFSafariViewController` inside SwiftUI is to create [a simple view representing an `SFSafariViewController`](/Demo/FullScreenSafariViewDemo/NaiveSafariView.swift), then present it with a [`sheet(isPresented:onDismiss:content:)`](https://developer.apple.com/documentation/swiftui/view/3352791-sheet) modifier or a [`NavigationLink`](https://developer.apple.com/documentation/swiftui/navigationlink) button (See [`ContentView.swift`](/Demo/FullScreenSafariViewDemo/ContentView.swift) in the demo project).

However, there’s a problem in this approach: it can’t present the `SFSafariViewController` with its default presentation style — a push transition covers full screen. A sheet modifier can present the view only in a modal sheet, and a navigation link shows the two navigation bars at the top so we have to deal with them. This comes down to the conclusion that there’s no option to present it the right way except for using [`present(_:animated:completion:)`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621380-present) method of an [`UIViewController`](https://developer.apple.com/documentation/uikit/uiviewcontroller) instance, but it is prohibited and not a good design to access the [`UIHostingController`](https://developer.apple.com/documentation/swiftui/uihostingcontroller) directly from the SwiftUI view.

`FullScreenSafariView` clearly achieves this goal by hosting a simple `UIViewController` to present an `SFSafariViewController` as a view’s background.

## Usage
You can use it easily with a `safariView(isPresented:content:)` modifier in a similar way to presenting a sheet.

##### `isPresented`
A [`Binding`](https://developer.apple.com/documentation/swiftui/binding) to whether the `SFSafariViewController` is presented.

##### `content`
A closure returning the `URL` to load.

```swift
import SwiftUI
import FullScreenSafariView

struct ContentView: View {
    
    @State private var showingSafariView = false
    
    var body: some View {
        Button(action: {
            self.showingSafariView = true
        }) {
            Text("Show SafariView")
        }
        .safariView(isPresented: $showingSafariView) {
            URL(string: "https://example.com/")!
        }
    }
}
```

## Installation
### Swift Package Manager
Add this repository as a dependency in your [`Package.swift`](https://developer.apple.com/documentation/swift_packages/package):

```swift
// swift-tools-version:5.1

import PackageDescription

let package = Package(
    ...,
    dependencies: [
        .package(url: "https://github.com/stleamist/FullScreenSafariView.git", .upToNextMajor(from: "1.0.0"))
    ],
    ...
)
```

### Xcode
Select File \> Swift Packages \> Add Package Dependency, then enter the following URL:

```
https://github.com/stleamist/FullScreenSafariView.git
```

For more details, see [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

## Demo
<img src="/Docs/Images/FullScreenSafariViewDemo-ContentView.png" width="375">

You can compare the behavior of FullScreenSafariView with the other two ways above in the demo project. Check out the demo app by opening FullScreenSafariView.xcworkspace.

## License
FullScreenSafariView is released under the MIT license. See [LICENSE](/LICENSE) for details.
