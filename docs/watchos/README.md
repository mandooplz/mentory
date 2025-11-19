# watchOS + SwiftUI 개발 기초 개념

> watchOS 플랫폼 특화 기능과 UI 컴포넌트 정리

## 목차
1. [watchOS 플랫폼 특성](#1-watchos-플랫폼-특성)
2. [watchOS 전용 UI 컴포넌트](#2-watchos-전용-ui-컴포넌트)
3. [iPhone과의 연동 (WatchConnectivity)](#3-iphone과의-연동)
4. [센서 및 헬스 데이터](#4-센서-및-헬스-데이터)
5. [watchOS Best Practices](#5-watchos-best-practices)

---

## 1. watchOS 플랫폼 특성

### 핵심 제약사항
- **화면 크기**: 38mm ~ 49mm (매우 작은 디스플레이)
- **상호작용**: 5-10초 이내의 짧은 인터랙션 선호
- **입력**: 터치, Digital Crown, 사이드 버튼
- **배터리**: 제한적 - 센서 사용과 화면 업데이트 최소화 필요

### 디자인 원칙
```swift
// 너무 많은 정보 지양
VStack {
    Text("긴 설명 텍스트...")
    HStack {
        Button("A") { }
        Button("B") { }
        Button("C") { }
    }
}

// 명확하고 단순하게
VStack(spacing: 8) {
    Text("운동")
        .font(.headline)
    Text("5km")
        .font(.system(size: 40, weight: .bold))
}
```

---

## 2. watchOS 전용 UI 컴포넌트

### Digital Crown
watchOS의 가장 특징적인 입력 방식
```swift
struct CrownExample: View {
    @State private var value: Double = 0
    
    var body: some View {
        VStack {
            Text("\(Int(value))")
                .font(.largeTitle)
        }
        .focusable()  // Crown 입력 활성화
        .digitalCrownRotation($value, from: 0, through: 100, by: 1)
    }
}
```

### Gauge (진행률 표시)
```swift
struct GaugeExample: View {
    @State private var progress: Double = 0.7
    
    var body: some View {
        VStack {
            // 원형 게이지 (watchOS 스타일)
            Gauge(value: progress) {
                Text("목표")
            } currentValueLabel: {
                Text("\(Int(progress * 100))%")
            }
            .gaugeStyle(.accessoryCircular)
        }
    }
}
```

### TabView 페이징
좌우 스와이프로 페이지 전환 (watchOS 앱의 일반적 패턴)
```swift
struct TabViewExample: View {
    var body: some View {
        TabView {
            WorkoutView()
                .containerBackground(.blue.gradient, for: .tabView)
            
            SummaryView()
                .containerBackground(.green.gradient, for: .tabView)
            
            SettingsView()
                .containerBackground(.orange.gradient, for: .tabView)
        }
        .tabViewStyle(.page)
    }
}
```

### List 스타일링
```swift
struct WorkoutList: View {
    let workouts = ["러닝", "사이클", "수영"]
    
    var body: some View {
        List(workouts, id: \.self) { workout in
            NavigationLink {
                WorkoutDetailView(workout: workout)
            } label: {
                HStack {
                    Image(systemName: "figure.run")
                    Text(workout)
                }
            }
        }
        .listStyle(.carousel)  // watchOS 전용 스타일
    }
}
```

---

## 3. iPhone과의 연동

### WatchConnectivity 설정
```swift
import WatchConnectivity

@Observable
class ConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = ConnectivityManager()
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // 즉시 메시지 전송 (iPhone이 켜져있을 때)
    func sendMessage(_ data: [String: Any]) {
        guard WCSession.default.isReachable else {
            print("iPhone 연결 안됨")
            return
        }
        WCSession.default.sendMessage(data, replyHandler: nil)
    }
    
    // 백그라운드 동기화 (언제든 가능)
    func syncData(_ data: [String: Any]) {
        try? WCSession.default.updateApplicationContext(data)
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, 
                 activationDidCompleteWith state: WCSessionActivationState, 
                 error: Error?) {
        print("Watch 연결 상태: \(state.rawValue)")
    }
    
    func session(_ session: WCSession, 
                 didReceiveMessage message: [String: Any]) {
        // iPhone에서 받은 메시지 처리
        print("받은 데이터: \(message)")
    }
    
    func session(_ session: WCSession, 
                 didReceiveApplicationContext context: [String: Any]) {
        // iPhone에서 동기화된 데이터 처리
    }
}
```

### 사용 예시
```swift
struct ContentView: View {
    let connectivity = ConnectivityManager.shared
    
    var body: some View {
        Button("iPhone에 데이터 전송") {
            connectivity.sendMessage([
                "workout": "러닝",
                "distance": 5.2
            ])
        }
    }
}
```

---

## 4. 센서 및 헬스 데이터

### HealthKit 권한 및 걸음수 조회
```swift
import HealthKit

class HealthManager {
    let healthStore = HKHealthStore()
    
    // 권한 요청
    func requestAuthorization() async throws {
        let types: Set = [
            HKQuantityType(.stepCount)
        ]
        
        try await healthStore.requestAuthorization(toShare: types, read: types)
    }
    
    // 오늘 걸음수 조회
    func readTodaySteps() async throws -> Double {
        let stepType = HKQuantityType(.stepCount)
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: steps)
            }
            
            healthStore.execute(query)
        }
    }
    
    // 사용 예시
    func displaySteps() async {
        do {
            let steps = try await readTodaySteps()
            print("오늘 걸음수: \(Int(steps))걸음")
        } catch {
            print("걸음수 조회 실패: \(error)")
        }
    }
}
```


---

## 5. watchOS Best Practices

### 1. 화면 크기 대응
```swift
// GeometryReader로 동적 레이아웃
struct AdaptiveView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if geometry.size.width > 180 {
                    // 큰 워치 (44mm, 49mm)
                    Text("큰 화면")
                        .font(.title)
                } else {
                    // 작은 워치 (38mm, 40mm)
                    Text("작은 화면")
                        .font(.headline)
                }
            }
        }
    }
}
```

### 2. 배터리 효율
```swift
struct BatteryEfficientView: View {
    @Environment(\.scenePhase) var scenePhase
    @State private var isTracking = false
    
    var body: some View {
        Text("운동 중")
            .onChange(of: scenePhase) { old, new in
                if new == .background {
                    // 화면 꺼지면 불필요한 업데이트 중단
                    stopUnnecessaryUpdates()
                } else if new == .active {
                    // 화면 켜지면 재개
                    resumeUpdates()
                }
            }
    }
    
    func stopUnnecessaryUpdates() {
        // GPS, 센서 업데이트 빈도 줄이기
    }
    
    func resumeUpdates() {
        // 정상 업데이트 재개
    }
}
```

### 3. Always-On Display 대응
```swift
struct AlwaysOnView: View {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    var body: some View {
        VStack {
            if isLuminanceReduced {
                // Always-On Display 상태 (간소화된 UI)
                Text("5.2km")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(.white)
            } else {
                // 일반 상태 (풀 UI)
                VStack {
                    Text("러닝 중")
                    Text("5.2km")
                        .font(.system(size: 50, weight: .bold))
                    Text("32분")
                }
            }
        }
    }
}
```

### 4. 햅틱 피드백
```swift
import WatchKit

struct HapticExample: View {
    var body: some View {
        Button("완료") {
            // 성공 피드백
            WKInterfaceDevice.current().play(.success)
        }
        
        Button("시작") {
            // 시작 피드백
            WKInterfaceDevice.current().play(.start)
        }
    }
}

// 햅틱 종류:
// .notification  - 알림
// .start        - 시작
// .stop         - 중단
// .success      - 성공
// .failure      - 실패
// .retry        - 재시도
// .click        - 클릭
```

### 5. 컴플리케이션 (Complication)
워치 페이스에 표시되는 위젯
```swift
// Info.plist에 CLKComplicationFamily 추가 필요
// ComplicationController.swift에서 구현

// 간단한 예시 구조:
struct ComplicationData {
    let value: String
    let description: String
}

// TimelineEntry 제공
// 워치 페이스에 실시간 데이터 표시
```

---

## 프로젝트 시작하기

```bash
# Xcode에서 새 프로젝트 생성
# 1. File > New > Project
# 2. watchOS > App 선택
# 3. Interface: SwiftUI
# 4. Minimum Deployment: watchOS 10.0+
```

### Info.plist 주요 설정
- **WKWatchOnly**: true (독립 실행 앱인 경우)
- **Privacy - Health Share/Update**: HealthKit 사용 시
- **Location When In Use**: GPS 사용 시

---

## 참고 링크
- [Apple Developer - watchOS](https://developer.apple.com/watchos/)
- [Human Interface Guidelines - watchOS](https://developer.apple.com/design/human-interface-guidelines/watchos)
- [HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [WatchConnectivity Framework](https://developer.apple.com/documentation/watchconnectivity)

---

**최소 지원**: watchOS 10.0+
