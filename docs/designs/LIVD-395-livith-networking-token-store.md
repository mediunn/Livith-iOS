# LIVD-395 LivithNetworking 토큰 저장소 설계

## 배경
- `LivithNetworking`은 기존 `LivithNetwork`를 즉시 대체하지 않는 신규 URLSession 기반 네트워킹 모듈이다.
- 기존 `LivithNetwork`에는 Keychain 기반 토큰 저장, access token 조회, refresh token 조회, refresh, 인증 헤더 삽입 흐름이 섞여 있다.
- 신규 모듈에서는 인증 헤더 삽입과 refresh/retry를 구현하기 전에 토큰을 안전하게 저장하고 조회하는 작은 경계가 먼저 필요하다.
- 토큰 저장은 보안에 영향을 주는 기능이므로 `UserDefaults`를 사용하지 않고 Keychain을 사용한다.
- 이번 설계는 기존 저장소와의 Keychain 호환보다 신규 모듈의 단순한 책임 분리와 후속 확장성을 우선한다.

## 목표
- `LivithNetworking`에 토큰 저장/조회/삭제를 담당하는 public `TokenStore` 경계를 둔다.
- `TokenStore`의 기본 구현체로 Keychain 기반 `KeychainTokenStore`를 제공한다.
- 토큰 데이터는 기존 네트워크 모듈과 동일한 `accessToken`, `refreshToken`, `refreshTokenIssuedAt`을 보관한다.
- `Token` 전체를 하나의 `Codable` payload로 인코딩하여 Keychain item 1개에 저장한다.
- refresh token 만료 여부는 `refreshTokenIssuedAt` 기준 3일 정책으로 판단한다.
- Keychain 접근 세부사항은 내부 저장소로 분리해 `KeychainTokenStore`가 Security API에 직접 의존하는 범위를 줄인다.
- 호출부가 저장 실패, 조회 데이터 없음, 삭제 실패, decoding 실패를 분기할 수 있는 `TokenError`를 제공한다.

## 범위
- `Token`은 `Codable`, `Equatable`, `Sendable`을 채택한다.
- `TokenStore`는 `save`, `fetch`, `remove`, `isRefreshTokenExpired`를 제공한다.
- `KeychainTokenStore`는 `TokenStore`를 채택하는 public 기본 구현체로 둔다.
- `KeychainTokenStore`는 매 요청마다 Keychain에 직접 접근하고 메모리 캐시를 갖지 않는다.
- Keychain에는 `Token` payload를 하나의 item으로 저장한다.
- Keychain item의 `kSecAttrAccessible`은 `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`로 둔다.
- 기본 Keychain service/account는 신규 `LivithNetworking` 전용 네임스페이스를 사용한다.
- 테스트 격리를 위해 `KeychainTokenStore` 생성자에서 service 값을 주입할 수 있게 둔다.
- payload 인코딩/디코딩은 `JSONEncoder`, `JSONDecoder`를 사용한다.
- `Date` 인코딩/디코딩 전략은 payload 호환성을 위해 `.secondsSince1970`으로 고정한다.
- refresh token 만료 판단은 `TokenExpirationPolicy`로 분리한다.
- `TokenExpirationPolicy`는 기본 만료 기간 3일을 제공하고 테스트에서 기준 시각을 주입할 수 있게 한다.
- `isRefreshTokenExpired`는 저장된 토큰을 조회하거나 해석할 수 없으면 보수적으로 `true`를 반환한다.
- 저장 시 기존 item이 있으면 삭제하지 않고 update로 교체한다.
- 삭제는 item이 없어도 성공으로 본다.

## 비목표
- 이번 설계에서 인증 헤더 삽입을 구현하지 않는다.
- 이번 설계에서 `NetworkClient`와 `TokenStore`를 연결하지 않는다.
- 이번 설계에서 401 응답 처리, refresh API 호출, 원 요청 retry를 구현하지 않는다.
- 이번 설계에서 메모리 캐시를 구현하지 않는다.
- 이번 설계에서 로그인/로그아웃 use case 또는 repository를 구현하지 않는다.
- 이번 설계에서 재로그인 필요 알림, `NotificationCenter` 연동, UI 상태 변경을 구현하지 않는다.
- 이번 설계에서 기존 `LivithNetwork`의 Keychain item을 읽거나 삭제하지 않는다.
- 이번 설계에서 토큰 원문 logging, 인증 응답 원문 logging을 추가하지 않는다.
- 이번 설계에서 App Group Keychain sharing을 다루지 않는다.
- 이번 설계에서 Keychain 접근 그룹, 생체 인증, iCloud 동기화 정책을 추가하지 않는다.

