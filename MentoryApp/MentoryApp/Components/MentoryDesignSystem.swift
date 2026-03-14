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
        self.font(.system(.title3, design: .rounded, weight: .semibold))
    }

    func mentoryTitle() -> some View {
        self.font(.system(.title, design: .serif, weight: .regular))
    }

    func mentorySubtitle() -> some View {
        self.font(.system(.headline, design: .rounded, weight: .semibold))
    }

    func mentoryHeadline() -> some View {
        self.font(.system(.body, design: .rounded, weight: .semibold))
    }

    func mentoryBody() -> some View {
        self.font(.system(.body, design: .rounded, weight: .regular))
    }

    func mentorySupportText() -> some View {
        self.font(.system(.subheadline, design: .rounded, weight: .regular))
    }

    func mentoryCaption() -> some View {
        self.font(.system(.caption, design: .rounded, weight: .medium))
    }

    func mentoryEyebrow() -> some View {
        self.font(.system(.caption2, design: .rounded, weight: .semibold))
            .tracking(0.3)
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
            .font(.system(.headline, design: .rounded, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 50)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.mentoryAccentPrimary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 10, y: 6)
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
            .opacity(configuration.isPressed ? 0.94 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.45)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

public struct MentorySecondaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    
    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.subheadline, design: .rounded, weight: .semibold))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.mentoryCard.opacity(0.82))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.mentoryBorder.opacity(0.8), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.42)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

public struct MentoryIconButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.primary)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.mentoryCard.opacity(0.76))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.mentoryBorder.opacity(0.8), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.03), radius: 6, y: 3)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
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
