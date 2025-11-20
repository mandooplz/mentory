//
//  AudioEngine.swift
//  Mentory
//
//  Created by 김민우 on 11/20/25.
//
import Foundation
import OSLog
import AVFoundation
import Speech


// MARK: Object
actor AudioEngine {
    // MARK: core
    static let shared = AudioEngine()
    
    
    // MARK: state
    private nonisolated let logger = Logger(subsystem: "MentoryiOS.AudioEngine", category: "Presentation")
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    private let audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    private var timer: Timer?
    
    var isSessionRunning: Bool = false
    
    
    // MARK: action
    func startSession() {
        // capture
        guard isSessionRunning == false else {
            logger.error("이미 세션이 실행 중입니다.")
            return
        }
        
        // process
        do {
            let session = AVAudioSession.sharedInstance()
            
            try session.setCategory(.playAndRecord,
                                    mode: .measurement,
                                    options: [.duckOthers, .defaultToSpeaker])
            
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            logger.error("\(error)")
            return
        }
        
        // mutate
        logger.debug("AudioEngine 세션 시작")
        self.isSessionRunning = true
    }
    
    func startEngineAndRecognition() {
        
    }
    
    
    // MARK: value
}
