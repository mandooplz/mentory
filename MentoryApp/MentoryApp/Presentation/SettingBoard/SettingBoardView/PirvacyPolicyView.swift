//
//  PirvacyPolicyView.swift
//  Mentory
//
//  Created by SJS on 11/17/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    private let sections: [PolicySection] = [
        .init(
            title: "1. 수집하는 개인정보 항목",
            lines: [
                "팀은 서비스 제공을 위해 다음 정보를 수집합니다.",
                "1) 필수 수집 항목",
                "• 사용자 정보",
                "  - 닉네임 또는 사용자가 입력한 이름",
                "• 감정 기록 데이터",
                "  - 텍스트로 입력한 감정 기록",
                "  - 음성 입력 → 텍스트로 변환된 내용",
                "  - 사진 입력 시 사진에 포함된 텍스트(사진 원본은 서버에 저장하지 않음)",
                "• 앱 사용 정보",
                "  - 기록 작성 일시",
                "  - 선택된 감정 정보",
                "  - 기기 정보(모델명, OS 버전, 앱 버전)",
                "  - 앱 오류 로그(비식별화 형태)",
                "2) 선택 수집 항목",
                "• 카메라/사진 접근 권한: 사진 기록 기능 사용 시",
                "• 마이크 접근 권한: 음성 기록 기능 사용 시",
                "※ 선택 권한 미허용 시 해당 기능만 제한되며 기본 기능은 이용 가능",
                "3) 자동 수집 정보",
                "• 서비스 품질 개선을 위한 비식별 로그 정보"
            ]
        ),
        .init(
            title: "2. 개인정보의 수집 및 이용 목적",
            lines: [
                "팀은 수집된 정보를 다음 목적 범위 내에서만 사용합니다.",
                "• 감정 기록 기능 제공",
                "• 감정 분석 및 변화를 기반으로 한 개인 맞춤형 피드백 제공",
                "• AI 기반 사고 리프레이밍 기능 제공",
                "• 서비스 개선 및 오류 대응",
                "• 사용자 맞춤형 알림 제공",
                "• 법령 준수",
                "🔐 원본 데이터 저장 여부",
                "• 음성 원본 파일은 저장하지 않으며, 텍스트로 변환된 내용만 이용",
                "• 사진 원본도 서버에 저장하지 않음",
                "• AI 분석을 위해 전송되는 모든 데이터는 비식별화된 텍스트 형태로만 전송됨"
            ]
        ),
        .init(
            title: "3. 개인정보 제3자 제공",
            lines: [
                "팀은 원칙적으로 이용자의 개인정보를 외부에 제공하지 않습니다.",
                "다만 다음의 경우 예외적으로 제공될 수 있습니다.",
                "• 이용자의 사전 동의가 있는 경우",
                "• 법령에 따라 수사기관 등이 요청한 경우"
            ]
        ),
        .init(
            title: "4. 개인정보 처리 위탁",
            lines: [
                "팀은 서비스 기능 제공을 위해 아래 업체에 일부 처리를 위탁할 수 있습니다.",
                "위탁 업체 / 위탁 내용 / 보관 기간",
                "• OpenAI / Microsoft Azure – 텍스트 기반 감정·패턴 분석 – 분석 후 즉시 삭제(저장하지 않음)",
                "• Apple – 앱 오류 분석(Crash log) – iOS 정책에 따름",
                "※ 위탁 업체 변경 시 사전 고지 후 본 방침을 수정합니다."
            ]
        ),
        .init(
            title: "5. 개인정보 보관 및 파기",
            lines: [
                "1) 보관 기간",
                "• 앱 내 로컬 데이터: 사용자가 앱을 삭제하면 모두 삭제됨",
                "• 서버 저장 데이터가 존재할 경우:",
                "  - 탈퇴 요청 시 즉시 삭제",
                "  - 법령상 필요 시 예외적 보관 가능",
                "• 법정 보관 기간(해당 시)",
                "  - 서비스 이용 기록: 6개월",
                "  - 소비자 분쟁 해결 관련 기록: 3년",
                "2) 파기 방법",
                "• 전자적 정보: 복구 불가능한 방식으로 영구 삭제",
                "• 문서가 존재할 경우: 물리적 파쇄 또는 소각"
            ]
        ),
        .init(
            title: "6. 이용자의 권리",
            lines: [
                "사용자는 다음과 같은 권리를 행사할 수 있습니다.",
                "• 개인정보 열람·수정 요청",
                "• 개인정보 삭제 요청",
                "• 서비스 탈퇴 신청",
                "• 접근 권한 변경(iOS 설정 → Mentory)",
                "요청은 support@mentory.app으로 문의하면 처리됩니다."
            ]
        ),
        .init(
            title: "7. 아동의 개인정보",
            lines: [
                "서비스는 만 14세 미만을 대상으로 하지 않습니다.",
                "만 14세 미만 사용자의 정보가 확인될 경우 즉시 삭제합니다."
            ]
        ),
        .init(
            title: "8. 개인정보 보호를 위한 기술적·관리적 조치",
            lines: [
                "팀은 개인정보 보호를 위해 다음과 같은 조치를 시행합니다.",
                "• 데이터 전송 구간 암호화(HTTPS/TLS)",
                "• 로컬 데이터 최소 저장 및 비식별 처리",
                "• 접근 권한 최소화 및 접근 통제",
                "• 정기적 보안 점검 및 버전 업데이트",
                "• 로그 및 오류 데이터의 비식별 처리"
            ]
        ),
        .init(
            title: "9. 개인정보 보호책임자",
            lines: [
                "개인정보 관련 문의는 아래로 연락해 주세요.",
                "• 책임자: Mentory 팀",
                "• 이메일: "
            ]
        ),
        .init(
            title: "10. 개인정보 처리방침 변경",
            lines: [
                "팀은 서비스 개선 또는 법령 변경 시 본 방침을 수정할 수 있습니다.",
                "중요 변경 사항은 앱 내 공지 또는 화면 안내를 통해 사전 고지합니다.",
                "• 공지 후 7일 경과 시 변경 내용이 적용됩니다."
            ]
        )
    ]

    private let warningText = """
    🔐 원본 데이터 저장 여부
    • 음성 원본 파일은 저장하지 않으며, 텍스트로 변환된 내용만 이용
    • 사진 원본도 서버에 저장하지 않음
    • AI 분석을 위해 전송되는 모든 데이터는 비식별화된 텍스트 형태로만 전송됨
    """

    var body: some View {
        MentoryScrollScreen {
            header
            warningBox
            ForEach(sections) { section in
                PolicySectionView(section: section)
            }
        }
        .navigationTitle("개인정보 처리방침")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        MentorySectionCard(cornerRadius: 30, contentPadding: 22) {
            VStack(alignment: .leading, spacing: 12) {
                MentorySectionHeader(
                    eyebrow: "개인정보",
                    title: "개인정보 처리방침",
                    subtitle: "서비스에서 개인정보를 어떻게 수집하고 이용하는지 확인할 수 있습니다."
                )

                Text("최종 업데이트: 2025. 11. 18")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var warningBox: some View {
        MentorySectionCard(cornerRadius: 24, contentPadding: 16) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.yellow)
                    .font(.title3)
                Text(warningText)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct PolicySectionView: View {
    let section: PolicySection

    var body: some View {
        MentorySectionCard(cornerRadius: 24, contentPadding: 18) {
            VStack(alignment: .leading, spacing: 12) {
                Text(section.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(section.lines, id: \.self) { line in
                        Text(line)
                            .font(
                                .system(
                                    size: line.hasPrefix("•") || line.hasPrefix("  -") ? 14 : 13,
                                    weight: line.hasPrefix("•") || line.hasPrefix("  -") ? .regular : .medium,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(line.hasPrefix("•") || line.hasPrefix("  -") ? Color.primary : Color.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}

private struct PolicySection: Identifiable {
    let title: String
    let lines: [String]

    var id: String { title }
}
