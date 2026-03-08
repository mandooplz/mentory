//
//  MentoryWatchApp.swift
//  MentoryWatchApp
//
//  Created by 구현모 on 11/19/25.
//

import SwiftUI

@main
struct MentoryWatchApp: App {
    // MARK: core
    @State private var watchConnectivity = WatchConnectManager.shared


    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(watchConnectivity)
                .task {
                    watchConnectivity.setUp()
                }
        }
    }
}
