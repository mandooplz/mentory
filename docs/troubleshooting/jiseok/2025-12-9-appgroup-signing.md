## App Group & Signing — “Unknown Name (Team ID)” 문제

---

## 문제 요약

팀원이 프로젝트를 빌드할 때 **Signing Team이 ‘Unknown Name (3X262XJF5T)’** 으로 표시되거나

**App Group이 빨간색으로 표시되는 문제**가 발생할 수 있다.

하지만 Owner 계정에서는 정상적으로 팀 이름과 App Group이 표시된다.

이 문서는 해당 현상의 원인과 해결 전략을 설명한다.

---

## 원인 분석

### 1. Owner와 초대 사용자 간 **권한 차이**

- 프로젝트의 실제 Apple Developer Team ID: **3X262XJF5T**
- 이 팀의 **Owner(Account Holder)** = *민우*
- Owner는 다음을 전체 접근 가능:
    - Certificates
    - Identifiers
    - App Groups
    - Provisioning Profiles
    - Bundle IDs

반면 초대받은 팀원(Role: **Developer**)은 아래 작업이 제한된다:

- App Group 생성/수정 ❌
- Provisioning Profile 생성/수정 ❌
- Certificates/Identifiers 접근 ❌
- 팀 Display Name 조회 ❌

따라서 Xcode가 팀 정보를 불러오지 못해: Unknown Name (3X262XJF5T)로 보여주게 된다.

하지만 **ID가 같으면 완전히 동일한 팀이며, 문제는 표시(UI) 차이에 불과하다.**

---

### 2. Provisioning Profile은 **Owner만 정확하게 생성 가능**

Owner가 만든 프로파일(`Mentory-Dev-Profile`)에는:

- App Group
- Team ID
- Signing Capabilities

등이 포함되어 있다.

팀원은 이 프로필을 사용할 수 있지만:

- 내부 설정을 수정할 수 없음
- App Group UI가 빨갛게 보일 수 있음
→ 하지만 실제 빌드에는 문제 없음

---

## 📈 실제 영향

| 항목 | Owner | 팀원(Developer Role) | 영향 |
| --- | --- | --- | --- |
| 시뮬레이터 실행 | ✔️ | ✔️ | 정상 |
| 실기기 빌드 | ✔️ | ✔️ | 프로필만 있으면 정상 |
| App Group 수정 | ✔️ | ❌ | Owner만 가능 |
| Provisioning Profile 생성 | ✔️ | ❌ | Owner만 가능 |
| Xcode 팀 이름 표시 | 정상 | Unknown Name | 표시 문제일 뿐 |

즉,

**Unknown Name이라고 해서 빌드/실행이 안 되는 것은 절대 아니다.**

---

## 🔧 해결 전략

### ✔️ 1. 역할 분담을 명확히 하기

**민우(Owner)**

- App Group, Certificates, Provisioning Profiles 관리
- 필요한 설정 변경 발생 시 Owner가 직접 수행

**팀원(Developer)**

- Signing Team에서 Team ID만 맞추고
- Owner가 생성한 프로비저닝 프로파일을 사용하여 빌드

---

### ✔️ 2. 팀원이 해야 할 작업은 아래로 충분

- 레포지토리 최신 버전 pull
- Xcode → Signing & Capabilities → Team 선택
    - `Unknown Name (3X262XJF5T)`이어도 정상
- Provisioning Profile 자동 적용 확인
- 빌드 & 실행

이 과정에서 App Group이 UI에서 빨간색으로 보이더라도

프로비저닝 프로파일에 포함되어 있기 때문에 실행에는 문제가 없다.

---

## 결론

- **Unknown Name은 권한 부족으로 인한 표시 문제**
- **Team ID(3X262XJF5T)만 동일하면 동일한 팀**
- **Owner가 Signing/Capabilities 관리**, 팀원은 빌드만 수행
- 이는 일반적인 조직 iOS 개발 구조와 동일하며, 정상적인 흐름이다.

---

## 체크리스트

### 팀원이 Unknown Name일 때 반드시 확인할 것

- [x]  Team ID가 3X262XJF5T 인가?
- [x]  Owner가 만든 Provisioning Profile이 선택되어 있는가?
- [x]  App Group이 프로파일에 포함되어 있는가?

### 문제로 이어지는 경우

- 팀원이 App Group을 임의 변경하려 함
- 잘못된 Provisioning Profile 사용
- entitlements 파일 충돌(Git) 발생