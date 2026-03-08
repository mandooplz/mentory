import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.mentory(
    name: "MentoryDB",
    packages: [
        .package(
            url: "https://github.com/apple/swift-collections.git",
            .upToNextMajor(from: "1.3.0")
        ),
    ],
    targets: [
        .mentoryStaticLibrary(
            name: "MentoryDBFake",
            sources: ["Sources/MentoryDBFake/**"],
            dependencies: [
                .mentoryShared("Values"),
                .package(product: "Collections"),
            ]
        ),
        .mentoryStaticLibrary(
            name: "NewMentoryDBCore",
            sources: ["Sources/NewMentoryDBCore/**"],
            dependencies: [
                .mentoryShared("Values"),
            ]
        ),
        .mentoryStaticLibrary(
            name: "NewMentoryDBFake",
            sources: ["Sources/NewMentoryDBFake/**"],
            dependencies: [
                .target(name: "NewMentoryDBCore"),
                .mentoryShared("Values"),
                .package(product: "Collections"),
            ]
        ),
        .mentoryFramework(
            name: "MentoryDBAdapter",
            sources: ["Sources/MentoryDBAdapter/**"],
            dependencies: [
                .mentoryShared("Values"),
                .target(name: "MentoryDBFake"),
            ]
        ),
    ]
)
