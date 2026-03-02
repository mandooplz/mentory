<!-- 프로젝트 개요 -->

<div align="center">
  <a href="https://github.com/EST-iOS4/Mentory">
    <img src="./assets/images/mentory-icon.png" alt="Logo" width="110" height="110">
  </a>

  <h3>Mentory</h3>

  <p>
    감정을 기록하면 LLM이 분석해 맞춤 행동을 제안하는 SwiftUI 멘탈케어 앱
  </p>

  <p>
    <img src="https://img.shields.io/badge/iOS-1A1A1A?style=for-the-badge&logo=apple&logoColor=white" />
    <img src="https://img.shields.io/badge/watchOS-000000?style=for-the-badge&logo=apple&logoColor=white" />
    <img src="https://img.shields.io/badge/Widget-FF7F2A?style=for-the-badge&logo=swift&logoColor=white" />
  </p>

  <p>
    <img src="https://img.shields.io/badge/SwiftUI-F05138?style=for-the-badge&logo=swift&logoColor=white" />
    <img src="https://img.shields.io/badge/Combine-333333?style=for-the-badge&logo=swift&logoColor=white" />
    <img src="https://img.shields.io/badge/Swift%206-FA7343?style=for-the-badge&logo=swift&logoColor=white" />
  </p>
</div>

<p align="center">
  <img src="./assets/images/mentory-intro.png" alt="App Introduction" width="800">
</p>

## Overview

Mentory는 감정 기록을 일회성 다이어리가 아닌 "분석 가능한 데이터"로 다뤄, 사용자 입력(텍스트/음성/이미지)을 SwiftData에 축적하고 LLM 분석 결과를 행동 제안으로 연결하는 iOS 앱입니다. 이 프로젝트는 기능 구현 자체보다도 SwiftUI + Combine + Swift Concurrency를 조합해 테스트 가능한 아키텍처로 설계하고, iOS/Watch/Widget까지 확장 가능한 구조를 구축하는 데 초점을 두었습니다.

## Tech Stack

- UI: SwiftUI
- State & Reactive: Combine
- Concurrency: Swift Concurrency (async/await)
- Local Persistence: SwiftData
- Build System: Tuist
- AI/LLM: Alan API, Firebase AI Logic
- Platform Extensions: WatchConnectivity, WidgetKit

## Portfolio Highlights

- `Domain`을 외부 프레임워크 의존에서 분리해 기능 추가 시 핵심 로직 변경 범위를 최소화
- `Adapter Interface` 중심 설계로 LLM/DB 구현체 교체와 테스트 대역(Mock) 주입이 쉬운 구조
- 기록 저장(SwiftData)과 분석 요청(LLM async)을 분리해 실패 지점을 독립적으로 복구 가능
- Combine 스트림(`@Published`)과 async/await를 역할별로 분리해 UI 반응성과 비동기 안정성 확보
- iOS 앱을 중심으로 WatchConnectivity/Widget 확장 포인트를 모듈 경계에서 일관되게 유지
- Tuist 기반 모듈화로 앱/DB/공유 타입/디바이스 연동을 빌드 단위에서 분리

## Architecture

### Layered Structure & Dependency Direction

- Layer: `Presentation` / `Domain` / `Adapter` / `Service`
- Dependency Direction:
  - `Presentation` → `Domain` (유스케이스 소비)
  - `Domain` → `Protocol` (구현이 아닌 추상화 의존)
  - `Adapter`/`Service` → `Protocol 구현` (외부 API, DB, 디바이스 연동)
- DIP(의존성 역전 원칙) 적용으로 Domain은 프레임워크 세부 구현에서 독립적으로 유지됩니다.

왜 이렇게 나눴는가:

- 비즈니스 로직을 View와 분리해 UI 변경(레이아웃/상태 표현)이 핵심 정책에 영향을 주지 않도록 하기 위해
- LLM/DB 같은 외부 의존성 실패를 Adapter 경계에서 캡슐화해 장애 전파를 줄이기 위해
- 같은 Domain 로직을 iOS UI, Watch 연동, Widget 업데이트에서 재사용하기 위해
- 테스트에서 빠른 피드백을 위해 실제 인프라 없이 Domain 단위 검증이 가능해야 했기 때문에

