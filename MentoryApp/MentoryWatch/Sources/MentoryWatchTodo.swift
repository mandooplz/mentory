import Foundation

public struct MentoryWatchTodo: Sendable, Hashable, Identifiable {
    public let id: UUID
    public let content: String
    public let isDone: Bool

    public init(
        id: UUID = UUID(),
        content: String,
        isDone: Bool
    ) {
        self.id = id
        self.content = content
        self.isDone = isDone
    }
}
