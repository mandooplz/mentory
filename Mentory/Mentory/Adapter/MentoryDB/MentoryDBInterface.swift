//
//  MentoryDBFlow.swift
//  Mentory
//
//  Created by 김민우 on 11/14/25.
//
import Foundation
import SwiftData
import OSLog


// MARK: Domain Interface
protocol MentoryDBInterface: Sendable {
    func updateName(_ newName: String) async throws -> Void
    func getName() async throws -> String?
}
