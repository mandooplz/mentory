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
    @ObservedObject var mentory: Mentory
    
    
    // MARK: viewModel
    @State private var selectedTab: Tab = .today
    
    
    // MARK: body
    var body: some View {
        ZStack {
            MentoryBackdrop()

            if mentory.isOnboardingFinished {
                TabView(selection: $selectedTab) {
                    TodayBoardTab
                        .tabItem {
                            Label("오늘", systemImage: "square.and.pencil")
                        }
                        .tag(Tab.today)

                    ArchiveTab
                        .tabItem {
                            Label("아카이브", systemImage: "calendar")
                        }
                        .tag(Tab.archive)

                    SettingTab
                        .tabItem {
                            Label("설정", systemImage: "gearshape")
                        }
                        .tag(Tab.settings)
                }
                .tint(.mentoryAccentPrimary)
                .toolbarBackground(Color.mentoryCard.opacity(0.98), for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
                .onOpenURL { url in
                    guard url.scheme == "mentory" else { return }

                    if url.host == "record" {
                        selectedTab = .today
                    }
                }
            } else {
                OnboardingTab
            }
        }
        .task {
            await mentory.loadUserName()
            mentory.setUp()
        }
    }
    
    
    // MARK: value
    enum Tab {
        case today
        case archive
        case settings
    }
    
    
    // MARK: component
    @ViewBuilder
    private var TodayBoardTab: some View {
        if let todayBoard = mentory.todayBoard {
            TodayBoardView(
                todayBoard: todayBoard,
                mentoryiOS: mentory
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
    private var ArchiveTab: some View {
        if let statBoard = mentory.statBoard {
            StatBoardView(board: statBoard)
        } else {
            MentoryStatusCard(
                systemImage: "calendar",
                title: "기록을 모아보고 있어요",
                message: "조금만 기다리면 지난 마음의 흐름을 차분히 다시 볼 수 있어요."
            )
        }
    }
    
    @ViewBuilder
    private var SettingTab: some View {
        if let settingBoard = mentory.settingBoard {
            SettingBoardView(settingBoard: settingBoard, settingBoardViewModel: SettingBoardViewModel())
        } else {
            MentoryStatusCard(
                systemImage: "gearshape",
                title: "조정할 항목을 불러오는 중이에요",
                message: "이름과 알림, 안내 정보를 곧 확인할 수 있어요."
            )
        }
    }
    
    @ViewBuilder
    private var OnboardingTab: some View {
        if let onBoarding = mentory.onboarding {
            OnboardingView(onBoarding)
        } else {
            MentoryStatusCard(
                systemImage: "sparkles",
                title: "조용히 시작을 준비하고 있어요",
                message: "Mentory가 오늘의 첫 화면을 열고 있습니다."
            )
            .padding(.horizontal, 20)
        }
    }
}


// MARK: Preview
fileprivate struct MentoryiOSPreview: View {
    @StateObject var mentoryiOS = Mentory()
    
    var body: some View {
        MentoryiOSView(mentory: mentoryiOS)
    }
}

#Preview {
    MentoryiOSPreview()
}
