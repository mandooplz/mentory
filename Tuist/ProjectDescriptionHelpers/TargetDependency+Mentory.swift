import ProjectDescription

extension TargetDependency {
    public static func mentoryShared(_ target: String) -> TargetDependency {
        .project(target: target, path: Mentory.Path.shared)
    }

    public static func mentoryDevice(_ target: String) -> TargetDependency {
        .project(target: target, path: Mentory.Path.device)
    }

    public static func mentoryDB(_ target: String) -> TargetDependency {
        .project(target: target, path: Mentory.Path.db)
    }

    public static func mentoryLLM(_ target: String) -> TargetDependency {
        .project(target: target, path: Mentory.Path.llm)
    }
}
