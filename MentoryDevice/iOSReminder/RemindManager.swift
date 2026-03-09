//
//  RemindManager.swift
//  iOSReminder
//
//  Created by 김민우 on 3/10/26.
//

import Foundation
import UserNotifications
import OSLog


// MARK: object
public actor RemindManager: RemindManagerInterface {
    // MARK: core
    private let logger = Logger()
    
    
    // MARK: state
    private let notificationCenter: UNUserNotificationCenter = .current()
    
    public private(set) var authStatus: UNAuthorizationStatus? = nil
    
    
    // MARK: action
    public func updateAuthStatus() async {
        // capture
        let notificationCenter = self.notificationCenter
        
        
        // process
        let notificationSettings = await notificationCenter.notificationSettings()
        let authStatus = notificationSettings.authorizationStatus
        
        
        // mutate
        self.authStatus = authStatus
    }
    
    public func requestAuthorization() async {
        // capture
        let notificationCenter = self.notificationCenter
        
        
        // process
        let currentSettings = await notificationCenter.notificationSettings()
        let currentAuthStatus = currentSettings.authorizationStatus
        
        switch currentAuthStatus {
        case .notDetermined:
            do {
                let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
                
                if granted {
                    logger.info("알림 권한이 허용되었습니다.")
                } else {
                    logger.error("알림 권한이 거부되었습니다.")
                }
            } catch {
                logger.error("알림 권한 요청 중 오류 발생: \(String(describing: error), privacy: .public)")
            }
            
        case .denied:
            logger.error("알림 권한이 시스템 설정에서 거부된 상태입니다.")
            
        case .authorized, .provisional, .ephemeral:
            logger.debug("알림 권한이 이미 허용된 상태입니다.")
            
        @unknown default:
            logger.error("알 수 없는 알림 권한 상태입니다.")
        }
        
        let updatedSettings = await notificationCenter.notificationSettings()
        let updatedAuthStatus = updatedSettings.authorizationStatus
        
        
        // mutate
        self.authStatus = updatedAuthStatus
    }
}
