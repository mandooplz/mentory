//
//  MentoryiOS.swift
//  Mentory
//
//  Created by 김민우 on 11/13/25.
//
import Foundation
import Combine
import OSLog


// MARK: Object
@MainActor
final class MentoryiOS: Sendable, ObservableObject {
    // MARK: core
    init() { }
    
    private let userNameDefaultsKey = "mentory.userName"
    
    // MARK: state
    nonisolated let id: UUID = UUID()
    nonisolated let logger = Logger(subsystem: "MentoryiOS", category: "Domain")
    
    @Published var userName: String? = nil {
        didSet {
            // userName이 변경될 때마다 UserDefaults에 저장
            if let name = userName {
                UserDefaults.standard.set(name, forKey: userNameDefaultsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: userNameDefaultsKey)
            }
        }
    }
    @Published var onboardingFinished: Bool = false
    
    @Published var onboarding: Onboarding? = nil
    @Published var todayBoard: TodayBoard? = nil
    
    
    // MARK: action
    func setUp() {
        loadUserName()
        
        if userName != nil {
            return
        }
        
        guard onboarding == nil else {
            logger.error("Onboarding 객체가 이미 존재합니다.")
            return
        }
        self.onboarding = Onboarding(owner: self)
    }
    
    
    func loadUserName() {
        
        if let savedName = UserDefaults.standard.string(forKey: userNameDefaultsKey) {
            self.userName = savedName
            self.onboardingFinished = true
            
            if self.todayBoard == nil {
                let todayBoard = TodayBoard(owner: self)
                self.todayBoard = todayBoard
                todayBoard.recordForm = RecordForm(owner: todayBoard)
            }
        } else {
            self.onboardingFinished = false
        }
    }
}
