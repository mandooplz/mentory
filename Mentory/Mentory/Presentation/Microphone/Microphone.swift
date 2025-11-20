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
    private(set) var recognizedText: String = "" // STT 결과 텍스트
    
    
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
        
        // process
        do {
            try setupAudioSession()
        } catch {
            logger.error("\(error)")
            return
        }
        
    }
    
    func recordAndConvertToText() {
        
    }
    
    
    // MARK: Helpher
    private func setupAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord,
                                mode: .measurement,
                                options: [.duckOthers])
        try session.setActive(true, options: .notifyOthersOnDeactivation)
        logger.debug("AudioSession 설정 완료")
    }
    
    // 1. STT 요청 생성
    // 2. 녹음 파일 관련 흐름
    // 3. 마이크 → 버퍼 → request + 파일 흐름
    // 4. Recognition Task → recognizedText 흐름
    private func startEngineAndRecognition() throws {
        
        recognitionTask?.cancel()
        recognitionTask = nil

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        // 1) 녹음 파일 경로 생성
        let documentsPath = FileManager.default.urls(for: .documentDirectory,
                                                     in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent("recording_\(UUID().uuidString).m4a")
        audioURL = fileURL   // ✅ 여기서 외부에 노출

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        audioFile = try AVAudioFile(forWriting: fileURL,
                                    settings: recordingFormat.settings)

        logger.debug("inputNode.installTap 설정 시작")

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0,
                             bufferSize: 1024,
                             format: recordingFormat) { [weak self] buffer, _ in
            guard let self = self,
                  let recognitionRequest = self.recognitionRequest else { return }

            // 2) STT에 버퍼 전달
            recognitionRequest.append(buffer)

            // 3) 파일로 버퍼 쓰기
            do {
                try self.audioFile?.write(from: buffer)
            } catch {
                self.logger.error("오디오 파일 쓰기 실패: \(error.localizedDescription)")
            }
        }

        audioEngine.prepare()
        try audioEngine.start()
        logger.debug("audioEngine.start() 성공 — 녹음 + STT 시작됨")

        // 4) STT 작업 시작
        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                Task { @MainActor in
                    self.recognizedText = result.bestTranscription.formattedString
                    self.logger.debug("recognitionTask 업데이트: \(self.recognizedText, privacy: .public)")
                }
            }

            if let error = error {
                self.logger.error("recognitionTask 오류: \(error.localizedDescription)")
                Task { @MainActor in
                    self.stop()
                }
            }
        }
    }
    func stop() {
        logger.debug("stop() 호출됨 — 녹음 및 인식 중지")

        // STT 중지
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil

        // 오디오 엔진 중지
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        // 파일 닫기
        audioFile = nil

        // 타이머 정리
        timer?.invalidate()
        timer = nil

        // 세션 비활성화
        Task {
            let session = AVAudioSession.sharedInstance()
            try? session.setActive(false, options: .notifyOthersOnDeactivation)
        }

        isRecording = false
        logger.debug("stop() 완료")
    }
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1,
                                     repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                if self.audioEngine.isRunning {
                    self.recordingTime += 0.1
                }
            }
        }
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
