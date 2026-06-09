# LIVD-418 TokenManager 리팩토링 - 트러블슈팅

## 기록

### 2026-06-10 00:35 - TDD 순서 위반으로 인한 컴파일 에러

**상황**
- TokenManager 프로토콜에 새 메서드 추가 작업 시작
- 사용자가 "토큰 매니저와 관련한 기존 테스트를 수정해야 하지는 않는지도 확인해봐" 요청

**문제**
- TDD 규칙을 무시하고 프로덕션 코드를 먼저 작성
- `TokenManager`에 `refreshToken()`, `save()`, `remove()`, `isTokenValid()` 메서드 추가
- 테스트를 나중에 작성하려고 시도

**원인**
- TDD 규칙 위반: Red-Green-Refactor 사이클을 따르지 않음
- 올바른 순서: 실패하는 테스트 작성 → 프로덕션 코드 작성 → 리팩토링
- 실제 발생 순서: 프로덕션 코드 작성 → 빌드 에러 → 테스트 작성

**해결**
- 이미 작성된 프로덕션 코드에 대해 테스트 추가
- 하지만 이는 TDD가 아닌 "테스트 나중에 추가"에 해당

**교훈**
- **TDD 규칙을 반드시 준수**: 새로운 기능을 추가할 때는 항상 실패하는 테스트를 먼저 작성
- 프로덕션 코드 변경 전에 먼저 테스트 파일을 열고 실패하는 테스트 케이스 작성
- "나중에 테스트 추가해야지"라는 생각은 TDD 원칙 위반
- 사용자가 지적하기 전에 스스로 규칙 위반을 인지하고 수정했어야 함

---

### 2026-06-10 00:35 - tuist generate 규칙 위반으로 인한 빌드 실패

**상황**
- TokenManager 리팩토링 완료 후 전체 앱 빌드 시도
- develop 브랜치 머지로 Swift 파일 리네임 발생 (ConcertDisplayText.swift → ConcertDisplayHelper.swift)

**문제**
```
error: Build input files cannot be found: 
'Projects/Shared/DisplaySupport/Sources/ConcertDisplayText.swift', 
'Projects/Shared/DisplaySupport/Sources/InterestConcertDisplayText.swift'
```

**원인**
- **프로젝트 규칙 위반**: `docs/rules/project-operations.md`의 "프로젝트 생성" 규칙을 따르지 않음
  - "Swift 파일을 추가, 이동, 또는 삭제한 후에는 빌드 또는 테스트 전에 반드시 `tuist generate`를 실행한다."
  - "Swift 파일 변경 후 `tuist generate` 없이 `xcodebuild test`를 실행하지 않는다."
- develop 브랜치 머지로 Swift 파일이 리네임되었으나 `tuist generate`를 실행하지 않고 바로 빌드 시도

**해결**
```bash
tuist generate
```
- 프로젝트 파일을 재생성하여 새로운 파일 경로를 반영
- 빌드 성공

**교훈**
- **Swift 파일 변경 후 반드시 `tuist generate` 실행** (프로젝트 규칙)
- Git merge로 파일 구조가 변경된 경우에도 예외 없이 실행
- 빌드/테스트 전에 체크리스트 확인: "Swift 파일 추가/이동/삭제 후 `tuist generate`를 실행했는가"

---

### 2026-06-10 00:32 - AuthInterceptorTests 컴파일 에러

**상황**
- TokenManager 프로토콜에 새 메서드 추가 후 테스트 실행

**문제**
```
error: type 'AuthInterceptorTests.SpyTokenManager' does not conform to protocol 'TokenManager'
```

**원인**
- TokenManager 프로토콜이 확장됨:
  - 추가된 메서드: `refreshToken()`, `save(_:)`, `remove()`, `isTokenValid()`
- SpyTokenManager가 새로운 프로토콜 요구사항을 구현하지 않음

**해결**
- SpyTokenManager에 누락된 메서드 구현 추가:
  ```swift
  func refreshToken() async throws(NetworkError) -> String
  func save(_ token: Token) async throws(NetworkError)
  func remove() async throws(NetworkError)
  func isTokenValid() async -> Bool
  ```

**교훈**
- 프로토콜을 확장할 때 모든 테스트용 Mock/Spy 클래스도 함께 업데이트 필요
- 컴파일 에러 메시지가 명확하므로 빠르게 대응 가능

---

### 2026-06-10 00:30 - TokenManager.isTokenValid() 컴파일 에러

**상황**
- TokenManager 프로토콜에 `isTokenValid()` 메서드 추가 후 빌드 시도

**문제**
```
error: method 'isTokenValid()' must be as accessible as its enclosing type 
because it matches a requirement in protocol 'TokenManager'

error: value of type 'Token' has no member 'refreshTokenIsExpired'
```

**원인**
1. `isTokenValid()`이 `private extension` 안에 정의되어 프로토콜 요구사항을 만족하지 못함
2. `Token` struct에 `refreshTokenIsExpired` 프로퍼티가 없음
   - LivithNetworking 모듈에서 만료 로직이 `TokenExpirationPolicy`로 이동됨
   - TokenStore가 `isRefreshTokenExpired()` 메서드를 제공

**해결**
1. `isTokenValid()`을 `private extension`에서 `TokenManagerImpl` actor 본문으로 이동
2. 구현을 `tokenStore.isRefreshTokenExpired()` 사용하도록 변경:
   ```swift
   func isTokenValid() async -> Bool {
       await !tokenStore.isRefreshTokenExpired()
   }
   ```

**교훈**
- Swift에서 프로토콜 요구사항을 구현하는 메서드는 프로토콜과 동일한 접근 수준 필요
- 리팩토링 시 기존 API의 존재 여부를 반드시 확인
- 만료 로직의 위치를 정확히 파악해야 함 (Token vs TokenStore vs TokenExpirationPolicy)

---

<!-- 새 항목은 위에 추가한다 (최신순 정렬) -->
