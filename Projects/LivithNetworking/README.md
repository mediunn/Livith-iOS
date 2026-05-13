# LivithNetworking

`LivithNetworking`은 기존 `LivithNetwork`를 바로 대체하지 않는 신규 네트워킹 모듈이다. 현재 단계에서는 외부 라이브러리 없이 `RequestBuilder`, transport, `ResponseHandler`, Keychain 기반 토큰 저장소, 인증 헤더 삽입, refresh token 기반 재발급, 401 refresh/retry, plugin 기반 요청/응답 생명주기 확장 흐름까지 연결한다.

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
    Done --> TokenStore[Keychain 기반 TokenStore]
    Done --> Interceptor[AuthInterceptor]
    Done --> RefreshService[TokenRefreshService]
    Done --> TokenManager[TokenManager]
    Done --> Retry[401 refresh / retry]
    Done --> Plugin[NetworkPlugin]
    Done --> DebugPlugin[DebugNetworkPlugin]

    Out --> Cache[cache / ETag]
    Out --> Logout[refresh 실패 시 로그아웃/토큰 삭제]
    Out --> DI[앱/데이터 레이어 DI 등록]
    Out --> Migration[기존 LivithNetwork 대체]

    Next --> DI
    Next --> Logout
    Next --> Cache
    DI --> Migration
    Logout --> Migration
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

    class NetworkEndpoint {
        +path: String
        +method: HTTPMethod
        +task: RequestTask
        +headers: [String: String]
        +requiresAuthentication: Bool
    }

    class RequestInterceptor {
        <<protocol>>
        +adapt(URLRequest) URLRequest
        +retry(URLRequest, NetworkError, HTTPURLResponse, retryCount) RetryResult
    }

    class NetworkPlugin {
        <<protocol>>
        +prepare(URLRequest, NetworkEndpoint) URLRequest
        +willSend(URLRequest, NetworkEndpoint)
        +didReceive(Result, URLRequest, NetworkEndpoint)
    }

    class DebugNetworkPlugin {
        +willSend(URLRequest, NetworkEndpoint)
        +didReceive(Result, URLRequest, NetworkEndpoint)
    }

    class AuthInterceptor {
        +adapt(URLRequest) URLRequest
        +retry(URLRequest, NetworkError, HTTPURLResponse, retryCount) RetryResult
    }

    class TokenManager {
        <<protocol>>
        +accessToken() String
        +refresh()
    }

    class TokenManagerImpl {
        +accessToken() String
        +refresh()
    }

    class TokenRefreshService {
        <<protocol>>
        +refresh(refreshToken) Token
    }

    class TokenRefreshServiceImpl {
        +refresh(refreshToken) Token
    }

    class TokenStore {
        <<protocol>>
        +save(Token)
        +fetch() Token
        +remove()
        +isRefreshTokenExpired() Bool
    }

    class KeychainTokenStore {
        +save(Token)
        +fetch() Token
        +remove()
        +isRefreshTokenExpired() Bool
    }

    class Token {
        +accessToken: String
        +refreshToken: String
        +refreshTokenIssuedAt: Date
    }

    NetworkClient --> NetworkEndpoint
    NetworkClient --> RequestInterceptor
    NetworkClient --> NetworkPlugin
    AuthInterceptor ..|> RequestInterceptor
    DebugNetworkPlugin ..|> NetworkPlugin
    AuthInterceptor --> TokenManager
    TokenManagerImpl ..|> TokenManager
    TokenManagerImpl --> TokenStore
    TokenManagerImpl --> TokenRefreshService
    TokenRefreshServiceImpl ..|> TokenRefreshService
    TokenRefreshServiceImpl --> NetworkClient
    KeychainTokenStore ..|> TokenStore
    KeychainTokenStore --> Token
```

## 요청 흐름

```mermaid
sequenceDiagram
    participant Caller
    participant Client as NetworkClient
    participant Builder as RequestBuilder
    participant Plugin as NetworkPlugin
    participant Interceptor as AuthInterceptor
    participant Manager as TokenManager
    participant Transport as NetworkTransport
    participant Handler as ResponseHandler

    Caller->>Client: request(endpoint)
    Client->>Builder: build(endpoint, config)
    Builder-->>Client: URLRequest
    Client->>Plugin: prepare(request, endpoint)
    Plugin-->>Client: prepared request
    alt requiresAuthentication == true
        Client->>Interceptor: adapt(prepared request)
        Interceptor->>Manager: accessToken()
        Manager-->>Interceptor: access token
        Interceptor-->>Client: Authorization 적용 request
    end
    Client->>Plugin: willSend(request, endpoint)
    Client->>Transport: data(for: request)
    Transport-->>Client: Data + HTTPURLResponse
    Client->>Plugin: didReceive(success, request, endpoint)
    alt 401 && requiresAuthentication && retryCount == 0
        Client->>Interceptor: retry(...)
        Interceptor->>Manager: refresh()
        Manager-->>Interceptor: refresh 완료
        Interceptor-->>Client: .retry
        Client->>Plugin: prepare(originalRequest, endpoint)
        Client->>Interceptor: adapt(prepared originalRequest)
        Interceptor->>Manager: accessToken()
        Manager-->>Interceptor: refreshed access token
        Client->>Plugin: willSend(re-adapted request, endpoint)
        Client->>Transport: data(for: re-adapted request)
        Transport-->>Client: Data + HTTPURLResponse
        Client->>Plugin: didReceive(success, re-adapted request, endpoint)
    end
    Client->>Handler: handle(data, response)
    Handler-->>Client: decoded value
    Client-->>Caller: value 또는 Void
