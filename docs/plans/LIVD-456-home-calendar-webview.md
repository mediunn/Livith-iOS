# LIVD-456 홈 캘린더 WebView 연동 (URL 로드 · 월별 데이터 주입 · 날짜 탭)

## 배경
- LIVD-439에서 필터 칩 + 빈 WebView(`about:blank`) 골격을 올렸고, LIVD-452에서 월별·날짜별 API를 Domain → Data → `CalendarHomeStore`까지 연동했다.
- 월 헤더·그리드는 WebView 소속이며, Store의 `calendarMonth`는 아직 WebView에 전달되지 않는다. 날짜 탭 → 모달은 DEBUG Intent로만 검증 중이다.
- 웹 브릿지 계약(문서 기준)이 준비됐다.
  - iOS → Web: 로드 완료 후 `window.setCalendarData(...)` (객체 인자)
  - Web → iOS: `calendarDateSelected` 메시지 `{ "date": "yyyy-MM-dd" }`
- 월 이동(◀▶ / 오늘) 브릿지는 웹에서 후속 제공 예정 → **이번 비범위** (웹 UI가 보여도 네이티브 year/month와 **동기화되지 않음** — 알려진 제한).
- 스펙 리뷰 반영: Optional DI 항상 등록, `updateUIView` load/inject 분리, 핸들러 수명, JS 이스케이프, blank inject 스킵, 실 URL 로드 실패 시 blank 폴백.
- 브랜치: `feat/LIVD-456-home-calendar-webview`

## 목표
- `CALENDAR_WEB_URL`로 실 WebView를 로드한다. 없거나 파싱 실패 시 `about:blank`를 유지한다 (앱 비종료).
- 월별 성공 결과(`CalendarMonth`)를 웹 계약 JSON으로 직렬화해 `setCalendarData`로 주입한다.
- Web 날짜 탭 → `calendarDateSelected` → 기존 `.dayScheduleRequested` → 일정 모달 E2E를 연결한다.
- 필터·pull-to-refresh로 월 데이터가 바뀌면 `setCalendarData`를 다시 호출한다. `days: []`여도 호출한다.
- 실 URL **네트워크/로드 실패**(`didFail` / `didFailProvisionalNavigation`) 시 `about:blank`로 폴백하고 inject는 하지 않는다.

## 작업 항목

### 1. URL 설정 · App 주입
- [ ] `App-Info.plist`에 `CALENDAR_WEB_URL` = `$(CALENDAR_WEB_URL)` 추가
- [ ] `Tuist/Config/*.xcconfig`에 `CALENDAR_WEB_URL` 키 추가 (실값은 로컬/비공개 설정, 문서·커밋·이슈에 URL 원문 금지)
- [ ] `CalendarWebConfig` 값 타입 추가 (`url: URL?`)
  - App 기동 시 `Bundle.main`에서 읽어 **항상** `DIContainer.register` (`resolve` 미등록 `fatalError` 방지)
  - 없/파싱 실패 → `CalendarWebConfig(url: nil)` — **`fatalError` 금지**
- [ ] HomeFeature는 `Bundle.main`을 직접 읽지 않는다
  - URL은 `@Injected` `CalendarWebConfig` 또는 View prop으로만 수신 (둘 중 하나로 통일: **prop 우선** — ContentView가 Config/`url`을 WebView에 전달)

### 2. Web 계약 페이로드 매핑 (TDD)
- [ ] `CalendarMonth` → 웹 `setCalendarData`용 JSON 직렬화 (순수 매퍼/인코더)
  - 스키마: `{ year, month, days: [{ date: "yyyy-MM-dd", events: [{ id, artist, type }] }] }`
  - Domain `dayList`/`eventList`/`concertID` → 웹 `days`/`events`/`id` (**`id`는 Int `concertID`**, `CalendarEventID` 직렬화 금지)
  - `date`: `DateFormatType.dashDate` (`yyyy-MM-dd`)
  - `type`: `CalendarMonthEventType.rawValue` (`CONCERT` | `TICKETING`)
  - `days: []`도 유효 페이로드 (year/month 유지)
