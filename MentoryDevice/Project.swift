import ProjectDescription
import ProjectDescriptionHelpers

let frameworkSettings = Settings.mentoryTarget(
    base: .mentoryFrameworkModule()
)

let project = Project.mentory(
    name: "MentoryDevice",
    targets: [
        .mentoryFramework(
            name: "iOSReminder",
            sources: ["iOSReminder/**/*.swift"],
            dependencies: [
                .mentoryShared("Values"),
            ],
            settings: frameworkSettings
        ),
    ]
)
