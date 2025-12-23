// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MentoryDB",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "MentoryDBAdapter",
            targets: ["MentoryDBAdapter"]
        ),
    ],
    dependencies: [
        .package(path: "../Values")
    ],
    targets: [
        .target(
            name: "MentoryDB",
            dependencies: [
                .product(name: "Values", package: "Values")
            ]
        ),
        
        .target(
            name: "MentoryDBAdapter",
            dependencies: [
                "MentoryDB",
                "MentoryDBFake"
            ]
        ),
        
        .target(
            name: "MentoryDBFake"
        )
    ]
)
