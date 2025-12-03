//
//  MentorySwiftDataFlow.swift
//  Mentory
//
//  Created by 김민우 on 11/21/25.
//
import Foundation
import MentoryDB
import Values



// MARK: Domain
nonisolated struct MentoryDBAdapter: MentoryDBInterface {
    private let object = MentoryDatabase.shared
    
    @concurrent func getName() async throws -> String? {
        return await object.getName()
    }
    @concurrent func setName(_ newName: String) async throws {
        await object.setName(newName)
    }
    
    @concurrent func getMentorMessage() async throws -> MessageData? {
        return await object.getMentorMessage()
    }
    @concurrent func setMentorMessage(_ data: MessageData) async throws {
        await object.setMentorMessage(data)
    }
    
    @concurrent func getCharacter() async throws -> MentoryCharacter? {
        fatalError()
    }
    @concurrent func setCharacter(_ character: MentoryCharacter) async throws {
        fatalError()
    }
    
    @concurrent func getRecordCount() async throws -> Int {
        await object.getRecordCount()
    }
    
    @concurrent func saveRecord(_ data: RecordData) async throws {
        await object.insertTicket(data)
        
        await object.createDailyRecords()
    }
}
