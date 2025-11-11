# 9999-12-19 음성 전사 중 앱 크래시

## 이슈 개요

- **증상**: 대화 모드에서 음성 기록을 시작하면 2~3초 후 앱이 즉시 종료됨.
- **영향 범위**: iOS 18 TestFlight 빌드를 설치한 모든 사용자.
- **감지 배경**: QA가 Crashlytics에서 `EXC_BAD_ACCESS KERN_INVALID_ADDRESS` 로그 확인.

## 진단 과정

1. 음성 세션 시작 시점에 한 번, 전사 결과가 돌아올 때 한 번 `startRecording()`이 호출되는 것을 확인.
2. Crashlytics 로그에서 `SpeechRecognizer.handlePartialResult` 내부에서 `transcript.compactMap` 호출 직전에 크래시 발생.
3. 디버깅 결과, STT가 빈 배열을 반환하면 `result.bestTranscription.segments.last`가 `nil`인데, 강제 언래핑 연산(`!`) 때문에 크래시가 발생함.

## 해결 방법

- `SpeechRecognizer`의 partial result 처리에서 `guard let`으로 마지막 세그먼트를 안전하게 언래핑.
- 빈 전사 문장을 무시하도록 `filter { !$0.isEmpty }` 추가.
- Fastlane beta 빌드 `1.2.0(45)`를 배포하고, Crashlytics에서 동일 스택의 크래시 재발 여부 모니터링.

## 회고 및 예방

- 음성·텍스트 입력처럼 외부 SDK 데이터가 `nil`을 반환할 수 있는 경로는 모두 옵셔널 바인딩을 강제.
- STT 파이프라인에 대한 단위 테스트를 작성해 빈 결과와 오류 케이스를 시뮬레이션.
- QA가 재현 절차를 쉽게 따라 할 수 있도록 음성 전사 플로우 테스트 체크리스트를 추가로 문서화.
