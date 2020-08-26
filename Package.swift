// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "BetterSafariView",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "BetterSafariView", targets: ["BetterSafariView"])
    ],
    targets: [
        .target(name: "BetterSafariView")
    ]
)