```

## 401 refresh/retry 정책

```mermaid
flowchart TD
    Response[HTTPURLResponse]
    Auth{requiresAuthentication?}
    Status{statusCode == 401?}
    Count{retryCount == 0?}
    Refresh[TokenManager.refresh]
    Retry[원 요청 재-prepare/re-adapt 후 재전송]
    NoRetry[재시도하지 않음]
    Failure[NetworkError 전달]

    Response --> Auth
    Auth -- no --> NoRetry
    Auth -- yes --> Status
    Status -- no --> NoRetry
    Status -- yes --> Count
    Count -- no --> NoRetry
    Count -- yes --> Refresh
    Refresh -- success --> Retry
    Refresh -- failure --> Failure
```

- retry 대상은 인증 endpoint의 401 응답만이다.
- retry 횟수는 최대 1회로 고정한다.
- 재시도 시 실패한 adapted request를 재사용하지 않고 원 요청에 plugin `prepare`와 interceptor `adapt`를 다시 적용한다.
- refresh 실패 시 원 요청을 재전송하지 않고 `NetworkError`를 전달한다.
- 비인증 endpoint는 `adapt`와 `retry` hook을 모두 호출하지 않는다.
- plugin hook은 인증 여부와 무관하게 호출한다.

## 에러 경계

```mermaid
flowchart TD
    Build[RequestBuildError]
    Transport[transport Error]
    NonHTTP[Non-HTTP URLResponse]
    Response[ResponseError]
    Refresh[refresh 실패]

    InvalidURL[invalidURL]
    Encoding[encodingFailed]
    Cancelled[cancelled]
    Timeout[timeout]
    Connection[noConnection]
    Unknown[unknown]
    InvalidResponse[invalidResponse]
    NoData[noData]
    Decoding[decodingFailed]
    HTTP[HTTP status mapping]
    RefreshError[NetworkError 전달]

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
    Refresh --> RefreshError

    HTTP --> BadRequest[badRequest]
    HTTP --> Unauthorized[unauthorized]
    HTTP --> Forbidden[forbidden]
    HTTP --> NotFound[notFound]
    HTTP --> ClientError[clientError]
    HTTP --> ServerError[serverError]
