import ProjectDescription

let project = Project(
    name: "MentoryDB",
    options: .options(
        automaticSchemesOptions: .disabled
    ),
    packages: [
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.3.0")),
    ],
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.0",
        ]
    ),
    targets: [
        .target(
            name: "MentoryDBCore",
            destinations: .iOS,
            product: .staticLibrary,
            bundleId: "cloud.mandooplz.MentoryDBCore",
            deploymentTargets: .iOS("26.1"),
            sources: ["Sources/MentoryDBCore/**"],
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
            name: "NewMentoryDBCore",
            destinations: .iOS,
            product: .staticLibrary,
            bundleId: "cloud.mandooplz.NewMentoryDBCore",
            deploymentTargets: .iOS("26.1"),
            sources: ["Sources/NewMentoryDBCore/**"],
            resources: [],
            dependencies: [
                .project(target: "Values", path: "../MentoryShared"),
            ]
        ),
        .target(
            name: "NewMentoryDBFake",
            destinations: .iOS,
            product: .staticLibrary,
            bundleId: "cloud.mandooplz.NewMentoryDBFake",
            deploymentTargets: .iOS("26.1"),
            sources: ["Sources/NewMentoryDBFake/**"],
            resources: [],
            dependencies: [
                .target(name: "NewMentoryDBCore"),
                .project(target: "Values", path: "../MentoryShared"),
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
                .target(name: "MentoryDBCore"),
                .target(name: "MentoryDBFake"),
            ]
        ),
    ]
)
