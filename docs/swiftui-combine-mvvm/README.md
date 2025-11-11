# SwiftUI에서 Combine 기반 MVVM 사용하기

## 목차
- [개요](#개요)
- [아키텍처 구조](#아키텍처-구조)
- [ViewModel 예시](#viewmodel-예시)
- [Combine 패턴 팁](#combine-패턴-팁)
- [참고 자료](#참고-자료)

## 개요

SwiftUI는 선언형 UI 프레임워크이기 때문에 상태 변화를 예측 가능하게 관리하는 패턴이 중요합니다. Combine 기반 MVVM을 사용하면 `ObservableObject`로 ViewModel을 정의하고 `@Published` 또는 `@StateObject`를 활용해 UI와 데이터 스트림을 연결할 수 있습니다. Mentory에서는 감정 기록과 같이 비동기로 들어오는 데이터를 Combine 파이프라인에서 가공해 View가 단순하게 구독하도록 설계합니다.

## 아키텍처 구조

1. **Model**  
   API 혹은 로컬 데이터 소스를 표현하며, Combine Publisher를 통해 ViewModel에 업데이트를 제공합니다.
2. **ViewModel (`ObservableObject`)**  
   비즈니스 로직을 담당합니다. Model의 Publisher를 구독하고, `@Published` 프로퍼티로 View에 반영할 값을 노출합니다.
3. **View (`SwiftUI.View`)**  
   `@StateObject` 또는 `@ObservedObject`로 ViewModel을 보유하며, `body`는 Published 값 변화를 기반으로 자동 업데이트됩니다.

## ViewModel 예시

```swift
final class EmotionDiaryViewModel: ObservableObject {
    @Published var entries: [EmotionEntry] = []
    @Published var isLoading = false
    private let repository: EmotionDiaryRepository
    private var cancellables = Set<AnyCancellable>()

    init(repository: EmotionDiaryRepository) {
        self.repository = repository
    }

    func load() {
        isLoading = true
        repository.fetchLatestEntries()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("Load failed: \(error)")
                    }
                },
                receiveValue: { [weak self] entries in
                    self?.entries = entries
                }
            )
            .store(in: &cancellables)
    }
}
```

```swift
struct EmotionDiaryView: View {
    @StateObject private var viewModel: EmotionDiaryViewModel

    init(viewModel: EmotionDiaryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(viewModel.entries) { entry in
            Text(entry.summary)
        }
        .overlay {
            if viewModel.isLoading { ProgressView() }
        }
        .task { viewModel.load() }
    }
}
```

## Combine 패턴 팁

- **에러 처리 분리**: `catch` 연산자로 에러 전용 Publisher를 만들어 UI에 피드백하도록 합니다.
- **테스트 용이성**: ViewModel은 Combine Publisher를 주입받게 설계하면 `AnyPublisher` 목업으로 테스트할 수 있습니다.
- **Backpressure 관리**: `debounce`, `removeDuplicates` 등을 통해 감정 검색·필터 입력 시 불필요한 이벤트를 줄입니다.
- **메모리 관리**: `store(in:)`으로 `AnyCancellable`을 모아 ViewModel 해제 시 자동으로 구독이 정리되도록 합니다.

## 참고 자료

- [Apple: Introducing Combine](https://developer.apple.com/videos/play/wwdc2019/722/)
- [Apple: Data Essentials in SwiftUI](https://developer.apple.com/videos/play/wwdc2020/10040/)
- [Swift by Sundell: Combine basics](https://www.swiftbysundell.com/articles/combining-swiftui-and-combine/)
