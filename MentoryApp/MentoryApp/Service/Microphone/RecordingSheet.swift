//
//  RecordingSheet.swift
//  Mentory
//
//  Created by 김민우 on 11/20/25.
//
import AVFoundation
import Combine
import OSLog
import SwiftUI

// MARK: View
public struct RecordingSheet: View {
    let microphone = Microphone.shared

    public var onComplete: (URL) -> Void
    public var onCancel: () -> Void

    public init(onComplete: @escaping (URL) -> Void, onCancel: @escaping () -> Void) {
        self.onComplete = onComplete
        self.onCancel = onCancel
    }

    public var body: some View {
        ZStack {
            MentoryBackdrop()

            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("음성으로 남기기")
                        .mentoryDisplayTitle()
                        .foregroundStyle(.primary)

                    Text("말로 남겨도 괜찮아요. 정리하고 싶을 만큼만 천천히 들려주세요.")
                        .mentorySupportText()
                        .foregroundStyle(.secondary)
                }

                MentorySectionCard(cornerRadius: 24, contentPadding: 18) {
                    VStack(spacing: 18) {
                        Text(timeString(from: microphone.recordingTime))
                            .font(.system(.largeTitle, design: .monospaced, weight: .light))
                            .foregroundStyle(microphone.isListening ? Color.mentoryAccentPrimary : .primary)

                        if microphone.isListening {
                            WaveformView()
                                .frame(height: 80)
                                .padding(.horizontal, 12)
                        } else {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.mentorySubCard.opacity(0.82))
                                .frame(height: 80)
                                .overlay(
                                    Text("준비되면 아래 버튼으로 시작할 수 있어요.")
                                        .mentorySupportText()
                                        .foregroundStyle(.secondary)
                                )
                        }

                        if microphone.recognizedText.isEmpty == false {
                            Text(microphone.recognizedText)
                                .mentorySupportText()
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                Spacer()

                HStack(spacing: 18) {
                    recordingActionButton(
                        systemName: "xmark",
                        title: "닫기",
                        fill: Color.mentorySubCard,
                        foreground: .primary,
                        action: {
                            Task {
                                if microphone.isListening {
                                    await microphone.stopListening()
                                    microphone.stopTimer()
                                }
                            }
                            onCancel()
                        }
                    )

                    recordingActionButton(
                        systemName: microphone.isListening ? "stop.fill" : "mic.fill",
                        title: microphone.isListening ? "멈추기" : "시작",
                        fill: microphone.isListening ? Color.mentoryAccentPrimary : Color.mentoryAccentSecondary,
                        foreground: .white,
                        isProminent: true,
                        action: {
                            Task {
                                if !microphone.isSetUp {
                                    await microphone.setUp()
                                }

                                if microphone.isListening {
                                    await microphone.stopListening()
                                    microphone.stopTimer()
                                } else {
                                    await microphone.startListening()
                                    microphone.startTimer()
                                }
                            }
                        }
                    )

                    recordingActionButton(
                        systemName: "checkmark",
                        title: "완료",
                        fill: microphone.audioURL != nil ? Color.mentoryAccentPrimary : Color.mentorySubCard,
                        foreground: microphone.audioURL != nil ? .white : .secondary,
                        action: {
                            Task {
                                if microphone.isListening {
                                    await microphone.stopListening()
                                    microphone.stopTimer()
                                }
                                if let url = microphone.audioURL {
                                    onComplete(url)
                                }
                            }
                        }
                    )
                    .disabled(microphone.audioURL == nil)
                }
            }
            .padding(.horizontal, MentorySpacing.screenHorizontal)
            .padding(.top, 28)
            .padding(.bottom, 34)
        }
        .onDisappear {
            Task {
                if microphone.isListening {
                    await microphone.stopListening()
                }
                microphone.stopTimer()
            }
        }
    }

    private func recordingActionButton(
        systemName: String,
        title: String,
        fill: Color,
        foreground: Color,
        isProminent: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(fill)
                        .frame(width: isProminent ? 76 : 60, height: isProminent ? 76 : 60)

                    Image(systemName: systemName)
                        .font(.system(isProminent ? .title2 : .title3, design: .rounded, weight: .semibold))
                        .foregroundStyle(foreground)
                }

                Text(title)
                    .mentoryEyebrow()
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    RecordingSheet { url in
        Logger().debug("\(url)")
    } onCancel: {
        Logger().debug("Recording이 취소되었습니다.")
    }
}
