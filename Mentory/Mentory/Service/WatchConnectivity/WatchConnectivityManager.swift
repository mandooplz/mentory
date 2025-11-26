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
@MainActor
final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    // MARK: - Published Properties
    @Published var isPaired: Bool = false
    @Published var isWatchAppInstalled: Bool = false
    @Published var isReachable: Bool = false

    // MARK: - Private Properties
    private let session: WCSession
    private var todayString: String = ""

    // MARK: - Initialization
    private override init() {
        self.session = WCSession.default
        super.init()

        if WCSession.isSupported() {
            session.delegate = self
            self.session.activate()
        }
    }

    // MARK: - Public Methods

    /// 오늘의 명언을 설정하고 Watch로 전송
    func updateTodayString(_ string: String) {
        self.todayString = string
        self.sendDataToWatch()
    }

    // MARK: - Private Methods

    /// Watch로 데이터 전송 (Application Context 사용 - 백그라운드에서도 동작)
    private func sendDataToWatch() {
        guard session.activationState == .activated else {
            print("WCSession이 활성화되지 않음")
            return
        }

        let context: [String: Any] = [
            "todayString": todayString,
            "timestamp": Date().timeIntervalSince1970
        ]

        do {
            try session.updateApplicationContext(context)
            print("Watch로 데이터 전송 성공")
        } catch {
            print("Watch로 데이터 전송 실패: \(error.localizedDescription)")
        }
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityManager: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        let isPaired = session.isPaired
        let isWatchAppInstalled = session.isWatchAppInstalled
        let isReachable = session.isReachable
        let errorDescription = error?.localizedDescription

        Task { @MainActor in
            self.isPaired = isPaired
            self.isWatchAppInstalled = isWatchAppInstalled
            self.isReachable = isReachable

            if let errorDesc = errorDescription {
                print("WCSession 활성화 오류: \(errorDesc)")
            } else {
                print("WCSession 활성화 완료")
                self.sendDataToWatch()
            }
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
    }

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        let isReachable = session.isReachable
        Task { @MainActor in
            self.isReachable = isReachable
        }
    }

    /// Watch로부터 메시지를 받고 응답해야 할 때
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if message["request"] as? String == "initialData" {
            let reply: [String: Any] = [
                "todayString": self.todayString
            ]
            replyHandler(reply)
        } else {
            replyHandler(["status": "received"])
        }
    }
}