```

## 에러 처리 예시

```swift
do {
    let value: SomeResponse = try await client.request(endpoint)
} catch .unauthorized(let message) {
    // refresh/retry 후에도 401이거나 refresh에 실패한 경우.
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
    Interceptor[Sources/Interceptor]
    Plugin[Sources/Plugin]
    Token[Sources/Token]
    Service[Sources/Service]
    DTO[Sources/DTO]
    ClientTests[Tests/Client]
    InterceptorTests[Tests/Interceptor]
    PluginTests[Tests/Plugin]
    TokenTests[Tests/Token]

    Root --> Sources
    Root --> Tests
    Sources --> Request
    Sources --> Response
    Sources --> Client
    Sources --> Interceptor
    Sources --> Plugin
    Sources --> Token
    Sources --> Service
    Sources --> DTO
    Tests --> ClientTests
    Tests --> InterceptorTests
    Tests --> PluginTests
    Tests --> TokenTests

    Client --> NetworkClient[NetworkClient.swift]
    Client --> NetworkError[NetworkError.swift]
    Client --> Transport[NetworkTransport.swift]

    Interceptor --> RequestInterceptor[RequestInterceptor.swift]
    Interceptor --> AuthInterceptor[AuthInterceptor.swift]

    Plugin --> NetworkPlugin[NetworkPlugin.swift]
    Plugin --> DebugNetworkPlugin[DebugNetworkPlugin.swift]

    Token --> TokenModel[Token.swift]
    Token --> TokenError[TokenError.swift]
    Token --> Expiration[TokenExpirationPolicy.swift]
    Token --> TokenStoreFile[TokenStore.swift]
    Token --> KeychainStorage[KeychainStorage.swift]
    Token --> TokenManagerFile[TokenManager.swift]

    Service --> TokenRefresh[TokenRefreshService.swift]
    DTO --> DTOFile[DTO.swift]
    DTO --> AuthToken[Auth/AuthToken.swift]

    ClientTests --> NetworkClientTests[NetworkClientTests.swift]
    InterceptorTests --> AuthInterceptorTests[AuthInterceptorTests.swift]
    PluginTests --> NetworkPluginTests[NetworkPluginTests.swift]
    PluginTests --> DebugNetworkPluginTests[DebugNetworkPluginTests.swift]
    TokenTests --> TokenModelTests[TokenTests.swift]
    TokenTests --> ExpirationTests[TokenExpirationPolicyTests.swift]
    TokenTests --> KeychainStoreTests[KeychainTokenStoreTests.swift]
    TokenTests --> TokenRefreshTests[TokenRefreshServiceTests.swift]
    TokenTests --> TokenManagerTests[TokenManagerTests.swift]
```

## 사용 형태

### 비인증 또는 interceptor 없는 요청

```swift
let client = NetworkClient(
    config: NetworkConfig(baseURL: baseURL)
)

let value: SomeResponse = try await client.request(endpoint)
try await client.request(voidEndpoint)
```

### 인증 요청

```swift
let config = NetworkConfig(baseURL: baseURL)
let authInterceptor = AuthInterceptor(config: config)
let client = NetworkClient(
    config: config,
    interceptor: authInterceptor
)

let value: SomeResponse = try await client.request(authenticatedEndpoint)
```

### 직접 조립

```swift
let tokenStore: any TokenStore = KeychainTokenStore()
let tokenRefreshService: any TokenRefreshService = TokenRefreshServiceImpl(config: config)
let tokenManager: any TokenManager = TokenManagerImpl(
    tokenStore: tokenStore,
    tokenRefreshService: tokenRefreshService
)
let authInterceptor = AuthInterceptor(tokenManager: tokenManager)
let client = NetworkClient(config: config, interceptor: authInterceptor)
```

### 디버그 플러그인

```swift
#if DEBUG
let client = NetworkClient(
    config: config,
    interceptor: authInterceptor,
    plugins: [DebugNetworkPlugin()]
)
#else
let client = NetworkClient(
    config: config,
    interceptor: authInterceptor
)
#endif
```

`DebugNetworkPlugin`은 기본적으로 구분선과 모듈명을 포함한 로그 블록에 method, userinfo/query/fragment를 제거한 URL의 scheme/host/path, status code, 전송 실패 요약만 출력한다. query string, request/response body, request/response header 값은 출력하지 않는다.

## 플러그인과 인터셉터 책임

| 타입 | 책임 | 요청 수정 | 재시도 정책 |
|------|------|-----------|-------------|
| `NetworkPlugin` | 요청/응답 생명주기 확장, 로깅, metrics, activity tracking | `prepare`에서 가능 | 담당하지 않음 |
| `RequestInterceptor` | 인증 헤더 삽입, 401 refresh/retry | `adapt`에서 가능 | `retry`에서 담당 |

## 확정된 결정

```mermaid
flowchart TD
    A[NetworkClient가 NetworkConfig 소유]
    B[NetworkTransport는 internal]
    C[URLSessionTransport는 얇은 위임]
    D[값 응답은 ServerResponse decoding]
    E[void 성공은 2xx만 확인]
    F[void 실패는 ResponseHandler 실패 경로 재사용]
    G[민감한 body 원문 logging 금지]
    H[NetworkError는 의미 기반 case로 노출]
    I[HTTP 에러는 서버 message 보존]
    J[TokenStore는 Keychain payload item 1개 사용]
    K[토큰 원문 logging 금지]
    L[AuthInterceptor는 TokenManager 의존]
    M[401 retry는 최대 1회]
    N[retry 시 원 요청 재-prepare/re-adapt]
    O[NetworkPlugin은 prepare/willSend/didReceive만 제공]
    P[DebugNetworkPlugin은 query/body/header 미출력]

    A --> B --> C
    D --> E --> F
    G --> P
    H --> I
    J --> K
    L --> M --> N
    O --> P
```

## LocalizedError 및 보안 정책

- `NetworkError`는 `LocalizedError`를 채택한다.
- `TokenError`는 `LocalizedError`를 채택한다.
- HTTP 에러의 `errorDescription`은 서버 `message`가 있으면 포함한다.
- response body 원문은 logging하거나 설명 문구에 포함하지 않는다.
- request body 원문은 logging하지 않는다.
- 토큰 원문, refresh token, Authorization 헤더 전체 값, Cookie, Set-Cookie, API key, Keychain payload 원문은 logging하거나 설명 문구에 포함하지 않는다.
- `DebugNetworkPlugin`은 URL userinfo, query string, fragment, request/response header 값을 기본 출력하지 않는다.
- 토큰과 비밀값은 `UserDefaults` 계열 저장소에 저장하지 않는다.

## 검증

```bash
tuist generate
xcodebuild test -workspace Livith-iOS.xcworkspace -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17'
git diff --check
```

## 관련 문서

- `docs/designs/LIVD-298-livith-networking-boundary.md`
- `docs/designs/LIVD-298-livith-networking-basic-request.md`
- `docs/designs/LIVD-298-livith-networking-response.md`
- `docs/designs/LIVD-298-livith-networking-client.md`
- `docs/designs/LIVD-395-livith-networking-token-store.md`
- `docs/archives/LIVD-395-livith-networking-token-management.md`
- `docs/archives/LIVD-395-livith-networking-token-management-troubleshooting.md`
- `docs/archives/LIVD-399-networking-plugin.md`
