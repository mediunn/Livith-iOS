# LIVD-395 LivithNetworking Token Management

## 배경
- `LivithNetworking`은 요청 생성, 전송, 응답 처리 경계를 먼저 고정한 신규 네트워킹 모듈이다.
- 인증 요청 처리와 401 refresh/retry를 구현하기 위해 토큰 저장소, 인증 interceptor, refresh API 호출 서비스, 토큰 생명주기 관리 객체가 단계적으로 필요했다.
- 토큰은 보안에 영향을 주므로 `UserDefaults` 계열 저장소를 사용하지 않고 Keychain 기반 저장소로 분리한다.
- 인터셉터가 토큰 저장소와 refresh API 호출을 직접 조합하지 않도록, 저장/조회/refresh/save orchestration을 별도 객체로 분리한다.

## 목표
- `LivithNetworking`에 토큰 저장, 인증 헤더 삽입, refresh API 호출, 토큰 refresh orchestration 기반을 구축한다.
- `TokenStore`와 `KeychainTokenStore`로 토큰을 안전하게 저장/조회/삭제한다.
- `RequestInterceptor`와 `AuthInterceptor`로 인증 요청에 access token을 삽입한다.
- `TokenRefreshService`로 refresh token 기반 토큰 재발급 API를 호출한다.
- `TokenManager`로 `TokenStore`와 `TokenRefreshService`를 조합해 `fetch → refresh → save` 흐름을 관리한다.
- 이번 통합 범위에서는 `AuthInterceptor`에 실제 401 refresh/retry를 연결하지 않는다.

## 작업 항목

### 1. 토큰 저장소
- [x] `Token` 모델 추가
  - `accessToken`, `refreshToken`, `refreshTokenIssuedAt`을 가진 `Codable`, `Equatable`, `Sendable` 모델을 추가한다.
- [x] `TokenError` 추가
  - 저장/조회/삭제/인코딩/디코딩 실패를 표현하는 `LocalizedError`, `Sendable` 에러를 추가한다.
- [x] `TokenExpirationPolicy` 추가
  - refresh token 발급 시각 기준 3일 초과 시 만료로 판단한다.
- [x] `TokenStore` 프로토콜 추가
  - `save(_:)`, `fetch()`, `remove()`, `isRefreshTokenExpired()`를 제공한다.
- [x] `KeychainTokenStore` 구현
  - `Token` 전체를 하나의 Codable payload로 인코딩해 Keychain item 1개에 저장한다.
  - 저장/조회/삭제/만료 판단을 제공한다.
- [x] `KeychainStorage` 구현
  - Security API 접근을 internal 추상화로 분리한다.
  - `SecItemUpdate`, `SecItemAdd`, `SecItemCopyMatching`, `SecItemDelete`를 감싼다.
- [x] 토큰 저장소 테스트 추가
  - 저장/조회/삭제/디코딩 실패/Keychain 에러 매핑/만료 판단을 검증한다.

### 2. 인증 Interceptor
- [x] `RequestInterceptor` 프로토콜과 `RetryResult` 추가
  - `adapt`와 향후 retry 확장을 위한 `retry` 메서드를 정의한다.
- [x] `AuthInterceptor` 구현
  - `TokenStore.fetch()`로 access token을 조회해 `Authorization: Bearer <token>` 헤더를 설정한다.
  - 토큰 조회 실패는 `NetworkError.unauthorized(message: nil)`로 매핑한다.
  - 현재 `retry`는 항상 `.doNotRetry`를 반환한다.
- [x] `NetworkClient`에 interceptor 연결
  - `NetworkEndpoint.requiresAuthentication == true`이고 interceptor가 있으면 `adapt`를 호출한다.
  - 비인증 endpoint에서는 interceptor를 호출하지 않는다.
  - 이번 단계에서는 `NetworkClient`가 `retry`를 호출하지 않는다.
- [x] interceptor/client 테스트 추가
  - Authorization 헤더 삽입/대체, 토큰 조회 실패, 비인증 요청 미적용, adapt 실패 전파를 검증한다.

### 3. Token Refresh Service
- [x] DTO 네임스페이스 추가
  - `DTO.Request.Token`, `DTO.Response.Token`으로 refresh 요청/응답 모델을 정의한다.
- [x] `TokenRefreshService` 프로토콜 추가
  - refresh token을 입력받아 새 `Token`을 반환하는 API를 정의한다.
- [x] `TokenRefreshServiceImpl` 구현
  - 내부적으로 `NetworkClient`를 사용한다.
  - `POST /auth/refresh?client=mobile` 요청을 보낸다.
  - refresh endpoint는 `requiresAuthentication: false`로 호출한다.
  - 응답의 access/refresh token과 클라이언트 현재 시각으로 `Token`을 생성한다.
- [x] refresh API single-flight 적용
  - 진행 중인 refresh 네트워크 요청이 있으면 기존 작업 결과를 공유한다.
