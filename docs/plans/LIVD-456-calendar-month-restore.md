# LIVD-456 캘린더 상세 복귀 시 월 유지

## 배경
- 8월로 이동한 뒤 일자 일정 → 콘서트 상세 → 뒤로가기 시 캘린더가 7월(현재 월)로 돌아간다.
- 원인 후보가 두 갈래로 겹친다.
  1. `CalendarHomeContentView.onAppear` → `onAppear` Intent가 항상 `performFetchMonth(showInitialLoading: true)`를 호출한다. 로딩 중 WebView가 제거(dismantle)된다.
  2. 재생성된 WebView가 현재 월로 로드되며 `calendarMonthChanged`(7월)를 보낼 수 있고, Store의 `selectedYear`/`selectedMonth`(8월)를 덮어쓴 뒤 7월을 다시 fetch한다.

## 목표
- 콘서트 상세에서 홈 캘린더로 복귀해도 **이전에 보던 year/month가 유지**된다.
- 사용자가 웹에서 월을 바꾼 뒤의 `calendarMonthChanged` 동기화는 그대로 동작한다.
- 첫 진입·로드 실패 후 재시도 등 기존 초기 로딩 UX는 유지한다.

## 작업 항목
- [x] Store `onAppear` TDD
  - 이미 `calendarMonth != nil` 이고 `isLoadFailed == false`이면 **같은 year/month soft refresh** (`showInitialLoading: false`) — 관심 변경 반영 + WebView remount 방지
  - 미로드/`isLoadFailed`면 기존처럼 `showInitialLoading: true` fetch
- [x] WebView Coordinator: 첫 `setCalendarData` 성공 전까지 `calendarMonthChanged` 콜백 **무시**
  - 초기 로드·remount 시 웹이 보내는 현재 월 이벤트가 Store를 덮지 않게 한다
  - inject 성공 이후의 월 변경은 기존대로 전달
  - blank/로드 실패로 inject가 스킵되면 콜백은 계속 무시 (또는 remount 시 플래그 리셋)
- [x] 필요 시 Coordinator 단위로 “inject 전 monthChanged 무시”를 검증할 수 있는 순수 헬퍼/플래그 로직 분리 (UIViewRepresentable 직접 테스트 부담을 줄임)
- [x] 트러블슈팅 기록 (`docs/troubleshooting/LIVD-456-home-calendar-webview.md`)
- [x] 검증: Store 테스트 + `Livith-iOS-Dev` 빌드
- [ ] 수동: 8월 → 상세 → 복귀 시 8월 유지 확인

## 영향 범위
- `Projects/HomeFeature/Sources/Home/Store/CalendarHomeStore.swift`
- `Projects/HomeFeature/Tests/CalendarHomeStoreTests.swift`
- `Projects/HomeFeature/Sources/Home/View/Calendar/CalendarWebView.swift` (+ 필요 시 Helper)
- `docs/troubleshooting/LIVD-456-home-calendar-webview.md`

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 복귀 시 onAppear | A) no-op if loaded / B) soft refresh without loading / C) 유지 | **B (soft refresh)** | 상세에서 관심 변경 반영. `showInitialLoading: false`로 remount 방지 |
| 초기 monthChanged | A) inject 전 무시 / B) Store에서 무시 / C) 웹 수정만 | **A** | remount 레이스는 WebView 쪽에서 끊는 것이 맞음 |
| 웹 URL에 year/month 쿼리 | 추가 vs 안 함 | **안 함** | 계약 미확인, inject+suppress로 충분 |

## 주의 사항
- `onAppear` no-op 후에도 Navigation으로 WebView가 dismantle되면 remount는 발생한다 → monthChanged suppress가 필수다.
- 필터 변경·PTR·사용자 월 스와이프 경로는 회귀시키면 안 된다.
- TDD: Store Intent 변경은 red→green. WebView 플래그는 가능하면 순수 로직으로 검증.

## 검증 방법
- `xcodebuild test` (HomeFeature / CalendarHomeStore 관련)
- `xcodebuild build` Livith-iOS-Dev
- 수동: 캘린더 8월 → 일정 탭 → 상세 → 뒤로가기 → **8월 유지** / 웹 ◀▶로 월 변경은 계속 동기화
