//
//  SettingBoard.swift
//  Mentory
//
//  Created by SJS on 11/17/25.
//

import Foundation
import Combine
import OSLog

// MARK: Object
@MainActor
final class SettingBoard: Sendable, ObservableObject {
    
    // MARK: core
    init(owner: MentoryiOS) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let owner: MentoryiOS
    nonisolated let id = UUID()
    nonisolated private let logger = Logger(
        subsystem: "MentoryiOS.SettingBoard",
        category: "Domain"
    )
    
    /// 알림 사용 여부 (예: 감정 기록 리마인드)
    @Published var isReminderOn: Bool = true
    
    /// 알림 시간 (예: 저녁 9시)
    @Published var reminderTime: Date = .now
    
    /// 앱 테마 (예시: T / F 테마)
    enum AppTheme: String, CaseIterable, Sendable {
        case tTheme
        case fTheme
    }
    
    @Published var selectedTheme: AppTheme = .tTheme
    
    
    // MARK: value
    
    /// "반가워요, 지석님!" 같은 인사 문구
    var greetingText: String {
        let name = owner.userName ?? "사용자"
        return "반가워요, \(name)님!"
    }
    
    
    // MARK: action
    
    /// 리마인드 알림 on/off 토글
    func toggleReminder() {
        isReminderOn.toggle()
        logger.info("Reminder toggled: \(self.isReminderOn)")
    }
    
    /// 리마인드 알림 시간 변경
    func updateReminderTime(_ newTime: Date) {
        reminderTime = newTime
        logger.info("Reminder time updated: \(String(describing: newTime))")
    }
    
    /// 앱 테마 변경
    func updateTheme(_ theme: AppTheme) {
        selectedTheme = theme
        logger.info("App theme changed: \(theme.rawValue)")
    }
}