## 결정
| 결정 사항 | 결정 | 근거 |
|-----------|------|------|
| 공개 경계 | `TokenStore` protocol | 호출부가 구현체가 Keychain인지 알 필요 없고, 후속 캐시/refresh 데코레이터로 확장할 수 있다. |
| 기본 구현체 | `KeychainTokenStore` | 토큰과 비밀값은 `UserDefaults`에 저장하지 않고 Keychain에 저장해야 한다. |
| 저장 모델 | `Token` | 기존 모듈과 같은 토큰 데이터 계약을 유지하되 신규 모듈 타입으로 분리한다. |
| 저장 방식 | `Token` payload item 1개 | access/refresh/issuedAt을 따로 저장하는 중간 실패 상태를 줄이고 필드 확장을 단순화한다. |
| 기존 저장소 호환 | 비호환 | 기존 모듈과 사이드이펙트를 만들지 않고 신규 모듈 저장소를 독립적으로 검증한다. |
| Keychain 네임스페이스 | 신규 service/account | 기존 item과 충돌하거나 기존 토큰을 삭제하는 위험을 줄인다. |
| service 주입 | 생성자 주입 허용 | 테스트 격리와 환경별 분리가 필요하다. |
| 접근 정책 | `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` | 기기가 잠금 해제된 동안만 접근하고 백업/기기 이전 대상에서 제외하는 보수적 정책이다. |
| 메모리 캐시 | 제외 | 토큰의 메모리 체류 시간을 늘리지 않고 저장소 책임을 단순하게 유지한다. |
| 만료 정책 | `TokenExpirationPolicy` | 만료 기간 변경, 기준 시각 주입, 테스트를 저장소 구현에서 분리한다. |
| refresh token 만료 기간 | 3일 | 기존 네트워크 모듈의 토큰 데이터 계약과 만료 판단을 유지한다. |
| payload codec | `JSONEncoder`/`JSONDecoder` | Swift 표준 Foundation만으로 구현 가능하고 필드 추가가 쉽다. |
| Date 전략 | `.secondsSince1970` | 시스템 기본 전략 변화나 사람이 읽는 문자열 포맷 의존을 피한다. |
| `isRefreshTokenExpired` 실패 정책 | 실패 시 `true` | 인증 상태를 낙관하지 않도록 토큰 조회/해석 실패를 만료로 간주한다. |
| 삭제 idempotency | item 없음은 성공 | 로그아웃/정리 흐름에서 이미 삭제된 상태를 실패로 볼 필요가 없다. |
| 에러 노출 | `TokenError: Sendable` | 네트워크 에러와 분리된 저장소 중심 에러 경계를 제공하고 Swift concurrency 경계를 안전하게 넘긴다. |

## API 형태
```swift
public struct Token: Codable, Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let refreshTokenIssuedAt: Date

    public init(
        accessToken: String,
        refreshToken: String,
        refreshTokenIssuedAt: Date
    )
}
```

```swift
public protocol TokenStore: Sendable {
    func save(_ token: Token) async throws(TokenError)
    func fetch() async throws(TokenError) -> Token
    func remove() async throws(TokenError)
    func isRefreshTokenExpired() async -> Bool
}
```

```swift
public actor KeychainTokenStore: TokenStore {
    public init(
        service: String = KeychainTokenStore.defaultService,
        account: String = KeychainTokenStore.defaultAccount,
        expirationPolicy: TokenExpirationPolicy = .default
    )

    public func save(_ token: Token) async throws(TokenError)
    public func fetch() async throws(TokenError) -> Token
    public func remove() async throws(TokenError)
    public func isRefreshTokenExpired() async -> Bool
}
```

