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
            todayDate: {
                RecordFormHeader(recordForm: recordForm)
            },
            main: {
                BodyField(
                    recordForm: recordForm,
                    prompt: "오늘 가장 오래 남아 있는 장면이나 감정부터 적어보세요.",
                    text: $recordForm.textInput
                )

                TitleField(
                    recordForm: recordForm,
                    prompt: "짧은 제목을 남기고 싶다면",
                    text: $recordForm.titleInput
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
        VStack(alignment: .leading, spacing: MentorySpacing.large) {
            MentoryInfoChip(text: dateTitle, systemImage: "square.and.pencil")

            VStack(alignment: .leading, spacing: 8) {
                Text("지금 떠오르는 마음부터 적어보세요.")
                    .mentoryDisplayTitle()
                    .foregroundStyle(.primary)

                Text("설명보다 느낌부터 적어도 충분해요. 사진이나 음성은 필요할 때만 덧붙이세요.")
                    .mentorySupportText()
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var dateTitle: String {
        let relativeDay = recordForm.targetDate.relativeDay(from: .now)
        if relativeDay == .unknown {
            return recordForm.targetDate.formatted()
        }

        return "\(relativeDay.rawValue) 기록"
    }
}

fileprivate struct AttachmentButtonLabel: View {
    let systemName: String
    let label: String
    var isEnabled: Bool = false
    var accessibilityLabel: String?

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isEnabled ? Color.mentoryAccentPrimary.opacity(0.16) : Color.mentorySubCard.opacity(0.92))
                    .frame(width: 40, height: 40)

                Image(systemName: systemName)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(isEnabled ? Color.mentoryAccentPrimary : .primary)
            }

            Text(label)
                .mentoryEyebrow()
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 64)
        .accessibilityLabel(accessibilityLabel ?? label)
    }
}

fileprivate struct TitleField: View {
    let recordForm: RecordForm
    let prompt: String
    @Binding var text: String

    var body: some View {
        MentorySectionCard(cornerRadius: 24, contentPadding: 18) {
            VStack(alignment: .leading, spacing: 12) {
                fieldHeader(title: "짧은 제목", helper: "선택 사항")

                TextField(prompt, text: $text)
                    .font(.system(.body, design: .rounded, weight: .medium))
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
        MentorySectionCard(cornerRadius: 24, contentPadding: 18) {
            VStack(alignment: .leading, spacing: 14) {
                fieldHeader(title: "오늘의 기록", helper: "길지 않아도 괜찮아요")

                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(prompt)
                            .foregroundStyle(.secondary.opacity(0.76))
                            .padding(.horizontal, 4)
                            .padding(.top, 10)
                            .allowsHitTesting(false)
                    }

                    TextEditor(text: $text)
                        .scrollContentBackground(.hidden)
                        .font(.system(.body, design: .rounded, weight: .regular))
                        .frame(minHeight: 280)
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
            .font(.system(.subheadline, design: .rounded, weight: .semibold))
            .foregroundStyle(.primary)

        Text(helper)
            .mentoryEyebrow()
            .foregroundStyle(.secondary)
    }
}

fileprivate struct AttachmentSection: View {
    @ObservedObject var model: RecordForm

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("사진이나 음성은 필요할 때만 더해도 충분해요.")
                .mentorySupportText()
                .foregroundStyle(.secondary)

            if model.imageInput != nil || model.voiceInput != nil {
                VStack(spacing: 12) {
                    ImagePreviewCard(model: model)
                    VoicePreviewCard(model: model)
                }
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
            AttachmentButtonLabel(
                systemName: "photo",
                label: "사진",
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
            AttachmentButtonLabel(
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
            AttachmentButtonLabel(
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
                MentorySectionCard(cornerRadius: 24, contentPadding: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("첨부한 사진")
                                .mentoryEyebrow()
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
                MentorySectionCard(cornerRadius: 24, contentPadding: 16) {
                    HStack(spacing: 14) {
                        MentoryToneMark(character: .cool, size: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("음성 메모가 첨부되어 있어요")
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundStyle(.primary)

                            Text(voiceInput.lastPathComponent)
                                .mentorySupportText()
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
