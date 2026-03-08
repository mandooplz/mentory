import Foundation
import Values

public struct MentoryWatchPayload: Sendable, Hashable {
    public let message: String?
    public let character: MentoryCharacter?
    public let todos: [MentoryWatchTodo]

    public init(
        message: String?,
        character: MentoryCharacter?,
        todos: [MentoryWatchTodo]
    ) {
        self.message = message
        self.character = character
        self.todos = todos
    }

    public var characterName: String? {
        character?.rawValue
    }

    public var todoTexts: [String] {
        todos.map(\.content)
    }

    public var todoCompletions: [Bool] {
        todos.map(\.isDone)
    }
}
