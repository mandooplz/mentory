# Mentory-iOS

## 개요

Mentory는 STT와 LLM을 활용해 사용자의 감정을 기록·분석하고 맞춤형 조언을 제공하는 멘탈 케어 iOS 앱입니다. 일기처럼 텍스트·이미지·채팅으로 감정을 남기거나 음성을 iOS Speech Framework로 전사해 기록할 수 있으며, 전사된 데이터는 LLM이 감정 상태를 해석하고 캐릭터 기반 위로 멘트와 실천 가능한 Todo까지 추천합니다.

주간·월간 감정 통계, 감정 캘린더, Alert/리마인드, 하루 한 줄 조언, 감정 상태별 행사 추천 등으로 사용자가 스스로의 변화를 추적할 수 있고, SwiftData·iCloud·HealthKit 연동으로 안전한 백업과 헬스 데이터 확장이 가능합니다.

## 기술

- SwiftUI & Combine 기반 MVVM
- Swift Concurrency(Swift 6)

## 개발 문서

- [이슈(Issue) 작성하기](docs/write-issue/README.md)
- 브랜치 전략, Trunk-Based Development
