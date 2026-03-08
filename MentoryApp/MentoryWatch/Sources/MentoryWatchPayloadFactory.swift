import Foundation
import Values

public enum MentoryWatchPayloadFactory {
    public static func make(
        message: String?,
        character: MentoryCharacter?,
        todos: [(content: String, isDone: Bool)]
    ) -> MentoryWatchPayload {
        MentoryWatchPayload(
            message: message,
            character: character,
            todos: todos.map {
                MentoryWatchTodo(
                    content: $0.content,
                    isDone: $0.isDone
                )
            }
        )
    }
}
