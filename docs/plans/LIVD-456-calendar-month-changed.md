# LIVD-456 홈 캘린더 Web → iOS 월 변경 (`calendarMonthChanged`)

## 배경
- LIVD-456에서 URL 로드·`setCalendarData`·`calendarDateSelected`까지 연동했다.
- 월 이동(◀▶ / 오늘)은 웹 UI에 있고, 기존 계획에서는 브릿지 미제공으로 **비범위**였다.
- 웹 계약이 추가됐다. Web → iOS `calendarMonthChanged` + `{ "year": Int, "month": Int }`.
- Store는 이미 `selectedYear` / `selectedMonth`로 `fetchMonth`한다. Intent만 없으면 웹 월과 API 월이 어긋난다.
- 브랜치: `feat/LIVD-456-home-calendar-webview`

## 목표
- WebView가 `calendarMonthChanged`를 수신해 year/month를 파싱한다.
- Store가 year/month를 갱신한 뒤 기존 필터로 `fetchMonth`한다 (성공 시 기존 `setCalendarData` 재주입 경로 사용).
- 동일 year/month·잘못된 month는 무시한다. 로드/inject 실패 정책은 유지한다.

## 작업 항목

### 1. 메시지 파서 (TDD)
- [x] `CalendarMonthChangedMessageParser` (`Home/Helper/`)
  - body: `NSDictionary` / `[String: Any]` / JSON `String` 수용
  - `year: Int`, `month: Int` (1...12)만 유효
  - 실패 시 `nil`
- [x] 단위 테스트 (유효 JSON/dict, month 범위 밖, 필드 누락)

### 2. Store Intent
- [x] `CalendarHomeIntent.monthChanged(year:month:)`
  - 동일 year/month → no-op
  - month ∉ 1...12 → no-op
  - 일자 모달 닫기 + 진행 중 일자 fetch **취소** (`CancelID.fetchDayEvents` + `dayEventsRequestID`)
  - year/month 갱신 후 `performFetchMonth(showInitialLoading: false)` (월 fetch 연타도 기존 `monthRequestID` 취소)
  - **실패 시** 기존과 동일 `isLoadFailed = true` → 엠티뷰
- [x] Store 단위 테스트 (동일월 no-op, 유효 변경 fetch, 실패 시 `isLoadFailed`, 모달 닫기)

### 3. WebView 브릿지
- [x] `calendarMonthChanged` 핸들러 등록/해제 (기존 weak proxy 재사용, `message.name` 분기)
- [x] 파싱 성공 → MainActor에서 `onMonthChanged(year, month)` 콜백
- [x] `CalendarHomeContentView`: `store.send(.monthChanged(year:month:))` 연결
- [x] WK 배선은 TDD 예외 (`docs/rules/tdd.md`). 파서·Store는 TDD

### 4. 검증 · 문서
- [x] 파서·Store 테스트 red → green
- [x] `tuist generate --no-open` (파일 추가 시)
- [x] `HomeFeature` 테스트 + `Livith-iOS-Dev` 빌드
- [ ] 수동: 웹 ◀▶ / 오늘 → 월 데이터·점 갱신, 날짜 탭 모달, 동일월 연타 no-op
- [ ] 기존 LIVD-456 계획·트러블슈팅에 월 변경 반영 후, 이슈 완료 시 함께 `docs/archives/` 이동

## 영향 범위
- `Projects/HomeFeature/`
  - `CalendarWebView`, `CalendarHomeContentView`
  - `CalendarHomeStore` (+ Intent/State 사용)
  - `CalendarMonthChangedMessageParser` + Tests
  - `CalendarHomeStoreTests`
- Domain / Data / Networking — **계약 변경 없음** (기존 `fetchMonth(year:month:...)`)

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 핸들러 이름 | 임의 vs 계약 | **`calendarMonthChanged`** | 웹 문서 |
| 페이로드 | year/month Int | **그대로** | 웹 문서 |
| 동일 월 | refetch vs no-op | **no-op** | 불필요 API |
| month 범위 | clamp vs ignore | **ignore (`nil`/no-op)** | 잘못된 브릿지 방어 |
| 로딩 UI | 초기 로딩 vs 조용히 | **`showInitialLoading: false`** | 필터 변경과 동일 |
| 월 변경 fetch 실패 | WebView 유지+토스트 vs 엠티뷰 | **엠티뷰 (`isLoadFailed`)** | 최초/필터 실패와 동일 경로 |
| 열린 일자 모달 | 유지 vs 닫기 | **A: 닫기** | 이전 월 일자 모달 잔존 방지 |
| 진행 중 일자 fetch | 방치 vs 취소 | **A: 취소** (+ requestID 무효화) | 늦은 성공으로 모달 재오픈 방지 |
| 월 fetch 연타 | 신규 vs 취소 | **기존 `monthRequestID`/Task 취소 재사용** | 빠른 월 이동 시 최신만 반영 |
| iOS → Web 월 동기화 | 별도 메시지 vs setCalendarData | **`setCalendarData`만** (fetch 성공 후 기존 주입) | 추가 브릿지 불필요 |

## 주의 사항
- `updateUIView`에서 URL 재load 금지 유지. 월 변경은 Store fetch → `calendarMonth` 변경 → inject만.
- `calendarDateSelected`와 핸들러 수명(add/remove)을 함께 관리.
- unlock/maxBottom 높이 측정은 inject 성공 후 기존 스케줄 유지.
- 웹이 year/month를 보낸 뒤 iOS fetch 전에 UI만 바뀌면 점 데이터가 잠깐 어긋날 수 있음 — 허용 (후속 주입으로 맞춤). 실패 시에는 엠티뷰로 WebView가 내려감.

## 검증 방법
- 파서·Store 테스트 통과
- 시뮬: 월 이동 → 그리드/`setCalendarData` 반영, 날짜 탭 모달, PTR·필터 회귀
- `docs/rules/project-operations.md`에 따른 generate/test
