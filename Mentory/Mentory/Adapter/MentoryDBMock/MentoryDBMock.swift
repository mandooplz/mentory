//
//  MentoryDBMock.swift
//  Mentory
//
//  Created by 김민우 on 11/18/25.
//
import Foundation
import Values


// MARK: Mock
nonisolated
struct MentoryDBMock: MentoryDBInterface {
    // MARK: core
    nonisolated let object = MentoryDBModel()
    
    
    // MARK: flow
    @concurrent func getName() async throws -> String? {
        return await MainActor.run {
            object.userName
        }
    }
    @concurrent func setName(_ newName: String) async throws {
        await MainActor.run {
            object.userName = newName
        }
    }
    
    @concurrent func getMentorMessage() async throws -> Values.MessageData? {
        return await MainActor.run {
            object.message
        }
    }
    @concurrent func setMentorMessage(_ data: MessageData) async throws {
        await MainActor.run {
            object.message = data
        }
    }
    
    @concurrent func getCharacter() async throws -> MentoryCharacter? {
        return await MainActor.run {
            object.userCharacter
        }
    }
    @concurrent func setCharacter(_ character: MentoryCharacter) async throws {
        await MainActor.run {
            object.userCharacter = character
        }
    }
    
    @concurrent func getRecordCount() async throws -> Int {
        fatalError()
    }
    
    
    @concurrent func saveRecord(_ recordData: RecordData) async throws {
        await object.insertTicket(recordData)
        
        await object.createDailyRecords()
    }
}
