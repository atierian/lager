// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Lager",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Lager",
            targets: ["Lager"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Lager",
            dependencies: []),
        .testTarget(
            name: "LagerTests",
            dependencies: ["Lager"]),
    ]
)
