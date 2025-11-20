//
//  RecordingSheet.swift
//  Mentory
//
//  Created by 김민우 on 11/20/25.
//
import SwiftUI
import Combine
import AVFoundation
import OSLog


// MARK: View
struct RecordingSheet: View {
    // MARK: core
    nonisolated let logger = Logger(subsystem: "Mentory.RecordForm", category: "Presentation")
    
    @State var microphone = Microphone.shared
    @StateObject private var sttManager = SpeechToTextManager()
    
    var onComplete: (URL) -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Text("음성 녹음")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 30)

            // 녹음 시간 표시
            Text(timeString(from: microphone.recordingTime))
                .font(.system(size: 48, weight: .light, design: .monospaced))
                .foregroundColor(microphone.isListening ? .red : .primary)

            // 녹음 파형 애니메이션 (시각적 효과)
            if microphone.isListening {
                WaveformView()
                    .frame(height: 80)
                    .padding(.horizontal, 40)
            } else {
                Spacer()
                    .frame(height: 80)
            }
            Text(sttManager.recognizedText.isEmpty ? "" : sttManager.recognizedText)
                .font(.subheadline)
                .padding()
            Spacer()

            // 녹음 컨트롤
            HStack(spacing: 40) {
                // 취소 버튼
                Button(action: {
                    Task {
                        if microphone.isListening {
                            await microphone.stopListening()
                        }
                    }
                    onCancel()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.gray)
                        .clipShape(Circle())
                }

                // 녹음/정지 버튼
                Button(action: {
                    Task {
                        if microphone.isListening {
                            await microphone.startListening()
                        } else {
                            await microphone.stopListening()
                        }
                    }
                }) {
                    Image(systemName: microphone.isListening ? "stop.fill" : "mic.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(microphone.isListening ? Color.red : Color.blue)
                        .clipShape(Circle())
                }

                // 완료 버튼
                Button(action: {
                    if microphone.isListening {
                        Task { await microphone.stopListening() }
                    }
                    if let url = microphone.audioURL {
                        onComplete(url)
                    }
                }) {
                    Image(systemName: "checkmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(microphone.audioURL != nil ? Color.green : Color.gray)
                        .clipShape(Circle())
                }
                .disabled(microphone.audioURL == nil)
            }
            .padding(.bottom, 50)
        }
        .onDisappear {
            Task {
                if microphone.isListening {
                    await microphone.stopListening()
                }
            }
        }
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
