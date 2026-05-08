# LIVD-298 LivithNetworking 트러블슈팅

## 기록

### 2026-05-08 19:49 - `#require` 중첩 컴파일 실패 재발

**상황**
- `ResponseHandlerTests`를 추가하고 `xcodebuild test -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1'`를 실행했다.

**문제**
- `HTTPURLResponse`를 `#require`로 감싸는 표현식 안에서 `URL(string:)`도 `#require`로 감싸 Swift Testing macro가 recursive expansion 오류로 컴파일에 실패했다.

**원인**
- 이전 `RequestBuilderTests`와 같은 유형의 `#require` 중첩을 테스트 helper에서 반복했다.

**해결**
- `URL` 생성 결과를 `let url = try #require(...)`로 먼저 분리한 뒤 `HTTPURLResponse` 생성 결과에만 별도로 `#require`를 적용한다.

**교훈**
- 테스트 helper 안에서도 `#require`를 중첩하지 않는다.
- nullable 값을 여러 단계로 구성할 때는 단계별 지역 상수를 먼저 만든다.

---

### 2026-05-08 19:27 - `#require` 중첩으로 테스트 컴파일 실패

**상황**
- `RequestBuilderTests`를 추가하고 `tuist generate` 후 `xcodebuild test -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1'`를 실행했다.

**문제**
- `URLComponents(url: try #require(request.url), resolvingAgainstBaseURL: false)`를 다시 `#require`로 감싸면서 Swift Testing macro가 recursive expansion 오류로 컴파일에 실패했다.

**원인**
- `#require` macro를 한 표현식 안에 중첩해 사용했다.
- 이 실패는 기대한 runtime red가 아니라 테스트 코드 컴파일 오류였다.

**해결**
- `request.url`을 별도 `let url = try #require(request.url)`로 분리한 뒤 `URLComponents` 결과에만 다시 `#require`를 적용한다.

**교훈**
- Swift Testing의 `#require`는 복합 표현식 안에서 중첩하지 않고 단계별 지역 상수로 분리한다.

---

### 2026-05-08 - 테스트 helper를 소속 없는 전역 메서드로 작성함

**상황**
- `NetworkConfigTests`에서 `Sendable` 제약을 컴파일 타임에 확인하기 위해 `assertSendable` helper를 추가했다.
- 이 helper를 테스트 타입 밖의 파일 전역 함수로 작성했다.

**문제**
- 특정 테스트 타입에서만 쓰이는 helper가 파일 전역에 노출됐다.

**원인**
- helper가 특정 테스트 타입에서만 쓰이는지 확인하지 않고 파일 전역에 배치했다.
- 작은 테스트 보조 함수라도 소속 범위를 명확히 해야 한다는 기준을 적용하지 못했다.

**해결**
- `assertSendable`을 `NetworkConfigTests` 내부 `private static func`로 이동한다.
- 특정 테스트 타입에서만 쓰이는 helper는 해당 테스트 타입 내부에 둔다.
- 여러 테스트 타입에서 공유할 필요가 생기기 전까지 파일 전역 helper를 만들지 않는다.

**교훈**
- 새 helper를 만들 때 먼저 가장 좁은 소속 위치를 선택한다.
- 타입 내부에서만 쓰이면 타입 내부 `private static func` 또는 인스턴스 메서드로 둔다.
- 파일 전역 함수는 여러 타입에서 공유해야 하는 구체적 필요가 있을 때만 사용한다.

---

<!-- 새 항목은 위에 추가한다 (최신순 정렬) -->
