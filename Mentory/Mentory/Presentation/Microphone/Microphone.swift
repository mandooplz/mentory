//
//  Microphone.swift
//  Mentory
//
//  Created by 김민우 on 11/20/25.
//
import Foundation
import OSLog
import Speech
import AVFoundation


// MARK: Object
@MainActor @Observable
final class Microphone: Sendable {
    // MARK: core
    static let shared = Microphone()
    private init() { }
    
    private nonisolated let logger = Logger(subsystem: "MentoryiOS.Microphone", category: "Presentation")
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR")) // 한국어 인식을 위한 SFSpeechRecognizer(ko-KR)
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest? // 실시간 스트림으로 오디오 버퍼를 계속 append하는 객체
    private var recognitionTask: SFSpeechRecognitionTask? // 실제로 STT 수행, 콜백으로 resut나 error 전달

    private let audioEngine = AVAudioEngine() // 마이크로부터 오디오 스트림을 받아오는 엔진
    private var audioFile: AVAudioFile? // 들어오는 버터를 m4a 파일로 쓰는 객체
    private var timer: Timer? // 0.1초마다 recoringTime을 증가시키는 타이머
    
    
    // MARK: state
    private(set) var isSetUp: Bool = false
    
    private(set) var isRecording: Bool = false
    private(set) var audioURL: URL? = nil // 녹음 결과가 저장될 파일 경로
    private(set) var recordingTime: TimeInterval = 0 // 녹음 진행 시간
    private(set) var recognizedTest: String = "" // STT 결과 텍스트
    
    
    // MARK: action
    func setUp() async {
        // capture
        guard isSetUp == false else {
            logger.error("이미 Microphone이 setUp되어 있습니다.")
            return
        }
        
        // process
        let userDevice = UserDevice()
        
        let micGranted = await userDevice.getRecordPermission()
        let speechGranted = await userDevice.getSpeechPermission()
        
        
        // mutate
        guard micGranted && speechGranted else {
            logger.error("사용자의 녹음 및 음성 인식 권한이 없습니다.")
            return
        }
        
        self.isSetUp = true
    }
    
    func startSesstion() async {
        // capture
        guard isSetUp == true else {
            logger.error("Microphone이 setUp되지 않았습니다. startSession() 전에 setUp()을 먼저 실행해주세요.")
            return
        }
        
        
    }
    
    func recordAndConvertToText() {
        
    }
    
    
    // MARK: value
    nonisolated struct UserDevice: Sendable {
        private nonisolated let logger = Logger(subsystem: "MentoryiOS.Microphone.UserDevice", category: "Presentation")
        
        // Privacy - Microphone Usage Description 키가 없으면 앱이 강제 종료(Crash)됩니다.
        func getRecordPermission() async -> Bool {
            await withCheckedContinuation { continuation in
                AVAudioApplication.requestRecordPermission() { granted in
                    logger.debug("사용자의 녹음 권한은 \(granted)입니다.")
                    
                    continuation.resume(returning: granted)
                }
            }
        }
        
        // Privacy - Microphone Usage Description 키가 없으면 앱이 강제 종료(Crash)됩니다.
        func getSpeechPermission() async -> Bool {
            await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { status in
                    logger.debug("사용자의 음성 인식 권한은 \(status.rawValue)입니다.")
                    
                    continuation.resume(returning: status == .authorized)
                }
            }
        }
    }
}
