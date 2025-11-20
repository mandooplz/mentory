//
//  AudioRecorder.swift
//  Mentory
//
//  Created by 구현모 on 11/18/25.
//
import SwiftUI
import Combine
import AVFoundation
import OSLog

@MainActor
class AudioRecorderManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false
    @Published var audioURL: URL?
    @Published var recordingTime: TimeInterval = 0

    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?

    override init() {
        super.init()
        setupAudioSession()
    }

    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    func startRecording() {
        // 녹음 파일 경로 생성
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording_\(UUID().uuidString).m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()

            isRecording = true
            recordingTime = 0

            // 타이머 시작
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                Task { @MainActor in
                    self.recordingTime = self.audioRecorder?.currentTime ?? 0
                }
            }
        } catch {
            print("Could not start recording: \(error)")
        }
    }
    func stopRecording() {
        audioRecorder?.stop()
        timer?.invalidate()
        timer = nil
        isRecording = false

        if let url = audioRecorder?.url {
            audioURL = url
        }
    }

    func deleteRecording() {
        if let url = audioURL {
            try? FileManager.default.removeItem(at: url)
            audioURL = nil
        }
        recordingTime = 0
    }

    // AVAudioRecorderDelegate
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            Task { @MainActor in
                self.isRecording = false
            }
        }
    }
}