- `KeychainTokenStore`는 동시 접근 순서를 단순화하기 위해 `actor`로 둔다.
- `KeychainTokenStore.defaultService`와 `defaultAccount`는 public read-only 상수로 노출할 수 있다.
- `isRefreshTokenExpired()`는 `fetch()`가 `.noToken`, `.decodingFailed`, `.loadFailed` 등으로 실패하면 `true`를 반환한다.
- 저장소 실패 원인을 호출부가 알아야 하는 경우에는 `fetch()`를 직접 호출한다.
- 테스트에서 Security API 자체를 대체해야 하면 implementation-only initializer로 internal `KeychainStorage`를 주입한다.
- public initializer에는 Security API 세부 추상화를 노출하지 않는다.

## 저장 형태
```text
kSecClass: kSecClassGenericPassword
kSecAttrService: com.livith.livith-networking.token-store
kSecAttrAccount: token
kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
kSecValueData: JSONEncoder로 인코딩한 Token payload
```

예시 payload 구조는 아래와 같다. 실제 토큰 값은 문서와 로그에 남기지 않는다.

```json
{
  "accessToken": "<access-token>",
  "refreshToken": "<refresh-token>",
  "refreshTokenIssuedAt": 1770000000
}
```

- Keychain item은 하나만 사용한다.
- `save`는 payload encoding이 성공한 뒤 Keychain write를 수행한다.
- 기존 item이 있으면 `SecItemUpdate`로 `kSecValueData`를 교체하고, item이 없으면 `SecItemAdd`로 새로 추가한다.
- `SecItemAdd`가 `errSecDuplicateItem`으로 실패하면 `SecItemUpdate`를 한 번 시도한다.
- 저장 과정에서 기존 item을 먼저 삭제하지 않는다.
- `JSONEncoder.dateEncodingStrategy`는 `.secondsSince1970`으로 둔다.
- `JSONDecoder.dateDecodingStrategy`는 `.secondsSince1970`으로 둔다.
- `fetch`는 item이 없으면 `.noToken`을 던진다.
- `fetch`는 payload decoding에 실패하면 `.decodingFailed`를 던진다.
- `remove`는 item이 없어도 성공으로 처리한다.

## 만료 정책
```swift
public struct TokenExpirationPolicy: Sendable {
    public static let `default`: TokenExpirationPolicy

    public init(refreshTokenLifetime: TimeInterval)

    public func isRefreshTokenExpired(
        issuedAt: Date,
        now: Date = .now
    ) -> Bool
}
```

- 기본 `refreshTokenLifetime`은 `3 * 24 * 60 * 60`초다.
- `isRefreshTokenExpired`는 `now.timeIntervalSince(issuedAt) > refreshTokenLifetime`이면 만료로 판단한다.
- `now`가 `issuedAt`보다 이전이면 만료되지 않은 것으로 본다.
- `Token` 자체에는 현재 시각 의존 로직을 넣지 않는다.

## 에러 경계
```swift
public enum TokenError: LocalizedError, Sendable {
    case saveFailed
    case loadFailed
    case deleteFailed
    case noToken
    case encodingFailed
    case decodingFailed
    case unknown
}
```

- `saveFailed`는 Keychain write/update가 실패했지만 구체 원인을 호출부 처리 기준으로 노출할 필요가 없는 경우 사용한다.
- `loadFailed`는 Keychain read가 실패했지만 item 없음이 아닌 경우 사용한다.
- `deleteFailed`는 Keychain delete가 실패했고 item 없음이 아닌 경우 사용한다.
- `noToken`은 저장된 token payload가 없는 경우 사용한다.
- `encodingFailed`는 Keychain 접근 전 payload encoding 실패에 사용한다.
- `decodingFailed`는 저장된 payload가 현재 `Token` 모델로 해석되지 않는 경우 사용한다.
- `unknown`은 내부 추상화에서 예상하지 못한 실패를 호출부 처리 기준으로 축약할 때만 사용한다.
- `TokenError`는 Swift concurrency 경계를 안전하게 넘기 위해 원본 `Error` associated value를 보존하지 않는다.
- 내부 원본 에러와 payload 원문은 로그에 남기지 않는다.
- `LocalizedError.errorDescription`은 한글 기본 설명을 제공하되 토큰 원문이나 payload 원문을 포함하지 않는다.