- [x] refresh service 테스트 추가
  - 성공 응답 변환, 요청 구성, 에러 전달, single-flight를 검증한다.

### 4. Token Manager
- [x] `TokenManager` 프로토콜 추가
  - access token 조회와 token refresh를 위한 최소 API를 정의한다.
- [x] `TokenManagerImpl` 구현
  - `TokenStore`에서 저장된 토큰을 조회한다.
  - 저장된 refresh token으로 `TokenRefreshService.refresh`를 호출한다.
  - refresh 성공 시 새 토큰을 `TokenStore.save`로 저장한다.
- [x] 에러 매핑 정책 적용
  - `TokenStore.fetch()` 실패는 `NetworkError.unauthorized(message: nil)`로 매핑한다.
  - `TokenRefreshService.refresh()` 실패는 원래 `NetworkError`를 전달한다.
  - `TokenStore.save()` 실패는 `NetworkError.unknown(TokenError)`으로 매핑한다.
- [x] refresh orchestration single-flight 적용
  - 동시에 여러 refresh가 호출되면 `fetch → refresh → save` 전체 흐름을 1회만 수행하고 결과를 공유한다.
- [x] `TokenManager` 테스트 추가
  - access token 조회, 저장 토큰 조회 실패, refresh token 전달, 새 토큰 저장, refresh 실패 시 저장 방지, 저장 실패 매핑, single-flight를 검증한다.

## 영향 범위
- `Projects/LivithNetworking/Sources/Token/Token.swift`
- `Projects/LivithNetworking/Sources/Token/TokenError.swift`
- `Projects/LivithNetworking/Sources/Token/TokenExpirationPolicy.swift`
- `Projects/LivithNetworking/Sources/Token/TokenStore.swift`
- `Projects/LivithNetworking/Sources/Token/KeychainStorage.swift`
- `Projects/LivithNetworking/Sources/Token/TokenManager.swift`
- `Projects/LivithNetworking/Sources/Interceptor/RequestInterceptor.swift`
- `Projects/LivithNetworking/Sources/Interceptor/AuthInterceptor.swift`
- `Projects/LivithNetworking/Sources/Client/NetworkClient.swift`
- `Projects/LivithNetworking/Sources/DTO/DTO.swift`
- `Projects/LivithNetworking/Sources/DTO/Auth/AuthToken.swift`
- `Projects/LivithNetworking/Sources/Service/TokenRefreshService.swift`
- `Projects/LivithNetworking/Tests/Token/TokenTests.swift`
- `Projects/LivithNetworking/Tests/Token/TokenExpirationPolicyTests.swift`
- `Projects/LivithNetworking/Tests/Token/KeychainTokenStoreTests.swift`
- `Projects/LivithNetworking/Tests/Token/TokenRefreshServiceTests.swift`
- `Projects/LivithNetworking/Tests/Token/TokenManagerTests.swift`
- `Projects/LivithNetworking/Tests/Interceptor/AuthInterceptorTests.swift`
- `Projects/LivithNetworking/Tests/Client/NetworkClientTests.swift`
- `Projects/LivithNetworking/README.md`

