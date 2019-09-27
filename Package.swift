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
        .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
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
        .testTarget(
            name: "ArcheryInterfaceTests",
            dependencies: ["ArcheryInterface"]
        ),
    ]
)
