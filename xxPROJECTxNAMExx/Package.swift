// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xxPROJECTxNAMExx",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "xxPROJECTxNAMExx",
            targets: ["xxPROJECTxNAMExx"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/hocgin/SwiftHit", from: "0.0.49"),
        .package(url: "https://github.com/bryan-vh/Voyager", from: "1.3.0"),
        .package(url: "https://github.com/krzysztofzablocki/Inject", from: "1.5.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "xxPROJECTxNAMExx",
            dependencies: [
                .product(name: "SwiftHit", package: "SwiftHit"),
                .product(name: "Voyager", package: "Voyager"),
            ]
        ),
        .testTarget(
            name: "xxPROJECTxNAMExxTests",
            dependencies: ["xxPROJECTxNAMExx"]
        ),
    ]
)
