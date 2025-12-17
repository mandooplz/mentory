//
//  NewWatchConManager.swift
//  Mentory
//
//  Created by 김민우 on 12/17/25.
//
import Foundation
import OSLog
import WatchConnectivity


// MARK: Object
@MainActor @Observable
final class NewWatchConManager: Sendable {
    // MARK: core
    
    
    // MARK: state
    private let logger = Logger()
    private let session: WCSession = .default
    
    var mentorMessage: String? = nil // 멘토 메시지를 불러오는 중...
    var mentorCharacter: String? = nil
    var actionTodos: [String] = []
    var todoCompletionStatus: [Bool] = []
    var connectionStatus: String? = nil // 연결 대기 중
    
    private var isSetUp: Bool = false
    private var handler: HandlerSet? = nil
    
    
    // MARK: action
    func setUp() {
        // capture
        guard WCSession.isSupported() else {
            logger.error("WCSession이 지원되지 않는 기기입니다.")
            return
        }
        
        // process
        let handler = HandlerSet()
        
        session.delegate = handler
        session.activate()
        
        // mutate
        
    }
    
    
    // MARK: value
    typealias UpdateHandler = @Sendable (WatchData) -> Void
    
    struct WatchData: Sendable, Hashable {
        let mentorMessage: String
        let mentorCharacter: String
        let actionTodos: [String]
        let todoCompletionStatus: [Bool]
        let connectionStatus: String
    }
    
    final nonisolated class HandlerSet: NSObject, WCSessionDelegate {
        func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
            fatalError("구현 예정입니다.")
        }   
    }
}
