//
//  NewDailyRecordInterface.swift
//  MentoryDB
//
//  Created by 김민우 on 3/8/26.
//


import Foundation
import OSLog
import SwiftData
import Values


// MARK: interface
public protocol NewDailyRecordInterface: Actor, Sendable {
    // MARK: state
    var id: UUID { get }
    var suggestions: [SuggestionData] { get }
}
