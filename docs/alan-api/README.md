# Alan API 사용법

## 목차

- [Alan API 사용법](#alan-api-사용법)
  - [목차](#목차)
  - [API 테스트](#api-테스트)
  - [연동 가이드](#연동-가이드)
    - [REST 호출 빌더](#rest-호출-빌더)
    - [SSE 스트림 처리](#sse-스트림-처리)
    - [상태 초기화 요청](#상태-초기화-요청)
    - [Secrets.xcconfig](#secretsxcconfig)

## API 테스트

![alt text](<스크린샷 2025-11-14 오전 3.13.08.png>)

![alt text](<스크린샷 2025-11-14 오전 3.12.24.png>)

![alt text](<스크린샷 2025-11-14 오전 3.12.53.png>)

![alt text](<스크린샷 2025-11-14 오전 3.12.59.png>)

## 연동 가이드

### REST 호출 빌더

```swift
struct AlanQuestionResponse: Decodable {
    struct Action: Decodable {
        let name: String
        let speak: String
    }
    let action: Action?
    let content: String
}

func makeQuestionRequest(content: String, clientID: String) throws -> URLRequest {
    var components = URLComponents(string: AlanEnvironment.current.baseURL)!
    components.path = "/api/v1/question"
    components.queryItems = [
        .init(name: "content", value: content),
        .init(name: "client_id", value: clientID)
    ]

    guard let url = components.url else { throw AlanError.invalidURL }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(Secrets.alanAPIKey)", forHTTPHeaderField: "Authorization")
    return request
}
```

`AlanClient.sendQuestion(...)`는 위 요청을 만들어 `URLSession.data(for:)`를 호출한 뒤 `AlanQuestionResponse`로 디코드하여 도메인 모델(`LLMEmotionSummary`)에 매핑합니다.

### SSE 스트림 처리

```swift
func streamQuestion(content: String, clientID: String) -> AsyncThrowingStream<String, Error> {
    AsyncThrowingStream { continuation in
        Task {
            do {
                let request = makeSSERequest(content: content, clientID: clientID)
                let (bytes, _) = try await URLSession.shared.bytes(for: request)
                for try await line in bytes.lines {
                    guard line.hasPrefix("data: ") else { continue }
                    let payload = line.dropFirst(6)
                    if let chunk = decodeSSEChunk(payload) {
                        continuation.yield(chunk)
                        if chunk.isComplete { break }
                    }
                }
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
}
```

`decodeSSEChunk`는 `type == "continue"`일 때 `data.content`를, `type == "complete"`일 때 스트림 종료를 알리는 구조를 반환하도록 구현합니다(예: `AlanStreamChunk(text: String, isComplete: Bool)`).

### 상태 초기화 요청

```swift
struct ResetAgentStateRequest: Encodable { let client_id: String }

func resetState(clientID: String) async throws {
    var request = URLRequest(url: AlanEnvironment.current.url(path: "/api/v1/reset-state"))
    request.httpMethod = "DELETE"
    request.setValue("Bearer \(Secrets.alanAPIKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(ResetAgentStateRequest(client_id: clientID))

    let (_, response) = try await URLSession.shared.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw AlanError.resetFailed
    }
}
```

초기화는 사용자가 계정을 로그아웃하거나 감정 히스토리를 삭제할 때 호출합니다. 호출 후 Mentory 내 캐시와 SwiftData 레코드도 함께 정리해야 합니다.

### Secrets.xcconfig

1. `.xcconfig` 파일(예: `Config/Secrets.xcconfig`)에 `ALAN_API_KEY`를 정의합니다.
2. 런타임에서는 `ProcessInfo.processInfo.environment["ALAN_API_KEY"]`로 값을 읽고, `URLRequest` 헤더에 `Authorization`을 설정합니다.
3. 로컬 개발자는 `.xcconfig.local`을 사용하고 저장소에는 커밋하지 않습니다.
4. CI/CD 파이프라인은 `xcodebuild` 실행 전 `export ALAN_API_KEY=...` 식으로 동일한 변수를 주입합니다.
