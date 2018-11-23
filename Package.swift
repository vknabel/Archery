// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Archery",
    products: [
        .executable(
            name: "archery",
            targets: ["Archery"]
        ),
        .library(
            name: "ArcheryKit",
            targets: ["ArcheryKit"]
        ),
        .library(
            name: "ArcheryInterface",
            targets: ["ArcheryInterface"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/jakeheis/SwiftCLI.git", from: "5.2.1"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "0.9.1"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "1.0.1"),
    ],
    targets: [
        .target(
            name: "Archery",
            dependencies: [
                "ArcheryInterface",
            ]
        ),
        .target(
            name: "ArcheryKit",
            dependencies: [
                "PathKit",
                "Yams",
                "MintKitShim",
            ]
        ),
        .testTarget(
            name: "ArcheryKitTests",
            dependencies: ["ArcheryKit"]
        ),
        .target(
            name: "ArcheryInterface",
            dependencies: [
                "ArcheryKit",
                "PathKit",
            ]
        ),
        .target(
            name: "MintKitShim",
            dependencies: [
                "PathKit",
                "SwiftCLI",
            ]
        ),
        .testTarget(
            name: "ArcheryInterfaceTests",
            dependencies: ["ArcheryInterface"]
        ),
    ]
)
