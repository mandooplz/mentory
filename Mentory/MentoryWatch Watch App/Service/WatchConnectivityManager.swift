//
//  WatchConnectivityManager.swift
//  MentoryWatch Watch App
//
//  Created by 구현모 on 11/26/25.
//

import Foundation
import Combine

/// WatchOS에서 iOS 앱과 통신하기 위한 매니저
@MainActor
final class WatchConnectivityManager: ObservableObject {
    // MARK: - Core
    static let shared = WatchConnectivityManager()

    // MARK: - State
    @Published var mentorMessage: String = "멘토 메시지를 불러오는 중..."
    @Published var mentorCharacter: String = ""
    @Published var connectionStatus: String = "연결 대기 중"

    private var engine: WatchConnectivityEngine? = nil

    // MARK: - Initialization
    private init() { }

    // MARK: - Public Methods

    /// 엔진 설정 및 활성화
    func setUp() async {
        // capture
        guard engine == nil else {
            return
        }

        // process
        let engine = WatchConnectivityEngine.shared
        await engine.setDataUpdateHandler { [weak self] data in
            Task { @MainActor in
                self?.mentorMessage = data.mentorMessage
                self?.mentorCharacter = data.mentorCharacter
                self?.connectionStatus = data.connectionStatus
            }
        }
        await engine.activate()

        // mutate
        self.engine = engine
    }

    /// iOS 앱에서 보낸 데이터 로드
    func loadInitialData() {
        engine?.loadInitialDataFromContext()
    }
}
