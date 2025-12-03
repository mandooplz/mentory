//
//  MentoryDBFlow.swift
//  Mentory
//
//  Created by 김민우 on 11/14/25.
//
import Foundation
import SwiftData
import OSLog
import Values



// MARK: Interface
protocol MentoryDBInterface: Sendable {
    func setName(_ newName: String) async throws -> Void
    func getName() async throws -> String?

    func getMentorMessage() async throws -> MessageData?
    func setMentorMessage(_ data: MessageData) async throws -> Void
    
    func getRecordCount() async throws -> Int
}
