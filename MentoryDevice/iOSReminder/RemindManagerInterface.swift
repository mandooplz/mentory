//
//  RemindManagerInterface.swift
//  iOSReminder
//
//  Created by 김민우 on 3/10/26.
//


import Foundation
import UserNotifications
import OSLog

public protocol RemindManagerInterface: Sendable {
    // MARK: state
    var authStatus: ReminderAuthStatus { get async }
    
    func setReservation(_: ReminderReservationInfo) async
    
    var pendingReservations: [ReminderReservationInfo] { get async }
    
    // MARK: action
    func updateAuthStatus() async
    func requestAuthorization() async
    
    func scheduleReminder() async
    func cancelAllReminder() async
    
    func loadPendingNotifications() async
}
