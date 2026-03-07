import ProjectDescription

let project = Project(
    name: "MentoryShared",
    options: .options(
        automaticSchemesOptions: .disabled
    ),
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.0",
        ]
    ),
    targets: [
        .target(
            name: "Values",
            destinations: .iOS,
            product: .framework,
            bundleId: "cloud.mandooplz.Values",
            deploymentTargets: .iOS("26.1"),
            sources: ["Sources/Values/**"],
            resources: [],
            dependencies: []
        ),
    ]
)
