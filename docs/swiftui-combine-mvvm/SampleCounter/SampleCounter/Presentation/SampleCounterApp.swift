//
//  SampleCounterApp.swift
//  SampleCounter
//
//  Created by 김민우 on 11/12/25.
//
import SwiftUI


@main
struct SampleCounterApp: App {
    let app = SampleCounter()
    
    var body: some Scene {
        WindowGroup {
            ContentView(app: app)
        }
    }
}
