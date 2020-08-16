# Changelog

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
