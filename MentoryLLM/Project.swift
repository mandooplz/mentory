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
            name: "FirebaseLLMFake",
            sources: ["Sources/FirebaseLLMFake/**"],
            dependencies: [
                .mentoryShared("Values"),
            ]
        ),
        .mentoryFramework(
            name: "FirebaseLLMAdapter",
            sources: ["Sources/FirebaseLLMAdapter/**"],
            dependencies: [
                .target(name: "FirebaseLLMFake"),
                .mentoryShared("Values"),
                .package(product: "FirebaseAI"),
                .package(product: "FirebaseAILogic"),
                .package(product: "FirebaseCore"),
            ]
        ),
    ]
)
