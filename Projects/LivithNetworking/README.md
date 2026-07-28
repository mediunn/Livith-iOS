# LivithNetworking

`LivithNetworking`은 기존 `LivithNetwork`를 대체하는 URLSession 기반 네트워킹 모듈이다. 외부 라이브러리 없이 `RequestBuilder`, transport, `ResponseHandler`, Keychain 기반 토큰 저장소, 인증 헤더 삽입, refresh token 기반 재발급, 401 refresh/retry, plugin 기반 요청/응답 생명주기 확장, ETag 기반 메모리 캐시 흐름까지 연결한다.

기존의 `*Service` 계층(thin wrapper)은 제거하고, `*API` 네임스페이스의 `static func`로 엔드포인트를 정의한다. Repository는 `NetworkClient`를 직접 주입받아 `networkClient.request(*API.method(...))` 형태로 호출한다.

## 현재 범위

```mermaid
flowchart LR
    Done[구현 완료]

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
    Done --> Cache[ETag 메모리 캐시]
    Done --> Builder[NetworkClientBuilder]
    Done --> API["*API 네임스페이스 (10종)"]
    Done --> MockTransport[MockNetworkTransport]
    Done --> Logout[refresh 만료 시 앱 이벤트 전파]
```

## 모듈 경계

```mermaid
flowchart LR
    App[App]
    Feature[Feature Modules]
    Data[Data Modules]
    Net["LivithNetworking<br/>URLSession 기반 네트워크 모듈"]

    App --> Feature
    Feature --> Data
    Data --> Net
```

## 타입 관계

```mermaid
classDiagram
    class NetworkClientBuilder {
        <<enum>>
        +build(config, onAuthExpired, tokenStore)
    }

    class NetworkClient {
        +request(endpoint) T
        +request(endpoint) Void
    }

    class NetworkEndpoint {
        +path: String
        +method: HTTPMethod
        +task: RequestTask
        +headers: [String: String]
        +authentication: AuthenticationPolicy
        +cache: CachePolicy
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

    class MockNetworkTransport {
        +data(for:) async
        +request() URLRequest?
        +requests() [URLRequest]
    }

    class SongAPI {
        <<enum>>
        +fetchLyrics(songID) NetworkEndpoint
        +fetchFanchant(setlistID, songID) NetworkEndpoint
    }

    class SetlistAPI {
        <<enum>>
        +fetchSetlistDetail(concertID, setlistID) NetworkEndpoint
        +fetchSetlistSongList(setlistID) NetworkEndpoint
        +fetchConcertMainSetlist(concertID) NetworkEndpoint
    }

    NetworkClientBuilder --> NetworkClient : build
    NetworkClientBuilder --> TokenStore
    NetworkClientBuilder --> AuthInterceptor
    NetworkClientBuilder --> TokenManagerImpl
    NetworkClientBuilder --> TokenRefreshServiceImpl
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
    MockNetworkTransport ..|> NetworkTransport
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
    alt etagCacheEnabled && GET && cache hit
        Client->>Client: If-None-Match 적용
    end
    Client->>Plugin: willSend(request, endpoint)
    Client->>Transport: data(for: request)
    Transport-->>Client: Data + HTTPURLResponse
    Client->>Plugin: didReceive(success, request, endpoint)
    alt 304 && cache hit
        Client->>Handler: handle(cached data, cached 2xx response)
    else 304 && cache miss
        Client->>Transport: If-None-Match 없이 1회 fallback
    else 200 && ETag exists
        Client->>Client: ETag와 body 저장
    else 200 && ETag missing
        Client->>Client: 기존 cache 삭제
    end
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
- refresh 토큰까지 만료된 경우(401) `onAuthenticationExpired` 클로저를 통해 앱으로 이벤트를 전파한다.
- 비인증 endpoint는 `adapt`와 `retry` hook을 모두 호출하지 않는다.
- plugin hook은 인증 여부와 무관하게 호출한다.

## ETag 캐시 정책

- `etagCacheEnabled == true`인 GET 요청에만 적용한다.
- 캐시는 `NetworkClient` 인스턴스가 소유하는 메모리 저장소를 사용하며, `URLCache`나 디스크 저장소를 사용하지 않는다.
- 캐시 키는 실제 전송 URL 기준의 `HTTP method + absolute URL`이다.
- 200 응답에 `ETag` 헤더가 있으면 ETag와 response body를 저장한다.
- 200 응답에 `ETag` 헤더가 없으면 해당 key의 기존 캐시를 삭제한다.
- 같은 key의 캐시가 있으면 다음 요청에 `If-None-Match`를 추가한다.
- 304 응답이 오면 캐시된 body와 저장된 2xx status metadata를 사용해 기존 decoding 경로로 반환한다.
- 304 응답인데 캐시가 없으면 `If-None-Match` 없이 1회 fallback 요청한다.
- 네트워크 실패 시 기존 캐시를 반환하는 offline fallback은 제공하지 않는다.
- 로그아웃 또는 사용자 전환 시 `await client.removeAllETagCache()`를 호출해 현재 클라이언트의 캐시를 비울 수 있다.

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
    API[Sources/API]
    Foundation[Sources/Foundation]
    DTO[Sources/DTO]
    Testing[Sources/Testing]
    Service[Sources/Service]

    Root --> Sources
    Root --> Tests
    Sources --> API
    Sources --> Foundation
    Sources --> DTO
    Sources --> Testing
    Sources --> Service

    API --> SongAPI[SongAPI.swift]
    API --> SetlistAPI[SetlistAPI.swift]
    API --> ConcertAPI[ConcertAPI.swift]
    API --> CommentAPI[CommentAPI.swift]
    API --> HomeAPI[HomeAPI.swift]
    API --> NotificationAPI[NotificationAPI.swift]
    API --> OnboardingAPI[OnboardingAPI.swift]
    API --> PreferenceAPI[PreferenceAPI.swift]
    API --> SearchAPI[SearchAPI.swift]
    API --> UserAPI[UserAPI.swift]

    Foundation --> Client[Client]
    Foundation --> Request[Request]
    Foundation --> Response[Response]
    Foundation --> Interceptor[Interceptor]
    Foundation --> Plugin[Plugin]
    Foundation --> Token[Token]
    Foundation --> Helper[Helper]

    Client --> NetworkClient[NetworkClient.swift]
    Client --> NetworkClientBuilder[NetworkClientBuilder.swift]
    Client --> NetworkError[NetworkError.swift]
    Client --> NetworkTransport[NetworkTransport.swift]
    Client --> NetworkConfig[NetworkConfig.swift]
    Client --> RequestAttempt[RequestAttempt.swift]

    Testing --> MockNetworkTransport[MockNetworkTransport.swift]
    Service --> TokenRefresh[TokenRefreshService.swift]
```

