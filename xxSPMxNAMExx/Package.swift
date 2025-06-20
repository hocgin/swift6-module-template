// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xxSPMxNAMExx",
    defaultLocalization: "zh",
    platforms: [
        .iOS(.v17),
        .macOS(.v15),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "xxSPMxNAMExx",
            targets: ["xxSPMxNAMExx"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "xxSPMxNAMExx",
            dependencies: [],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
    ]
)
