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
    
    
    // MARK: action
    
    
    // MARK: value
}
