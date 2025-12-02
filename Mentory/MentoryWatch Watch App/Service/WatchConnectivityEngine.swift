//
//  WatchConnectivityEngine.swift
//  MentoryWatch Watch App
//
//  Created by 구현모 on 12/2/25.
//

import Foundation
@preconcurrency import WatchConnectivity
import OSLog

/// WCSessionDelegate를 구현하는 백그라운드 처리 전용 액터
actor WatchConnectivityEngine {
    // MARK: - Core
    static let shared = WatchConnectivityEngine()

    private nonisolated let logger = Logger(subsystem: "MentoryWatch.WatchConnectivityEngine", category: "Service")
    private nonisolated(unsafe) let session: WCSession
    private var sessionDelegate: SessionDelegate?

    // MARK: - State
    private var cachedMentorMessage: String = ""
    private var cachedMentorCharacter: String = ""
    private var cachedConnectionStatus: String = "연결 대기 중"

    // MARK: - Handler
    private var dataUpdateHandler: DataUpdateHandler?

    typealias DataUpdateHandler = @Sendable (WatchData) -> Void

    // MARK: - Initialization
    private init() {
        self.session = WCSession.default
    }

    // MARK: - Public Methods

    /// 엔진 활성화 (WCSession delegate 설정 및 activate)
    nonisolated func activate() {
        guard WCSession.isSupported() else {
            logger.error("WCSession이 지원되지 않는 기기입니다.")
            return
        }

        let delegate = SessionDelegate(engine: self)
        Task {
            await self.setSessionDelegate(delegate)
        }
        session.delegate = delegate
        session.activate()
    }

    private func setSessionDelegate(_ delegate: SessionDelegate) {
        self.sessionDelegate = delegate
    }

    /// 데이터 업데이트 핸들러 설정
    func setDataUpdateHandler(_ handler: @escaping DataUpdateHandler) {
        self.dataUpdateHandler = handler
    }

    /// iOS 앱에 데이터 요청
    func requestDataFromPhone() {
        guard session.isReachable else {
            logger.warning("iPhone과 연결되지 않음")
            updateConnectionStatus("iPhone과 연결되지 않음")
            return
        }

        let message = ["request": "initialData"]
        session.sendMessage(message, replyHandler: { [weak self] reply in
            guard let self = self else { return }

            // Task 외부에서 데이터 추출 (Sendable하지 않은 Dictionary를 직접 전달하지 않음)
            let mentorMsg = reply["mentorMessage"] as? String ?? ""
            let character = reply["mentorCharacter"] as? String ?? ""

            Task {
                await self.handleReceivedData(mentorMsg: mentorMsg, character: character)
            }
        }, errorHandler: { [weak self] error in
            self?.logger.error("데이터 요청 실패: \(error.localizedDescription)")
        })
    }

    // MARK: - Internal Methods

    /// 받은 데이터 처리
    func handleReceivedData(mentorMsg: String?, character: String?) {
        if let mentorMsg = mentorMsg {
            cachedMentorMessage = mentorMsg
        }
        if let character = character {
            cachedMentorCharacter = character
        }

        updateConnectionStatus("연결됨")
        notifyDataUpdate()
    }

    /// 활성화 상태 업데이트
    func handleActivation(state: WCSessionActivationState, error: Error?) {
        let statusMessage: String

        switch state {
        case .activated:
            statusMessage = "활성화됨"
            // 활성화 완료되면 데이터 요청
            Task {
                await self.requestDataFromPhone()
            }
        case .inactive:
            statusMessage = "비활성화됨"
        case .notActivated:
            statusMessage = "활성화 안됨"
        @unknown default:
            statusMessage = "알 수 없는 상태"
        }

        if let error = error {
            logger.error("WCSession 활성화 오류: \(error.localizedDescription)")
            updateConnectionStatus("오류: \(error.localizedDescription)")
        } else {
            updateConnectionStatus(statusMessage)
        }
    }

    // MARK: - Private Methods

    /// 연결 상태 업데이트
    private func updateConnectionStatus(_ status: String) {
        cachedConnectionStatus = status
        notifyDataUpdate()
    }

    /// 핸들러를 통해 데이터 변경 알림
    private func notifyDataUpdate() {
        let data = WatchData(
            mentorMessage: cachedMentorMessage,
            mentorCharacter: cachedMentorCharacter,
            connectionStatus: cachedConnectionStatus
        )

        dataUpdateHandler?(data)
    }
}

// MARK: - SessionDelegate
private final class SessionDelegate: NSObject, @preconcurrency WCSessionDelegate {
    private weak var engine: WatchConnectivityEngine?

    nonisolated init(engine: WatchConnectivityEngine) {
        self.engine = engine
        super.init()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task {
            await engine?.handleActivation(state: activationState, error: error)
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        let mentorMsg = message["mentorMessage"] as? String
        let character = message["mentorCharacter"] as? String

        Task {
            await engine?.handleReceivedData(mentorMsg: mentorMsg, character: character)
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        let mentorMsg = message["mentorMessage"] as? String
        let character = message["mentorCharacter"] as? String

        Task {
            await engine?.handleReceivedData(mentorMsg: mentorMsg, character: character)
        }

        replyHandler(["status": "received"])
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        let mentorMsg = applicationContext["mentorMessage"] as? String
        let character = applicationContext["mentorCharacter"] as? String

        Task {
            await engine?.handleReceivedData(mentorMsg: mentorMsg, character: character)
        }
    }
}

// MARK: - Data Model
struct WatchData: Sendable {
    let mentorMessage: String
    let mentorCharacter: String
    let connectionStatus: String
}
