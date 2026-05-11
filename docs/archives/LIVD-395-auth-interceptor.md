# LIVD-395 AuthInterceptor 구현

## 배경
- `LivithNetworking` 모듈에 `Token`, `TokenStore`, `KeychainTokenStore`가 추가되어 토큰 저장과 조회 기반이 마련되었다.
- 현재 `NetworkEndpoint.requiresAuthentication` 값은 존재하지만 `NetworkClient` 요청 생성/전송 흐름에서 사용되지 않는다.
- 인증이 필요한 API 요청에 access token을 삽입하기 위한 interceptor 계층이 필요하다.

## 목표
- `LivithNetworking`에 `RequestInterceptor` 프로토콜과 `AuthInterceptor` 구현체를 추가한다.
- 인증이 필요한 요청에는 `Authorization: Bearer <accessToken>` 헤더를 삽입한다.
- `NetworkClient`가 endpoint의 인증 필요 여부를 판단해 선택적으로 interceptor `adapt`를 수행하게 한다.
- interceptor는 endpoint를 알지 않고, 이미 생성된 `URLRequest`에 필요한 변경만 적용한다.
- 추후 token refresh와 401 retry를 붙일 수 있도록 `retry` 확장 지점을 제공하되, 이번 작업에서는 실제 refresh/retry 동작을 구현하지 않는다.

## 작업 항목
- [x] interceptor 타입 추가
  - `Projects/LivithNetworking/Sources/Interceptor/RequestInterceptor.swift`에 `RequestInterceptor` 프로토콜과 `RetryResult`를 추가한다.
  - public API 흔들림을 줄이기 위해 이번 작업의 시그니처를 아래 형태로 고정한다.

    ```swift
    public protocol RequestInterceptor: Sendable {
        func adapt(
            _ request: URLRequest
        ) async throws(NetworkError) -> URLRequest

        func retry(
            _ request: URLRequest,
            dueTo error: NetworkError,
            response: HTTPURLResponse?,
            retryCount: Int
        ) async -> RetryResult
    }

    public enum RetryResult: Sendable {
        case retry
        case doNotRetry
    }
    ```

  - `retry`는 이번 범위에서 실패를 던질 필요가 없으므로 non-throwing으로 둔다.
  - `RetryResult`는 `NetworkError`가 `Equatable`이 아닌 점과 후속 확장 가능성을 고려해 이번에는 `Equatable`을 채택하지 않는다.
- [x] `AuthInterceptor` 구현
  - `Projects/LivithNetworking/Sources/Interceptor/AuthInterceptor.swift`를 추가한다.
  - `TokenStore`를 주입받고 기본값은 `KeychainTokenStore()`로 둔다.
  - `TokenStore.fetch()`로 access token을 조회해 `Authorization` 헤더를 `Bearer` 형식으로 설정한다.
  - endpoint나 인증 필요 여부를 알지 않고, 전달받은 `URLRequest`에 헤더만 적용한다.
  - 토큰 조회 실패는 토큰 원문이나 내부 오류 메시지를 노출하지 않고 `NetworkError.unauthorized(message: nil)`로 매핑한다.
  - `retry`는 이번 범위에서 항상 `.doNotRetry`를 반환한다.
- [x] `NetworkClient`에 interceptor 연결
  - `NetworkClient`가 optional `RequestInterceptor`를 주입받도록 한다.
  - public initializer의 기본 interceptor 값은 `nil`로 두어 기존 동작과 테스트를 보존한다.
  - 테스트 가능한 구성을 위해 internal initializer에도 optional interceptor 파라미터를 추가한다.
  - public initializer는 전달받은 interceptor를 internal initializer로 전달한다.
  - `RequestBuilder`로 만든 요청을 transport로 넘기기 전에 `endpoint.requiresAuthentication == true`이고 interceptor가 있으면 `adapt`를 호출한다.
  - `endpoint.requiresAuthentication == false`이면 interceptor가 있더라도 `adapt`를 호출하지 않고 원본 요청을 transport로 전달한다.
  - endpoint 인증 여부 판단은 endpoint를 이미 알고 있는 `NetworkClient`가 담당하고, `AuthInterceptor`는 요청 헤더 적용만 담당한다.
  - 이번 작업에서는 `NetworkClient`가 `retry`를 호출하지 않는다.
- [x] 테스트 추가 및 보강
  - `AuthInterceptorTests`를 새로 추가한다.
  - `AuthInterceptorTests`에는 async `TokenStore` 테스트 더블을 두어 fetch 성공/실패를 제어한다.
  - 전달받은 요청에 Authorization 헤더가 삽입되는지 검증한다.
  - 기존 Authorization 헤더가 있으면 Bearer token으로 대체되는지 검증한다.
  - 토큰 조회 실패 시 `NetworkError.unauthorized`가 발생하는지 pattern matching으로 검증한다.
  - 현재 `retry`는 `.doNotRetry`를 반환하는지 pattern matching으로 검증한다.
  - `NetworkClientTests`에 request capture 가능한 `NetworkTransport` 테스트 더블을 추가하거나 기존 `FakeTransport`를 확장한다.
  - `NetworkClientTests`에 호출 여부를 기록하는 `RequestInterceptor` 테스트 더블을 추가한다.
  - 인증 endpoint에서는 interceptor가 적용된 요청이 transport로 전달되는지 검증한다.
  - 비인증 endpoint에서는 interceptor가 호출되지 않고 원본 요청이 transport로 전달되는지 검증한다.
  - 인증 endpoint에서 adapt 실패가 `NetworkError`로 전달되는지 pattern matching으로 검증한다.
