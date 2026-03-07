import ProjectDescription

extension Project {
    public static func mentory(
        name: String,
        packages: [Package] = [],
        configurations: [Configuration] = [],
        targets: [Target],
        schemes: [Scheme] = [],
        additionalFiles: [FileElement] = []
    ) -> Project {
        Project(
            name: name,
            options: Mentory.projectOptions,
            packages: packages,
            settings: .mentoryProject(
                configurations: configurations.isEmpty
                    ? Mentory.defaultConfigurations
                    : configurations
            ),
            targets: targets,
            schemes: schemes,
            additionalFiles: additionalFiles
        )
    }
}
