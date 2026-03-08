import Foundation
import Values

public enum MentoryWatchSamples {
    public static let emptyState = MentoryWatchPayload(
        message: nil,
        character: nil,
        todos: []
    )

    public static let morningCheckIn = MentoryWatchPayloadFactory.make(
        message: "You already made progress today.",
        character: .warm,
        todos: [
            (content: "Stretch for five minutes", isDone: false),
            (content: "Write one line in your journal", isDone: false),
        ]
    )

    public static let finishedPlan = MentoryWatchPayloadFactory.make(
        message: "Nice work. Keep the pace steady.",
        character: .cool,
        todos: [
            (content: "Take a short walk", isDone: true),
            (content: "Turn off notifications for one hour", isDone: true),
        ]
    )

    public static let all: [MentoryWatchPayload] = [
        emptyState,
        morningCheckIn,
        finishedPlan,
    ]
}
