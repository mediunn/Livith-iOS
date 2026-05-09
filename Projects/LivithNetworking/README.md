# LivithNetworking

`LivithNetworking`은 기존 `LivithNetwork`를 바로 대체하지 않는 신규 네트워킹 모듈이다. 현재 단계의 목표는 외부 라이브러리 없이 `RequestBuilder`, transport, `ResponseHandler`를 연결하는 최소 클라이언트 경계를 고정하는 것이다.

## 현재 범위

```mermaid
flowchart LR
    Done[구현 완료]
    Out[현재 제외]
    Next[후속 후보]

    Done --> Request[RequestBuilder]
    Done --> Response[ResponseHandler]
    Done --> Client[NetworkClient]
    Done --> Transport[URLSessionTransport]

    Out --> Auth[인증 토큰 삽입]
    Out --> Refresh[401 refresh / retry]
    Out --> Logging[logging]
    Out --> Cache[cache / ETag]
    Out --> Migration[기존 LivithNetwork 대체]

    Next --> Auth
    Auth --> Refresh
    Refresh --> Migration
    Logging --> Migration
    Cache --> Migration
```

## 모듈 경계

```mermaid
flowchart LR
    App[App]
    Feature[Feature Modules]
    Data[Data Modules]
    Legacy[LivithNetwork<br/>Alamofire 기반 기존 레이어]
    New[LivithNetworking<br/>URLSession 기반 신규 모듈]

    App --> Feature
    Feature --> Data
    Data --> Legacy

    New -.->|현재 단계에서는 독립 구현| Data
    Legacy -.->|아직 수정하거나 대체하지 않음| New
```

## 타입 관계

```mermaid
classDiagram
    class NetworkClient {
        +requestValue(endpoint) T
        +requestVoid(endpoint) Void
    }

    class NetworkConfig {
        +baseURL: URL
    }

    class NetworkEndpoint {
        <<protocol>>
        +path: String
        +method: HTTPMethod
        +task: RequestTask
        +headers: [String: String]
        +requiresAuthentication: Bool
    }

    class RequestBuilder {
        +build(any NetworkEndpoint, NetworkConfig) URLRequest
    }

    class NetworkTransport {
        <<protocol>>
        +data(for: URLRequest) (Data, URLResponse)
    }

    class URLSessionTransport {
        +data(for: URLRequest) (Data, URLResponse)
    }

    class ResponseHandler {
        +handle(data, response) T
    }

    class NetworkError {
        <<LocalizedError>>
        +invalidURL
        +noConnection
        +badRequest
        +unauthorized
        +serverError
    }

    class ServerResponse {
        +statusCode: Int
        +message: String?
        +data: T?
    }

    NetworkClient --> NetworkConfig
    NetworkClient --> RequestBuilder
    NetworkClient --> NetworkTransport
    NetworkClient --> ResponseHandler
    NetworkClient --> NetworkError
    URLSessionTransport ..|> NetworkTransport
    RequestBuilder --> NetworkEndpoint
    ResponseHandler --> ServerResponse
```

## 요청 흐름

```mermaid
sequenceDiagram
    participant Caller
    participant Client as NetworkClient
    participant Builder as RequestBuilder
    participant Transport as NetworkTransport
    participant Handler as ResponseHandler

    Caller->>Client: request(endpoint)
    Client->>Builder: build(endpoint, config)
    Builder-->>Client: URLRequest
    Client->>Transport: data(for: request)
    Transport-->>Client: Data + URLResponse
    Client->>Client: HTTPURLResponse 확인
    Client->>Handler: handle(data, response)
    Handler-->>Client: decoded value
    Client-->>Caller: value 또는 Void
```

## 응답 분기

```mermaid
flowchart TD
    Start[NetworkClient.request]
    Build[RequestBuilder.build]
    Send[NetworkTransport.data]
    HTTP{HTTPURLResponse?}
    API{API 종류}
    Value["request<T: Decodable>"]
    Void[request -> Void]
    Decode["ResponseHandler.handle<br/>ServerResponse<T> decoding"]
    Status{2xx?}
    SuccessValue[decoded value 반환]
    SuccessVoid[Void 성공]
    Failure[NetworkError throw]

    Start --> Build --> Send --> HTTP
    HTTP -- no --> Failure
    HTTP -- yes --> API
    API -- 값 응답 --> Value --> Decode
    API -- void 응답 --> Void --> Status
    Decode -- success --> SuccessValue
    Decode -- failed --> Failure
    Status -- yes --> SuccessVoid
    Status -- no --> Failure
```

## 에러 경계

