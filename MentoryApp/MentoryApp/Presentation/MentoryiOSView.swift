//
//  ContentView.swift
//  Mentory
//
//  Created by 김민우 on 11/11/25.
//
import SwiftUI
import MentoryCore


// MARK: View
struct MentoryiOSView: View {
    // MARK: model
    @ObservedObject var mentoryiOS: Mentory
    init(_ mentoryiOS: Mentory) {
        self.mentoryiOS = mentoryiOS
    }
    
    
    // MARK: viewModel
    @State private var selectedTab: Tab = .record
    
    
    // MARK: body
    var body: some View {
        ZStack {
            MentoryBackdrop()

            if mentoryiOS.onboardingFinished {
                TabView(selection: $selectedTab) {
                    TodayBoardTab
                        .tabItem {
                            Label("기록", systemImage: "square.and.pencil")
                        }
                        .tag(Tab.record)

                    StaticTab
                        .tabItem {
                            Label("통계", systemImage: "chart.xyaxis.line")
                        }
                        .tag(Tab.statistics)

                    SettingTab
                        .tabItem {
                            Label("설정", systemImage: "gearshape")
                        }
                        .tag(Tab.setting)
                }
                .tint(.mentoryAccentPrimary)
                .toolbarBackground(Color.mentoryCard.opacity(0.96), for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
                .onOpenURL { url in
                    guard url.scheme == "mentory" else { return }

                    if url.host == "record" {
                        selectedTab = .record
                    }
                }
            } else {
                OnboardingTab
            }
        }
        .task {
            await mentoryiOS.loadUserName()
            mentoryiOS.setUp()
        }
    }
    
    
    // MARK: value
    enum Tab {
        case record
        case statistics
        case setting
    }
    
    
    // MARK: component
    @ViewBuilder
    private var TodayBoardTab: some View {
        if let todayBoard = mentoryiOS.todayBoard {
            TodayBoardView(
                todayBoard: todayBoard,
                mentoryiOS: mentoryiOS
            )
        } else {
            MentoryStatusCard(
                systemImage: "square.and.pencil",
                title: "기록 화면을 준비 중입니다",
                message: "오늘의 감정 기록 화면을 불러오는 중이에요."
            )
        }
    }
    
    @ViewBuilder
    private var StaticTab: some View {
        if let statBoard = mentoryiOS.statBoard {
            StatBoardView(board: statBoard)
        } else {
            MentoryStatusCard(
                systemImage: "chart.xyaxis.line",
                title: "통계 화면을 준비 중입니다",
                message: "기록 데이터를 불러오면 월별 흐름을 확인할 수 있어요."
            )
        }
    }
    
    @ViewBuilder
    private var SettingTab: some View {
        if let settingBoard = mentoryiOS.settingBoard {
            SettingBoardView(settingBoard: settingBoard, settingBoardViewModel: SettingBoardViewModel())
        } else {
            MentoryStatusCard(
                systemImage: "gearshape",
                title: "설정 화면을 준비 중입니다",
                message: "앱 설정과 안내 정보를 가져오고 있어요."
            )
        }
    }
    
    @ViewBuilder
    private var OnboardingTab: some View {
        if let onBoarding = mentoryiOS.onboarding {
            OnboardingView(onBoarding)
        } else {
            MentoryStatusCard(
                systemImage: "sparkles",
                title: "시작 화면을 준비 중입니다",
                message: "Mentory를 시작하기 위한 초기 데이터를 불러오고 있어요."
            )
            .padding(.horizontal, 20)
        }
    }
}


// MARK: Preview
fileprivate struct MentoryiOSPreview: View {
    @StateObject var mentoryiOS = Mentory()
    
    var body: some View {
        MentoryiOSView(mentoryiOS)
    }
}

#Preview {
    MentoryiOSPreview()
}
