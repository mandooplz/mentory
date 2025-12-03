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
            object.getMentorMessage()
        }
    }
    @concurrent func setMentorMessage(_ data: MessageData) async throws {
        await MainActor.run {
            object.updateMentorMessage(data)
        }
    }
    
    @concurrent func getRecordCount() async throws -> Int {
        fatalError()
    }
}
