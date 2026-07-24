# LIVD-456 홈 캘린더 WebView 연동 - 트러블슈팅

## 기록

### 2026-07-24 22:25 - messageHandlerProxy 보관·sortedKeys 제거

**상황**
- 브랜치 불필요 코드 점검 후 정리 커밋.

**문제**
- Coordinator에 proxy를 저장만 하고 nil 처리만 함. encoder `sortedKeys`는 동작에 불필요.

**원인**
- retain 해제·테스트 친화 설정으로 넣었으나 실질 이득 없음.

**해결**
- proxy는 add/remove(이름)만 사용. encoder는 기본 `JSONEncoder()`.

**교훈**
- WKUserContentController가 handler를 보유하므로 별도 참조 보관은 최소화한다.

---

### 2026-07-24 22:21 - WebView mapper/parser를 Home/Helper로 분리

**상황**
- 유저 피드백: mapper·parser는 Model보다 Helper(또는 유사 폴더)가 낫다.

**문제**
- `CalendarWebMonthPayloadMapper` / `CalendarDateSelectedMessageParser`가 `Home/Model`에 있었다.

**원인**
- 초기 배치 시 Model로 묶음.

**해결**
- `Home/Helper/`로 이동. `CalendarWebConfig`는 Model 유지.

**교훈**
- 변환·파싱 유틸은 Helper, 설정/표시 모델은 Model.

---

### 2026-07-24 22:18 - 웹 날짜 탭이 모달로 이어지지 않음 (파이프라인 점검)

**상황**
- 캘린더 WebView는 보이지만 날짜 탭 시 네이티브 모달이 뜨지 않았다.

**문제**
- Web → iOS `calendarDateSelected` → `.dayScheduleRequested` 경로가 동작하지 않는 것으로 보임.

**원인**
- 유력 1: `WKScriptMessageHandler` 콜백이 메인 스레드가 아닐 수 있는데 `@MainActor` Store/`onDateSelected`를 그대로 호출.
- 유력 2: `message.body`가 `NSDictionary`/순수 `yyyy-MM-dd` 문자열일 때 기존 파서가 nil → 조용히 return.

**해결**
- `Task { @MainActor in onDateSelected(date) }`로 메인 보장.
- `CalendarDateSelectedMessageParser`로 딕셔너리/NSDictionary/JSON 문자열/순수 날짜 문자열 수용.

**교훈**
- WebKit 메시지 → Feature Store는 항상 메인 액터로 넘기고, body 타입을 넓게 파싱한다. DEBUG 「일정 모달」로 Store 단독 경로를 먼저 분리 확인한다.

---

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
