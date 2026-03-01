import ProjectDescription

let workspace = Workspace(
    name: "mentory",
    projects: [
        "MentoryApp",
        "MentoryDevice",
        "MentoryShared",
        "MentoryDB",
        "MentoryLLM",
    ],
    additionalFiles: [
        "README.md",
    ]
)
