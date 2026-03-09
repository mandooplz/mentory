import ProjectDescription

public enum Mentory {
    public static let projectOptions = Project.Options.options(
        automaticSchemesOptions: .disabled
    )

    public static let bundleIdPrefix = "cloud.mandooplz"
    public static let swiftVersion = "6.0"
    public static let developmentTeam = "3X262XJF5T"

    public static let iOSDeploymentTargets: DeploymentTargets = .iOS("26.1")
    public static let defaultConfigurations: [Configuration] = [
        .debug(name: "Debug"),
        .release(name: "Release"),
    ]

    public static func bundleId(_ suffix: String) -> String {
        "\(bundleIdPrefix).\(suffix)"
    }

    public enum Path {
        public static let device = ProjectDescription.Path.relativeToManifest(
            "../MentoryDevice"
        )
        public static let db = ProjectDescription.Path.relativeToManifest(
            "../MentoryDB"
        )
        public static let llm = ProjectDescription.Path.relativeToManifest(
            "../MentoryLLM"
        )
        public static let shared = ProjectDescription.Path.relativeToManifest(
            "../MentoryShared"
        )
    }
}
