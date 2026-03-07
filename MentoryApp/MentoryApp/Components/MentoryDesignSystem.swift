//
//  MentoryDesignSystem.swift
//  Mentory
//
//  Created by Mentory on 2026/03/03.
//

import SwiftUI

// MARK: - Typography
public extension View {
    func mentoryTitle() -> some View {
        self.font(.system(size: 32, weight: .bold))
    }
    
    func mentorySubtitle() -> some View {
        self.font(.system(size: 16, weight: .medium))
    }
    
    func mentoryHeadline() -> some View {
        self.font(.system(size: 18, weight: .semibold))
    }
    
    func mentoryBody() -> some View {
        self.font(.system(size: 14, weight: .medium))
    }
}

// MARK: - Button Style
public struct MentoryPrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    
    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.mentoryAccentPrimary,
                                Color.mentoryAccentPrimary.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: Color.mentoryAccentPrimary.opacity(0.35), radius: 14, y: 8)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.45)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Background Modifier
public struct MentoryBackgroundModifier: ViewModifier {
    public func body(content: Content) -> some View {
        ZStack {
            Color.mentoryBackground
                .ignoresSafeArea()
            content
        }
    }
}

public extension View {
    func withMentoryBackground() -> some View {
        self.modifier(MentoryBackgroundModifier())
    }
}
