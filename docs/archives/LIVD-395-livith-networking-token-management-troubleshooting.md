# LIVD-395 LivithNetworking Token Management - 트러블슈팅

## 기록

### 2026-05-13 12:21 - TokenManagerTests 기본 파라미터 컴파일 실패

**상황**
- `TokenManager` 테스트 red 단계 확인을 위해 `xcodebuild test -workspace Livith-iOS.xcworkspace -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:LivithNetworkingTests/TokenManagerTests`를 실행했다.

**문제**
- `TokenManagerTests.makeSUT`의 기본 파라미터에서 인스턴스 메서드 `makeRefreshedToken()`을 사용해 컴파일이 실패했다.

**원인**
- Swift 기본 파라미터 값에서는 인스턴스 멤버를 사용할 수 없는데, 테스트 헬퍼 기본값에 인스턴스 메서드 호출을 넣었다.

**해결**
- 기본 파라미터를 optional `SpyTokenRefreshService? = nil`로 바꾸고, 함수 본문에서 nil일 때 `makeRefreshedToken()`으로 기본 테스트 더블을 생성하도록 수정했다.
- 수정 후 테스트가 컴파일되고, 최소 구현 상태에서 기대한 런타임 실패(red)를 확인했다.

**교훈**
- 테스트 헬퍼라도 기본 파라미터에는 인스턴스 멤버 접근을 넣지 않는다. 동적 기본값이 필요하면 optional 인자를 받고 함수 본문에서 구성한다.

---

### 2026-05-13 12:05 - 테스트 전용 Date 주입 제거

**상황**
- `TokenRefreshServiceImpl` 생성자에 테스트에서 고정 시각을 주입하기 위한 `now` 클로저가 남아 있다는 피드백을 받았다.

**문제**
- `now` 클로저는 운영 동작에 필요한 의존성이 아니라 테스트 편의를 위한 의존성이어서 서비스 생성자 책임을 흐렸다.

**원인**
- `refreshTokenIssuedAt`을 정확한 값으로 검증하기 위해 테스트 전용 seam을 생산 코드 생성자에 추가했다.

**해결**
- `TokenRefreshServiceImpl`에서 `now` 주입을 제거하고 `.now`를 직접 사용하도록 수정했다.
- 테스트는 정확한 고정 시각 대신 refresh 호출 전후 범위 안에 `refreshTokenIssuedAt`이 있는지 검증하도록 변경했다.

**교훈**
- 테스트 편의를 위해 운영 객체의 생성자에 불필요한 의존성을 추가하지 않는다. 시간 값은 가능하면 범위 검증으로 처리하고, 실제 정책 의존성이 필요할 때만 명시적으로 주입한다.

---

### 2026-05-13 12:02 - DTO 파일명 중복으로 Swift 빌드 실패

**상황**
- DTO 구조 변경 후 `xcodebuild test -workspace Livith-iOS.xcworkspace -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17'`를 실행했다.

**문제**
- `Sources/DTO/Auth/Token.swift`와 `Sources/Token/Token.swift` 파일명이 같은 모듈 안에서 중복되어 Swift 빌드가 실패했다.

**원인**
- Swift 컴파일러는 같은 모듈 안의 파일명을 private 선언 구분에 사용하므로 동일한 `Token.swift` 파일명을 허용하지 않는다.

**해결**
- DTO 타입 이름은 `DTO.Request.Token`, `DTO.Response.Token`으로 유지하고, 파일명만 `AuthToken.swift`로 변경했다.

**교훈**
- DTO 네임스페이스 타입명과 파일명을 반드시 동일하게 맞출 필요는 없으며, 같은 모듈 안의 기존 파일명과 충돌하지 않는 파일명을 선택해야 한다.

---

### 2026-05-13 12:00 - DTO 네임스페이스와 Literals 위치 피드백 반영

**상황**
- 구현 완료 후 DTO를 서비스 파일 내부 private 타입이 아니라 기존 네트워크 모듈처럼 `DTO.Request.*`, `DTO.Response.*` 확장 구조로 두고, `Literals`를 구현체에 속한 private extension 안에 두는 피드백을 받았다.

**문제**
- 최초 구현은 `TokenRefreshService.swift` 내부에 `TokenRefreshRequest`, `TokenRefreshResponse`, 파일 전역 `Literals`를 두어 원하는 구조와 달랐다.

**원인**
- 초기 구현에서 서비스 파일 안에 작은 private 타입으로 DTO와 상수를 직접 배치했다.