## 제외 범위
- `AuthInterceptor`의 실제 401 refresh/retry 연결
- `NetworkClient`의 retry loop 구현
- refresh 실패 시 토큰 삭제 정책
- refresh 실패 시 로그아웃 알림 또는 재로그인 알림
- 앱/데이터 레이어 DI 등록
- 기존 `Projects/Core/LivithNetwork` 수정 또는 기존 Keychain item 호환
- 메모리 캐시

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 토큰 저장소 공개 경계 | `TokenStore`, `TokenService`, client 통합 | `TokenStore` | 저장/조회 책임만 먼저 고정하고 refresh orchestration은 별도 객체로 분리한다. |
| 기본 저장소 | Keychain, UserDefaults, 파일 저장 | Keychain | 토큰과 비밀값은 `UserDefaults`에 저장하지 않는다. |
| 저장 방식 | 필드별 item 여러 개, payload item 1개 | payload item 1개 | 부분 저장 실패 상태를 줄이고 필드 확장을 단순화한다. |
| 기존 저장소 호환 | 호환, 분리 | 분리 | 기존 `LivithNetwork` item을 실수로 읽거나 삭제하는 사이드이펙트를 피한다. |
| Keychain save 전략 | delete-add, update/add/fallback | update/add/fallback | 저장 중간에 token 없음 상태를 만들지 않는다. |
| 만료 정책 위치 | `Token`, `KeychainTokenStore`, `TokenExpirationPolicy` | `TokenExpirationPolicy` | 현재 시각 의존 로직을 값 모델과 저장소 I/O에서 분리한다. |
| Interceptor API | completion handler, async-await | async-await | `TokenStore`와 `NetworkClient`가 async 기반이므로 흐름을 단순하게 유지한다. |
| 인증 적용 기준 | interceptor 내부 판단, `NetworkClient` 판단 | `NetworkClient` 판단 | endpoint를 알고 있는 쪽에서 인증 필요 여부를 판단하고 interceptor는 요청 보정에 집중한다. |
| `NetworkClient` 기본 interceptor | `AuthInterceptor()`, `nil` | `nil` | 기존 요청과 테스트가 기본 토큰 조회에 의존하지 않도록 한다. |
| retry 동작 | 즉시 구현, hook만 제공 | hook만 제공 | refresh/retry 연결은 후속 작업으로 분리한다. |
| refresh API 호출 객체 이름 | `TokenRefresher`, `TokenRefreshService` | `TokenRefreshService` | 네트워크 통신 서비스 책임을 명확히 표현한다. |
| refresh 내부 통신 | `URLSession` 직접 사용, `NetworkClient` 사용 | `NetworkClient` 사용 | 요청 구성, 응답 wrapper 처리, 에러 매핑을 모듈 규칙과 일치시킨다. |
| refresh DTO 구조 | private 타입, `DTO.Request/Response` 확장 | `DTO.Request.Token`, `DTO.Response.Token` | 기존 네트워크 모듈의 DTO 네임스페이스 스타일을 따른다. |
| refresh token 발급 시각 | 서버 응답 사용, 클라이언트 현재 시각 사용 | 클라이언트 현재 시각 사용 | 서버 응답에 발급 시각이 없고 `Token` 모델에는 `refreshTokenIssuedAt`이 필요하다. |
| TokenManager 위치 | `Sources/Service`, `Sources/Token` | `Sources/Token` | 네트워크 통신 서비스가 아니라 토큰 생명주기 관리 책임을 갖는다. |
| TokenManager 구현 타입 | `struct`, `final class`, `actor` | `actor` | single-flight 상태를 안전하게 보호하고 토큰 갱신 흐름을 직렬화한다. |
| TokenManager 공개 에러 | `TokenError`, `NetworkError` | `NetworkError` | 이후 interceptor retry 판단과 맞는 에러 타입을 제공한다. |
| single-flight 위치 | refresh service만, manager만, 둘 다 | 둘 다 | 서비스는 네트워크 요청 중복을, manager는 `fetch → refresh → save` 전체 중복을 막는다. |
| refresh 실패 정책 | 토큰 삭제, 로그아웃 알림, 에러 전달만 | 에러 전달만 | 세션 만료 처리는 별도 단계에서 결정한다. |

## 주의 사항
- 토큰 원문, refresh token, 인증 응답 원문, Keychain payload 원문을 로그/문서/테스트 failure message에 남기지 않는다.
- 테스트 토큰 값은 실제 토큰이 아닌 `test-*`, `stored-*`, `refreshed-*` 같은 더미 값을 사용한다.
- `UserDefaults` 계열 저장소에는 토큰이나 비밀값을 저장하지 않는다.
- `*.xcconfig`와 `Projects/App/Resources/GoogleService-Info.plist` 본문을 읽지 않는다.
- 기존 `Projects/Core/LivithNetwork` 파일과 기존 Keychain service/account를 수정하거나 공유하지 않는다.
- 파일 추가 또는 폴더 구조 변경 후 테스트/빌드 전 `tuist generate`를 실행한다.
- 테스트 편의를 위해 운영 객체 생성자에 불필요한 의존성을 추가하지 않는다.
- `NetworkError`는 `Equatable`이 아니므로 테스트는 pattern matching으로 검증한다.
- 새 production throwing API는 가능한 경우 typed throws를 사용한다.
- `KeychainStorageImpl`는 시스템 Security API 연결 구간이므로 fake 기반 단위 테스트와 빌드/선택 검증으로 확인한다.

## 검증 방법
- 각 단계는 가능한 한 테스트를 먼저 작성하고 실패를 확인한 뒤 구현한다.
- 새 타입/메서드가 없어 테스트가 컴파일되지 않으면 컴파일에 필요한 최소 선언만 먼저 추가하고, 동작 구현 없이 런타임 실패를 확인한다.
- 파일 추가 또는 폴더 구조 변경이 있었으면 테스트/빌드 전 `tuist generate`를 실행한다.
- 주요 검증 명령:
  - `xcodebuild test -workspace Livith-iOS.xcworkspace -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17'`
  - `git diff --check`
- 검증 항목:
  - 토큰 저장/조회/삭제/만료 판단이 동작하는가
  - 인증 endpoint에만 Authorization 헤더가 삽입되는가
  - refresh service가 인증 없이 refresh endpoint를 호출하는가
  - refresh service가 응답을 `Token`으로 변환하고 실패를 `NetworkError`로 전달하는가
  - TokenManager가 저장된 refresh token으로 새 토큰을 발급받아 저장하는가
  - TokenManager가 refresh 실패 시 새 토큰을 저장하지 않는가
  - refresh service와 TokenManager의 single-flight가 각각 중복 호출을 방지하는가

## 관련 트러블슈팅 문서
- `docs/archives/LIVD-395-livith-networking-token-management-troubleshooting.md`
