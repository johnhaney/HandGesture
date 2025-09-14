// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HandGesture",
    platforms: [
        .visionOS(.v26),
        .iOS(.v18),
        .macOS(.v15),
        .macCatalyst(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HandGesture",
            targets: ["HandGesture"]),
    ],
    dependencies: [
        .package(url: "https://github.com/johnhaney/ARUnderstanding", from: "26.0.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HandGesture", dependencies: ["ARUnderstanding"]),
    ]
)
