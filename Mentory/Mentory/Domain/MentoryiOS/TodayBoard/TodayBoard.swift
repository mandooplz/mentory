//
//  TodayBoard.swift
//  Mentory
//
//  Created by 구현모 on 11/14/25.
//
import Foundation
import Combine
import OSLog


// MARK: Object
@MainActor
final class TodayBoard: Sendable, ObservableObject {
    // MARK: core
    init(owner: MentoryiOS) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let owner: MentoryiOS
    nonisolated let id = UUID()
    nonisolated private let logger = Logger(subsystem: "MentoryiOS.TodayBoard", category: "Domain")

    var recordForm: RecordForm? = nil
    @Published var records: [Record] = []


    // MARK: action
    func addRecord(_ record: Record) {
        records.append(record)
        logger.info("새로운 기록이 추가되었습니다. ID: \(record.id)")
    }


    // MARK: value
    struct Record: Identifiable, Sendable, Hashable {
        let id: UUID
        let title: String
        let date: Date
        let text: String?
        let image: Data?
        let voice: URL?

        init(id: UUID = UUID(), title: String, date: Date, text: String? = nil, image: Data? = nil, voice: URL? = nil) {
            self.id = id
            self.title = title
            self.date = date
            self.text = text
            self.image = image
            self.voice = voice
        }
    }
}
