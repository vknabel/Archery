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
        .package(url: "https://github.com/JohnSundell/Unbox.git", from: "2.0.0"),
        .package(url: "https://github.com/JohnSundell/Wrap.git", from: "3.0.0"),
        .package(url: "https://github.com/yonaskolb/Mint.git", from: "0.7.1"),
        .package(url: "https://github.com/kareman/SwiftShell.git", from: "4.0.0"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "0.8.0"),
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
                "MintKit",
                "PathKit",
                "Unbox",
                "Wrap",
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
                "Unbox",
                "SwiftShell"
            ]
        ),
        .testTarget(
            name: "ArcheryInterfaceTests",
            dependencies: ["ArcheryInterface"]
        ),
    ]
)
