//
//  WatchConnectivityManager.swift
//  Mentory
//
//  Created by 구현모 on 11/26/25.
//

import Foundation
import WatchConnectivity
import Combine

/// iOS 앱에서 Watch 앱과 통신하기 위한 매니저
final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    // MARK: - Published Properties
    @Published var isPaired: Bool = false
    @Published var isWatchAppInstalled: Bool = false
    @Published var isReachable: Bool = false
    @Published var lastReceivedVoiceData: Data?
    @Published var lastReceivedActionUpdate: (actionId: String, isCompleted: Bool)?

    // MARK: - Private Properties
    private let session: WCSession
    private var todayString: String = ""
    private var actionItem: [ActionItem] = []

    // MARK: - Initialization
    private override init() {
        self.session = WCSession.default
        super.init()

        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    // MARK: - Public Methods

    /// 오늘의 명언을 설정하고 Watch로 전송
    func updateTodayString(_ string: String) {
        self.todayString = string
        sendDataToWatch()
    }

    /// 행동 추천 목록을 설정하고 Watch로 전송
    func updateActionItem(_ actions: [ActionItem]) {
        self.actionItem = actions
        sendDataToWatch()
    }

    /// Watch로 데이터 전송 (Application Context 사용 - 백그라운드에서도 동작)
    func sendDataToWatch() {
        guard session.activationState == .activated else {
            print("WCSession이 활성화되지 않음")
            return
        }

        let actionsData = actionItem.map { action in
            [
                "id": action.id,
                "text": action.text,
                "isCompleted": action.isCompleted
            ] as [String : Any]
        }

        let context: [String: Any] = [
            "todayString": todayString,
            "actionRecommendations": actionsData,
            "timestamp": Date().timeIntervalSince1970
        ]

        do {
            try session.updateApplicationContext(context)
            print("Watch로 데이터 전송 성공")
        } catch {
            print("Watch로 데이터 전송 실패: \(error.localizedDescription)")
        }
    }

    /// Watch로 즉시 메시지 전송 (Watch가 연결되어 있을 때만 사용)
    func sendMessageToWatch(_ message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        guard session.isReachable else {
            print("Watch가 연결되어 있지 않음")
            return
        }

        session.sendMessage(message, replyHandler: replyHandler) { error in
            print("메시지 전송 실패: \(error.localizedDescription)")
        }
    }

    /// 음성 녹음 데이터 처리 (Watch로부터 받은 데이터)
    func handleVoiceRecording(_ audioData: Data, duration: TimeInterval) {
        self.lastReceivedVoiceData = audioData
        // TODO: 음성 데이터를 파일로 저장하거나 처리
        print("음성 녹음 수신: \(duration)초, \(audioData.count) bytes")
    }

    /// 행동 완료 상태 업데이트 처리
    func handleActionCompletion(actionId: String, isCompleted: Bool) {
        self.lastReceivedActionUpdate = (actionId, isCompleted)
        // TODO: 행동 완료 상태를 데이터베이스에 저장
        print("행동 상태 업데이트: \(actionId) - \(isCompleted)")
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isPaired = session.isPaired
            self.isWatchAppInstalled = session.isWatchAppInstalled
            self.isReachable = session.isReachable

            if let error = error {
                print("WCSession 활성화 오류: \(error.localizedDescription)")
            } else {
                print("WCSession 활성화 완료")
                // 활성화되면 데이터 전송
                self.sendDataToWatch()
            }
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession이 비활성화됨")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession이 비활성화되었습니다. 다시 활성화합니다.")
        session.activate()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            print("Watch 연결 상태 변경: \(session.isReachable ? "연결됨" : "연결 끊김")")
        }
    }

    /// Watch로부터 메시지를 받았을 때
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.handleReceivedMessage(message)
        }
    }

    /// Watch로부터 메시지를 받고 응답해야 할 때
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            self.handleReceivedMessage(message)

            // Watch에 초기 데이터 전송
            if message["request"] as? String == "initialData" {
                let actionsData = self.actionItem.map { action in
                    [
                        "id": action.id,
                        "text": action.text,
                        "isCompleted": action.isCompleted
                    ] as [String : Any]
                }

                let reply: [String: Any] = [
                    "todayString": self.todayString,
                    "actionRecommendations": actionsData
                ]
                replyHandler(reply)
            } else {
                replyHandler(["status": "received"])
            }
        }
    }

    /// Watch로부터 데이터를 받았을 때
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        DispatchQueue.main.async {
            // 음성 녹음 데이터로 가정
            self.handleVoiceRecording(messageData, duration: 0)
            replyHandler(Data())
        }
    }

    // MARK: - Private Methods

    private func handleReceivedMessage(_ message: [String: Any]) {
        guard let type = message["type"] as? String else { return }

        switch type {
        case "voiceRecording":
            if let duration = message["duration"] as? TimeInterval {
                // 실제 음성 데이터는 didReceiveMessageData에서 처리
                print("음성 녹음 메타데이터 수신: \(duration)초")
            }

        case "actionCompletion":
            if let actionId = message["actionId"] as? String,
               let isCompleted = message["isCompleted"] as? Bool {
                handleActionCompletion(actionId: actionId, isCompleted: isCompleted)
            }

        default:
            print("알 수 없는 메시지 타입: \(type)")
        }
    }
}

// MARK: - ActionItem Model
struct ActionItem: Identifiable, Codable {
    let id: String
    var text: String
    var isCompleted: Bool

    init(id: String = UUID().uuidString, text: String, isCompleted: Bool) {
        self.id = id
        self.text = text
        self.isCompleted = isCompleted
    }
}
