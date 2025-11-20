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
        loadSavedReminderTime()
    }
    
    
    // MARK: state
    weak var owner: MentoryiOS?
    nonisolated let id = UUID()
    nonisolated private let logger = Logger(
        subsystem: "MentoryiOS.SettingBoard",
        category: "Domain"
    )
    
    private static let reminderTimeKey = "mentory.settingBoard.reminderTime"
    private var isApplyingSavedReminderTime = false
    
    /// 알림 사용 여부 (알림 설정 토글)
    @Published var isReminderOn: Bool = true
    
    /// 알림 시간 (알림 시간 표시 + DatePicker)
    @Published var reminderTime: Date = .now {
        didSet {
            guard reminderTime != oldValue else { return }
            guard isApplyingSavedReminderTime == false else { return }
            persistReminderTime()
        }
    }
    
    // 화면 클릭
    @Published var isShowingPrivacyPolicy: Bool = false
    @Published var isShowingLicenseInfo: Bool = false
    @Published var editingName: String = ""
    
    // MARK: value
    
    
    // MARK: action
    
    /// 알림 on/off 토글 액션
    func toggleReminder() {
        isReminderOn.toggle()
        logger.info("Reminder toggled: \(self.isReminderOn)")
    }
    
    /// 알림 시간 변경 액션
    func updateReminderTime(_ newTime: Date) {
        reminderTime = newTime
        logger.info("Reminder time updated: \(String(describing: newTime))")
    }
    
    func showPrivacyPolicy() {
        isShowingPrivacyPolicy = true
    }
    
    func showLicenseInfo() {
        isShowingLicenseInfo = true
    }
    
    func startRenaming() {
        editingName = owner?.userName ?? ""
    }
    
    func cancelRenaming() {
        editingName = ""
    }
    
    func commitRename() async {
        let trimmedName = editingName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.isEmpty == false else {
            logger.error("입력된 이름이 비어 있어 저장을 건너뜁니다.")
            return
        }
        
        guard let owner else {
            logger.error("owner가 존재하지 않아 이름을 저장할 수 없습니다.")
            return
        }
        
        owner.userName = trimmedName
        await owner.saveUserName()
        editingName = ""
        logger.info("사용자 이름이 \(trimmedName, privacy: .public)로 변경되었습니다.")
    }
    
    // 데이터 삭제 버튼 탭 처리 (확인 Alert 노출)
    func requestDataDeletion() {
        logger.info("데이터 삭제 확인 Alert를 노출합니다.")
    }
    
    func cancelDataDeletion() {
        logger.info("데이터 삭제가 취소되었습니다.")
    }
    
    func confirmDataDeletion() {
        logger.info("데이터 삭제를 진행합니다. 실제 삭제 로직은 추후 구현 예정")
        // TODO: 추후 담당자가 삭제 로직 구현
    }
    
    // MARK: private
    private func loadSavedReminderTime() {
        guard let savedTime = UserDefaults.standard.object(forKey: Self.reminderTimeKey) as? Date else {
            logger.info("Saved reminder time not found. Keep default: \(String(describing: self.reminderTime))")
            return
        }
        isApplyingSavedReminderTime = true
        reminderTime = savedTime
        isApplyingSavedReminderTime = false
    }
    
    private func persistReminderTime() {
        UserDefaults.standard.set(reminderTime, forKey: Self.reminderTimeKey)
        logger.info("Reminder time persisted: \(String(describing: self.reminderTime))")
    }
}
