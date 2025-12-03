//
//  MentoryDBModel.swift
//  Mentory
//
//  Created by 김민우 on 11/18/25.
//
import Foundation
import Collections
import Values


// MARK: Object Model
@MainActor
final class MentoryDBModel: Sendable {
    // MARK: core
    nonisolated init() { }
    
    // MARK: state
    var userName: String? = nil
    
    var records: [DailyRecordModel] = []
    
    var createRecordQueue: Deque<RecordData> = []
    
    var userCharacter: MentoryCharacter? = nil
    
    var message: MessageData? = nil

    
    
    // MARK: action
    func createDailyRecords() {
        // mutate
        while createRecordQueue.isEmpty == false {
            let data = createRecordQueue.removeFirst()
            
            let newRecord = DailyRecordModel(
                owner: self,
                recordDate: data.recordDate,
                createAt: data.createdAt,
                analyzedContent: data.analyzedResult,
                emotion: data.emotion
            )
            
            records.append(newRecord)
        }
    }
    

    // MARK: value
}
