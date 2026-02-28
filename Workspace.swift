import ProjectDescription

let workspace = Workspace(
    name: "mentory",
    projects: [
        "Mentory",
        "iOSManager",
    ],
    additionalFiles: [
        "README.md",
        "docs/**",
        "FirebaseLLM/Package.swift",
        "FirebaseLLM/Sources/**",
        "MentoryDB/Package.swift",
        "MentoryDB/Sources/**",
        "Values/Package.swift",
        "Values/Sources/**",
    ]
)
