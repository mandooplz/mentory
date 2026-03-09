//
//  MentoryPresentationKit.swift
//  Mentory
//
//  Created by Codex on 3/9/26.
//

import SwiftUI

enum MentorySpacing {
    static let screenHorizontal: CGFloat = 20
    static let screenVertical: CGFloat = 24
    static let section: CGFloat = 20
    static let card: CGFloat = 18
    static let compact: CGFloat = 12
    static let mini: CGFloat = 8
}

struct MentoryBackdrop: View {
    var body: some View {
        ZStack {
            Color.mentoryBackground
                .ignoresSafeArea()

            Circle()
                .fill(Color.mentoryAccentPrimary.opacity(0.11))
                .frame(width: 300, height: 300)
                .blur(radius: 20)
                .offset(x: -130, y: -260)

            Circle()
                .fill(Color.mentoryAccentSecondary.opacity(0.09))
                .frame(width: 280, height: 280)
                .blur(radius: 24)
                .offset(x: 150, y: -160)

            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .frame(width: 240, height: 240)
                .rotationEffect(.degrees(18))
                .blur(radius: 60)
                .offset(x: 150, y: 320)
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
    var cornerRadius: CGFloat = 28
    var contentPadding: CGFloat = 20
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
        VStack(alignment: .leading, spacing: 8) {
            if let eyebrow, eyebrow.isEmpty == false {
                MentoryInfoChip(text: eyebrow, systemImage: "sparkles")
            }

            Text(title)
                .mentoryDisplayTitle()
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
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
            }

            Text(text)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(Color.mentoryAccentPrimary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule(style: .continuous)
                .fill(Color.mentoryAccentPrimary.opacity(0.12))
        )
    }
}

struct MentoryMetricPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.mentoryCard.opacity(0.72))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
    }
}

struct MentoryStatusCard: View {
    let systemImage: String
    let title: String
    let message: String
    var tint: Color = .mentoryAccentPrimary

    var body: some View {
        MentorySectionCard(cornerRadius: 24, contentPadding: 24) {
            VStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(tint)

                Text(title)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text(message)
                    .mentorySupportText()
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
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
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 34, height: 34)
        }
        .buttonStyle(MentoryIconButtonStyle())
        .accessibilityLabel(accessibilityLabel)
    }
}
