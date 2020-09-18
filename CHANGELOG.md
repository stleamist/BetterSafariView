# Changelog

## [v2.2.2](https://github.com/stleamist/BetterSafariView/releases/tag/v2.2.2) (2020-09-19)
### Fixed
- Fixed an issue where the changes of `SafariView` and `WebAuthenticationSession` is not applied after an initialization.

## [v2.2.1](https://github.com/stleamist/BetterSafariView/releases/tag/v2.2.1) (2020-08-26)
### Fixed
- Fixed an issue where the package could not be compiled on Swift 5.2 or earlier.

## [v2.2.0](https://github.com/stleamist/BetterSafariView/releases/tag/v2.2.0) (2020-08-26)
### Added
- `SafariView` now conforms to `View` protocol, so it can be used even in the `.sheet()` or the `.fullScreenCover()` modifiers for the advanced usage.
- Added `accentColor(_:)` modifier to `SafariView` as a convenience method of `preferredControlAccentColor(_:)`.
- Added a new initializer of `WebAuthenticationSession` where the `onCompletion` closure receives a `Result` instance, which contains either a `URL` or an `Error`.

### Fixed
- Fixed typos on the markup.

## [v2.1.0](https://github.com/stleamist/BetterSafariView/releases/tag/v2.1.0) (2020-08-24)
### Changed
- Coordinators are now in charge of view controller presentations, following the structure of [VisualEffects](https://github.com/twostraws/VisualEffects).

## [v2.0.1](https://github.com/stleamist/BetterSafariView/releases/tag/v2.0.1) (2020-08-22)
### Fixed
- Fixed typos on the markup.

## [v2.0.0](https://github.com/stleamist/BetterSafariView/releases/tag/v2.0.0) (2020-08-16)
### Added
- You can now authenticate a user through a web authentication session by using `WebAuthenticationSession`.
- With the new `SafariView` representation and its modifiers, configurations and properties on `SFSafariViewController` also could be used.
- Using `safariView(isPresented:onDismiss:content:)` modifier, actions could be performed when the Safari view dismisses.
- Using `safariView(item:onDismiss:content:)` modifier, the Safari view could be replaced on the `item`'s identity change.

### Changed
- The package has been renamed to BetterSafariView from FullScreenSafariView.
- `safariView(isPresented:content:)` modifier now gets a closure returning a `SafariView` representation instead of a `URL` instance.

### Fixed
- Fixed an issue where the dismissed Safari view is presented and dismissed again on iOS 14.
- Fixed an issue where page loading and parallel push animation are not working when a modifier is attached to the view in a `List`.
- Improved stability during the SwiftUI view update process.

## [v1.0.0](https://github.com/stleamist/BetterSafariView/releases/tag/v1.0.0) (2020-05-18)
- Initial Release
