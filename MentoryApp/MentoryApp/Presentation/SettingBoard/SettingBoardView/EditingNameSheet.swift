//
//  EditingNameSheet.swift
//  Mentory
//
//  Created by JAY on 11/24/25.
//

import Combine
import MentoryCore
import SwiftUI

// MARK: View
struct EditingNameSheet: View {
    @Environment(\.dismiss) var closeEditingNameSheet
    @ObservedObject var editingName: EditingName
    @FocusState private var nameTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                MentoryBackdrop()

                VStack(alignment: .leading, spacing: 20) {
                    MentorySectionHeader(
                        eyebrow: "이름",
                        title: "지금 불리는 이름을 바꿔둘까요?",
                        subtitle: "저장하면 이후 메시지와 안내 문구에 바로 반영돼요."
                    )

                    nameField

                    Button("이 이름으로 저장") {
                        Task { await editingName.submit() }
                        closeEditingNameSheet()
                    }
                    .buttonStyle(MentoryPrimaryButtonStyle(isEnabled: !editingName.isSubmitDisabled))
                    .disabled(editingName.isSubmitDisabled)

                    Spacer()
                }
                .padding(.horizontal, MentorySpacing.screenHorizontal)
                .padding(.top, 24)
            }
            .toolbar {
                cancelToolbarButton
            }
        }
        .presentationDetents([.height(360)])
        .onAppear(perform: focusNameTextField)
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("새 이름")
                .mentoryEyebrow()
                .foregroundStyle(.secondary)

            TextField("새 이름을 입력하세요", text: $editingName.nameInput)
                .font(.system(.title3, design: .rounded, weight: .medium))
                .padding(.horizontal, 18)
                .frame(minHeight: 54)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.mentoryCard.opacity(0.96))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.mentoryBorder.opacity(0.82), lineWidth: 1)
                )
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($nameTextFieldFocused)
                .task {
                    let stream = editingName.$nameInput.values
                    for await _ in stream {
                        editingName.validate()
                    }
                }

            Text("너무 길지 않으면 충분해요.")
                .mentorySupportText()
                .foregroundStyle(.secondary)
        }
    }

    @ToolbarContentBuilder
    private var cancelToolbarButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("닫기") {
                Task { await editingName.cancel() }
                closeEditingNameSheet()
            }
        }
    }

    private func focusNameTextField() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            nameTextFieldFocused = true
        }
    }
}
