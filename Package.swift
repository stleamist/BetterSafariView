// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "BetterSafariView",
    platforms: [.iOS(.v13), .macOS(.v10_15), .watchOS("6.2")],
    products: [
        .library(name: "BetterSafariView",
                 targets: ["BetterSafariView"]),
        .library(name: "SafariView",
                 targets: ["SafariView"]),
        .library(name: "WebAuthenticationSession",
                 targets: ["WebAuthenticationSession"])
    ],
    targets: [
        .target(name: "BetterSafariView",
                dependencies: ["SafariView", "WebAuthenticationSession"]),
        .target(name: "SafariView",
                dependencies: ["Shared"]),
        .target(name: "WebAuthenticationSession",
                dependencies: ["Shared"]),
        .target(name: "Shared")
    ]
)
