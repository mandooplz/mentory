import ProjectDescription

let workspace = Workspace(
    name: "mentory",
    projects: [
        "Mentory",
        "iOSManager",
        "Values",
        "MentoryDB",
    ],
    additionalFiles: [
        "README.md",
        "docs/**",
        "FirebaseLLM/Package.swift",
        "FirebaseLLM/Sources/**",
    ]
)
