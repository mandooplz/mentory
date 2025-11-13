# Alan API 사용법

## 목차

- [Alan API 사용법](#alan-api-사용법)
  - [목차](#목차)
  - [개요](#개요)
  - [준비 사항](#준비-사항)
    - [Alan 프로젝트와 API 키](#alan-프로젝트와-api-키)
    - [Mentory에서 키 관리하기](#mentory에서-키-관리하기)
  - [API 기본 정보](#api-기본-정보)
    - [Base URL과 인증](#base-url과-인증)
    - [공통 파라미터](#공통-파라미터)
  - [지원 엔드포인트](#지원-엔드포인트)
    - [질문하기 (REST)](#질문하기-rest)
    - [질문하기 (SSE Streaming)](#질문하기-sse-streaming)
    - [에이전트 상태 초기화](#에이전트-상태-초기화)
  - [Swift 연동 가이드](#swift-연동-가이드)
    - [REST 호출 빌더](#rest-호출-빌더)
    - [SSE 스트림 처리](#sse-스트림-처리)
    - [상태 초기화 요청](#상태-초기화-요청)
  - [오류 스키마](#오류-스키마)
  - [체크리스트](#체크리스트)
  - [참고 자료](#참고-자료)

## 개요

ESTsoft Alan LLM API는 Mentory에서 감정 분석, 맞춤형 위로 멘트, Todo 추천을 생성하는 핵심 서비스입니다. `docs/alan-api/alan_api.pdf`에서 제공되는 사양을 바탕으로 Mentory-iOS에서 Alan API를 호출할 때 필요한 공통 규칙과 구현 패턴을 정리했습니다.

> Mentory에서는 Domain 계층의 `MentoryLLM` 모듈 하나만 Alan API를 직접 호출하도록 하고, Presentation 계층에는 도메인 DTO만 노출합니다.

## 준비 사항

### Alan 프로젝트와 API 키

1. Alan 콘솔에서 Mentory용 프로젝트를 생성합니다.
2. 프로젝트 관리자만 접근 가능한 `Secret Key`를 발급받습니다.
3. 운영/스테이징/개발 환경별로 서로 다른 키를 발급하고 권한을 분리합니다.

### Mentory에서 키 관리하기

1. `.xcconfig` 파일(예: `Config/Secrets.xcconfig`)에 `ALAN_API_KEY`를 정의합니다.
2. 런타임에서는 `ProcessInfo.processInfo.environment["ALAN_API_KEY"]`로 값을 읽고, `URLRequest` 헤더에 `Authorization`을 설정합니다.
3. 로컬 개발자는 `.xcconfig.local`을 사용하고 저장소에는 커밋하지 않습니다.
4. CI/CD 파이프라인은 `xcodebuild` 실행 전 `export ALAN_API_KEY=...` 식으로 동일한 변수를 주입합니다.

## API 기본 정보

### Base URL과 인증

- 기본 호스트: Alan 콘솔에서 제공하는 베이스 URL (예: `https://alan.estsoft.com`)
- 모든 요청 헤더에 `Authorization: Bearer <ALAN_API_KEY>`를 포함합니다.
- Mentory 고유 추적을 위해 `X-Client-Id` 또는 `client_id` 쿼리 파라미터에 UUID를 사용합니다.

### 공통 파라미터

| 이름        | 위치       | 타입   | 설명                                                                        |
| ----------- | ---------- | ------ | --------------------------------------------------------------------------- |
| `client_id` | Query/Body | String | 사용자를 식별하는 UUID. Mentory에서는 `LLMSession.id` 등 도메인 값으로 맵핑 |
| `content`   | Query      | String | Alan에게 던질 질문/프롬프트 문자열                                          |

`client_id`는 SSE, REST, 상태 초기화 요청에서 모두 사용되므로 모델 객체(`AlanSessionContext`)로 묶어 관리하면 좋습니다.

## 지원 엔드포인트

### 질문하기 (REST)

- **Method / Path**: `GET /api/v1/question`
- **Query**:
  - `content` _(required)_: 사용자 질문 또는 감정 로그
  - `client_id` _(required)_: Mentory가 발급한 세션 ID
- **200 응답 예시**:

```json
{
  "action": {
    "name": "search_web",
    "speak": "검색 결과를 바탕으로 답변을 생성하고 있어요."
  },
  "content": "String Result"
}
```

- **422 응답**: `HTTPValidationError` 스키마 반환

이 엔드포인트는 Mentory의 빠른 질의·응답이나 비동기 요약 결과를 가져올 때 사용합니다.

### 질문하기 (SSE Streaming)

- **Method / Path**: `GET /api/v1/question/sse-streaming`
- **Query**:
  - `client_id` _(required)_
  - `content` _(required)_
- **200 응답**: Server-Sent Events. 각 이벤트는 아래 형식을 따릅니다.

```
id: 1740718688940
event: response
data: {
  "type": "continue",
  "data": { "content": "이스트" }
}
```

`type`이 `continue`이면 추가 토큰이 도착한다는 의미이고, `complete`이면 응답 종료를 뜻합니다. Mentory에서는 `URLSession.shared.bytes(for:)`를 사용해 스트림을 읽으며, UI에는 누적 문자열을 렌더링합니다.

### 에이전트 상태 초기화

- **Method / Path**: `DELETE /api/v1/reset-state`
- **Body** (`ResetAgentStateRequest`):

```json
{
  "client_id": "abcd1234-efgh-5i6j-7kl8-901m2n3o45p6"
}
```

- **200 응답**: `null` (성공)
- **422 응답**: `HTTPValidationError`

주로 사용자가 Mentory 계정을 리셋하거나 LLM 캐시를 초기화하고 싶을 때 호출합니다.

## Swift 연동 가이드

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

## 오류 스키마

`HTTPValidationError`와 `ValidationError` 구조체는 Alan이 파라미터 검증에 실패했을 때 반환하는 공통 스키마입니다.

```json
{
  "detail": [
    {
      "loc": ["string", 0],
      "msg": "string",
      "type": "string"
    }
  ]
}
```

- `loc`: 오류 위치(필드명, 인덱스 등)
- `msg`: 사람이 읽을 수 있는 에러 메시지
- `type`: FastAPI 스타일의 오류 코드

Mentory에서는 `AlanValidationError` 모델로 변환해 사용자 로그에 기록하고, 심각한 케이스는 Sentry에 전송합니다.

## 체크리스트

- [ ] Alan 콘솔에서 환경별 API 키를 분리했는가?
- [ ] 모든 요청에 `client_id`가 포함되는가?
- [ ] REST/SSE 호출이 `MentoryLLM` 계층 안으로 격리되어 있는가?
- [ ] `HTTPValidationError`에 대한 로깅과 사용자 대응 로직이 있는가?
- [ ] SSE 스트림 중단 시 재시도 또는 graceful fallback이 구현되어 있는가?
- [ ] `reset-state` 호출 후 로컬 캐시/SwiftData를 함께 초기화하는가?

## 참고 자료

- Alan API 사양 PDF: `docs/alan-api/alan_api.pdf`
- Mentory-iOS 아키텍처 개요 (`docs/swiftui-combine-mvvm/README.md`)
- Swift Concurrency 가이드 (`docs/mvvm-swift-concurrency/README.md`)
