# MVVM에 Swift Concurrency 도입하기

## 목차
- [개요](#개요)
- [비동기 흐름 설계](#비동기-흐름-설계)
- [Async/Await ViewModel 예시](#asyncawait-viewmodel-예시)
- [Actor와 상태 관리](#actor와-상태-관리)
- [적용 팁](#적용-팁)
- [참고 자료](#참고-자료)

## 개요

Swift Concurrency는 `async/await`, `Task`, `Actor` 등을 제공해 Combine보다 단순한 제어 흐름으로 비동기 작업을 표현할 수 있습니다. Mentory의 MVVM 구조에서는 네트워크 호출, 음성 전사, 감정 분석 LLM 요청 등을 비동기 함수로 추상화해 ViewModel이 명령형 스타일로 로직을 작성하면서도 UI는 SwiftUI의 상태 업데이트만 신경 쓰도록 합니다.

## 비동기 흐름 설계

1. **Repository**는 `async throws` 함수로 데이터 소스를 추상화합니다.
2. **ViewModel**은 Swift Concurrency의 `Task` 또는 `task` modifier에서 호출되며, 결과를 `@Published`나 `@MainActor` 속성과 연결합니다.
3. **View**는 `@StateObject` ViewModel을 가진 상태로, 비동기 작업을 `task { await viewModel.load() }`처럼 트리거합니다.

## Async/Await ViewModel 예시

```swift
@MainActor
final class EmotionAdviceViewModel: ObservableObject {
    @Published var advice: String?
    @Published var isLoading = false
    private let service: EmotionAdviceService

    init(service: EmotionAdviceService) {
        self.service = service
    }

    func loadAdvice(for entry: EmotionEntry) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let suggestion = try await service.fetchAdvice(for: entry)
            advice = suggestion
        } catch {
            advice = "오늘은 스스로에게 휴식을 선물해보세요."
            print("Advice fetch failed: \\(error)")
        }
    }
}
```

```swift
struct EmotionAdviceView: View {
    @StateObject private var viewModel: EmotionAdviceViewModel
    private let entry: EmotionEntry

    init(viewModel: EmotionAdviceViewModel, entry: EmotionEntry) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.entry = entry
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.advice ?? "감정 분석 중...")
            if viewModel.isLoading {
                ProgressView().frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .task { await viewModel.loadAdvice(for: entry) }
    }
}
```

## Actor와 상태 관리

```swift
actor EmotionEntryStore {
    private var entries: [EmotionEntry] = []

    func add(_ entry: EmotionEntry) {
        entries.append(entry)
    }

    func latest(limit: Int) -> [EmotionEntry] {
        Array(entries.suffix(limit))
    }
}
```

- Actor를 Repository나 로컬 캐시 계층에 적용하면 동시 접근으로 인한 데이터 경쟁을 방지할 수 있습니다.
- `@MainActor`를 ViewModel에 선언해 UI 관련 상태가 항상 메인 스레드에서 업데이트되도록 해야 합니다.

## 적용 팁

- **Task 취소 처리**: 긴 작업은 `Task { try await ... }` 내에서 `Task.checkCancellation()`을 호출하거나 `withTaskCancellationHandler`를 사용해 중단 시 리소스를 정리합니다.
- **AsyncSequence 활용**: 음성 전사처럼 스트리밍 데이터는 `AsyncStream` 또는 `AsyncThrowingStream`으로 감싸 상태를 순차적으로 방출하게 합니다.
- **테스트**: `XCTest`의 `async` 테스트 함수를 활용하고, `@MainActor` 메서드는 `await MainActor.run { ... }`를 통해 검증합니다.
- **Combine과 병용**: 기존 Combine Publisher를 `values` 프로퍼티나 `async` 변환으로 연결해 점진적으로 전환할 수 있습니다.

## 참고 자료

- [Apple: Meet async/await in Swift](https://developer.apple.com/videos/play/wwdc2021/10132/)
- [Apple: Swift Concurrency in Practice](https://developer.apple.com/videos/play/wwdc2022/110352/)
- [WWDC Sample: Bring structured concurrency to SwiftUI](https://developer.apple.com/documentation/swiftui/bringing-structured-concurrency-to-swiftui)
