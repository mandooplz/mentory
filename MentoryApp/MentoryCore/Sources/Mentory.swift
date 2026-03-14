//
//  Mentory.swift
//  Mentory
//
//  Created by 김민우 on 11/13/25.
//
import Foundation
import OSLog
import Values
import Combine
import iOSReminder
import NewMentoryDBCore
import NewMentoryDBFake
import NewFirebaseLLM
import NewFirebaseLLMFake


// MARK: object
@MainActor
public final class Mentory: Sendable, ObservableObject {
    // MARK: core
    private nonisolated let logger = Logger()
    internal nonisolated let newMentoryDB: any NewMentoryDBInterface
    internal nonisolated let newFirebaseLLM: any NewFirebaseLLMInterface

    public init(_ mode: SystemMode = .test) {
        switch mode {
        case .real:
            do {
                try NewMentoryDBConfig.default.createOnce()
            } catch {
                logger.fault("\(error)")
            }
            
            self.newFirebaseLLM = NewFirebaseLLM()
            self.newMentoryDB = NewMentoryDB(id: NewMentoryDBConfig.default.rootID)
        case .test:
            self.newFirebaseLLM = NewFirebaseLLMFake()
            self.newMentoryDB = NewMentoryDBFake()
        }
    }

    // MARK: state
    public nonisolated let infoURL = URL.info

    @Published public var userName: String? = nil
    public var greetingText: String {
        guard let userName else {
            return "오늘도 천천히 살펴볼까요?"
        }

        return "\(userName)님, 오늘도 반가워요."
    }

    @Published public var onboarding: Onboarding? = nil
    @Published public var isOnboardingFinished: Bool = false

    @Published public var todayBoard: TodayBoard? = nil
    @Published public var settingBoard: SettingBoard? = nil
    @Published public var statBoard: StatBoard? = nil

    
    // MARK: action
    public func setUp() {
        // capture
        guard isOnboardingFinished == false else {
            logger.error("setUp 중단: isOnboardingFinished == true 상태입니다. 이미 온보딩이 완료되었으므로 onboarding을 다시 생성하지 않습니다.")
            return
        }
        guard userName == nil else {
            logger.error("setUp 중단: userName이 이미 설정되어 있습니다. 온보딩이 필요한 초기 상태가 아니므로 onboarding을 생성하지 않습니다.")
            return
        }
        guard onboarding == nil else {
            logger.error("setUp 중단: onboarding 객체가 이미 존재합니다. 중복 생성을 방지하기 위해 기존 onboarding을 유지합니다.")
            return
        }

        // mutate
        self.onboarding = Onboarding(owner: self)
    }

    public func loadUserName() async {
        // capture
        let newMentoryDB = self.newMentoryDB

        // process
        guard let userNameFromDB = await newMentoryDB.name else {
            logger.error("loadUserName 실패: NewMentoryDB에 저장된 userName이 없습니다. userName, todayBoard, settingBoard, statBoard를 초기화하지 않고 종료합니다.")
            return
        }

        // mutate
        self.userName = userNameFromDB
        self.isOnboardingFinished = true

        self.todayBoard = TodayBoard(owner: self)
        self.settingBoard = SettingBoard(owner: self)
        self.statBoard = StatBoard(owner: self)
    }
    public func saveUserName() async {
        // capture
        guard let userName else {
            logger.error("saveUserName 실패: Mentory의 userName이 nil입니다. 저장할 사용자 이름이 없어 NewMentoryDB에 반영하지 않습니다.")
            return
        }

        let newMentoryDB = self.newMentoryDB

        // process
        await newMentoryDB.setName(userName)
    }

    
    // MARK: value
    public struct URL: Sendable, Hashable {
        // MARK: core
        public let rawValue: Foundation.URL
        
        private init(rawValue: Foundation.URL) {
            self.rawValue = rawValue
        }

        public static let info: Self = .init(
            rawValue: Foundation.URL(
                string:
                    "https://nice-asp-f94.notion.site/Mentory-Information-2b11c49e815f80c5873befe3b6847f70?source=copy_link"
            )!)
    }
}