## Data Flow

1. 감정 기록 생성 시나리오
   - 사용자가 `RecordForm`에서 텍스트/음성/이미지를 입력
   - Domain이 입력 검증 후 `MentoryDBInterface`를 통해 SwiftData에 기록 저장
   - 저장된 기록을 기반으로 LLM Adapter에 비동기 분석 요청 (`async/await`)
   - 분석 결과를 `Suggestion`/`MentorMessage`로 변환하여 Domain 상태 갱신
   - `@Published` 상태 변경이 Combine을 통해 SwiftUI View에 반영

2. 재진입/조회 시나리오
   - 앱 재실행 시 SwiftData에서 최근 기록/추천을 로드
   - 로드된 Domain 상태를 Combine 스트림으로 UI에 즉시 반영
   - 필요 시 추가 분석은 async task로 분리해 UI 블로킹 없이 후속 갱신

## Testing Strategy

- 핵심 전략: `Adapter Interface + Mock 구현체`를 사용해 Domain 로직을 외부 인프라 없이 테스트
- 실제 API/DB 호출 없이 상태 전이와 규칙 검증에 집중한 단위 테스트 구성

대표 테스트 대상 및 범위:

- `Onboarding`
  - 입력 검증(공백/유효 입력), 온보딩 완료 상태 전이, 소유자(Domain) 반영 여부
- `TodayBoard`
  - 기록/추천 로드, 상태 업데이트, 재조회 시 중복/순서 안정성
- `RecordForm`/`MindAnalyzer`
  - 입력 유효성, 분석 트리거 조건, 분석 결과가 추천 생성으로 연결되는 흐름
- `MentorMessage`
  - 분석 결과 기반 메시지 업데이트 및 컨텍스트 동기화 포인트 검증

## My Role

- Domain-First 아키텍처 방향 정의 및 계층 경계(`Presentation/Domain/Adapter/Service`) 구체화
- 감정 기록 → 저장 → 분석 → 제안 반영으로 이어지는 핵심 데이터 플로우 설계/구현
- 모듈 분리(Tuist) 기준 정리 및 공유 타입(`MentoryShared`) 중심 의존성 정돈
- Adapter 인터페이스/Mock 전략 도입으로 테스트 가능한 구조 구축
- Onboarding/TodayBoard 중심으로 상태 전이와 회귀 리스크를 확인하는 테스트 시나리오 작성

## Screenshots

<table>
  <tr>
    <td align="center" width="25%">
      <img src="./screenshots/todayboard.png" alt="todayboard" width="100%">
      <br>
      <b>오늘의 감정 보드</b>
      <br>
      <sub>오늘 하루의 감정 기록</sub>
    </td>
    <td align="center" width="25%">
      <img src="./screenshots/suggestion.png" alt="suggestion" width="100%">
      <br>
      <b>활동 추천</b>
      <br>
      <sub>AI가 추천하는 맞춤형 활동</sub>
    </td>
    <td align="center" width="25%">
      <img src="./screenshots/badge.png" alt="badge" width="100%">
      <br>
      <b>뱃지</b>
      <br>
      <sub>기록 달성에 따른 뱃지 획득</sub>
    </td>
    <td align="center" width="25%">
      <img src="./screenshots/todayboard-record.png" alt="todayboard-record" width="100%">
      <br>
      <b>기록 히스토리</b>
      <br>
      <sub>이틀 전까지 기록 가능</sub>
    </td>
  </tr>
  <tr>
    <td align="center" width="25%">
      <img src="./screenshots/recordform.png" alt="recordform" width="100%">
      <br>
      <b>감정 기록 폼</b>
      <br>
      <sub>텍스트, 음성, 사진 기록</sub>
    </td>
    <td align="center" width="25%">
      <img src="./screenshots/recordform-pic.png" alt="recordform-pic" width="100%">
      <br>
      <b>사진으로 기록</b>
      <br>
      <sub>이미지를 통한 감정 표현</sub>
    </td>
    <td align="center" width="25%">
      <img src="./screenshots/recordform-audio.png" alt="recordform-audio" width="100%">
      <br>
      <b>음성으로 기록</b>
      <br>
      <sub>음성 녹음을 통한 감정 기록</sub>
    </td>
    <td align="center" width="25%">
      <img src="./screenshots/analyze.png" alt="analyze" width="100%">
      <br>
      <b>AI 감정 분석</b>
      <br>
      <sub>LLM 기반 감정 분석, 조언</sub>
    </td>
  </tr>
  <tr>
    <td align="center" width="25%">
      <img src="./screenshots/setting.png" alt="setting" width="100%">
      <br>
      <b>설정</b>
      <br>
      <sub>알림 및 개인 설정 관리</sub>
    </td>
    <td align="center" width="25%"></td>
    <td align="center" width="25%"></td>
    <td align="center" width="25%"></td>
  </tr>
