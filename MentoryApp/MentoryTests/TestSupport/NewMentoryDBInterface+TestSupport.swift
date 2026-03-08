import NewMentoryDBCore
import Values

extension NewMentoryDBInterface {
    func submitAnalysis(
        recordData: RecordSnapshot,
        suggestionData: [SuggestionData]
    ) async {
        await insertTicket(recordData)
        await createDailyRecords()
        await insertSuggestions(
            ticketId: recordData.objectID,
            suggestions: suggestionData
        )
    }
}