**해결**
- `DTO` 네임스페이스 파일과 `DTO.Request.Token`, `DTO.Response.Token` 타입을 추가했다.
- `TokenRefreshServiceImpl`이 새 DTO 타입을 사용하도록 수정했다.
- `Literals`를 `private extension TokenRefreshServiceImpl` 내부로 이동했다.

**교훈**
- 기존 모듈에서 이미 사용 중인 DTO 네임스페이스 관례가 있으면, 새 네트워킹 모듈에서도 동일한 구조를 우선 적용한다.

---

### 2026-05-13 11:55 - LivithNetworking 테스트 빌드 입력 파일 누락

**상황**
- 신규 `TokenRefreshService` 테스트의 red 단계 확인을 위해 `xcodebuild test -workspace Livith-iOS.xcworkspace -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:LivithNetworkingTests/TokenRefreshServiceTests`를 실행했다.

**문제**
- 테스트 실행 전 빌드 단계에서 `Projects/LivithNetworking/Sources/DTO/Auth/UpdateToken.swift` 파일을 찾을 수 없어 실패했다.

**원인**
- 현재 워크스페이스/프로젝트 파일이 실제 파일 구조와 동기화되지 않은 상태로 보인다. 신규 테스트의 기대 실패 여부를 확인하기 전에 기존 프로젝트 참조 누락으로 빌드가 중단되었다.

**해결**
- `tuist generate`를 실행해 워크스페이스/프로젝트 파일을 실제 파일 구조와 동기화했다.
- 이후 동일한 테스트 명령을 다시 실행해 신규 테스트가 기대한 구현 부재 실패(red)까지 진행되는 것을 확인했다.

**교훈**
- 신규 파일 추가 후 테스트 전, Tuist 기반 프로젝트의 생성 산출물이 최신 파일 구조와 일치하는지 확인해야 한다.

---

### 2026-05-11 16:20 - JSONEncoder/JSONDecoder 반복 생성 방지

**상황**
- `KeychainTokenStore`의 `save(_:)`, `fetch()` 흐름에서 토큰 payload를 JSON으로 인코딩/디코딩한다.
- 호출마다 `JSONEncoder`, `JSONDecoder`를 새로 만들면 토큰 조회가 많아질수록 동일 설정 객체를 반복 생성하게 된다.

**문제**
- `.secondsSince1970` date strategy가 고정된 codec 객체를 매번 재생성하는 것은 불필요한 비용이다.
- 이후 유사 구현에서 편의상 메서드 내부 생성 패턴이 반복될 수 있다.

**예방 방안**
- `JSONEncoder`, `JSONDecoder`는 `KeychainTokenStore` actor 내부 private 프로퍼티로 보관해 재사용한다.
- codec 객체는 init 시점에 생성하고 date strategy를 `.secondsSince1970`으로 고정한다.
- 전역 shared/static codec은 mutable configuration을 공유할 수 있으므로 피한다.
- actor 내부 private codec 재사용은 토큰 값을 메모리에 보관하는 캐시가 아니므로 메모리 캐시 제외 결정과 충돌하지 않는다.

**교훈**
- 값 자체를 캐싱하지 않더라도, 고정 설정을 가진 보조 객체는 actor 내부 상태로 재사용해 반복 생성 비용과 구현 중복을 줄인다.

---

### 2026-05-11 15:55 - typed throws closure 컴파일 실패

**상황**
- `KeychainStorage`를 `@Sendable` closure property와 `throws(KeychainStorageError)` function type으로 구성하고, 최소 선언 상태에서 테스트 컴파일을 시도했다.

**문제**
- closure literal이 `any Error`를 던지는 것으로 추론되어 `KeychainStorageError` typed throws function type으로 변환되지 않았다.
- 동일한 문제가 테스트 fake `KeychainStorage` closure에서도 발생했다.

**원인**
- 현재 Swift 컴파일 환경에서 closure literal을 typed throws function type으로 직접 맞추는 과정이 안정적으로 추론되지 않았다.

**해결**
- `KeychainStorage`를 closure 기반 struct에서 typed throws 메서드를 요구하는 internal protocol로 변경했다.
- production 구현은 `KeychainStorageImpl`, 테스트 대역은 `KeychainStorageBox`가 각각 `KeychainStorage`를 채택하도록 분리했다.
- `KeychainTokenStore`는 `any KeychainStorage`를 주입받고 typed throws 메서드만 호출하도록 유지했다.

**교훈**
- typed throws를 function property에 직접 적용하기보다, protocol 메서드로 추상화하면 테스트 주입과 typed throws API를 함께 유지하기 쉽다.

---

<!-- 새 항목은 위에 추가한다 (최신순 정렬) -->
