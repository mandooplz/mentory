//
//  NewDailySuggestionFake.swift
//  MentoryDB
//
//  Created by 김민우 on 3/8/26.
//

import NewMentoryDBCore
import Values
import Foundation


// MARK: fake
@MainActor
public final class NewDailySuggestionFake: NewDailyRecordInterface {
    // MARK: state
    public nonisolated let id: UUID = UUID()

    public var suggestions: [Values.SuggestionData] = []


}
