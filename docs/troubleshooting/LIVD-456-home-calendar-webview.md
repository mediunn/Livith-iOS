# LIVD-456 홈 캘린더 WebView 연동 - 트러블슈팅

## 기록

### 2026-07-24 21:19 - 캘린더 WebView 스크롤 임시 활성화

**상황**
- 유저가 레이아웃·새로고침 조작을 위해 WebView 스크롤을 켜 달라고 했다.

**문제**
- `isScrollEnabled`/`bounces`가 false라 스크롤·bounce가 불가했다.

**원인**
- LIVD-439 골격에서 캘린더 그리드 고정용으로 스크롤을 막아 두었다.

**해결**
- `isScrollEnabled = true`, `bounces = true`로 변경 (임시 조작용).

**교훈**
- VStack 채우기 + UIRefreshControl 전에 스크롤 가능 여부를 먼저 확인할 수 있다.

---

### 2026-07-24 21:11 - Shared CALENDAR_WEB_URL이 Dev/Release 빈 키에 덮임

**상황**
- 유저가 `Shared.xcconfig`에 `CALENDAR_WEB_URL`을 넣었는데 캘린더가 안 보였다.

**문제**
- WebView가 `about:blank`만 로드됨.

**원인**
- 구현 시 `Development`/`Release.xcconfig` 끝에 빈 `CALENDAR_WEB_URL =`를 추가해, `#include "Shared.xcconfig"` 값을 덮어썼다.

**해결**
- Dev/Release의 빈 `CALENDAR_WEB_URL` 줄을 제거해 Shared 값이 쓰이도록 했다.

**교훈**
- Shared에 두는 키는 Dev/Release에 빈 재정의를 넣지 않는다. 키 추가 전 include 계층을 확인한다.

---

### 2026-07-24 21:04 - Model 폴더 이동 및 blank URL 강제 언래핑 제거

**상황**
- `CalendarWebConfig` / 페이로드 매퍼가 View/Calendar 아래에 있었고, `about:blank`를 `URL(string:)!`로 선언했다.

**문제**
- 유저 피드백: 모델 성격은 `Home/Model`, URL 강제 언래핑은 원하지 않음.

**원인**
- 초기 배치·상수 선언 습관.

**해결**
- 두 파일을 `Sources/Home/Model/`로 이동. `blankURL`을 `URL?`로 두고 `guard`/`if let`로 로드.

**교훈**
- Feature 모델·매퍼는 기존 `Home/Model`에 두고, 리터럴 URL은 강제 언래핑하지 않는다.

---

### 2026-07-24 21:00 - Livith-iOS-Dev scheme에 test action 없음

**상황**
- 계획서 검증 scheme을 `Livith-iOS-Dev`로 두고 XcodeBuildMCP `test_sim`을 실행했다.

**문제**
- `Scheme Livith-iOS-Dev is not currently configured for the test action` / `test-without-building action`

**원인**
- 앱 스킴 `Livith-iOS-Dev`는 빌드용이며 HomeFeatureTests test action이 없다.

**해결**
- 컴파일 검증은 `Livith-iOS-Dev` + `build_sim`, 단위 테스트는 `HomeFeature` + `test_sim`으로 분리한다.

**교훈**
- 앱 Dev 스킴과 Feature 테스트 스킴을 검증 문서에 구분해 적는다.

---

### 2026-07-24 20:57 - private WeakScriptMessageHandlerProxy와 Coordinator 프로퍼티 접근 제어 충돌

**상황**
- `CalendarWebView`에 weak message handler proxy를 `private`로 두고 Coordinator에 저장했다.

**문제**
- 빌드 실패: `property must be declared fileprivate because its type uses a private type`

**원인**
- `Coordinator`는 internal인데 `private` 타입을 프로퍼티로 노출할 수 없다.

**해결**
- proxy 타입과 프로퍼티를 `fileprivate`로 맞췄다.

**교훈**
- UIViewRepresentable Coordinator에 파일 전용 타입을 둘 때는 `fileprivate`로 맞춘다.

---

<!-- 새 항목은 위에 추가한다 (최신순 정렬) -->
