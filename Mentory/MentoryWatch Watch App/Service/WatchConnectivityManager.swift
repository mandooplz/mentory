//
//  WatchConnectivityManager.swift
//  MentoryWatch Watch App
//
//  Created by 구현모 on 11/26/25.
//

import Foundation
import WatchConnectivity
import Combine

// WatchOS에서 iOS 앱과 통신하기 위한 매니저
final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var todayString: String = "명언을 불러오는 중..."
    @Published var actionItem: [ActionItem] = []
    @Published var connectionStatus: String = "연결 대기 중"

    private let session: WCSession

    private override init() {
        self.session = WCSession.default
        super.init()

        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    // MARK: - Public Methods

    // iOS 앱에 데이터 요청
    func requestDataFromPhone() {
        guard session.isReachable else {
            connectionStatus = "iPhone과 연결되지 않음"
            return
        }

        let message = ["request": "initialData"]
        session.sendMessage(message, replyHandler: { reply in
            DispatchQueue.main.async {
                self.handleReceivedData(reply)
            }
        }) { error in
            DispatchQueue.main.async {
                self.connectionStatus = "데이터 요청 실패: \(error.localizedDescription)"
            }
        }
    }

    // 음성 녹음 데이터를 iOS 앱으로 전송
    func sendVoiceRecording(_ audioData: Data, duration: TimeInterval) {
        guard session.isReachable else {
            print("iPhone과 연결되지 않음")
            return
        }

        let message: [String: Any] = [
            "type": "voiceRecording",
            "duration": duration,
            "timestamp": Date().timeIntervalSince1970
        ]

        session.sendMessageData(audioData, replyHandler: { replyData in
            print("음성 녹음 전송 성공")
        }) { error in
            print("음성 녹음 전송 실패: \(error.localizedDescription)")
        }
    }

    // 행동 완료 상태를 iOS 앱으로 전송
    func sendActionCompletion(_ actionId: String, isCompleted: Bool) {
        guard session.isReachable else {
            print("iPhone과 연결되지 않음")
            return
        }

        let message: [String: Any] = [
            "type": "actionCompletion",
            "actionId": actionId,
            "isCompleted": isCompleted,
            "timestamp": Date().timeIntervalSince1970
        ]

        session.sendMessage(message, replyHandler: nil) { error in
            print("행동 완료 상태 전송 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - Private Methods

    private func handleReceivedData(_ data: [String: Any]) {
        if let quote = data["todayString"] as? String {
            self.todayString = quote
        }

        if let actionsData = data["actionRecommendations"] as? [[String: Any]] {
            self.actionItem = actionsData.compactMap { dict in
                guard let id = dict["id"] as? String,
                      let text = dict["text"] as? String,
                      let isCompleted = dict["isCompleted"] as? Bool else {
                    return nil
                }
                return ActionItem(id: id, text: text, isCompleted: isCompleted)
            }
        }

        connectionStatus = "연결됨"
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            switch activationState {
            case .activated:
                self.connectionStatus = "활성화됨"
                // 활성화되면 자동으로 데이터 요청
                self.requestDataFromPhone()
            case .inactive:
                self.connectionStatus = "비활성화됨"
            case .notActivated:
                self.connectionStatus = "활성화 안됨"
            @unknown default:
                self.connectionStatus = "알 수 없는 상태"
            }

            if let error = error {
                self.connectionStatus = "오류: \(error.localizedDescription)"
            }
        }
    }

    // iPhone으로부터 메시지를 받았을 때
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.handleReceivedData(message)
        }
    }

    // iPhone으로부터 메시지를 받고 응답해야 할 때
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            self.handleReceivedData(message)
            replyHandler(["status": "received"])
        }
    }

    // Application Context가 업데이트되었을 때
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            self.handleReceivedData(applicationContext)
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
