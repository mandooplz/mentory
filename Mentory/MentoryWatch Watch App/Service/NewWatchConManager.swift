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
        let handler = HandlerSet { [weak self] watchData in
            Task { @MainActor in
                self?.mentorMessage = watchData.mentorMessage
                self?.mentorCharacter = watchData.mentorCharacter
                self?.actionTodos = watchData.actionTodos
                self?.todoCompletionStatus = watchData.todoCompletionStatus
                self?.connectionStatus = watchData.connectionStatus
            }
        }
        
        session.delegate = handler
        session.activate()
        
        // mutate
        self.handler = handler
    }
    
    func updateContext() {
        // capture
        let message = self.mentorMessage ?? ""
        let character = self.mentorCharacter ?? ""
        let todos = self.actionTodos
        let todoCompletions = self.todoCompletionStatus
        
        // process
        let context: [String: Any] = [
            "mentorMessage": message,
            "mentorCharacter": character,
            "actionTodos": todos,
            "todoCompletionStatus": todoCompletions,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        do {
            try session.updateApplicationContext(context)
            logger.debug("iOS으로 데이터 전송 성공")
        } catch {
            logger.error("iOS으로 데이터 전송 실패: \(error.localizedDescription)")
        }
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
    
    nonisolated final class HandlerSet: NSObject, WCSessionDelegate {
        let updateHandler: UpdateHandler
        init(updateHandler: @escaping UpdateHandler) {
            self.updateHandler = updateHandler
        }
        
        func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
            // ConnectionStatus 업데이트
            fatalError("구현 예정입니다.")
        }
        
        func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
            let mentorMsg = message["mentorMessage"] as! String
            let character = message["mentorCharacter"] as! String
            let todos = message["actionTodos"] as! [String]
            let completionStatus = message["todoCompletionStatus"] as! [Bool]
            
            let data = WatchData(
                mentorMessage: mentorMsg,
                mentorCharacter: character,
                actionTodos: todos,
                todoCompletionStatus: completionStatus,
                connectionStatus: "연결됨"
            )
            
            updateHandler(data)
        }
        
        func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
            let mentorMsg = applicationContext["mentorMessage"] as! String
            let character = applicationContext["mentorCharacter"] as! String
            let todos = applicationContext["actionTodos"] as! [String]
            let completionStatus = applicationContext["todoCompletionStatus"] as! [Bool]
            
            let data = WatchData(
                mentorMessage: mentorMsg,
                mentorCharacter: character,
                actionTodos: todos,
                todoCompletionStatus: completionStatus,
                connectionStatus: "연결됨"
            )
            
            updateHandler(data)
        }
    }
}
