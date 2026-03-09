//
//  MentoryDesignSystem.swift
//  Mentory
//
//  Created by Mentory on 2026/03/03.
//

import SwiftUI

// MARK: - Typography
public extension View {
    func mentoryDisplayTitle() -> some View {
        self.font(.system(size: 24, weight: .semibold, design: .rounded))
    }

    func mentoryTitle() -> some View {
        self.font(.system(size: 27, weight: .semibold, design: .rounded))
    }
    
    func mentorySubtitle() -> some View {
        self.font(.system(size: 16, weight: .medium, design: .rounded))
    }
    
    func mentoryHeadline() -> some View {
        self.font(.system(size: 18, weight: .semibold, design: .rounded))
    }
    
    func mentoryBody() -> some View {
        self.font(.system(size: 15, weight: .medium, design: .rounded))
    }

    func mentorySupportText() -> some View {
        self.font(.system(size: 14, weight: .regular, design: .rounded))
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
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 56)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.mentoryAccentPrimary,
                                Color.mentoryAccentSecondary.opacity(0.92)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: Color.mentoryAccentPrimary.opacity(0.26), radius: 16, y: 10)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.45)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

public struct MentorySecondaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    
    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium, design: .rounded))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 52)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.mentoryCard.opacity(0.88))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.mentoryBorder.opacity(0.32), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.42)
            .animation(.spring(response: 0.25, dampingFraction: 0.74), value: configuration.isPressed)
    }
}

public struct MentoryIconButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.primary)
            .background(
                Circle()
                    .fill(Color.mentoryCard.opacity(0.8))
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.24, dampingFraction: 0.74), value: configuration.isPressed)
    }
}

// MARK: - Background Modifier
public struct MentoryBackgroundModifier: ViewModifier {
    public func body(content: Content) -> some View {
        ZStack {
            MentoryBackdrop()
            content
        }
    }
}

public extension View {
    func withMentoryBackground() -> some View {
        self.modifier(MentoryBackgroundModifier())
    }
}