- [x] TDD 순서 준수
  - 생산 코드 변경 전 관련 실패 테스트를 먼저 작성한다.
  - 새 타입이 없어 테스트가 컴파일되지 않는 경우, 컴파일에 필요한 최소 선언만 먼저 추가한다.
  - 최소 선언에는 실제 동작 구현을 넣지 않는다.
  - 최소 선언 후 테스트를 실행해 기대 동작 부재로 인한 런타임 실패를 확인한 뒤 구현한다.
  - 구현 후 관련 테스트와 영향 범위의 보호 테스트를 다시 실행한다.

## 영향 범위
- `Projects/LivithNetworking/Sources/Interceptor/RequestInterceptor.swift` 신규 파일
- `Projects/LivithNetworking/Sources/Interceptor/AuthInterceptor.swift` 신규 파일
- `Projects/LivithNetworking/Sources/Client/NetworkClient.swift`
- `Projects/LivithNetworking/Tests/Interceptor/AuthInterceptorTests.swift` 신규 파일
- `Projects/LivithNetworking/Tests/Client/NetworkClientTests.swift`

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| interceptor API 방식 | completion handler / async-await | async-await | `TokenStore`가 async 기반이고 `NetworkClient`도 async API이므로 흐름을 단순하게 유지한다. |
| 프로토콜 의존 타입 | Endpoint 포함 / Foundation + 에러 타입만 사용 | Foundation + 에러 타입만 사용 | interceptor는 이미 생성된 요청만 조정하고 endpoint를 알 필요가 없으므로 `URLRequest`, `HTTPURLResponse`, `NetworkError`만 사용한다. |
| `NetworkClient` 기본 interceptor | `AuthInterceptor()` / `nil` | `nil` | `NetworkEndpoint.requiresAuthentication` 기본값이 `true`이므로 기본 interceptor를 켜면 기존 호출과 테스트가 토큰 조회에 의존하게 된다. |
| 인증 적용 기준 | interceptor 내부에서 `requiresAuthentication` 확인 / `NetworkClient`에서 호출 여부 결정 | `NetworkClient`에서 호출 여부 결정 | endpoint를 이미 알고 있는 `NetworkClient`가 적용 여부를 판단하고, `AuthInterceptor`는 URLRequest 헤더 적용만 담당하게 해 결합을 줄인다. |
| 토큰 조회 실패 매핑 | `invalidRequest` / `unauthorized` / `unknown` | `unauthorized(message: nil)` | 인증 토큰 부재 또는 조회 실패는 요청 인증 실패로 보는 것이 호출자 처리에 적합하며, 내부 토큰 오류 메시지를 외부에 노출하지 않는다. |
| retry 메서드 throwing 여부 | `async throws(NetworkError) -> RetryResult` / `async -> RetryResult` | `async -> RetryResult` | 이번 범위의 `retry`는 항상 재시도하지 않는 결정을 반환하므로 throwing은 과하다. |
| retry 동작 | 즉시 401 retry 구현 / hook만 제공 | hook만 제공 | 이번 범위는 AuthInterceptor 구현까지이며 refresh token 갱신과 실제 401 retry는 추후 작업으로 분리한다. |
| retry 결과 타입 | Bool / enum | `RetryResult` enum | Bool보다 의도가 명확하고, 현재는 `retry`와 `doNotRetry` 두 결정을 단순하게 표현할 수 있다. |
| `RetryResult` Equatable 채택 | 채택 / 미채택 | 미채택 | `NetworkError`가 `Equatable`이 아니고 후속 case 확장 시 제약이 생길 수 있으므로 테스트는 pattern matching으로 작성한다. |

## 주의 사항
- 이번 작업에서는 refresh token으로 access token을 재발급하지 않는다.
- 이번 작업에서는 HTTP 401 응답을 실제 재시도 루프에 연결하지 않는다.
- 토큰, 인증 응답 원문, 사용자 식별값을 로그나 테스트 fixture에 노출하지 않는다.
- 테스트 토큰 값은 실제 토큰이 아닌 `test-access-token` 같은 명백한 더미 값을 사용한다.
- 인증 토큰은 `UserDefaults` 계열 저장소에 저장하지 않는다.
- 기존 `NetworkClient` public API 사용처가 깨지지 않도록 initializer 기본값과 기존 테스트를 보존한다.
- `RequestInterceptor`와 `AuthInterceptor`는 모듈 외부 조립부에서 사용할 수 있어야 하므로 필요한 타입과 initializer만 `public`으로 공개한다.
- 새 Swift 파일의 헤더와 import 순서는 같은 모듈의 기존 파일 형식을 따른다.
- `NetworkError`는 `Equatable`이 아니므로 테스트의 에러 검증은 equality 비교가 아닌 `catch .unauthorized` 같은 pattern matching으로 수행한다.

## 검증 방법
- 테스트 실행 명령은 `xcodebuild`를 사용한다.
- 파일 또는 폴더 구조가 변경된 경우 빌드나 테스트를 실행하기 전에 `tuist generate`를 먼저 실행한다.
- 구현 단계에서 사용 가능한 scheme 또는 test 명령을 확인한다.
- `LivithNetworkingTests` 중 interceptor 및 client 관련 테스트를 실행한다.
- 가능하면 전체 `LivithNetworkingTests`를 실행해 기존 요청 생성, 응답 처리, 토큰 저장 테스트의 회귀를 확인한다.
- 테스트 실행이 환경 문제로 불가능하면 실행 명령과 실패 원인을 기록하고, 컴파일 영향 범위를 수동 점검한다.
