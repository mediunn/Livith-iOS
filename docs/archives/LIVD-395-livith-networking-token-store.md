# LIVD-395 LivithNetworking 토큰 저장소 구현

## 배경
- `LivithNetworking`은 요청 생성, 전송, 응답 처리 경계를 먼저 고정한 신규 네트워킹 모듈이다.
- 인증 헤더 삽입과 401 refresh/retry를 구현하기 전에 토큰을 안전하게 저장하고 조회하는 독립 경계가 필요하다.
- 기존 `LivithNetwork`의 토큰 저장 값은 참고하되, 신규 모듈은 기존 Keychain item과 호환하지 않고 payload 기반 저장소로 분리한다.
- 토큰 저장은 보안에 영향을 주므로 `UserDefaults`를 사용하지 않고 Keychain에 저장한다.
- 상세 설계는 `docs/designs/LIVD-395-livith-networking-token-store.md`를 따른다.

## 목표
- `LivithNetworking`에 public `TokenStore` 프로토콜을 추가한다.
- `TokenStore` 기본 구현체로 public `KeychainTokenStore` actor를 추가한다.
- `Token` 전체를 하나의 `Codable` payload로 인코딩해 Keychain item 1개에 저장한다.
- 저장/조회/삭제/refresh token 만료 여부 확인을 제공한다.
- refresh token 만료 기준은 `refreshTokenIssuedAt` 기준 3일로 둔다.
- Keychain 접근은 internal `KeychainStorage`로 분리해 테스트 가능하게 한다.
- 토큰 원문과 payload 원문을 로그, 테스트 메시지, 문서에 남기지 않는다.

## 작업 항목
- [x] 설계 기준 확인
  - `docs/designs/LIVD-395-livith-networking-token-store.md`의 결정 사항을 구현 범위로 고정한다.
  - 제외 범위인 인증 헤더 삽입, refresh API 호출, retry, 메모리 캐시, 기존 Keychain item 호환을 구현하지 않는다.
- [x] 파일 구조 생성
  - `Projects/LivithNetworking/Sources/Token/` 하위에 토큰 저장소 관련 production 파일을 추가한다.
  - `Projects/LivithNetworking/Tests/Token/` 하위에 `Testing` 기반 테스트 파일을 추가한다.
  - 새 Swift 파일 헤더는 `Projects/LivithNetworking`의 기존 파일 형식을 따른다.
  - 파일 추가 또는 폴더 구조 변경 후 테스트/빌드를 실행하기 전에 `tuist generate`를 실행한다.
- [x] TDD 실행 기준 고정
  - 새 타입/메서드/시그니처가 없어 테스트가 컴파일되지 않으면 컴파일에 필요한 최소 선언만 먼저 추가한다.
  - 최소 선언에는 동작 구현을 넣지 않고, 해당 테스트를 다시 실행해 런타임 실패를 확인한다.
  - 각 green 단계 뒤에는 현재 실패 테스트와 영향 범위의 보호 테스트를 실행한다.
  - `KeychainStorageImpl`는 Security API 연결 구간으로 TDD 예외 허용 작업으로 간주하고 fake 기반 단위 테스트, 빌드 검증, 선택 Keychain 검증으로 확인한다.
- [x] `Token` 모델 red/green
  - 실패 테스트: `Token`이 `accessToken`, `refreshToken`, `refreshTokenIssuedAt` 값을 보관하고 `Equatable` 비교가 가능해야 한다.
  - 최소 구현: `Token`을 `Codable`, `Equatable`, `Sendable` public struct로 추가한다.
- [x] `TokenError` red/green
  - 실패 테스트: `TokenError`가 저장소 실패 케이스와 한글 `errorDescription`을 제공해야 한다.
  - 최소 구현: `TokenError: LocalizedError, Sendable`을 추가하고 원본 `Error` associated value는 포함하지 않는다.
- [x] `TokenExpirationPolicy` red/green
  - 실패 테스트: refresh token 발급 후 3일 초과 시 만료로 판단해야 한다.
  - 실패 테스트: refresh token 발급 후 3일 이하이면 만료가 아니어야 한다.
  - 실패 테스트: 기준 시각이 발급 시각보다 이전이면 만료가 아니어야 한다.
  - 최소 구현: `TokenExpirationPolicy`와 기본 lifetime `3 * 24 * 60 * 60`초를 추가한다.
