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
                VStack(spacing: 20) {
                    heroSection
                    nameInputSection
                    submitButton

                    Text("이름은 언제든지 설정에서 변경할 수 있어요.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, MentorySpacing.screenHorizontal)
                .padding(.top, 44)
                .padding(.bottom, 28)
            }
        }
    }

    // MARK: component
    @ViewBuilder
    private var heroSection: some View {
        MentorySectionCard(cornerRadius: 36, contentPadding: 24) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 12) {
                        MentoryInfoChip(text: "WELCOME TO MENTORY", systemImage: "sparkles")

                        Text("감정 기록을\n멘토링 흐름으로 바꿔볼까요?")
                            .mentoryTitle()
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("이름을 설정하면 오늘부터 기록, 감정 리포트, 행동 제안을 하나의 흐름으로 이어서 경험할 수 있어요.")
                            .mentorySupportText()
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    Image("greeting")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 108, height: 108)
                }

                HStack(spacing: 10) {
                    MentoryMetricPill(title: "기록", value: "텍스트 · 사진 · 음성")
                    MentoryMetricPill(title: "출력", value: "감정 리포트 · 행동 제안")
                }
            }
        }
    }

    @ViewBuilder
    private var nameInputSection: some View {
        MentorySectionCard(cornerRadius: 30, contentPadding: 20) {
            VStack(alignment: .leading, spacing: 14) {
                Text("이름 또는 닉네임")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)

                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.mentoryAccentPrimary)

                    TextField("어떻게 불러드리면 좋을까요?", text: $onboarding.nameInput)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
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
                }
                .padding(.horizontal, 16)
                .frame(height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.mentorySubCard)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(inputBorderColor, lineWidth: 1.5)
                )

                if onboarding.validationResult == .nameInputIsEmpty {
                    Text("이름을 입력하면 시작할 수 있어요.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.red.opacity(0.85))
                } else {
                    Text("설정된 이름은 메시지와 멘토링 문구에 자연스럽게 반영됩니다.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var submitButton: some View {
        Button(action: submitIfPossible) {
            Text("Mentory 시작하기")
        }
        .buttonStyle(MentoryPrimaryButtonStyle(isEnabled: !isSubmitDisabled))
        .disabled(isSubmitDisabled)
    }

    // MARK: value
    private var isSubmitDisabled: Bool {
        onboarding.trimmedName.isEmpty || onboarding.isUsed
    }

    private var inputBorderColor: Color {
        if onboarding.validationResult == .nameInputIsEmpty {
            return .red.opacity(0.7)
        }

        if isNameFieldFocused {
            return Color.mentoryAccentPrimary.opacity(0.5)
        }

        return .clear
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
        } else if mentoryiOS.onboardingFinished {
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
