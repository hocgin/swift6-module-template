// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xxPROJECTxNAMExx",
    defaultLocalization: "zh",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
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
        .package(url: "git@github.com:hocgin/SwiftHit.git", revision: "1ca5df38ad1425a065961352c2e83cee069356b4"),
        .package(url: "git@github.com:hocgin/StoreKitHelper.git", revision: "6db54ccae7a25538452e58e80c6c854a5f9c5935"),
        .package(url: "git@github.com:hocgin/Voyager.git", revision: "aa1d0abfc6dd769f0dd6a716f355cf09cd30b437"),
        .package(url: "https://github.com/marcprux/MemoZ.git", .upToNextMajor(from: "1.5.2")),
    ],
    targets: [
        .target(
            name: "SharedAit",
            dependencies: [
                /// SwiftHit
                .product(name: "LogHit", package: "SwiftHit"),
                .product(name: "ExtensionHit", package: "SwiftHit"),
                .product(name: "RequestHit", package: "SwiftHit"),
                /// MemoZ
                .product(name: "MemoZ", package: "MemoZ"),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "WidgetAit",
            dependencies: [
                .target(name: "SharedAit"),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "AppAit",
            dependencies: [
                .target(name: "SharedAit"),
                .product(name: "StoreKitHelper", package: "StoreKitHelper"),
                .product(name: "Voyager", package: "Voyager"),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