- [x] `TokenStore` API 선언
  - `save(_:)`, `fetch()`, `remove()`, `isRefreshTokenExpired()`를 갖는 public `TokenStore: Sendable` 프로토콜을 `TokenStore.swift`에 추가한다.
  - 모든 throwing API는 `throws(TokenError)` typed throws를 사용한다.
- [x] `KeychainStorage` fake 기반 저장 성공 red/green
  - 실패 테스트: `KeychainTokenStore.save(_:)` 후 `fetch()`가 동일한 `Token`을 반환해야 한다.
  - 최소 구현: internal `KeychainStorage`, `KeychainStorageError`, `KeychainTokenStore`의 fake 주입 initializer, payload encode/decode 흐름을 추가한다.
  - `JSONEncoder.dateEncodingStrategy`와 `JSONDecoder.dateDecodingStrategy`는 `.secondsSince1970`으로 고정한다.
- [x] `KeychainTokenStore.remove` red/green
  - 실패 테스트: `remove()` 후 `fetch()`는 `.noToken`을 던져야 한다.
  - 실패 테스트: item이 없는 상태의 `remove()`는 성공해야 한다.
  - 최소 구현: `KeychainStorage.delete` 결과를 `TokenError`로 매핑한다.
- [x] `KeychainTokenStore` decoding 실패 red/green
  - 실패 테스트: Keychain에 저장된 payload가 `Token`으로 디코딩되지 않으면 `fetch()`가 `.decodingFailed`를 던져야 한다.
  - 최소 구현: decode 실패를 `.decodingFailed`로 매핑하고 payload 원문을 로그로 남기지 않는다.
- [x] `KeychainTokenStore` Keychain 실패 매핑 red/green
  - 실패 테스트: `KeychainStorage.save` 실패는 `.saveFailed`로 매핑되어야 한다.
  - 실패 테스트: `KeychainStorage.load`의 item 없음은 `.noToken`으로 매핑되어야 한다.
  - 실패 테스트: `KeychainStorage.load`의 그 외 실패는 `.loadFailed`로 매핑되어야 한다.
  - 실패 테스트: `KeychainStorage.delete`의 그 외 실패는 `.deleteFailed`로 매핑되어야 한다.
  - 최소 구현: `KeychainStorageError`에서 public `TokenError`로 변환하는 mapping을 추가한다.
- [x] `isRefreshTokenExpired` red/green
  - 실패 테스트: 저장된 토큰이 만료 정책상 만료되었으면 `true`를 반환해야 한다.
  - 실패 테스트: 저장된 토큰이 만료되지 않았으면 `false`를 반환해야 한다.
  - 실패 테스트: `fetch()`가 `.noToken`, `.decodingFailed`, `.loadFailed` 등으로 실패하면 `true`를 반환해야 한다.
  - 최소 구현: `fetch()` 결과와 `TokenExpirationPolicy`를 조합한다.
- [x] live `KeychainStorage` 구현
  - `SecItemUpdate`, `SecItemAdd`, `SecItemCopyMatching`, `SecItemDelete`를 감싼다.
  - 저장은 update 우선, item 없음 시 add, duplicate 발생 시 update fallback 순서로 구현한다.
  - 저장 과정에서 기존 item을 먼저 삭제하지 않는다.
  - `kSecAttrAccessible`은 `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`로 둔다.
  - `errSecItemNotFound`는 load에서는 `.itemNotFound`, delete에서는 성공으로 처리한다.
  - 이 항목은 Security API 연결 구간이므로 TDD 예외로 진행하되, fake `KeychainStorage`로 저장 전략 분기와 에러 매핑을 이미 검증한 뒤 구현한다.
- [x] 실제 Keychain 선택 검증
  - 환경 의존성을 줄이기 위해 기본 자동 테스트는 fake `KeychainStorage` 기반으로 둔다.
  - 실제 Keychain 동작은 테스트 전용 service/account 값을 사용한 선택 테스트 또는 수동 검증으로만 수행한다.
  - 선택 테스트를 추가하는 경우 테스트 이름에 실제 Keychain 검증임을 드러내고, 기본 단위 테스트와 분리 가능한 형태로 둔다.
  - 실제 Keychain 검증을 추가할 경우 테스트 종료 시 `remove()`를 호출해 정리한다.
