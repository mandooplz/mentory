//
//  NewMentoryDBError.swift
//  MentoryDB
//
//  Created by 김민우 on 3/7/26.
//


import Foundation
import OSLog
import SwiftData
import Values

public enum NewMentoryDBError: Error, Sendable {
        case containerUnavailable
        case databaseNotFound
        case recordNotFound
    }