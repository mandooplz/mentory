//
//  OnboardingView.swift
//  Mentory
//
//  Created by 구현모 on 11/14/25.
//
import MentoryCore
import SwiftUI

// MARK: View
struct OnboardingView: View {
    @ObservedObject var onboarding: Onboarding
    @FocusState private var isNameFieldFocused: Bool

    init(_ onboarding: Onboarding) {
        self.onboarding = onboarding
    }

    var body: some View {
        ZStack {
            MentoryBackdrop()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: MentorySpacing.xLarge) {
                    topCopy
                    nameInputSection
                }
                .padding(.horizontal, MentorySpacing.screenHorizontal)
                .padding(.top, 56)
                .padding(.bottom, 128)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .safeAreaInset(edge: .bottom) {
            bottomAction
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                isNameFieldFocused = true
            }
        }
    }

    // MARK: component
    private var topCopy: some View {
        VStack(alignment: .leading, spacing: MentorySpacing.large) {
            MentoryInfoChip(text: "시작", systemImage: "sparkles")

            VStack(alignment: .leading, spacing: 10) {
                Text("어떻게 불러드리면 좋을까요?")
                    .mentoryTitle()
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("이름이 있으면 기록과 메시지가 조금 더 자연스럽게 이어져요.")
                    .mentorySupportText()
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var nameInputSection: some View {
        VStack(alignment: .leading, spacing: MentorySpacing.small) {
            Text("이름 또는 닉네임")
                .mentoryEyebrow()
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: MentorySpacing.small) {
                TextField("예: 민우", text: $onboarding.nameInput)
                    .font(.system(.title3, design: .rounded, weight: .medium))
                    .foregroundStyle(.primary)
                    .focused($isNameFieldFocused)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .onSubmit {
                        submitIfPossible()
                    }
                    .onChange(of: onboarding.nameInput) { _, _ in
                        if onboarding.validationResult != .none {
                            onboarding.validateInput()
                        }

                        if onboarding.nameInput != onboarding.trimmedName {
                            onboarding.setName(onboarding.trimmedName)
                        }
                    }

                Rectangle()
                    .fill(inputBorderColor)
                    .frame(height: 1)

                Text(helperCopy)
                    .mentorySupportText()
                    .foregroundStyle(helperCopyColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.mentoryCard.opacity(0.94))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(inputBorderColor.opacity(0.45), lineWidth: 1)
            )
        }
    }

    private var bottomAction: some View {
        VStack(spacing: MentorySpacing.small) {
            Button(action: submitIfPossible) {
                Text("이 이름으로 시작하기")
            }
            .buttonStyle(MentoryPrimaryButtonStyle(isEnabled: !isSubmitDisabled))
            .disabled(isSubmitDisabled)

            Text("언제든 설정에서 다시 바꿀 수 있어요.")
                .mentorySupportText()
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, MentorySpacing.screenHorizontal)
        .padding(.top, 10)
        .padding(.bottom, 16)
        .background(Color.mentoryBackground.opacity(0.94))
    }

    // MARK: value
    private var isSubmitDisabled: Bool {
        onboarding.trimmedName.isEmpty || onboarding.isUsed
    }

    private var inputBorderColor: Color {
        if onboarding.validationResult == .nameInputIsEmpty {
            return .red.opacity(0.75)
        }

        if isNameFieldFocused {
            return Color.mentoryAccentPrimary
        }

        return Color.mentoryBorder
    }

    private var helperCopy: String {
        onboarding.validationResult == .nameInputIsEmpty
            ? "한 글자만 적어도 괜찮아요."
            : "부를 이름이 정해지면 오늘의 기록이 더 자연스럽게 이어져요."
    }

    private var helperCopyColor: Color {
        onboarding.validationResult == .nameInputIsEmpty ? .red.opacity(0.78) : .secondary
    }

    private func submitIfPossible() {
        guard isSubmitDisabled == false else {
            return
        }

        onboarding.submitForm()

        Task {
            if let mentoryiOS = onboarding.owner {
                await mentoryiOS.saveUserName()
            }
        }
    }
}

// MARK: Preview
fileprivate struct OnboardingPreview: View {
    @StateObject var mentoryiOS = Mentory()

    var body: some View {
        if let onboarding = mentoryiOS.onboarding {
            OnboardingView(onboarding)
        } else if mentoryiOS.isOnboardingFinished {
            Text("Onboarding이 종료되었습니다.")
        } else {
            ProgressView()
                .task {
                    mentoryiOS.setUp()
                }
        }
    }
}

#Preview {
    OnboardingPreview()
}
