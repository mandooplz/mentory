
//
//  Mentory.swift
//  Mentory
//
//  Created by 김민우 on 11/13/25.
//
import Foundation
import NewMentoryDBCore
import OSLog
import Values
import iOSReminder
import Combine
import FirebaseLLMAdapter


// MARK: object
@MainActor
public final class Mentory: Sendable, ObservableObject {
  // MARK: core
  private nonisolated let logger = Logger()
  internal nonisolated let newMentoryDB: any NewMentoryDBInterface

  internal nonisolated let firebaseLLM: any NewFirebaseLLMInterface
  internal nonisolated let reminderCenter: any ReminderNotificationInterface

  public init(_ mode: SystemMode = .test) {
    switch mode {
    case .real:
      self.firebaseLLM = NewFirebaseLLM()
      self.reminderCenter = ReminderNotificationAdapter()
    case .test:
      self.firebaseLLM = NewFirebaseLLMFake()
      self.reminderCenter = ReminderNotificationAdapter()
    }

    do {
      try NewMentoryDBConfig.default.createOnce()
    } catch {
      logger.error("\(error)")
    }

    self.newMentoryDB = NewMentoryDB(id: NewMentoryDBConfig.default.rootID)
  }

  // MARK: state
  public nonisolated let informationURL = URL.info

  @Published public var userName: String? = nil
  public func getGreetingText() -> String {
    guard let userName else {
      return "반가워요!"
    }

    return "반가워요, \(userName)님!"
  }

  @Published public var onboarding: Onboarding? = nil
  @Published public var onboardingFinished: Bool = false

  @Published public var todayBoard: TodayBoard? = nil
  @Published public var settingBoard: SettingBoard? = nil
  @Published public var statBoard: StatBoard? = nil

  // MARK: action
  public func setUp() {
    // capture
    guard onboardingFinished == false else {
      logger.error("Onboarding이 이미 완료되어 있어 종료됩니다.")
      return
    }
    guard userName == nil else {
      logger.error("MentoryiOS의 userName이 현재 nil이서 종료됩니다.")
      return
    }
    guard onboarding == nil else {
      logger.error("Onboarding 객체가 이미 존재합니다.")
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
      logger.error("현재 NewMentoryDB에 저장된 이름이 존재하지 않습니다.")
      return
    }

    // mutate
    self.userName = userNameFromDB
    self.onboardingFinished = true

    self.todayBoard = TodayBoard(owner: self)
    self.settingBoard = SettingBoard(owner: self)
    self.statBoard = StatBoard(owner: self)
  }
  public func saveUserName() async {
    // capture
    guard let userName else {
      logger.error("MentoryiOS에 userName이 존재하지 않습니다.")
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

    public static let info: Self = .init(
      rawValue: Foundation.URL(
        string:
          "https://nice-asp-f94.notion.site/Mentory-Information-2b11c49e815f80c5873befe3b6847f70?source=copy_link"
      )!)

    private init(rawValue: Foundation.URL) {
      self.rawValue = rawValue
    }
  }
}
