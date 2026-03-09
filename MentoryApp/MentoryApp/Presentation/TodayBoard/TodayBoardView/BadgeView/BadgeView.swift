//
//  BadgeView.swift
//  Mentory
//
//  Created by 구현모 on 12/8/25.
//
import SwiftUI
import Values


// MARK: View
struct BadgeGridView: View {
    let earnedBadges: [BadgeType]
    let completedCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("완료된 제안")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)

                    Text("\(completedCount)개")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }

                Spacer()

                Text("\(earnedBadges.count)/\(BadgeType.allCases.count)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.mentoryAccentPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.mentoryAccentPrimary.opacity(0.12))
                    )
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(BadgeType.allCases, id: \.self) { badgeType in
                    BadgeItemView(
                        badgeType: badgeType,
                        isEarned: earnedBadges.contains(badgeType)
                    )
                }
            }
        }
    }
}


// MARK: Component
fileprivate struct BadgeItemView: View {
    let badgeType: BadgeType
    let isEarned: Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isEarned ? [
                                Color.mentoryAccentPrimary,
                                Color.mentoryAccentSecondary.opacity(0.92)
                            ] : [
                                Color.mentorySubCard,
                                Color.mentoryCard
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 86, height: 86)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(
                                isEarned ? Color.white.opacity(0.24) : Color.mentoryBorder.opacity(0.22),
                                lineWidth: 1
                            )
                    )

                Image(systemName: badgeType.iconName)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(isEarned ? .white : .secondary.opacity(0.55))
            }

            Text(badgeType.rawValue)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(isEarned ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .opacity(isEarned ? 1.0 : 0.62)
    }
}


// MARK: Preview
#Preview {
    VStack {
        LiquidGlassCard {
            BadgeGridView(
                earnedBadges: [.first, .five, .ten],
                completedCount: 12
            )
        }
        .padding()
    }
    .background(Color.mentoryBackground)
}
