// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xxTCAxNAMExx",
    defaultLocalization: "zh",
    platforms: [
        .iOS(.v17),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "AppAit",
            targets: ["AppAit"]
        ),
        .library(
            name: "WidgetAit",
            targets: ["WidgetAit"]
        ),
    ],
    dependencies: [
        /// - TCA
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", .upToNextMajor(from: "1.20.2")),
        .package(url: "https://github.com/pointfreeco/sharing-grdb.git", .upToNextMajor(from: "0.4.1")),
        .package(url: "https://github.com/pointfreeco/swift-tagged.git", .upToNextMajor(from: "0.10.0")),
        .package(url: "https://github.com/tgrapperon/swift-dependencies-additions.git", .upToNextMajor(from: "1.1.1")),
        /// - Core
        .package(url: "git@github.com:hocgin/SwiftUIError.git", .upToNextMajor(from: "1.0.1")),
        .package(url: "git@github.com:hocgin/SwiftLogKit.git", .upToNextMajor(from: "1.0.1")),
        .package(url: "git@github.com:hocgin/SwiftExtensionsKit.git", .upToNextMajor(from: "1.0.0")),
        /// - Feature
        .package(url: "git@github.com:hocgin/SwiftPermissionKit.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "git@github.com:hocgin/SwiftNetworkKit.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "git@github.com:hocgin/CacheKit.git", .upToNextMajor(from: "1.0.2")),
        .package(url: "git@github.com:hocgin/HTTPRequestKit.git", .upToNextMajor(from: "1.0.6")),
        /// - UI
        .package(url: "git@github.com:hocgin/SwiftUIProductKit.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "git@github.com:hocgin/SwiftUIWebKit.git", .upToNextMajor(from: "1.0.1")),
        .package(url: "git@github.com:hocgin/SwiftChangeKit.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "git@github.com:hocgin/SwiftGuideKit.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "git@github.com:hocgin/SwiftUIToast.git", .upToNextMajor(from: "1.0.4")),
    ],
    targets: [
        .target(
            name: "SharedModelAit",
            dependencies: [],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .target(
            name: "SharedAit",
            dependencies: [
                /// SwiftHit
                .product(name: "SwiftLogKit", package: "SwiftLogKit"),
                .product(name: "SwiftExtensionsKit", package: "SwiftExtensionsKit"),
                .product(name: "HTTPRequestKit", package: "HTTPRequestKit"),
                .product(name: "CacheKit", package: "CacheKit"),
                /// Tagged
                .product(name: "Tagged", package: "swift-tagged"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        /// Platform
        .target(
            name: "WidgetAit",
            dependencies: [
                .target(name: "SharedAit"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .target(
            name: "AppAit",
            dependencies: [
                .target(name: "SharedAit"),
                .product(name: "SharingGRDB", package: "sharing-grdb"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
//                .product(name: "DependenciesAdditions", package: "swift-dependencies-additions"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
//                .enableExperimentalFeature("Macros"),
            ]
        ),
        .target(
            name: "xxTCAxNAMExx",
            dependencies: [],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
    ]
)
