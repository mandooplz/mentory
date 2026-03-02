//
//  MentoryApp.swift
//  Mentory
//
//  Created by 김민우 on 11/11/25.
//
import SwiftUI
import SwiftData
import Values
import MentoryCore
import WatchManager


// MARK: App
@main
struct MentoryApp: App {
    // MARK: model
    @State var mentory = Mentory(.test)
    

    // MARK: body
    var body: some Scene {
        WindowGroup {
            MentoryiOSView(mentory)
        }
    }
}
