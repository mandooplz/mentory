//
//  MentorMessage.swift
//  MentoryDB
//
//  Created by JAY on 11/26/25.
//

import Foundation
import SwiftData
import OSLog

// MARK: Object
actor MentorMessage: Sendable {
    //MARK: core
    init(id: UUID) {
        self.id = id
    }
    nonisolated let id: UUID
    nonisolated let logger = Logger(subsystem: "MentoryDB.MentorMessage", category: "Domain")
    
    //MARK: state
    
    //MARK: action
    
    //MARK: value
    //>>여기에 모델.. 어떤 규격?으로 저장될지 정하기 (UUID, 캐릭터타입, 메세지..?)
    
    
}
