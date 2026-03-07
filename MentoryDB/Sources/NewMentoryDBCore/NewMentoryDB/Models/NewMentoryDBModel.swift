//
//  NewMentoryDBModel.swift
//  MentoryDB
//
//  Created by 김민우 on 3/7/26.
//

import Foundation
import SwiftData
import Values
import OSLog


@Model
final class NewMentoryDBModel {
    // MARK: core
    @Attribute(.unique) var id: UUID

    var userName: String? = nil
    var userCharacter: MentoryCharacter? = nil

    var messageCreatedAt: Date? = nil
    var messageContent: String? = nil
    var messageCharacter: MentoryCharacter? = nil

    @Relationship var recordCreationQueue: [NewRecordTicket] = []
    @Relationship var records: [NewDailyRecordModel] = []

    init(id: UUID, userName: String? = nil) {
        self.id = id
        self.userName = userName
    }
}

extension NewMentoryDBModel {

}
