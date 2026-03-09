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
    
    public init() { }
    
    
    // MARK: state
    private let notificationCenter: UNUserNotificationCenter = .current()
    
    public private(set) var authStatus: ReminderAuthStatus = .idle
    
    private var reservation: ReminderReservationInfo?
    public func setReservation(_ reservation: ReminderReservationInfo) {
        if self.reservation == nil {
            self.reservation = reservation
        } else {
            logger.error("이미 reservation이 존재합니다.")
        }
    }
    
    public private(set) var pendingReservations: [ReminderReservationInfo] = []
    
    
    
    // MARK: action
    public func updateAuthStatus() async {
        // capture
        let notificationCenter = self.notificationCenter
        
        
        // process
        let notificationSettings = await notificationCenter.notificationSettings()
        let authStatus = notificationSettings.authorizationStatus
        
        
        // mutate
        self.authStatus = .init(authStatus)
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
        self.authStatus = .init(updatedAuthStatus)
    }
    
    public func scheduleReminder() async {
        // capture
        guard let reservation else {
            logger.error("예약된 알림이 없습니다. 먼저 reservation 프로퍼티에 값을 설정해주세요")
            return
        }
        
        // process
        let request = reservation.makeRequest()
        
        do {
            try await notificationCenter.add(request)
            logger.info("리마인더 알림 등록 완료: \(request.identifier, privacy: .public)")
        } catch {
            logger.error("리마인더 알림 등록 실패: \(String(describing: error), privacy: .public)")
        }
    }
    public func cancelAllReminder() async {
        // capture
        let center = self.notificationCenter


        // process
        center.removeAllPendingNotificationRequests()
        
        logger.info("모든 리마인더 알림을 취소했습니다.")
        
        // mutate
        self.pendingReservations = []
    }
    
    public func loadPendingNotifications() async {
        // capture
        let center = self.notificationCenter

        // process
        let requests = await center.pendingNotificationRequests() // 예약된 알림
        let reservations = requests.compactMap(ReminderReservationInfo.init)
        
        // mutate
        self.pendingReservations = reservations
    }
}


// MARK: value
public enum ReminderAuthStatus: Sendable, Hashable {
    case idle
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral
    case unknown
    
    fileprivate init(_ rawValue: UNAuthorizationStatus) {
        switch rawValue {
        case .notDetermined:
            self = .notDetermined
        case .denied:
            self = .denied
        case .authorized:
            self = .authorized
        case .provisional:
            self = .provisional
        case .ephemeral:
            self = .ephemeral
        @unknown default:
            self = .unknown
        }
    }
}

public struct ReminderReservationInfo: Sendable, Hashable {
    // MARK: core
    public let identifier: String
    public let title: String
    public let body: String
    public let trigger: Trigger

    public init(
        identifier: String,
        title: String,
        body: String,
        trigger: Trigger
    ) {
        self.identifier = identifier
        self.title = title
        self.body = body
        self.trigger = trigger
    }
    
    public static func afterOneWeek(
        baseDate: Date,
        reminderTime: Date,
        title: String,
        body: String,
        calendar: Calendar = .current,
        identifier: String = UUID().uuidString
    ) -> Self? {
        guard let plus7Date = calendar.date(byAdding: .day, value: 7, to: baseDate) else {
            return nil
        }

        let timeComponents = calendar.dateComponents([.hour, .minute], from: reminderTime)

        var triggerComponents = calendar.dateComponents([.year, .month, .day], from: plus7Date)
        triggerComponents.hour = timeComponents.hour
        triggerComponents.minute = timeComponents.minute

        return Self(
            identifier: identifier,
            title: title,
            body: body,
            trigger: .calendar(
                dateComponents: triggerComponents,
                repeats: false
            )
        )
    }
    
    fileprivate init?(request: UNNotificationRequest) {
        let trigger: Trigger

        if let calendarTrigger = request.trigger as? UNCalendarNotificationTrigger {
            trigger = .calendar(
                dateComponents: calendarTrigger.dateComponents,
                repeats: calendarTrigger.repeats
            )
        } else {
            return nil
        }

        self.init(
            identifier: request.identifier,
            title: request.content.title,
            body: request.content.body,
            trigger: trigger
        )
    }
}

public extension ReminderReservationInfo {
    enum Trigger: Sendable, Hashable {
        case calendar(
            dateComponents: DateComponents,
            repeats: Bool
        )
    }

    fileprivate func makeRequest() -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = self.title
        content.body = self.body
        content.sound = .default

        let notificationTrigger: UNNotificationTrigger

        switch self.trigger {
        case let .calendar(dateComponents, repeats):
            notificationTrigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: repeats
            )
        }

        return UNNotificationRequest(
            identifier: self.identifier,
            content: content,
            trigger: notificationTrigger
        )
    }
}