```mermaid
flowchart TD
    Build[RequestBuildError]
    Transport[transport Error]
    NonHTTP[Non-HTTP URLResponse]
    Response[ResponseError]

    InvalidURL[invalidURL]
    Encoding[encodingFailed(Error)]
    Cancelled[cancelled]
    Timeout[timeout(Error)]
    Connection[noConnection(Error)]
    Unknown[unknown(Error)]
    InvalidResponse[invalidResponse]
    NoData[noData]
    Decoding[decodingFailed(Error)]
    HTTP[HTTP status mapping]

    Build --> InvalidURL
    Build --> Encoding
    Transport --> Cancelled
    Transport --> Timeout
    Transport --> Connection
    Transport --> Unknown
    NonHTTP --> InvalidResponse
    Response --> NoData
    Response --> Decoding
    Response --> HTTP

    HTTP --> BadRequest[badRequest(message)]
    HTTP --> Unauthorized[unauthorized(message)]
    HTTP --> Forbidden[forbidden(message)]
    HTTP --> NotFound[notFound(message)]
    HTTP --> ClientError[clientError(statusCode, message)]
    HTTP --> ServerError[serverError(statusCode, message)]
```

## 에러 처리 예시

```swift
do {
    let value: SomeResponse = try await client.request(endpoint)
} catch .unauthorized(let message) {
    // 401 refresh/retry는 후속 설계에서 다룬다.
} catch .noConnection {
    // 네트워크 연결 안내
} catch .serverError(let statusCode, let message) {
    // 서버 장애 또는 점검 안내
} catch {
    // errorDescription은 기본 한글 설명을 제공한다.
}
```

## 파일 구조

```mermaid
flowchart TD
    Root[Projects/LivithNetworking]
    Sources[Sources]
    Tests[Tests]
    Request[Sources/Request]
    Response[Sources/Response]
    Client[Sources/Client]
    ClientTests[Tests/Client]

    Root --> Sources
    Root --> Tests
    Sources --> Request
    Sources --> Response
    Sources --> Client
    Tests --> ClientTests

    Request --> HTTPMethod[HTTPMethod.swift]
    Request --> Config[NetworkConfig.swift]
    Request --> Endpoint[NetworkEndpoint.swift]
    Request --> Task[RequestTask.swift]
    Request --> Builder[RequestBuilder.swift]

    Response --> Server[ServerResponse.swift]
    Response --> Empty[EmptyResponse.swift]
    Response --> ResponseErr[ResponseError.swift]
    Response --> Handler[ResponseHandler.swift]

    Client --> NetworkClient[NetworkClient.swift]
    Client --> NetworkError[NetworkError.swift]
    Client --> Transport[NetworkTransport.swift]
    Client --> URLSession[URLSessionTransport.swift]

    ClientTests --> NetworkClientTests[NetworkClientTests.swift]
```

## 사용 형태

```swift
let client = NetworkClient(
    config: NetworkConfig(baseURL: baseURL)
)

let value: SomeResponse = try await client.request(endpoint)
try await client.request(voidEndpoint)
```

## 확정된 결정

```mermaid
flowchart TD
    A[NetworkClient가 NetworkConfig 소유]
    B[NetworkTransport는 internal]
    C[URLSessionTransport는 얇은 위임]
    D["값 응답은 ServerResponse<T> decoding"]
    E[void 성공은 2xx만 확인]
    F["void 실패는 ResponseHandler<EmptyResponse> 실패 경로 재사용"]
    G[민감한 body 원문 logging 금지]
    H[NetworkError는 의미 기반 case로 노출]
    I[HTTP 에러는 서버 message 보존]

    A --> B --> C
    D --> E --> F
    G --> Next[후속 logging 설계에서 유지]
    H --> I
```

## LocalizedError 정책

- `NetworkError`는 `LocalizedError`를 채택한다.
- HTTP 에러의 `errorDescription`은 서버 `message`가 있으면 포함한다.
- response body 원문은 logging하거나 설명 문구에 포함하지 않는다.

## 검증

```bash
tuist generate
xcodebuild test -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1'
git diff --check
```

## 관련 문서

- `docs/designs/LIVD-298-livith-networking-boundary.md`
- `docs/designs/LIVD-298-livith-networking-basic-request.md`
- `docs/designs/LIVD-298-livith-networking-response.md`
- `docs/designs/LIVD-298-livith-networking-client.md`
- `docs/plans/LIVD-298-livith-networking-client.md`
- `docs/plans/LIVD-298-livith-networking-error.md`
- `docs/troubleshooting/LIVD-298-livith-networking.md`
