//
//  RecordFormView.swift
//  Mentory
//
//  Created by JAY, 구현모 on 11/17/25.
//
import MentoryCore
import SwiftUI
import UIKit
import Values

// MARK: View
struct RecordFormView: View {
    @ObservedObject private(set) var recordForm: RecordForm

    var body: some View {
        RecordFormLayout(
            topBar: {
                ToolbarItem(id: "recordForm.finish", placement: .topBarLeading) {
                    MentoryToolbarIconButton(
                        systemName: "xmark",
                        accessibilityLabel: "기록 작성 닫기"
                    ) {
                        recordForm.finish()
                    }
                }

                ToolbarItem(id: "recordForm.next", placement: .topBarTrailing) {
                    Button("분석하기") {
                        Task {
                            recordForm.validateInput()
                            await recordForm.submit()
                        }
                    }
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(recordForm.canProceed ? Color.mentoryAccentPrimary : .secondary)
                    .disabled(!recordForm.canProceed)
                    .navigationDestination(item: $recordForm.mindAnalyzer) { mindAnalyzer in
                        MindAnalyzerView(mindAnalyzer: mindAnalyzer)
                    }
                }
            },
            todayDate: {
                RecordFormHeader(recordForm: recordForm)
            },
            main: {
                TitleField(
                    recordForm: recordForm,
                    prompt: "제목을 입력해 주세요",
                    text: $recordForm.titleInput
                )

                BodyField(
                    recordForm: recordForm,
                    prompt: "오늘 있었던 일을 차분히 적어보세요.",
                    text: $recordForm.textInput
                )

                AttachmentSection(model: recordForm)
            },
            bottomBar: {
                ImageButton(model: recordForm)
                CameraButton(model: recordForm)
                AudioButton(model: recordForm)
            }
        )
    }
}

// MARK: Preview
fileprivate struct RecordFormPreview: View {
    @StateObject var mentoryiOS = Mentory()

    var body: some View {
        if let todayBoard = mentoryiOS.todayBoard,
           let recordForm = todayBoard.recordForms.first {
            RecordFormView(recordForm: recordForm)
        } else {
            ProgressView("프리뷰 로딩 중입니다.")
                .task {
                    mentoryiOS.setUp()

                    let onboarding = mentoryiOS.onboarding!
                    onboarding.nameInput = "김철수"
                    onboarding.submitForm()

                    let todayBoard = mentoryiOS.todayBoard!
                    await todayBoard.setUpRecordForms()
                }
        }
    }
}

#Preview {
    RecordFormPreview()
}

// MARK: Component
fileprivate struct RecordFormHeader: View {
    @ObservedObject var recordForm: RecordForm

    var body: some View {
        MentorySectionCard(cornerRadius: 30, contentPadding: 22) {
            VStack(alignment: .leading, spacing: 18) {
                MentoryInfoChip(text: "기록", systemImage: "square.and.pencil")

                Text(dateTitle)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("먼저 텍스트로 정리하고, 필요하면 사진이나 음성을 함께 남길 수 있어요.")
                    .mentorySupportText()
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    MentoryMetricPill(
                        title: "텍스트 상태",
                        value: recordForm.textInput.isEmpty ? "작성 전" : "작성 중"
                    )
                    MentoryMetricPill(
                        title: "첨부 자료",
                        value: "\(attachmentCount)개"
                    )
                }
            }
        }
    }

    private var attachmentCount: Int {
        [recordForm.imageInput != nil, recordForm.voiceInput != nil]
            .filter { $0 }
            .count
    }

    private var dateTitle: String {
        let relativeDay = recordForm.targetDate.relativeDay(from: .now)
        if relativeDay == .unknown {
            return recordForm.targetDate.formatted()
        }

        return "\(relativeDay.rawValue) 기록"
    }
}

fileprivate struct LiquidGlassIconButtonLabel: View {
    let systemName: String
    let label: String
    var isEnabled: Bool = true
    var accessibilityLabel: String?

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 36, height: 36)
                .foregroundStyle(isEnabled ? Color.mentoryAccentPrimary : .secondary)
                .background(
                    Circle()
                        .fill(isEnabled ? Color.mentoryAccentPrimary.opacity(0.12) : Color.clear)
                )

            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(isEnabled ? .primary : .secondary)
        }
        .frame(minWidth: 64)
        .padding(.vertical, 4)
        .accessibilityLabel(accessibilityLabel ?? label)
    }
}

