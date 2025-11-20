//
//  Microphone.swift
//  Mentory
//
//  Created by 김민우 on 11/20/25.
//
import Foundation
import OSLog


// MARK: Object
@MainActor @Observable
final class Microphone: Sendable {
    // MARK: core
    static let shared = Microphone()
    private init() { }
    
    
    // MARK: state
    private nonisolated let logger = Logger(subsystem: "MentoryiOS.Microphone", category: "Presentation")
    var isSetUp: Bool = false
    
    private(set) var isRecording: Bool = false
    private(set) var audioURL: URL? = nil
    var recordingTime: TimeInterval = 0
    
    private(set) var recognizedTest: String? = nil
    
    
    // MARK: action
    func setUp() {
        // capture
        
    }
    
    func startRecording() {
        
    }
    
    
    // MARK: value
}
