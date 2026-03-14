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

                SettingGroup(
                    title: "프로필",
                    subtitle: "내 이름과 알림을 조용히 맞춰둘 수 있어요."
                ) {
                    EditingNameRow
                    ReminderTimeRow
                    ReminderStatusRow
                }

                SettingGroup(
                    title: "앱과 안내",
                    subtitle: "필요할 때만 열어보면 되는 항목이에요."
                ) {
                    AppSettingsRow
                    PrivacyPolicyRow
                    LicenseInfoRow
                    TermsOfServiceRow
                }

                SettingGroup(
                    title: "데이터",
                    subtitle: "되돌릴 수 없는 작업은 마지막에 한 번 더 확인해요."
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
        VStack(alignment: .leading, spacing: MentorySpacing.large) {
            MentoryInfoChip(text: "설정", systemImage: "gearshape")

            VStack(alignment: .leading, spacing: 12) {
                Text("설정을 조용히 정리해둘게요.")
                    .mentoryTitle()
                    .foregroundStyle(.primary)

                Text(headerCopy)
                    .mentorySupportText()
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var headerCopy: String {
        let reminder = settingBoard.formattedReminderTime()
        let status = settingBoardViewModel.notificationStatusText
        return "이름은 \(settingBoard.owner?.userName ?? "미설정"), 알림은 \(status), 현재 시간은 \(reminder)로 맞춰져 있어요."
    }

    @ViewBuilder
    private var EditingNameRow: some View {
        SettingRow(
            title: "이름",
            detail: settingBoard.owner?.userName ?? "미설정",
            helper: "메시지에 반영돼요"
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
            title: "iOS 설정 열기",
            detail: nil,
            helper: "권한과 세부 옵션"
        ) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        }
    }

    @ViewBuilder
    private var ReminderStatusRow: some View {
        SettingRow(
            title: "알림 권한",
            detail: settingBoardViewModel.notificationStatusText,
            helper: "필요하면 설정 앱으로 이동"
        ) {
            Task {
                await settingBoardViewModel.didTapReminderStatus(settingBoard: settingBoard)
            }
        }
    }

    @ViewBuilder
    private var ReminderTimeRow: some View {
        SettingRow(
            title: "알림 시간",
            detail: settingBoard.formattedReminderTime(),
            helper: "기록이 떠오르는 시간"
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
            title: "개인정보 처리방침",
            detail: nil,
            helper: "개인정보 이용 안내"
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
            title: "라이선스 정보",
            detail: nil,
            helper: "오픈소스 사용 내역"
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
            title: "이용 약관",
            detail: nil,
            helper: "서비스 이용 안내"
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
            title: "데이터 삭제",
            detail: nil,
            helper: "되돌릴 수 없어요",
            titleColor: .red
        ) {
            settingBoardViewModel.isShowingDataDeletionAlert = true
        }
        .alert(
            "데이터를 삭제하시겠어요?",
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
                Text("삭제를 누르면 저장된 기록과 설정이 모두 사라집니다.")
            }
        )
    }

    private var ReminderPickerSheet: some View {
        NavigationStack {
            ZStack {
                MentoryBackdrop()

                VStack(alignment: .leading, spacing: 20) {
                    MentorySectionHeader(
                        eyebrow: "알림 시간",
                        title: "기록이 떠오르는 시간으로 맞춰둘까요?",
                        subtitle: "억지로 바꾸지 않아도 괜찮아요. 편한 시간만 정하면 됩니다."
                    )

                    MentorySectionCard(cornerRadius: 24, contentPadding: 14) {
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
                        Text("이 시간으로 저장")
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
struct SettingGroup<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .mentoryHeadline()
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .mentorySupportText()
                    .foregroundStyle(.secondary)
            }

            MentorySectionCard(cornerRadius: 22, contentPadding: 4) {
                VStack(spacing: 0) {
                    content()
                }
            }
        }
    }
}

struct SettingRow: View {
    var title: String
    var detail: String?
    var helper: String?
    var titleColor: Color = .primary
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(titleColor)

                    if let helper {
                        Text(helper)
                            .mentoryEyebrow()
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if let detail {
                    Text(detail)
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(Color.mentoryAccentPrimary)
                        .multilineTextAlignment(.trailing)
                }

                Image(systemName: "chevron.right")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