fileprivate struct TitleField: View {
    let recordForm: RecordForm
    let prompt: String
    @Binding var text: String

    var body: some View {
        MentorySectionCard(cornerRadius: 28, contentPadding: 18) {
            VStack(alignment: .leading, spacing: 12) {
                fieldHeader(title: "제목", helper: "오늘 기록을 한 줄로 요약해보세요.")

                TextField(prompt, text: $text)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
        }
        .onReceive(recordForm.$titleInput) { _ in
            recordForm.validateInput()
        }
    }
}

fileprivate struct BodyField: View {
    let recordForm: RecordForm
    let prompt: String
    @Binding var text: String

    var body: some View {
        MentorySectionCard(cornerRadius: 30, contentPadding: 18) {
            VStack(alignment: .leading, spacing: 12) {
                fieldHeader(title: "본문", helper: "감정, 상황, 떠오른 생각을 순서대로 적으면 분석이 더 자연스러워져요.")

                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(prompt)
                            .foregroundStyle(.secondary.opacity(0.7))
                            .padding(.horizontal, 4)
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                    }

                    TextEditor(text: $text)
                        .scrollContentBackground(.hidden)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .frame(minHeight: 260)
                }
            }
        }
        .onReceive(recordForm.$textInput) { _ in
            recordForm.validateInput()
        }
    }
}

fileprivate func fieldHeader(title: String, helper: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text(title)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(.primary)

        Text(helper)
            .font(.system(size: 13, weight: .regular, design: .rounded))
            .foregroundStyle(.secondary)
    }
}

fileprivate struct AttachmentSection: View {
    @ObservedObject var model: RecordForm

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MentorySectionHeader(
                eyebrow: "첨부",
                title: "첨부 자료",
                subtitle: "필요한 경우 사진이나 음성을 함께 남길 수 있습니다."
            )

            if model.imageInput == nil, model.voiceInput == nil {
                MentorySectionCard(cornerRadius: 28, contentPadding: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("아직 첨부된 자료가 없어요")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(.primary)

                        Text("하단 버튼으로 사진, 카메라, 음성 기록을 추가할 수 있습니다.")
                            .mentorySupportText()
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                ImagePreviewCard(model: model)
                VoicePreviewCard(model: model)
            }
        }
    }
}

fileprivate struct ImageButton: View {
    @ObservedObject var model: RecordForm
    @State private var showImagePicker = false

    var body: some View {
        Button(action: {
            showImagePicker = true
        }) {
            LiquidGlassIconButtonLabel(
                systemName: "photo",
                label: "앨범",
                isEnabled: model.imageInput != nil,
                accessibilityLabel: "앨범에서 사진 선택"
            )
        }
        .sheet(isPresented: $showImagePicker) {
            PhotosPicker(imageData: $model.imageInput)
        }
    }
}

fileprivate struct CameraButton: View {
    @ObservedObject var model: RecordForm
    @State private var showCameraSheet = false

    var body: some View {
        Button(action: {
            showCameraSheet = true
        }) {
            LiquidGlassIconButtonLabel(
                systemName: "camera",
                label: "카메라",
                isEnabled: model.imageInput != nil,
                accessibilityLabel: "카메라 촬영"
            )
        }
        .sheet(isPresented: $showCameraSheet) {
            ImagePicker(imageData: $model.imageInput, sourceType: .camera)
        }
    }
}

fileprivate struct AudioButton: View {
    @ObservedObject var model: RecordForm
    @State private var showingAudioRecorder = false

    var body: some View {
        Button(action: {
            showingAudioRecorder = true
        }) {
            LiquidGlassIconButtonLabel(
                systemName: "waveform",
                label: "음성",
                isEnabled: model.voiceInput != nil,
                accessibilityLabel: "음성 녹음 추가"
            )
        }
        .sheet(isPresented: $showingAudioRecorder) {
            RecordingSheet(
                onComplete: { url in
                    model.voiceInput = url
                    showingAudioRecorder = false
                },
                onCancel: {
                    showingAudioRecorder = false
                }
            )
        }
    }
}

fileprivate struct ImagePreviewCard: View {
    @ObservedObject var model: RecordForm

    var body: some View {
        Group {
            if let imageData = model.imageInput,
               let uiImage = UIImage(data: imageData) {
                MentorySectionCard(cornerRadius: 28, contentPadding: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("첨부된 이미지", systemImage: "photo")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)

                            Spacer()

                            Button {
                                model.imageInput = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                }
            }
        }
    }
}

fileprivate struct VoicePreviewCard: View {
    @ObservedObject var model: RecordForm

    var body: some View {
        Group {
            if let voiceInput = model.voiceInput {
                MentorySectionCard(cornerRadius: 28, contentPadding: 16) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.mentoryAccentPrimary.opacity(0.12))
                                .frame(width: 42, height: 42)

                            Image(systemName: "waveform")
                                .foregroundStyle(Color.mentoryAccentPrimary)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("음성 메모 첨부됨")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.primary)

                            Text(voiceInput.lastPathComponent)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        Button {
                            model.voiceInput = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}