- [x] README 업데이트
  - `Projects/LivithNetworking/README.md`에 토큰 저장소의 현재 범위와 제외 범위를 반영한다.
  - 기존 다이어그램의 후속 후보 중 인증/refresh 앞 단계로 토큰 저장소 구현 완료 상태를 표현한다.
  - 토큰 원문이나 payload 원문을 문서에 포함하지 않는다.
- [x] 전체 테스트 및 정리
  - 새 테스트와 기존 `LivithNetworking` 테스트를 실행해 회귀를 확인한다.
  - 필요 시 접근 제어, 파일 위치, public API 표면을 정리한다.
  - 새 production throwing API가 typed throws를 사용하는지 확인한다.
  - Swift 6 strict concurrency 관점에서 `Sendable`, actor, `OSStatus` 사용이 빌드되는지 확인한다.
- [x] 최종 검증
  - 파일 추가 또는 폴더 구조 변경이 있었으면 `xcodebuild test` 전에 `tuist generate`를 실행한다.
  - `xcodebuild test -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1'`를 실행한다.
  - `git diff --check`를 실행한다.
- [x] 구현 완료 리뷰 및 피드백 반영
  - 계획 문서의 모든 구현 항목을 완료한 뒤 서브에이전트에게 이 계획 문서 기준으로 구현 내용을 점검받는다.
  - 서브에이전트 피드백이 있으면 필요한 수정을 반영하고 관련 테스트/검증을 다시 실행한다.
  - 서브에이전트 재점검에서 남은 필수 수정사항이 없을 때 작업 완료로 본다.
- [x] 계획/트러블슈팅 문서 정리
  - 작업 중 실패, 사용자 피드백, 예상과 다른 동작으로 접근을 변경한 경우 `docs/troubleshooting/LIVD-395-livith-networking-token-store.md`에 기록한다.
  - 작업 완료 후 계획 문서를 `docs/archives/`로 이동한다.
  - 트러블슈팅 문서가 있으면 규칙에 따라 `docs/archives/`로 함께 이동한다.

## 영향 범위
- `Projects/LivithNetworking/Sources/Token/Token.swift`
- `Projects/LivithNetworking/Sources/Token/TokenError.swift`
- `Projects/LivithNetworking/Sources/Token/TokenExpirationPolicy.swift`
- `Projects/LivithNetworking/Sources/Token/TokenStore.swift`
- `Projects/LivithNetworking/Sources/Token/KeychainStorage.swift`
- `Projects/LivithNetworking/Tests/Token/TokenTests.swift`
- `Projects/LivithNetworking/Tests/Token/TokenExpirationPolicyTests.swift`
- `Projects/LivithNetworking/Tests/Token/KeychainTokenStoreTests.swift`
- `Projects/LivithNetworking/README.md`
- `docs/plans/LIVD-395-livith-networking-token-store.md`
- `docs/troubleshooting/LIVD-395-livith-networking-token-store.md` (실패/피드백/접근 변경 발생 시)

참고 문서:
- `docs/designs/LIVD-395-livith-networking-token-store.md`

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 공개 경계 | `TokenStore`, `TokenService`, client 통합 | `TokenStore` | 이번 범위는 저장/조회이며 refresh orchestration과 요청 삽입은 후속 책임이다. |
| 기본 구현체 | Keychain, UserDefaults, 파일 저장 | Keychain | 토큰과 비밀값은 `UserDefaults`에 저장하지 않는다. |
| 저장 방식 | 필드별 item 3개, payload item 1개 | payload item 1개 | 부분 저장 실패 상태를 줄이고 필드 확장을 단순화한다. |
| 기존 저장소 호환 | 호환 또는 분리 | 분리 | 기존 `LivithNetwork` item을 실수로 읽거나 삭제하는 사이드이펙트를 피한다. |
| Keychain save 전략 | delete-add, update/add/fallback | update/add/fallback | 저장 중간에 token 없음 상태를 만들지 않는다. |
| 메모리 캐시 | 포함 또는 제외 | 제외 | 토큰의 메모리 체류 시간을 늘리지 않고 저장소 책임을 단순하게 유지한다. |
| 만료 정책 위치 | `Token`, `KeychainTokenStore`, `TokenExpirationPolicy` | `TokenExpirationPolicy` | 현재 시각 의존 로직을 값 모델과 저장소 I/O에서 분리한다. |
| Date 직렬화 | 기본값, ISO8601, secondsSince1970 | `.secondsSince1970` | payload 호환성을 명시하고 포맷 의존을 줄인다. |
| `isRefreshTokenExpired` 실패 처리 | throw, false, true | true | 인증 상태를 낙관하지 않도록 조회/해석 실패를 만료로 간주한다. |
| 에러 원본 보존 | associated `Error`, 축약 case | 축약 case | `TokenError: Sendable`을 유지하고 토큰/payload 원문 노출 가능성을 낮춘다. |
| 실제 Keychain 테스트 | 필수 자동 테스트, 선택 검증 | 선택 검증 | 환경 의존성을 줄이고 fake storage로 저장소 로직을 안정적으로 검증한다. |
| 실제 Keychain TDD 처리 | 하위 Security 추상화 테스트, TDD 예외 | TDD 예외 | `SecItem*` 호출은 시스템 API 연결 구간이며 fake 기반 저장소 테스트와 빌드/선택 검증으로 확인한다. |