- [ ] 매퍼 단위 테스트
  - 필드명·날짜 문자열·type·빈 days·`id` Int
  - `artist`에 `"`, `\`, 개행 포함 시 **유효 JSON** 출력

### 3. WebView · 브릿지 배선
- [ ] `CalendarWebView` + Coordinator 상태
  - `hasLoadedCalendarURL: Bool` — 실 URL load 성공 완료 여부
  - `pendingPayloadJSON: String?` — 최신 월 데이터 JSON (미주입분)
  - inject 조건: **`hasLoadedCalendarURL == true` ∧ `pendingPayloadJSON != nil`**
  - `url == nil` / `about:blank` / 로드 실패 폴백 후에는 **inject 스킵** (`setCalendarData` 미호출)
- [ ] URL load
  - `makeUIView`(또는 URL 최초 반영 1회): `url != nil`이면 `load(URLRequest)`, 아니면 `about:blank`
  - **`updateUIView`에서 URL `load` 재호출 금지** (SwiftUI가 month/필터마다 update 호출)
  - `calendarMonth` 변경 → pending JSON만 갱신 → inject 조건이면 `setCalendarData`만 재호출
  - 탭 전환 remount(`CalendarHomeContentView` 재생성) 시 WebView가 다시 만들어지므로 **재 load + 재 inject** (정상)
  - `isInitialLoading`으로 ProgressView 교체 시 WebView destroy → 복귀 시 remount와 동일
- [ ] Navigation
  - `WKNavigationDelegate.didFinish`: 실 캘린더 URL navigation일 때만 `hasLoadedCalendarURL = true` 후 inject 시도
  - `didFail` / `didFailProvisionalNavigation`: `about:blank` 폴백, `hasLoadedCalendarURL = false`, pending 유지하되 inject 안 함
- [ ] JS 호출 (웹은 **객체 인자** 계약)
  - `JSONEncoder`로 payload UTF-8 string 생성
  - `evaluateJavaScript`는 JSON을 **한 번 더 문자열 리터럴로 인코딩**한 뒤 `JSON.parse`로 객체화:
    - `window.setCalendarData(JSON.parse(<jsonStringLiteral>))`
  - 예: payload JSON이 `{"year":2026,...}`이면 JS 쪽은 `JSON.parse("{\"year\":2026,...}")` 형태 (특수문자·따옴표 안전)
- [ ] `calendarDateSelected` 핸들러
  - weak proxy로 등록 (Coordinator가 자기 자신을 강하게 add하지 않음 — retain cycle 방지)
  - WebView/Coordinator 해제 시 `removeScriptMessageHandler(forName: "calendarDateSelected")`
  - body가 `String`(JSON) 또는 `NSDictionary` 모두 수용 → `date`(`yyyy-MM-dd`) 파싱 → `Date` → 콜백
  - 파싱 실패 시 무시 (모달·토스트 없음)
- [ ] `CalendarHomeContentView`: `calendarMonth` / URL / `.dayScheduleRequested` 연결
  - DEBUG 「일정 모달」은 브릿지 E2E 검증 경로가 **아님** (유지, 웹 탭으로 수동 검증)
- [ ] WKWebView/delegate/메시지 핸들러 배선은 TDD **예외 허용** (`docs/rules/tdd.md` 연결 구간). 페이로드 매퍼는 TDD 유지. Store Intent 변경이 없으면 Store 추가 테스트 강제하지 않음

### 4. Store · Intent (필요 최소)
- [ ] Web 날짜 탭은 기존 `.dayScheduleRequested(date:)` 재사용 (신규 fetch 경로 만들지 않음)
- [ ] Store에 WebView 전용 year/month 변경 Intent **추가하지 않음** (월 이동 후속)
- [ ] 기존 월별 fetch·필터·PTR·날짜별 모달/토스트 회귀 유지

### 5. 검증 · 문서
- [ ] 페이로드 매퍼 테스트 red → green
- [ ] 기존 `CalendarHomeStoreTests` 등 회귀 통과
- [ ] `tuist generate --no-open` (plist/xcconfig/의존·Swift 파일 추가/이동/삭제 시)
- [ ] **빌드·테스트는 XcodeBuildMCP 우선** (`docs/rules/project-operations.md`와 병행)
  - `session_show_defaults`로 workspace/scheme/simulator 확인 (미설정 시 `session_set_defaults`)
  - scheme: **`Livith-iOS-Dev`**, simulator: **iPhone 17** (Available destinations 기준)
  - 매퍼·Store 테스트: XcodeBuildMCP `test_sim` (`-only-testing`로 범위 한정 가능)
  - 배선·App 변경 컴파일: 필요 시 `build_sim` (앱 실행은 `build_run_sim` — 수동 요청 시에만)
  - 셸 `xcodebuild test`는 MCP 불가/지속 실패 시에만 fallback
- [ ] 수동
  - 유효 `CALENDAR_WEB_URL`: 캘린더 그리드 로드
  - URL 없/무효: `about:blank` + 크래시 없음 + **`setCalendarData` 미호출**
  - 유효 URL **로드 실패**(오프라인/잘못된 호스트): blank 폴백 + 크래시 없음 + inject 스킵
  - 월별 성공 후 점/이벤트 반영 (`setCalendarData`)
  - 필터·PTR 후 그리드 갱신 (연타 시 **최신** `calendarMonth`만 반영)
  - **웹 날짜 탭**(DEBUG 버튼 아님) → 모달 (성공 목록 / 0건 엠티 / 실패 토스트)
  - 관심 ↔ 캘린더 전환 후 그리드·날짜 탭 재동작 (remount)
  - (가능하면) `artist`에 `"` 포함 fixture로 그리드 깨짐 없는지
