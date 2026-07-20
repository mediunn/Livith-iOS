# LIVD-439 홈 캘린더 UI 골격 (필터 칩 + 빈 WebView)

## 배경
- LIVD-438에서 홈을 **관심 콘서트 / 캘린더** 세그먼트로 분리했고, 캘린더 탭은 `준비 중` 플레이스홀더다.
- 이번 작업은 Figma 캘린더 화면의 **네이티브 상단 필터 + WebView 영역**을 골격으로 올린다.
- Figma: [기본 화면](https://www.figma.com/design/G53QwXoxT96gB68dO7vRZi/?node-id=15-2993), [캘린더](https://www.figma.com/design/G53QwXoxT96gB68dO7vRZi/?node-id=15-2582), [Description](https://www.figma.com/design/G53QwXoxT96gB68dO7vRZi/?node-id=15-2001)
- deep-interview로 범위·경계를 확정했다 (브랜치: `feat/LIVD-439-home-calendar-ui`).
- 계획 리뷰(Approve with changes) 반영: Store 생명주기·토스트 presentation·소프트 문구 제거.

## 목표
- 캘린더 탭에서 `준비 중`을 제거하고, Figma와 같은 **필터 칩 행 + 그 아래 빈 WebView 영역**을 보여 준다.
- 필터 칩은 **UI 토글**까지 동작한다. WebView와는 아직 연동하지 않는다.
- 예매일·공연일 **둘 다 off 시도** 시 선택 불가 토스트를 띄우고, 마지막 on 칩은 꺼지지 않는다.
- 월 헤더(연월·오늘·◀▶)와 날짜 그리드는 **WebView 소속**이며, 이번엔 URL 없이 빈 영역만 둔다.

## 작업 항목

### 1. 캘린더 필터 상태/로직 (TDD)
- [ ] `Projects/HomeFeature/Tests/CalendarHomeStoreTests.swift`에 `Testing` Suite 추가 (신규 파일, SUT = `CalendarHomeStore`)
- [ ] 실패 테스트 → 최소 구현 (각각 단일 행동):
  - 초기값: 예매일 on, 공연일 on, 공연 범위 = 전체 공연
  - 예매일/공연일 독립 토글
  - 마지막 on 칩 off 시도 → 상태 유지 + `selectionBlockedToastMessage` 설정
  - 토스트 문구: `예매일 또는 공연일 중 하나는 선택해야 해요.`
  - 전체 공연 ↔ 내 공연 상호 배타 전환
  - 토스트 dismiss Intent → 메시지 클리어
- [ ] `CalendarHomeStore`만 Intent/`send`로 상태 변경 (View 직접 변경 금지)

### 2. Store 소유·HomeView 배선
- [ ] `CalendarHomeContentView`에서 `HomeStore` 파라미터 **제거**
- [ ] `HomeView`가 `@StateObject private var calendarStore: CalendarHomeStore`를 소유하고, `CalendarHomeContentView(store: calendarStore)`로 주입 (`@ObservedObject`)
- [ ] `HomeView`의 `CalendarHomeContentView(...)` 호출부를 새 시그니처에 맞게 수정

### 3. 캘린더 탭 UI
- [ ] `CalendarHomeContentView`를 필터 행 + WebView 슬롯 레이아웃으로 교체
  - 상단: 예매일·공연일(좌) / 전체 공연·내 공연(우) — Figma `Frame 1739336441`
  - 하단: 남은 공간을 채우는 빈 WebView
- [ ] 칩: Figma 맞춤 로컬 Subview + DesignSystem 토큰 (`Color.livithColor`, `notosans`). `LivithChip`은 도트/스펙이 맞을 때만 사용
- [ ] `준비 중` 플레이스홀더 제거

### 4. 선택 불가 토스트
- [ ] `.livithToast(type: .failure, ...)`를 **`CalendarHomeContentView`**에 부착 (메시지 소스는 `CalendarHomeStore`)
- [ ] dismiss 시 Store Intent로 메시지 클리어
- [ ] HomeView `errorMessage` 토스트와 **메시지 필드를 공유하지 않음**
- [ ] `ToastWindowManager.shared` 단일 윈도우이므로, 관심 탭 에러 토스트와 캘린더 불가 토스트가 겹치면 **나중에 show한 쪽이 덮어씀**. 이번 범위에서는 동시 유도 UI를 만들지 않음. 캘린더 탭이 보이는 동안 유발하는 불가 토스트는 캘린더 View modifier가 담당

### 5. 빈 WebView 슬롯
- [ ] HomeFeature에 `CalendarWebView: UIViewRepresentable` 추가 (`WKWebView` + `about:blank`)
  - 브릿지·쿼리·쿠키·필터 동기화 **없음**
  - 배경은 홈 캘린더와 같게 `black100`에 맞출 것 (흰 플래시 최소화)
- [ ] 월 헤더는 네이티브로 그리지 않음 (WebView 영역)

### 6. 검증
- [ ] `CalendarHomeStoreTests` red→green 통과
- [ ] Swift 파일 추가 후 `tuist generate --no-open`
- [ ] `xcodebuild -list`로 HomeFeature 테스트 scheme 확인 후 `xcodebuild test` 실행 (destination: Available destinations 기준, 기본 `iPhone 17`)
- [ ] 수동: 캘린더 칩 토글·불가 토스트·빈 WebView, 관심 탭 세그먼트/API 회귀

## 영향 범위
- `Projects/HomeFeature/Sources/Home/View/Calendar/CalendarHomeContentView.swift`
- `Projects/HomeFeature/Sources/Home/View/Calendar/Subview/` (필터 칩 등)
- `Projects/HomeFeature/Sources/Home/View/Calendar/CalendarWebView.swift`
- `Projects/HomeFeature/Sources/Home/Store/CalendarHomeStore.swift` (State / Intent / Store)
- `Projects/HomeFeature/Sources/Home/View/HomeView.swift` — Calendar 생성·(결정에 따라) Store 소유
- `Projects/HomeFeature/Tests/CalendarHomeStoreTests.swift`
- DesignSystem — 기존 `.livithToast` / 토큰만 사용, **신규 API 없음**
- Domain / Networking / Repository — **변경 없음**

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 네이티브 / WebView 경계 | 월 헤더 네이티브 vs WebView | **월 헤더~그리드 = WebView**, 네이티브는 필터 칩만 | deep-interview |
| 이번 WebView 내용 | 실 URL vs 빈 영역 | **`CalendarWebView` + `about:blank` 필수** | deep-interview; 단색 placeholder로 대체하지 않음 |
| 칩 동작 | 시각만 vs UI 토글 vs WebView 연동 | **UI 토글 + 불가 토스트** | deep-interview |
| 둘 다 off | 무시 vs 허용 vs 토스트 | **상태 유지 + 토스트** | Figma Description 1·5 |
| 토스트 문구 | — | **`예매일 또는 공연일 중 하나는 선택해야 해요.`** | 유저 확정 |
| 비로그인 / 로그인 유도 | 포함 vs 무시 | **무시** | 모바일은 항상 로그인 |
| 상태 소유 | `HomeStore` vs `CalendarHomeStore` | **`CalendarHomeStore`** | 관심 파이프라인과 분리; 향후 WebView 브릿지 수용 |
| HomeStore 주입 | 유지 vs 제거 | **제거** | 캘린더 골격이 Home 관심 상태에 비의존 |
| 탭 전환 시 필터 | 유지 vs 리셋 | **유지** — `HomeView`가 `CalendarHomeStore` `@StateObject` 소유 후 주입 | 탭 `switch` 시 ContentView 재생성에도 필터 유지 (유저 확정) |
| 토스트 presentation | HomeView vs Calendar content | **`CalendarHomeContentView` + Store 메시지** | 메시지 슬롯 분리; 공유 `ToastWindowManager` 덮어쓰기 리스크는 주의 사항으로 수용 |
| 토스트 타입 | success vs failure | **`failure`** | validation 불가 → caution 아이콘. 전용 toast type 추가는 후속 |
| 칩 컴포넌트 | `LivithChip` vs 로컬 | **로컬 Subview + 토큰** | Figma 도트/스펙 |
| 후속(비범위) | — | URL 로드, JS 브릿지, 필터→WebView 동기화, 로드 실패 엠티뷰 | deep-interview |

## 주의 사항
- **TDD**: `CalendarHomeStore` 상태 변경은 `docs/rules/tdd.md` (`red → verify red → green → verify green → refactor`). `CalendarWebView` 배선·순수 레이아웃은 예외 허용.
- `ToastWindowManager.shared`로 Home 에러 토스트와 캘린더 불가 토스트가 경합할 수 있음. 필드는 분리하되 윈도우는 공유된다는 전제를 깨지 말 것.
- 관심 탭 `interestAppear`·세그먼트 회귀 금지 (LIVD-438).
- 웹용 Description(비로그인 팝업, 웹 엠티뷰)을 모바일 범위로 끌어오지 말 것.
- WebView 실데이터/브릿지 이번 PR 금지.
- `about:blank` 흰 화면 플래시 → WKWebView/`isOpaque`/배경을 `black100`에 맞출 것.
- 실패·피드백·가정 변경 시 `docs/archives/LIVD-439-home-calendar-ui-troubleshooting.md`에 기록.

## 검증 방법
- 자동화
  1. `CalendarHomeStoreTests` 실패→통과
  2. `tuist generate --no-open`
  3. `xcodebuild -list`로 scheme 확정 후  
     `xcodebuild test -workspace "Livith-iOS.xcworkspace" -scheme "<확정된 scheme>" -destination 'platform=iOS Simulator,name=iPhone 17'`  
     (`docs/rules/project-operations.md`)
- 수동
  - 홈 → 캘린더: 필터 기본값, 칩 토글, 마지막 칩 off 토스트, 하단 빈 WebView(`black100`)
  - 관심 ↔ 캘린더 전환 후 필터 선택값 **유지** 확인
  - 관심 탭 목록/섹션 로드 회귀