## 사용 형태

### NetworkClientBuilder로 생성 (권장)

팩토리가 `NetworkClient` + `TokenStore`를 한 번에 생성한다. App에서 `NetworkClientBuilder.build()`로 조립 후 DI 컨테이너에 등록한다.

```swift
// App 진입점
let config = NetworkConfig(baseURL: baseURL)
let onAuthenticationExpired: @Sendable () -> Void = {
    Task { @MainActor in
        NotificationCenter.default.post(
            name: Notification.Name("reloginRequired"),
            object: nil
        )
    }
}
let (client, tokenStore) = NetworkClientBuilder.build(
    config: config,
    onAuthenticationExpired: onAuthenticationExpired
)
container.register(client, for: NetworkClient.self)
container.register(tokenStore, for: TokenStore.self)
```

### DataAssembler에서 주입

```swift
// 각 DataAssembler에서 DI로 NetworkClient resolve
func registerSongRepository(to container: any DependencyContainer) {
    let client = container.resolve(NetworkClient.self)
    let songRepo = SongRepositoryImpl(networkClient: client)
    container.register(songRepo, for: SongRepository.self)
}
```

### Repository에서 사용

```swift
struct SongRepositoryImpl: SongRepository {
    private let networkClient: NetworkClient
    private let mapper: SongMapper = .init()
    private let errorMapper: SongErrorMapper = .init()

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func fetchSongLyrics(songID: Int) async throws(SongError) -> SongLyrics {
        do {
            let response: DTO.Response.FetchSongLyrics = try await networkClient.request(
                SongAPI.fetchSongLyrics(songID: songID)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToSongError(error)
        }
    }
}
```

### 비인증 요청 (interceptor 없음)

```swift
let client = NetworkClient(config: NetworkConfig(baseURL: baseURL))
let value: SomeResponse = try await client.request(endpoint)
try await client.request(voidEndpoint)
```

### 테스트 (MockNetworkTransport)

```swift
let transport = MockNetworkTransport(output: .success(data, response))
let client = NetworkClient(config: config, transport: transport)
let repo = SongRepositoryImpl(networkClient: client)
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
    Q[ETag 캐시는 endpoint Bool opt-in]
    R[ETag 캐시는 GET과 메모리 store만 사용]
    S[304 cache miss는 조건 없이 1회 fallback]
    T["NetworkClientBuilder가 모든 조립 담당"]
    U["TokenManager가 refresh 만료 이벤트 핸들러 소유"]
    V["TokenRefreshService는 순수 API 호출만 담당"]
    W["순환 의존성 방지: 별도 NetworkClient 사용"]
    X["TokenManager / TokenRefreshService / AuthInterceptor는 internal"]
    Y["NetworkClientBuilder는 enum + static func"]
    Z["onAuthenticationExpired는 @Sendable 클로저로 전파"]
    a1["NetworkTransport / NetworkClient / RequestBuilder / ResponseHandler는 Sendable 준수"]

    A --> B --> C
    D --> E --> F
    G --> P
    H --> I
    J --> K
    L --> M --> N
    O --> P
    Q --> R --> S
    T --> U --> V
    W --> X --> Y --> Z --> a1
```
```

## LocalizedError 및 보안 정책

- `NetworkError`는 `LocalizedError`를 채택한다.
- `TokenError`는 `LocalizedError`를 채택한다.
- HTTP 에러의 `errorDescription`은 서버 `message`가 있으면 포함한다.
- response body 원문은 logging하거나 설명 문구에 포함하지 않는다.
- request body 원문은 logging하지 않는다.
- 토큰 원문, refresh token, Authorization 헤더 전체 값, Cookie, Set-Cookie, API key, Keychain payload 원문은 logging하거나 설명 문구에 포함하지 않는다.
- `DebugNetworkPlugin`은 URL userinfo, query string, fragment, request/response header 값을 기본 출력하지 않는다.
- `ETag`와 `If-None-Match` 원문 값은 불필요하게 logging하지 않는다.
- 토큰과 비밀값은 `UserDefaults` 계열 저장소에 저장하지 않는다.

## 검증

```bash
tuist generate
xcodebuild test -workspace Livith-iOS.xcworkspace -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17'
git diff --check
```