- [ ] 완료 후 계획·트러블슈팅을 `docs/archives/`로 이동
- [ ] TDD 예외 사용 시 최종 보고에 대상·이유 명시

## 영향 범위
- `Tuist/Config/*.xcconfig` — `CALENDAR_WEB_URL` 키 (값 본문은 응답/문서에 인용 금지)
- `Projects/App/Resources/App-Info.plist`
- `Projects/App/Sources/LivithApp+InjectDependency.swift` — `CalendarWebConfig` 항상 등록
- `Projects/HomeFeature/`
  - `CalendarWebConfig` (또는 App/Shared 위치 — Feature가 읽는 쪽 기준 최소 위치)
  - `CalendarWebView` (+ Coordinator / weak message proxy)
  - `CalendarHomeContentView`
  - 페이로드 매퍼/인코더 + 테스트
- Domain / CalendarData / Networking — **월·일 API 계약 변경 없음**

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 이슈 범위 | URL만 vs URL+주입+날짜탭 | **URL 로드 · 월별 주입 · 날짜 탭** | 이슈 제목 2번 · 웹 문서 |
| 월 이동 브릿지 | 포함 vs 후속 | **후속** (동기화 안 됨 = 알려진 제한) | 웹 미제공 |
| URL 키 | 여러 후보 | **`CALENDAR_WEB_URL`** | `BASE_URL` 관례 |
| URL 추출 | Feature Bundle 직접 vs App DI | **App → `CalendarWebConfig` 항상 등록 → Feature** | `resolve` fatalError 방지 · Feature 경계 |
| URL 설정 실패 | `fatalError` vs blank | **`about:blank`** (`url: nil`) | 합의 |
| 실 URL 로드 실패 | 에러 페이지 방치 vs blank 폴백 | **`about:blank` 폴백 + inject 스킵** | URL 실패와 동일 · 스펙 리뷰 |
| blank/`url == nil` inject | 호출 vs 스킵 | **스킵** | `setCalendarData` 미정의 |
| `updateUIView` | load 재호출 vs inject만 | **URL load 금지(최초 제외), month는 inject만** | SwiftUI 재호출 · 스펙 리뷰 |
| 주입 타이밍 | `didFinish` only vs ready 메시지 | **실 URL `didFinish` + pending payload** | 웹 ready 없음 |
| 필터/PTR 후 | 재주입 vs 리로드 | **`setCalendarData` 재호출** | 합의 |
| 빈 `days` | 호출 스킵 vs 호출 | **호출** (inject 조건 충족 시) | 합의 |
| JS 인자 | 객체 vs JSON 문자열 직접 | **`JSON.parse(escapedString)` → 객체** | 웹 객체 계약 · 이스케이프 |
| 메시지 핸들러 | Coordinator 직접 vs weak proxy | **weak proxy + remove** | retain cycle |
| message body | String만 vs String+Dictionary | **둘 다** | WK 관례 |
| URL을 View에 전달 | `@Injected` vs prop | **prop 우선** | 테스트·경계 |
| 날짜 탭 경로 | 신규 Intent vs 기존 | **`.dayScheduleRequested`** | LIVD-452 재사용 |
| Domain→웹 JSON | Domain Codable vs 전용 매퍼 | **전용 매퍼/인코더** | 키·타입 불일치 |
| DEBUG 일정 모달 | 브릿지 검증용 vs 아님 | **브릿지 검증 경로 아님** (유지) | 스펙 리뷰 |
| 실 URL 공개 | 이슈/문서 기재 vs 금지 | **금지** (키 이름만) | 보안 · xcconfig |
| 검증 도구 | 셸 xcodebuild vs XcodeBuildMCP | **XcodeBuildMCP 우선** (`test_sim` / `build_sim`) | 유저 지정 · LIVD-447 관례 |
| 검증 scheme | HomeFeature 등 vs 앱 | **`Livith-iOS-Dev`** | 유저 지정 |

