import ProjectDescription
import ProjectDescriptionHelpers

let frameworkSettings = Settings.mentoryTarget(
    base: .mentoryFrameworkModule()
)

let project = Project.mentory(
    name: "MentoryDevice",
    targets: [
        .mentoryFramework(
            name: "WatchManager",
            sources: ["WatchManager/**/*.swift"],
            settings: frameworkSettings
        ),
        .mentoryFramework(
            name: "ImagePicker",
            sources: ["ImagePicker/**/*.swift"],
            settings: frameworkSettings
        ),
        .mentoryFramework(
            name: "Microphone",
            sources: ["Microphone/**/*.swift"],
            settings: frameworkSettings
        ),
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
