import ProjectDescription

enum Mentory {
    static let projectOptions = Project.Options.options(
        automaticSchemesOptions: .disabled
    )

    static let bundleIdPrefix = "cloud.mandooplz"
    static let swiftVersion = "6.0"
    static let developmentTeam = "3X262XJF5T"

    static let iOSDeploymentTargets: DeploymentTargets = .iOS("26.1")
    static let watchOSDeploymentTargets: DeploymentTargets = .watchOS("26.2")

    static func bundleId(_ suffix: String) -> String {
        "\(bundleIdPrefix).\(suffix)"
    }

    enum Path {
        static let device = ProjectDescription.Path.relativeToManifest(
            "../MentoryDevice"
        )
        static let db = ProjectDescription.Path.relativeToManifest(
            "../MentoryDB"
        )
        static let llm = ProjectDescription.Path.relativeToManifest(
            "../MentoryLLM"
        )
        static let shared = ProjectDescription.Path.relativeToManifest(
            "../MentoryShared"
        )
    }
}
