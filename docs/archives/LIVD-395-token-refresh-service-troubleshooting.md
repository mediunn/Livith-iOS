# LIVD-395 Token Refresh Service - 트러블슈팅

## 기록

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

<!-- 새 항목은 위에 추가한다 (최신순 정렬) -->
