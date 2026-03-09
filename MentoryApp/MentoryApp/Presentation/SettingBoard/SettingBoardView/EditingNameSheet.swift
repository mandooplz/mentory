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

                VStack(spacing: 20) {
                    MentorySectionHeader(
                        eyebrow: "PROFILE",
                        title: "이름을 변경할까요?",
                        subtitle: "변경된 이름은 이후 멘토 메시지와 안내 문구에 반영됩니다."
                    )

                    MentorySectionCard(cornerRadius: 28, contentPadding: 20) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("새 이름")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(.primary)

                            TextField("새 이름을 입력하세요", text: $editingName.nameInput)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .padding(.horizontal, 14)
                                .frame(height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color.mentorySubCard)
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

                            Text("저장하면 다음 화면부터 새로운 이름으로 호출됩니다.")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    Button("이름 저장") {
                        Task { await editingName.submit() }
                        closeEditingNameSheet()
                    }
                    .buttonStyle(MentoryPrimaryButtonStyle(isEnabled: !editingName.isSubmitDisabled))
                    .disabled(editingName.isSubmitDisabled)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            nameTextFieldFocused = true
        }
    }
}
