//
//  WatchConnectivityManager.swift
//  Mentory
//
//  Created by 구현모 on 11/26/25.
//
import Foundation
import Combine
import OSLog
import WatchConnectivity



// MARK: Object
@MainActor @Observable
final class WatchConnectivityManager {
    // MARK: core
    private let logger = Logger()
    static let shared = WatchConnectivityManager()
    private init() { }

    // MARK: state
    var isPaired: Bool = false
    var isWatchAppInstalled: Bool = false
    var isReachable: Bool = false

    private(set) var engine: WatchConnectivityEngine? = nil


    // MARK: action
    func setUp() async {
        // capture
        guard engine == nil else {
            logger.error("이미 세팅된 상태입니다.")
            return
        }

        // process
        let engine = WatchConnectivityEngine()
        await engine.setStateUpdateHandler { [weak self] state in
            Task { @MainActor in
                self?.isPaired = state.isPaired
                self?.isWatchAppInstalled = state.isWatchAppInstalled
                self?.isReachable = state.isReachable
            }
        }
        
        engine.activate()

        // mutate
        self.engine = engine
    }
    
    func updateMentorMessages() async {
        fatalError("구현 예정입니다.")
    }
    
    func updateActionTodos() async {
        fatalError("구현 예정입니다.")
    }

    
    // MARK: value
    typealias StateHandler = @Sendable (ConnectionState) -> Void
    typealias TodoHandler = @Sendable (String, Bool) -> Void
    
    struct ConnectionState: Sendable, Hashable {
        let isPaired: Bool
        let isWatchAppInstalled: Bool
        let isReachable: Bool
    }
    
    final class HandlerSet: NSObject, WCSessionDelegate {
        // MARK: core
        private let logger = Logger()
        let activateHandler: StateHandler
        let todoHandler: TodoHandler
        
        init(activateHandler: @escaping StateHandler, todoHandler: @escaping TodoHandler) {
            self.activateHandler = activateHandler
            self.todoHandler = todoHandler
        }
        
        // MARK: operator
        func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
            let connectionState = ConnectionState(
                isPaired: session.isPaired,
                isWatchAppInstalled: session.isWatchAppInstalled,
                isReachable: session.isReachable
            )
            
            activateHandler(connectionState)
        }
        
        func sessionDidBecomeInactive(_ session: WCSession) {
            // Watch가 새로운 기기로 전환하는 중
        }
        
        func sessionDidDeactivate(_ session: WCSession) {
            // Watch가 전환 완료
            session.activate()
        }
        
        func sessionReachabilityDidChange(_ session: WCSession) {
            let connectionState = ConnectionState(
                isPaired: session.isPaired,
                isWatchAppInstalled: session.isWatchAppInstalled,
                isReachable: session.isReachable
            )
            
            activateHandler(connectionState)
        }
        
        func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
            guard let action = message["action"] as? String,
                  action == "todoCompletion",
                  let todoText = message["todoText"] as? String,
                  let isCompleted = message["isCompleted"] as? Bool else {
                return
            }

            todoHandler(todoText, isCompleted)

        }
    }
}



// MARK: Extension
extension WatchConnectivityManager {
    func updateMentorMessage(_ message: String, character: String) async {
        // 멘토 메시지를 Watch로 전송
        await engine?.sendMentorMessage(message, character: character)
    }

    func updateActionTodos(_ todos: [String], completionStatus: [Bool]) async {
        // 행동 추천 투두를 Watch로 전송
        await engine?.sendActionTodos(todos, completionStatus: completionStatus)
    }

    func setTodoCompletionHandler(_ handler: @escaping @Sendable (String, Bool) -> Void) async {
        // 투두 완료 처리 핸들러 설정
        await engine?.setTodoCompletionHandler(handler)
    }
}
