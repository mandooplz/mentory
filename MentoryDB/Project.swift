import ProjectDescription

let project = Project(
    name: "MentoryDB",
    packages: [
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.3.0")),
    ],
    settings: .settings(
        base: [
            "OTHER_SWIFT_FLAGS": "$(inherited) -package-name MentoryDB",
        ]
    ),
    targets: [
        .target(
            name: "MentoryDB",
            destinations: .iOS,
            product: .staticLibrary,
            bundleId: "cloud.mandooplz.MentoryDB",
            deploymentTargets: .iOS("26.1"),
            sources: ["Sources/MentoryDB/**"],
            resources: [],
            dependencies: [
                .project(target: "Values", path: "../MentoryShared"),
            ]
        ),
        .target(
            name: "MentoryDBFake",
            destinations: .iOS,
            product: .staticLibrary,
            bundleId: "cloud.mandooplz.MentoryDBFake",
            deploymentTargets: .iOS("26.1"),
            sources: ["Sources/MentoryDBFake/**"],
            resources: [],
            dependencies: [
                .project(target: "Values", path: "../MentoryShared"),
                .package(product: "Collections"),
            ]
        ),
        .target(
            name: "MentoryDBAdapter",
            destinations: .iOS,
            product: .framework,
            bundleId: "cloud.mandooplz.MentoryDBAdapter",
            deploymentTargets: .iOS("26.1"),
            sources: ["Sources/MentoryDBAdapter/**"],
            resources: [],
            dependencies: [
                .project(target: "Values", path: "../MentoryShared"),
                .target(name: "MentoryDB"),
                .target(name: "MentoryDBFake"),
                .package(product: "DequeModule"),
            ]
        ),
    ]
)
