# LIVD-395 LivithNetworking 토큰 저장소 - 트러블슈팅

## 기록

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
