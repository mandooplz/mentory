//
//  OnboardingLayout.swift
//  Mentory
//
//  Created by 김민우 on 12/1/25.
//
import SwiftUI


// MARK: Layout
struct OnboardingLayout<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                HStack {
                    Text(title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 60)
                        .padding(.leading, 30)
                    
                    Spacer()
                }
            }
        }
    }
}


// MARK: Preview
#Preview {
    OnboardingLayout(
        title: "레이아웃 제목",
        content: {
            Text("컨텐츠 영역")
        })
}
