//
//  SettingBoardView.swift
//  Mentory
//
//  Created by SJS on 11/17/25.
//
import Combine
import MentoryCore
import OSLog
import SwiftUI
import WebKit
import iOSReminder

// MARK: Object
class SettingBoardViewModel: ObservableObject {
    @Published var isShowingInformationView = false

    @Published var selectedDate: Date = Date()
    @Published var isShowingEditingNameSheet = false
    @Published var isShowingReminderPickerSheet = false

    @Published var isShowingPrivacyPolicyView = false
    @Published var isShowingLicenseInfoView = false
    @Published var isShowingTermsOfServiceView = false

    @Published var isShowingDataDeletionAlert = false
    @Published var notificationStatusText: String = "미설정"

    func onAppear(settingBoard: SettingBoard) async {
        settingBoard.loadSavedReminderTime()
        await refreshNotificationStatus()
    }

    func refreshNotificationStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            notificationStatusText = "허용됨"
        case .denied:
            notificationStatusText = "꺼짐"
        case .notDetermined:
            notificationStatusText = "미설정"
        @unknown default:
            notificationStatusText = "-"
        }
    }

    func didTapReminderStatus(settingBoard: SettingBoard) async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .notDetermined:
            await refreshNotificationStatus()

        case .denied, .authorized, .provisional, .ephemeral:
            openAppSettings()

        @unknown default:
            break
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: View
struct SettingBoardView: View {
    @ObservedObject var settingBoard: SettingBoard
    @ObservedObject var settingBoardViewModel: SettingBoardViewModel

    nonisolated let logger = Logger(subsystem: "MentoryiOS.SettingBoardView", category: "Presentation")

    var body: some View {
        NavigationStack {
            MentoryScrollScreen {
                HeaderSection

                SettingSection(
                    title: "프로필 및 알림",
                    subtitle: "닉네임과 알림 설정을 관리할 수 있습니다."
                ) {
                    EditingNameRow
                    AppSettingsRow
                    ReminderStatusRow
                    ReminderTimeRow
                }

                SettingSection(
                    title: "정책 및 안내",
                    subtitle: "서비스 이용에 필요한 문서를 확인할 수 있습니다."
                ) {
                    PrivacyPolicyRow
                    LicenseInfoRow
                    TermsOfServiceRow
                }

                SettingSection(
                    title: "데이터 관리",
                    subtitle: "앱 데이터를 초기화하는 작업은 되돌릴 수 없습니다."
                ) {
                    DataDeletionRow
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    MentoryToolbarIconButton(
                        systemName: "info.circle",
                        accessibilityLabel: "서비스 정보 열기"
                    ) {
                        settingBoardViewModel.isShowingInformationView = true
                    }
                }
            }
            .sheet(isPresented: $settingBoardViewModel.isShowingInformationView) {
                WebView(url: settingBoard.owner!.infoURL.rawValue)
            }
            .task {
                await settingBoardViewModel.onAppear(settingBoard: settingBoard)
            }
        }
    }

