// swift-tools-version:5.4
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
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.1"),
    ],
    targets: [
        .executableTarget(
            name: "Archery",
            dependencies: [
                "ArcheryInterface",
            ]
        ),
        .target(
            name: "ArcheryKit",
            dependencies: [
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
            ]
        ),
        .testTarget(
            name: "ArcheryInterfaceTests",
            dependencies: ["ArcheryInterface"]
        ),
    ]
)
