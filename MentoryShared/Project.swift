import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.mentory(
    name: "MentoryShared",
    targets: [
        .mentoryFramework(
            name: "Values",
            sources: ["Sources/Values/**"]
        ),
    ]
)