    // MARK: ViewBuilder
    @ViewBuilder
    private var HeaderSection: some View {
        MentorySectionCard(cornerRadius: 34, contentPadding: 24) {
            VStack(alignment: .leading, spacing: 18) {
                MentoryInfoChip(text: "설정", systemImage: "gearshape")

                Text(settingBoard.owner?.greetingText ?? "설정을 준비하고 있어요")
                    .mentoryTitle()
                    .foregroundStyle(.primary)

                Text("이름, 알림, 안내 문서를 한 곳에서 관리할 수 있습니다.")
                    .mentorySupportText()
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    MentoryMetricPill(title: "알림 상태", value: settingBoardViewModel.notificationStatusText)
                    MentoryMetricPill(title: "알림 시간", value: settingBoard.formattedReminderTime())
                }
            }
        }
    }

    @ViewBuilder
    private var EditingNameRow: some View {
        SettingRow(
            iconName: "person.text.rectangle",
            iconBackground: .orange,
            title: "이름 변경",
            subtitle: "멘토 메시지와 안내 문구에 표시되는 이름을 수정합니다."
        ) {
            Task {
                settingBoard.setUpEditingName()
                settingBoardViewModel.isShowingEditingNameSheet = true
            }
        }
        .sheet(isPresented: $settingBoardViewModel.isShowingEditingNameSheet, onDismiss: {
            Task {
                await settingBoard.editingName?.cancel()
            }
        }) {
            EditingNameSheet(editingName: settingBoard.editingName!)
        }
    }

    @ViewBuilder
    private var AppSettingsRow: some View {
        SettingRow(
            iconName: "app.badge.fill",
            iconBackground: .blue,
            title: "앱 설정",
            subtitle: "시스템 권한과 세부 옵션을 iOS 설정에서 관리합니다."
        ) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        }
    }

    @ViewBuilder
    private var ReminderStatusRow: some View {
        SettingValueRow(
            iconName: "bell.fill",
            iconBackground: .red,
            title: "알림 상태",
            subtitle: "권한 상태를 확인하고 필요하면 설정 앱으로 이동합니다.",
            value: settingBoardViewModel.notificationStatusText
        ) {
            Task {
                await settingBoardViewModel.didTapReminderStatus(settingBoard: settingBoard)
            }
        }
    }

    @ViewBuilder
    private var ReminderTimeRow: some View {
        SettingValueRow(
            iconName: "clock.fill",
            iconBackground: .purple,
            title: "알림 시간",
            subtitle: "감정 기록을 떠올리기 좋은 시간으로 조정합니다.",
            value: settingBoard.formattedReminderTime()
        ) {
            settingBoardViewModel.isShowingReminderPickerSheet = true
        }
        .sheet(isPresented: $settingBoardViewModel.isShowingReminderPickerSheet) {
            ReminderPickerSheet
        }
    }

    @ViewBuilder
    private var PrivacyPolicyRow: some View {
        SettingRow(
            iconName: "lock.fill",
            iconBackground: .gray,
            title: "개인정보 처리방침",
            subtitle: "수집 항목과 이용 목적, 보관 기준을 확인합니다."
        ) {
            settingBoardViewModel.isShowingPrivacyPolicyView = true
        }
        .navigationDestination(isPresented: $settingBoardViewModel.isShowingPrivacyPolicyView) {
            PrivacyPolicyView()
        }
    }

    @ViewBuilder
    private var LicenseInfoRow: some View {
        SettingRow(
            iconName: "doc.text.fill",
            iconBackground: .green,
            title: "라이선스 정보",
            subtitle: "Mentory에 사용된 오픈소스와 라이선스를 확인합니다."
        ) {
            settingBoardViewModel.isShowingLicenseInfoView = true
        }
        .navigationDestination(isPresented: $settingBoardViewModel.isShowingLicenseInfoView) {
            LicenseInfoView()
        }
    }

    @ViewBuilder
    private var TermsOfServiceRow: some View {
        SettingRow(
            iconName: "book.fill",
            iconBackground: .blue.opacity(0.85),
            title: "이용 약관",
            subtitle: "서비스 이용 조건과 책임 범위를 안내합니다."
        ) {
            settingBoardViewModel.isShowingTermsOfServiceView = true
        }
        .navigationDestination(isPresented: $settingBoardViewModel.isShowingTermsOfServiceView) {
            TermsOfServiceView()
        }
    }

    @ViewBuilder
    private var DataDeletionRow: some View {
        SettingRow(
            iconName: "trash.fill",
            iconBackground: .red.opacity(0.9),
            title: "데이터 삭제",
            subtitle: "앱 데이터가 모두 제거되며 이 작업은 되돌릴 수 없습니다.",
            titleColor: .red
        ) {
            settingBoardViewModel.isShowingDataDeletionAlert = true
        }
        .alert(
            "데이터를 삭제하시겠습니까?",
            isPresented: $settingBoardViewModel.isShowingDataDeletionAlert,
            actions: {
                Button("삭제", role: .destructive) {
                    logger.debug("데이터 삭제 기능 구현 예정")
                }
                Button("취소", role: .cancel) {
                    logger.debug("데이터 삭제 취소 구현 예정")
                }
            },
            message: {
                Text("삭제를 누르면 앱 데이터가 모두 제거됩니다.")
            }
        )
    }

    private var ReminderPickerSheet: some View {
        NavigationStack {
            ZStack {
                MentoryBackdrop()

                VStack(spacing: 20) {
                    MentorySectionHeader(
                        eyebrow: "알림 시간",
                        title: "알림 시간을 조정하세요",
                        subtitle: "기록을 떠올리기 좋은 시간으로 설정할 수 있습니다."
                    )

                    MentorySectionCard(cornerRadius: 28, contentPadding: 16) {
                        DatePicker(
                            "알림 시간",
                            selection: $settingBoardViewModel.selectedDate,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .onAppear {
                            settingBoardViewModel.selectedDate = settingBoard.reminderTime
                        }
                    }

                    Button {
                        settingBoard.changeReminderTime(to: settingBoardViewModel.selectedDate)
                        settingBoardViewModel.isShowingReminderPickerSheet = false
                    } label: {
                        Text("알림 시간 저장")
                    }
                    .buttonStyle(MentoryPrimaryButtonStyle())
                }
                .padding(.horizontal, MentorySpacing.screenHorizontal)
                .padding(.top, 24)
                .padding(.bottom, 28)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    MentoryToolbarIconButton(
                        systemName: "xmark",
                        accessibilityLabel: "알림 시간 설정 닫기"
                    ) {
                        settingBoardViewModel.selectedDate = settingBoard.reminderTime
                        settingBoardViewModel.isShowingReminderPickerSheet = false
                    }
                }
            }
        }
        .presentationDetents([.height(440)])
    }
}

// MARK: SettingBoard Components
struct SettingSection<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)

            Text(subtitle)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)

            MentorySectionCard(cornerRadius: 28, contentPadding: 8) {
                VStack(spacing: 0) {
                    content()
                }
            }
        }
    }
}

struct SettingRow: View {
    var iconName: String
    var iconBackground: Color
    var title: String
    var subtitle: String?
    var titleColor: Color = .primary
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                SettingIcon(systemName: iconName, background: iconBackground)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(titleColor)

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct SettingValueRow: View {
    var iconName: String
    var iconBackground: Color
    var title: String
    var subtitle: String?
    var value: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                SettingIcon(systemName: iconName, background: iconBackground)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary)

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer()

                Text(value)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.mentoryAccentPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.mentoryAccentPrimary.opacity(0.08))
                    )

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct SettingIcon: View {
    var systemName: String
    var background: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(background)
                .frame(width: 40, height: 40)

            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: 44)
    }
}

// MARK: Preview
fileprivate struct SettingBoardPreview: View {
    @StateObject var mentoryiOS = Mentory()

    var body: some View {
        if let settingBoard = mentoryiOS.settingBoard {
            SettingBoardView(settingBoard: settingBoard, settingBoardViewModel: SettingBoardViewModel())
        } else {
            ProgressView("프리뷰 준비 중")
                .task {
                    mentoryiOS.setUp()

                    let onboarding = mentoryiOS.onboarding!
                    onboarding.nameInput = "김철수"
                    onboarding.submitForm()
                }
        }
    }
}

#Preview {
    SettingBoardPreview()
}
