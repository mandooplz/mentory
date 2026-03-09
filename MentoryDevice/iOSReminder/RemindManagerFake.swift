//
//  RemindManagerFake.swift
//  iOSReminder
//
//  Created by 김민우 on 3/10/26.
//

import Foundation
import OSLog


// MARK: fake
public actor RemindManagerFake: RemindManagerInterface {
    // MARK: core
    private let logger = Logger()
    
    public init() { }


    // MARK: state
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


        // process
        let authStatus = self.authStatus


        // mutate
        self.authStatus = authStatus == .idle ? .notDetermined : authStatus
    }

    public func requestAuthorization() async {
        // capture
        let currentAuthStatus = self.authStatus


        // process
        let updatedAuthStatus: ReminderAuthStatus

        switch currentAuthStatus {
        case .idle, .notDetermined:
            updatedAuthStatus = .authorized

        case .denied:
            logger.error("알림 권한이 거부된 상태입니다.")
            updatedAuthStatus = .denied

        case .authorized, .provisional, .ephemeral:
            logger.debug("알림 권한이 이미 허용된 상태입니다.")
            updatedAuthStatus = currentAuthStatus

        case .unknown:
            logger.error("알 수 없는 알림 권한 상태입니다.")
            updatedAuthStatus = .unknown
        }


        // mutate
        self.authStatus = updatedAuthStatus
    }

    public func scheduleReminder() async {
        // capture
        guard let reservation else {
            logger.error("예약된 알림이 없습니다. 먼저 reservation 프로퍼티에 값을 설정해주세요")
            return
        }


        // process
        let updatedReservations = self.pendingReservations + [reservation]


        // mutate
        self.pendingReservations = updatedReservations
    }

    public func cancelAllReminder() async {
        // capture


        // process


        // mutate
        self.pendingReservations = []
    }

    public func loadPendingNotifications() async {
        // capture
        let pendingReservations = self.pendingReservations


        // process
        let loadedReservations = pendingReservations


        // mutate
        self.pendingReservations = loadedReservations
    }
}


internal extension RemindManagerFake {
    func setAuthStatus(_ authStatus: ReminderAuthStatus) async {
        self.authStatus = authStatus
    }

    func clearReservation() async {
        self.reservation = nil
    }

    func setPendingReservations(_ reservations: [ReminderReservationInfo]) async {
        self.pendingReservations = reservations
    }
}
