//
//  NewDailySuggestionInterface.swift
//  MentoryDB
//
//  Created by 김민우 on 3/8/26.
//


import Foundation
import Values
import OSLog

public protocol NewDailySuggestionInterface: Sendable {
    // MARK: state
    var id: UUID { get }
    
    var target: SuggestionID { get async }
    var content: String { get async }
    
    var isDone: Bool { get async }
    func setDone(_: Bool) async
}
