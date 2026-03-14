//
//  MentorMessage.swift
//  Mentory
//
//  Created by 김민우 on 12/2/25.
//

import Combine
import NewFirebaseLLM
import Foundation
import OSLog
import Values

// MARK: Object
@MainActor
public final class MentorMessage: Sendable, ObservableObject {
    // MARK: core
    nonisolated private let logger = Logger()

    public init(owner: TodayBoard) {
        self.owner = owner
    }

    // MARK: state
    public nonisolated let id = UUID()
    public weak var owner: TodayBoard?

    public var recentUpdate: MentoryDate? = nil

    @Published public internal(set) var content: String? = nil
    public func resetContent() {
        self.content = nil
    }

    @Published public internal(set) var character: MentoryCharacter? = nil
    public func setCharacterOnce(to newCharacter: MentoryCharacter) {
        if self.character != nil {
            return
        } else {
            self.character = newCharacter
        }
    }


    // MARK: action
    public func updateContent() async {
        // capture
        let todayBoard = self.owner!

        let currentDate = todayBoard.currentDate
        logger.debug("currentDate is \(currentDate.rawValue)")

        if let recentUpdate,
          recentUpdate.isSameDate(as: currentDate)
        {
            logger.error("\(Date.now) 날짜의 MentorMessage가 이미 존재합니다.")
            return
        }

        guard let character else {
            logger.error("현재 MentorMessage의 Character가 설정되어 있지 않습니다. 먼저 Character를 설정해주세요.")
            return
        }

        let mentoryiOS = self.owner!.owner!
        let newMentoryDB = mentoryiOS.newMentoryDB
        let firebaseLLM = mentoryiOS.newFirebaseLLM

        // process
        let messageFromDB = await newMentoryDB.mentorMessage

        let messageContent: String
        let messageCharacter: MentoryCharacter

        let isMessageValid = messageFromDB?.createdAt
          .isSameDate(as: currentDate)

        if isMessageValid == true {
            // Message가 유효한 경우
            messageContent = messageFromDB!.content
            messageCharacter = messageFromDB!.characterType
        } else {
            // AlanLLM - 새로운 메시지 가져오기
            let question = FirebaseQuestion(character.question)

            await firebaseLLM.setQuestion(question)
            await firebaseLLM.getAnswer()
            
            guard let answer = await firebaseLLM.answer else {
                logger.error("FirebaseLLM의 응답이 nil입니다.")
                return
            }

            let newMessageContent = answer.content

            messageContent = newMessageContent
            messageCharacter = character

            // MentoryDB - 새로운 메시지 저장
            let newMessage = MessageData(
                createdAt: .now,
                content: messageContent,
                characterType: character)

            await newMentoryDB.setMentorMessage(newMessage)
        }

        // mutate
        self.content = messageContent
        self.character = messageCharacter
        self.recentUpdate = .now
    }
}
