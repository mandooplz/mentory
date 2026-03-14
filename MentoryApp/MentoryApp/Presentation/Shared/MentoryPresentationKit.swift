//
//  MentoryPresentationKit.swift
//  Mentory
//
//  Created by Codex on 3/9/26.
//

import SwiftUI
import Values

enum MentorySpacing {
    static let tiny: CGFloat = 4
    static let xSmall: CGFloat = 8
    static let small: CGFloat = 12
    static let medium: CGFloat = 16
    static let large: CGFloat = 20
    static let xLarge: CGFloat = 28
    static let xxLarge: CGFloat = 36

    static let screenHorizontal: CGFloat = 20
    static let screenVertical: CGFloat = 24
    static let section: CGFloat = 24
    static let card: CGFloat = 18
    static let compact: CGFloat = 12
    static let mini: CGFloat = 8
}

struct MentoryBackdrop: View {
    var body: some View {
        ZStack {
            Color.mentoryBackground
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.mentoryBackground,
                    Color.mentoryCard.opacity(0.55),
                    Color.mentoryBackground,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.mentoryAccentPrimary.opacity(0.05))
                .frame(width: 220, height: 220)
                .blur(radius: 48)
                .offset(x: -140, y: -320)

            Circle()
                .fill(Color.mentoryAccentSecondary.opacity(0.05))
                .frame(width: 180, height: 180)
                .blur(radius: 54)
                .offset(x: 170, y: -210)
        }
    }
}

struct MentoryScrollScreen<Content: View>: View {
    var alignment: HorizontalAlignment = .leading
    var spacing: CGFloat = MentorySpacing.section
    var horizontalPadding: CGFloat = MentorySpacing.screenHorizontal
    var topPadding: CGFloat = MentorySpacing.screenVertical
    var bottomPadding: CGFloat = 40
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            MentoryBackdrop()

            ScrollView(showsIndicators: false) {
                VStack(alignment: alignment, spacing: spacing) {
                    content()
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, topPadding)
                .padding(.bottom, bottomPadding)
            }
        }
    }
}

struct MentorySectionCard<Content: View>: View {
    var cornerRadius: CGFloat = 24
    var contentPadding: CGFloat = 18
    @ViewBuilder var content: () -> Content

    var body: some View {
        LiquidGlassCard(cornerRadius: cornerRadius) {
            content()
                .padding(contentPadding)
        }
    }
}

struct MentorySectionHeader: View {
    let eyebrow: String?
    let title: String
    let subtitle: String?

    init(
        eyebrow: String? = nil,
        title: String,
        subtitle: String? = nil
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let eyebrow, eyebrow.isEmpty == false {
                MentoryInfoChip(text: eyebrow, systemImage: "sparkles")
            }

            Text(title)
                .mentoryHeadline()
                .foregroundStyle(.primary)

            if let subtitle, subtitle.isEmpty == false {
                Text(subtitle)
                    .mentorySupportText()
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MentoryInfoChip: View {
    let text: String
    var systemImage: String?

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
            }

            Text(text)
                .mentoryEyebrow()
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(
            Capsule(style: .continuous)
                .fill(Color.mentorySubCard.opacity(0.78))
        )
    }
}

struct MentoryMetricPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .mentoryEyebrow()
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.mentorySubCard.opacity(0.88))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.mentoryBorder.opacity(0.82), lineWidth: 1)
        )
    }
}

struct MentoryStatusCard: View {
    let systemImage: String
    let title: String
    let message: String
    var tint: Color = .mentoryAccentPrimary

    var body: some View {
        MentorySectionCard(cornerRadius: 22, contentPadding: 22) {
            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(.title3, design: .rounded, weight: .medium))
                    .foregroundStyle(tint)

                Text(title)
                    .mentoryHeadline()
                    .foregroundStyle(.primary)

                Text(message)
                    .mentorySupportText()
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct MentoryToolbarIconButton: View {
    let systemName: String
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(.body, design: .rounded, weight: .semibold))
                .frame(width: 36, height: 36)
        }
        .accessibilityLabel(accessibilityLabel)
    }
}

struct MentoryToneMark: View {
    let character: MentoryCharacter?
    var size: CGFloat = 40

    private var resolvedCharacter: MentoryCharacter {
        character ?? .warm
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor.opacity(0.18))

            switch resolvedCharacter {
            case .cool:
                VStack(spacing: 4) {
                    Capsule()
                        .fill(backgroundColor)
                        .frame(width: size * 0.42, height: 3)

                    Capsule()
                        .fill(backgroundColor.opacity(0.75))
                        .frame(width: size * 0.26, height: 3)
                }
            case .warm:
                Circle()
                    .stroke(backgroundColor, lineWidth: 2)
                    .frame(width: size * 0.46, height: size * 0.46)
                    .overlay(
                        Circle()
                            .fill(backgroundColor.opacity(0.28))
                            .frame(width: size * 0.18, height: size * 0.18)
                    )
            }
        }
        .frame(width: size, height: size)
    }

    private var backgroundColor: Color {
        switch resolvedCharacter {
        case .cool:
            return .mentoryAccentSecondary
        case .warm:
            return .mentoryAccentPrimary
        }
    }
}
