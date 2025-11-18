//
//  RecordFormView.swift
//  Mentory
//
//  Created by JAY, 구현모 on 11/17/25.
//

import SwiftUI

struct RecordFormView: View {
    // Model -> 비즈니스 로직
    @ObservedObject var recordFormModel: RecordForm

    // ViewModel -> 화면의 열고 닫고
    @State private var cachedTextForAnalysis: String = ""
    @State private var isShowingMindAnalyzerView = false

    // 이미지 관련
    @State private var showingImagePicker = false
    @State private var showingCamera = false

    // 오디오 관련
    @StateObject private var audioManager = AudioRecorderManager()
    @State private var showingAudioRecorder = false

    var body: some View {
        ZStack {
            // iOS 26 스타일 배경
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                recordTopBar

                ScrollView {
                    VStack(spacing: 16) {
                        // 제목 입력 카드
                        LiquidGlassCard {
                            TextField("제목", text: $recordFormModel.titleInput)
                                .font(.title3)
                                .padding()
                        }

                        // 본문 입력 카드
                        LiquidGlassCard {
                            ZStack(alignment: .topLeading) {
                                if recordFormModel.textInput.isEmpty {
                                    Text("글쓰기 시작…")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 12)
                                        .allowsHitTesting(false)
                                }

                                TextEditor(text: $recordFormModel.textInput)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .frame(minHeight: 300)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 8)
                            }
                        }

                        // 첨부된 이미지 미리보기
                        if let imageData = recordFormModel.imageInput,
                           let uiImage = UIImage(data: imageData) {
                            LiquidGlassCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "photo")
                                            .foregroundColor(.blue)
                                        Text("첨부된 이미지")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Button(action: {
                                            recordFormModel.imageInput = nil
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.top, 16)

                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(12)
                                        .padding(.horizontal, 16)
                                        .padding(.bottom, 16)
                                }
                            }
                        }

                        // 첨부된 음성 녹음
                        if let _ = recordFormModel.voiceInput {
                            LiquidGlassCard {
                                HStack {
                                    Image(systemName: "waveform")
                                        .foregroundColor(.blue)
                                    Text("음성 녹음 첨부됨")
                                        .font(.subheadline)
                                    Spacer()
                                    Text(timeString(from: audioManager.recordingTime))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Button(action: {
                                        audioManager.deleteRecording()
                                        recordFormModel.voiceInput = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(16)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 80)
                }

                Spacer()
            }

            // 하단 툴바를 floating 스타일로
            VStack {
                Spacer()
                bottomToolbar
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .fullScreenCover(isPresented: $isShowingMindAnalyzerView) {
            MindAnalyzerView(mindAnalyzer: recordFormModel.mindAnalyzer!)
        }
    }
    
    private var recordTopBar: some View {
        ZStack {
            // 중앙 정렬된 날짜
            Text(formattedDate)
                .font(.headline)
                .foregroundStyle(.primary)

            // 오른쪽 정렬된 완료 버튼
            HStack {
                Spacer()

                // 리퀴드 글래스 완료 버튼
                Button(action: {
                    Task {
                        recordFormModel.validateInput()
                        recordFormModel.submit()
                        isShowingMindAnalyzerView.toggle()
                    }
                }) {
                    Text("완료")
                        .fontWeight(.semibold)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: isSubmitEnabled
                                    ? [Color.blue, Color.blue.opacity(0.8)]
                                    : [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(isSubmitEnabled ? 0.5 : 0.2), lineWidth: 1)
                        )
                        .shadow(
                            color: isSubmitEnabled
                                ? Color.blue.opacity(0.3)
                                : Color.clear,
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                }
                .disabled(!isSubmitEnabled)
                .animation(.easeInOut(duration: 0.2), value: isSubmitEnabled)
                .padding(.trailing)
            }
        }
        .padding(.vertical, 12)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 0)
        )
    }

    // 오늘 날짜 포맷팅
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: Date())
    }

    // 제출 가능 여부 계산
    private var isSubmitEnabled: Bool {
        !recordFormModel.titleInput.trimmingCharacters(in: .whitespaces).isEmpty &&
        !recordFormModel.textInput.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var bottomToolbar: some View {
        HStack(spacing: 0) {
            Spacer()
            Button(action: {
                showingImagePicker = true
            }) {
                Image(systemName: "photo")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(recordFormModel.imageInput != nil ? .blue : .primary)
            }
            Spacer()
            Button(action: {
                showingCamera = true
            }) {
                Image(systemName: "camera")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(recordFormModel.imageInput != nil ? .blue : .primary)
            }
            Spacer()
            Button(action: {
                showingAudioRecorder = true
            }) {
                Image(systemName: "waveform")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(recordFormModel.voiceInput != nil ? .blue : .primary)
            }
            Spacer()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: -4)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .sheet(isPresented: $showingImagePicker) {
            PhotosPicker(imageData: $recordFormModel.imageInput)
        }
        .sheet(isPresented: $showingCamera) {
            ImagePicker(imageData: $recordFormModel.imageInput, sourceType: .camera)
        }
        .sheet(isPresented: $showingAudioRecorder) {
            RecordingSheet(
                audioManager: audioManager,
                onComplete: { url in
                    recordFormModel.voiceInput = url
                    showingAudioRecorder = false
                },
                onCancel: {
                    showingAudioRecorder = false
                }
            )
        }
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
//    private func handleSubmitTapped() {
//        recordFormModel.validateInput()
//        guard recordFormModel.validationResult == .none else { return }
//        cachedTextForAnalysis = recordFormModel.textInput
//        recordFormModel.submit()
//        recordFormModel.mindAnalyzer = mindAnalyzer
//        recordFormModel.textInput = cachedTextForAnalysis
//        isShowingMindAnalyzerView = true
   // }
    
//    private func resetToEditor() {
//        cachedTextForAnalysis = ""
//        recordFormModel.titleInput = ""
//        recordFormModel.textInput = ""
//        recordFormModel.mindAnalyzer = mindAnalyzer
//        mindAnalyzer.isAnalyzing = false
//        mindAnalyzer.mindType = nil
//        mindAnalyzer.analyzedResult = nil
//    }
}

// MARK: - 리퀴드 글래스 컴포넌트
struct LiquidGlassCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 28, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: 10)
    }
}

#Preview {
    @MainActor
    struct PreviewWrapper: View {
        let recordForm: RecordForm
        init() {
            let mentoryiOS = MentoryiOS()
            let todayBoard = TodayBoard(owner: mentoryiOS)
            self.recordForm = RecordForm(owner: todayBoard)
        }
        var body: some View {
            RecordFormView(recordFormModel: recordForm)
        }
    }
    return PreviewWrapper()
}