## 주의 사항
- **TDD**: 페이로드 매퍼는 `docs/rules/tdd.md`. WKWebView·delegate·JS 배선은 예외 허용, 최종 보고에 대상·이유 명시.
- **빌드·테스트는 XcodeBuildMCP 우선**. 셸 `xcodebuild`는 MCP 불가 시에만 fallback하고 트러블슈팅에 기록.
- 실 `CALENDAR_WEB_URL` 값은 이슈·PR·계획·트러블슈팅·채팅에 원문으로 남기지 않는다. xcconfig 본문을 읽거나 인용하지 않는다 (`docs/rules/security.md`).
- `setCalendarData`는 **실 캘린더 URL navigation 완료 전·blank·로드 실패 후**에 호출하지 않는다.
- Web 메시지 스키마는 문서의 `{ "date": "yyyy-MM-dd" }`만 처리한다. 월 이동 등 추가 핸들러는 추가하지 않는다.
- `CalendarMonthEventType`과 날짜별 `CalendarDayEventType`을 브릿지 페이로드에 혼용하지 않는다.
- `didFinish` ≠ 스크립트 ready. ready 메시지 비범위라 레이스 잔존 가능 → 수동에서 빈 그리드 여부 확인.
- 관심 탭·세그먼트·기존 캘린더 API 회귀 금지.
- 실패·피드백·가정 변경 시 `docs/troubleshooting/LIVD-456-home-calendar-webview.md`에 즉시 기록.

## 검증 방법
- 자동화 (**XcodeBuildMCP**)
  1. `tuist generate --no-open` (Swift/설정 변경 시)
  2. `session_show_defaults` → 필요 시 `session_set_defaults` (scheme **`Livith-iOS-Dev`**, simulator **iPhone 17**)
  3. 페이로드 매퍼 테스트: `test_sim` 실패→통과 (`id` Int, 특수문자 artist, 빈 days)
  4. 기존 CalendarHomeStore 등 관련 테스트: `test_sim` 회귀
  5. App/배선 컴파일 필요 시 `build_sim` (실행은 수동 요청 시에만 `build_run_sim`)
  6. MCP 불가 시에만 셸 `xcodebuild test` fallback (`docs/rules/project-operations.md`)
- 수동
  - URL 유효 / 무효 / **로드 실패** 각각 WebView·inject 동작
  - 월 데이터 주입·필터·PTR 재주입(최신만)
  - **웹 날짜 탭** → 모달 E2E (성공/0건/실패 토스트)
  - 관심 ↔ 캘린더 remount 후 재동작

## 비범위 (후속)
- WebView 월 이동(◀▶ / 오늘) ↔ `selectedYear`/`selectedMonth` 동기화
- 웹 `calendarReady` 등 추가 메시지
- 네이티브 월 그리드 대체
- URL·브릿지 외 캘린더 API/Domain 변경
- DEBUG 「일정 모달」 제거
