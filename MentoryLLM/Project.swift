import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.mentory(
    name: "MentoryLLM",
    packages: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .branch("main")
        ),
    ],
    targets: [
        .mentoryStaticLibrary(
            name: "NewFirebaseLLMFake",
            sources: ["Sources/NewFirebaseLLMFake/**"],
            dependencies: [
                .mentoryShared("Values"),
                .target(name: "NewFirebaseLLM")
            ]
        ),
        .mentoryFramework(
            name: "NewFirebaseLLM",
            sources: ["Sources/NewFirebaseLLM/**"],
            dependencies: [
                .mentoryShared("Values"),
                .package(product: "FirebaseAI"),
                .package(product: "FirebaseAILogic"),
                .package(product: "FirebaseCore"),
            ]
        ),
    ]
)