</table>

## Getting Started

> [!NOTE]
> 프로젝트를 빌드하기 위해서는 `Secrets.xcconfig` 와 `GoogleService-Info.plist` 파일이 필요합니다.

### 필요 조건

- Xcode 26.1+
- iOS 26.0+
- watchOS 26.0+
- Swift 6.0
- Tuist

### 설치 방법

1. 저장소 클론
   ```bash
   git clone https://github.com/EST-iOS4/Mentory.git
   cd Mentory
   ```
2. Tuist 설치 및 의존성 동기화
   ```bash
   tuist install
   tuist generate
   ```
3. 워크스페이스 열기
   ```bash
   open mentory.xcworkspace
   ```

### 환경 설정

#### 1) Alan API 토큰 설정

```bash
cp MentoryApp/Secrets.xcconfig.sample MentoryApp/Secrets.xcconfig
```

`MentoryApp/Secrets.xcconfig`

```bash
TOKEN = 여기에-발급받은-토큰-입력
```

#### 2) Firebase 설정

- Firebase Console에서 프로젝트 생성 후 `GoogleService-Info.plist` 다운로드
- `MentoryApp/MentoryApp/`에 파일 추가
- Firebase AI(Gemini API) 활성화

### 실행 방법

- iOS 앱: `Mentory` 스킴 선택 후 Run
- watchOS 앱: `MentoryWatchApp` 스킴 선택 후 Run
- 위젯: 앱 실행 후 홈 화면에서 Mentory 위젯 추가

## Module Structure

```
Mentory/
├── MentoryApp/      # 메인 iOS 앱
├── MentoryDB/       # SwiftData 기반 DB 모듈
├── MentoryDevice/   # Watch/Device 연동 모듈
├── MentoryLLM/      # LLM 연동 모듈
├── MentoryShared/   # 공유 Values/Protocol 모듈
└── assets/          # 문서/이미지 리소스
```

## 팀원

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/dearjaypark">
        <img src="https://github.com/dearjaypark.png" width="100" height="100" style="border-radius: 50%;"><br>
        <b>박재이</b>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/ji-seok-Song">
        <img src="https://github.com/ji-seok-Song.png" width="100" height="100" style="border-radius: 50%;"><br>
        <b>송지석</b>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/funrace2">
        <img src="https://github.com/funrace2.png" width="100" height="100" style="border-radius: 50%;"><br>
        <b>구현모</b>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/mandooplz">
        <img src="https://github.com/mandooplz.png" width="100" height="100" style="border-radius: 50%;"><br>
        <b>김민우</b>
      </a>
    </td>
  </tr>
  <tr>
    <td align="center">iOS Developer</td>
    <td align="center">iOS Developer</td>
    <td align="center">iOS Developer</td>
    <td align="center">iOS Developer</td>
  </tr>
</table>

## Links

- [작업 진행 상황](https://www.figma.com/board/SiHyXGeXghxikBKJqoxnkh/%EC%A7%84%ED%96%89-%EC%83%81%ED%99%A9?node-id=0-1&t=87sDM1UrF9fC4KOp-1)