## 내부 Keychain 경계
```swift
protocol KeychainStorage: Sendable {
    func save(_ data: Data, service: String, account: String) throws(KeychainStorageError)
    func load(service: String, account: String) throws(KeychainStorageError) -> Data
    func delete(service: String, account: String) throws(KeychainStorageError)
}

struct KeychainStorageImpl: KeychainStorage {}

enum KeychainStorageError: Error, Sendable {
    case itemNotFound
    case duplicateItem
    case unexpectedStatus(OSStatus)
}
```

- `KeychainStorage`는 internal protocol로 둔다.
- `KeychainStorageImpl`가 `SecItemAdd`, `SecItemUpdate`, `SecItemCopyMatching`, `SecItemDelete`를 감싼다.
- `KeychainStorage.save`는 update 우선, item 없음 시 add, duplicate 발생 시 update fallback 순서로 저장한다.
- `KeychainStorageError.itemNotFound`는 `TokenError.noToken`으로 매핑한다.
- `KeychainStorageError.duplicateItem`은 save fallback 이후에도 중복 상태가 해소되지 않을 때만 사용한다.
- `errSecItemNotFound`로 인한 delete 실패는 성공으로 간주한다.
- `KeychainStorage`는 `Token` 모델을 알지 않는다.
- `KeychainTokenStore`는 Keychain query 세부사항보다 payload encode/decode와 에러 매핑 책임을 가진다.

## 보안 고려사항
- 토큰과 인증 응답 원문은 로그에 출력하지 않는다.
- `UserDefaults` 계열 저장소에는 토큰과 비밀값을 저장하지 않는다.
- 문서, 테스트, 예시 코드에는 실제 토큰 값을 하드코딩하지 않고 placeholder만 사용한다.
- Keychain item은 `ThisDeviceOnly` 정책을 사용하여 백업/기기 이전으로 이동하지 않게 한다.
- 메모리 캐시는 이번 범위에서 제외하여 토큰의 메모리 체류 시간을 늘리지 않는다.
- `fetch`가 반환한 token은 호출부 메모리에 존재할 수 있으므로 후속 logging/interceptor 설계에서도 원문 노출 금지 정책을 유지한다.
- 기존 `LivithNetwork` 저장소와 분리하여 기존 토큰을 실수로 삭제하거나 읽는 사이드이펙트를 피한다.

## 테스트 전략
- `TokenExpirationPolicy`는 순수 단위 테스트로 검증한다.
- `KeychainTokenStore`는 internal fake `KeychainStorage`를 주입해 저장/조회/삭제와 에러 매핑을 검증한다.
- 실제 Keychain integration test는 환경 의존성이 있으므로 필수 단위 테스트가 아니라 선택 검증으로 둔다.
- 실제 Keychain integration test가 필요하면 service 값을 테스트 전용 UUID로 주입하고 테스트 종료 시 삭제한다.
- 테스트에 실제 토큰 원문 형태의 긴 문자열이나 운영 토큰을 사용하지 않는다.
- 주요 검증 항목은 다음과 같다.
  - `save` 후 `fetch`가 동일한 `Token`을 반환한다.
  - `remove` 후 `fetch`는 `.noToken`을 던진다.
  - item이 없는 상태의 `remove`는 성공한다.
  - payload decoding 실패는 `.decodingFailed`로 매핑된다.
  - Keychain save/load/delete 실패는 각각 저장소 에러로 매핑된다.
  - `isRefreshTokenExpired`는 fetch 실패 또는 decoding 실패 시 `true`를 반환한다.
  - refresh token 발급 후 3일 초과 시 만료로 판단한다.
  - refresh token 발급 후 3일 이하이면 만료로 판단하지 않는다.

## 후속 작업
- 인증 헤더 설계에서 `NetworkEndpoint.requiresAuthentication`이 `true`인 요청에 access token을 삽입하는 경계를 정의한다.
- refresh 설계에서 401 응답, refresh token 사용, 원 요청 1회 retry, 동시 refresh coalescing 정책을 정의한다.
- 성능상 필요가 확인되면 `CachedTokenStore` 데코레이터를 별도 설계로 추가한다.
- 기존 `LivithNetwork`에서 신규 `LivithNetworking`으로 전환할 때 토큰 마이그레이션이 필요하면 일회성 bridge 설계를 별도로 작성한다.
- App Group 또는 extension에서 토큰 공유가 필요해지면 access group 정책을 별도로 설계한다.
