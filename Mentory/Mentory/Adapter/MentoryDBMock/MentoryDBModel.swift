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
    
    var createRecordQueue: Deque<RecordData> = []
    
    var records: [DailyRecordModel] = []
    func getAllRecords() -> [RecordData] {
        self.records
            .map {
                RecordData(id: $0.id,
                           createdAt: $0.createAt,
                           content: $0.content,
                           analyzedResult: $0.analyzedContent,
                           emotion: $0.emotion)
            }
    }
    func getTodayRecords() -> [RecordData] {
        let calendar = Calendar.current
        
        return self.records
            .filter { calendar.isDateInToday($0.createAt) }
            .map {
                RecordData(id: $0.id,
                           createdAt: $0.createAt,
                           content: $0.content,
                           analyzedResult: $0.analyzedContent,
                           emotion: $0.emotion)
            }
    }
    func getRecords(from: Date, to: Date) -> [RecordData] {
        let start = min(from, to)
        let end = max(from, to)
        
        return self.records
            .filter { $0.createAt >= start && $0.createAt <= end }
            .map {
                RecordData(id: $0.id,
                           createdAt: $0.createAt,
                           content: $0.content,
                           analyzedResult: $0.analyzedContent,
                           emotion: $0.emotion)
            }
    }
    
    
    // MARK: action
    func createDailyRecords() {
        // mutate
        while createRecordQueue.isEmpty == false {
            let data = createRecordQueue.removeFirst()
            
            let newRecord = DailyRecordModel(
                owner: self,
                createAt: data.createdAt,
                content: data.content,
                analyzedContent: data.analyzedResult,
                emotion: data.emotion
            )
            
            records.append(newRecord)
        }
    }
    
    
    // MARK: value
}
