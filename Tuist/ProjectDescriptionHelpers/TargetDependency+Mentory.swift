import ProjectDescription

extension TargetDependency {
    static func mentoryShared(_ target: String) -> TargetDependency {
        .project(target: target, path: Mentory.Path.shared)
    }

    static func mentoryDevice(_ target: String) -> TargetDependency {
        .project(target: target, path: Mentory.Path.device)
    }

    static func mentoryDB(_ target: String) -> TargetDependency {
        .project(target: target, path: Mentory.Path.db)
    }

    static func mentoryLLM(_ target: String) -> TargetDependency {
        .project(target: target, path: Mentory.Path.llm)
    }
}