## 주의 사항
- 구현 전 이 계획 문서를 사용자에게 확인받는다.
- 계획에 없는 인증 헤더 삽입, refresh API 호출, 401 retry, 메모리 캐시, migration bridge를 추가하지 않는다.
- 기존 `Projects/Core/LivithNetwork` 파일은 수정하지 않는다.
- 기존 `LivithNetwork` Keychain service/account와 호환하거나 공유하지 않는다.
- 토큰 원문, 인증 응답 원문, Keychain payload 원문을 로그/문서/테스트 failure message에 남기지 않는다.
- `UserDefaults` 계열 저장소를 사용하지 않는다.
- `*.xcconfig`와 `Projects/App/Resources/GoogleService-Info.plist` 본문을 읽지 않는다.
- 테스트 데이터는 복원 불가능한 placeholder 수준의 짧은 문자열만 사용한다.
- `KeychainTokenStore` public initializer에는 internal `KeychainStorage` 추상화를 노출하지 않는다.
- fake `KeychainStorage` 주입 initializer는 테스트를 위한 internal API로 둔다.
- production throwing API는 `throws(TokenError)` typed throws를 사용한다.
- `TokenError`에는 non-Sendable `Error` associated value를 추가하지 않는다.
- `KeychainStorageError.unexpectedStatus(OSStatus)`의 `Sendable` 적합성은 빌드로 확인한다.
- 실제 Keychain 선택 검증을 수행할 경우 test 전용 service/account를 사용하고 종료 시 정리한다.
- 파일 추가 또는 폴더 구조 변경 후 테스트/빌드를 실행하기 전에는 `tuist generate`를 먼저 실행한다.
- 작업 중 계획이 변경되면 계획 문서를 먼저 수정한 뒤 작업을 계속한다.
- 계획 문서의 모든 구현 항목 완료 후 서브에이전트 구현 리뷰와 피드백 반영까지 끝나야 작업 완료로 간주한다.
- 작업 중 실패, 사용자 피드백, 예상과 다른 동작으로 접근 변경이 발생하면 트러블슈팅 문서를 작성한다.

## 검증 방법
- 생산 코드 변경 전에 해당 동작을 설명하는 실패 테스트를 먼저 작성하고 실패 원인을 확인한다.
- 새 타입/메서드가 없어 테스트가 컴파일되지 않으면 테스트 컴파일에 필요한 최소 선언만 먼저 추가하고, 동작 구현 없이 런타임 실패를 확인한다.
- 각 green 단계 뒤에는 현재 실패 테스트와 영향 범위의 보호 테스트를 실행한다.
- `KeychainStorageImpl`는 Security API 연결 구간으로 TDD 예외 허용 작업으로 간주하고, fake `KeychainStorage` 단위 테스트, 빌드 검증, 선택 Keychain 검증으로 확인한다.
- 테스트는 `Testing` 기반으로 작성하고 `@Suite`, `@Test` 제목은 한글로 작성한다.
- fake `KeychainStorage` 기반 단위 테스트로 저장/조회/삭제/에러 매핑/만료 판단을 검증한다.
- 필요한 경우 test 전용 service/account로 실제 Keychain 선택 검증을 수행한다.
- 파일 추가 또는 폴더 구조 변경이 있었으면 테스트/빌드 전 `tuist generate`를 실행한다.
- `xcodebuild test -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1'`
- `git diff --check`
- 계획 문서 기준 서브에이전트 구현 리뷰를 받고, 피드백 반영 후 필요한 검증을 재실행한다.
