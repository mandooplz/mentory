//
//  OnboardingView.swift
//  Mentory
//
//  Created by 구현모 on 11/14/25.
//
import Foundation
import SwiftUI
import MentoryCore


// MARK: View
struct OnboardingView: View {
    // MARK: model
    @ObservedObject var onboarding: Onboarding
    @FocusState private var isNameFieldFocused: Bool
    
    init(_ onboarding: Onboarding) {
        self.onboarding = onboarding
    }
    
    
    // MARK: body
    var body: some View {
        ZStack {
            Color
                .mentoryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                headerSection
                
                nameInputSection
                
                submitButton
                
                Text("언제든지 설정에서 이름을 변경할 수 있어요.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 44)
            .padding(.bottom, 20)
        }
        .withMentoryBackground()
    }
    
    
    // MARK: component
    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MENTORY")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.mentoryAccentPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.mentoryAccentPrimary.opacity(0.12))
                )
            
            Text("어떻게 불러드릴까요?")
                .mentoryTitle()
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("닉네임을 입력하면 오늘부터 맞춤 멘토링을 시작해요.")
                .mentorySubtitle()
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private var nameInputSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("이름 또는 닉네임")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
            
            HStack(spacing: 10) {
                Image(systemName: "person.crop.circle.fill")
                    .foregroundStyle(Color.mentoryAccentPrimary)
                
                TextField("이름(닉네임)을 적어주세요.", text: $onboarding.nameInput)
                    .font(.system(size: 17, weight: .medium))
                    .focused($isNameFieldFocused)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
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
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.mentorySubCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(inputBorderColor, lineWidth: 1.6)
            )
            
            if onboarding.validationResult == .nameInputIsEmpty {
                Text("이름을 입력해 주세요.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.red)
            }
        }
    }
    
    @ViewBuilder
    private var submitButton: some View {
        Button(action: {
            guard isSubmitDisabled == false else {
                return
            }
            
            onboarding.submitForm()
            
            Task {
                if let mentoryiOS = onboarding.owner {
                    await mentoryiOS.saveUserName()
                }
            }
        }) {
            Text("계속")
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
            return Color.mentoryAccentPrimary.opacity(0.7)
        }
        
        return .clear
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
