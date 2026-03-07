import ProjectDescription

extension Project {
    static func mentory(
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
            settings: .mentoryProject(configurations: configurations),
            targets: targets,
            schemes: schemes,
            additionalFiles: additionalFiles
        )
    }
}
