//
//  LiquidGlassCard.swift
//  Mentory
//
//  Created by JAY on 11/20/25.
//
import Foundation
import SwiftUI


// MARK: Component
struct LiquidGlassCard<Content: View>: View {
    // MARK: variable
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let content: Content
    
    init(cornerRadius: CGFloat = 28,
         shadowRadius: CGFloat = 10,
         @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.content = content()
    }

    
    // MARK: body
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.mentoryCard.opacity(0.96))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.mentoryBorder.opacity(0.82), lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(0.03),
                radius: shadowRadius,
                x: 0,
                y: 4
            )
    }
}



// MARK: Preview
#Preview {
    ZStack {
        Color.gray
            .ignoresSafeArea()
        
        LiquidGlassCard {
            VStack(spacing: 12) {
                Text("Liquid Glass Card")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                Text("샘플 프리뷰입니다.")
            }
            .padding()
        }
    }
}
