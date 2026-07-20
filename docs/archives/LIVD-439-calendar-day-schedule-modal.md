# LIVD-439 캘린더 일자 일정 모달 (네이티브 UI + mock)

## 배경
- LIVD-439 1차에서 캘린더 필터 칩·빈 WebView·로드 실패 엠티뷰 골격을 올렸다.
- Figma 스펙 7·8·9는 **날짜 클릭 시 일정 정보 모달**이다.
  - [일정 있음](https://www.figma.com/design/G53QwXoxT96gB68dO7vRZi/?node-id=15-1523), [엠티](https://www.figma.com/design/G53QwXoxT96gB68dO7vRZi/?node-id=15-1925), [공연 취소](https://www.figma.com/design/G53QwXoxT96gB68dO7vRZi/?node-id=15-3768), [Description](https://www.figma.com/design/G53QwXoxT96gB68dO7vRZi/?node-id=15-2566)
- 이번 작업은 WebView 브릿지 없이 **네이티브 모달 UI·정렬·취소/엠티**를 mock으로 검증한다.
- deep-interview로 범위 확정 (브랜치: `feat/LIVD-439-home-calendar-ui`).
- 계획 리뷰(Request changes) 반영: HomeFeature-only 모델, 정렬 우선순위 고정, 모달 엠티 레이아웃 분리.

## 목표
- 일자 선택 시(DEBUG 트리거) **crossDissolve** 모달로 일정 정보 UI를 보여 준다.
- 일정 있음: 시간 정렬·예매일/공연일 카드·공연 취소(opacity 30%, 탭 불가).
- 일정 없음: `공연 일정이 없어요` 엠티 + `관심 콘서트 설정하기` CTA.
- 배경/X 탭으로 닫힌다.
- WebView 날짜 클릭 브릿지·API는 **포함하지 않는다**.

## 작업 항목

### 1. 일정 모델·정렬 (TDD)
- [x] **HomeFeature 내부 presentation 모델**로 일자 일정 아이템 정의 (Domain/Data/Networking 변경 금지)
  - 시간(optional) / 종류(예매일·공연일) / 제목 / 서브타이틀(티켓사이트·장소) / 취소 여부 / (선택) concertID
- [x] 정렬 순수 함수 테스트 → 구현. 우선순위(오름차순):
  1. `isCancelled == false` & 시간 있음 → 시각 → 동시이면 공연명 가나다 (`localizedStandardCompare`)
  2. `isCancelled == false` & 시간 없음 → 표시 `추후 발표` → 동그룹 내 공연명 가나다
  3. `isCancelled == true` → 표시 `공연 취소`(시간 유무 무관, 최하단) → 동그룹 내 공연명 가나다
- [x] 표시용 시간 문자열: `HH:mm` / `추후 발표` / `공연 취소`

### 2. `CalendarHomeStore` 모달 상태
- [x] State: `isDayScheduleModalPresented`, `selectedDayTitle`(또는 Date), `dayScheduleItems: [Item]`
- [x] Intent: `dayScheduleModalOpened`(fixture 또는 items), `dayScheduleModalDismissed`
  - **이번 범위에서 `dayScheduleItemTapped` Intent는 추가하지 않음** (카드 상세 네비 후속, YAGNI)
- [x] `dayScheduleModalOpened` 시 fixture를 **정렬 함수 통과 후** State에 저장 (Store 테스트로 검증)
- [x] mock fixture: 리스트(정상·긴 텍스트·추후 발표·취소 포함) / 빈 배열 (`#if DEBUG`, 엠티는 `[]`)
- [x] 테스트: open/dismiss, 빈 목록 → 엠티 분기 상태
- [x] `crossDissolve` Binding은 MVI 유지:
  `Binding(get: { store.state.isDayScheduleModalPresented }, set: { if !$0 { store.send(.dayScheduleModalDismissed) } })`

### 3. 모달 UI
- [x] `CalendarDayScheduleModalView` (또는 동등 Subview)
  - 헤더: 일자 타이틀 + X
  - 리스트: 시간 컬러 바 + chip + 제목(최대 2줄) + 서브타이틀(1줄) + chevron(취소 제외)
  - 취소 카드: opacity 30%, 탭 비활성
  - 활성 카드 pressed: 배경 `Black80` → `Black100` (Figma `15:1874`)
  - 모달 높이: 화면 높이 × `(540/812)` (Figma 비율), 세로 중앙
  - 엠티: 모달 카드 본문 안에서 Empty+CTA를 **세로 중앙** 배치 (`Spacer` 등). **`containerRelativeFrame`은 적용하지 않음** (로드실패 Empty 전용)
- [x] DesignSystem `.crossDissolve(isPresented:dismissOnTapOutside: true)` 사용
- [x] 부착 위치: `CalendarHomeContentView`

### 4. DEBUG 트리거
- [x] `#if DEBUG` 임시 버튼으로 모달 오픈 (리스트 fixture / 엠티 fixture)
- [x] 릴리즈 빌드에 트리거 미노출
- [x] 로드실패 Empty가 떠 있어도 DEBUG 버튼으로 모달을 열 수 있게 ContentView 루트에 배치

### 5. 네비게이션
- [x] 엠티 CTA → `homeRouter.push(.interestConcertSetting(mode: .update))`
  - 근거: `InterestHomeContentView`의 `onChangeTap`과 동일 (`.update`)
- [x] 진행 중 카드: 탭 가능 UI만 (chevron), 네비게이션 **없음** (후속)
- [x] 취소 카드 → 탭 무시

### 6. 검증
- [x] 정렬·Store 테스트 통과
- [x] `tuist generate --no-open` (신규 파일 시)
- [x] XcodeBuildMCP / `xcodebuild test` HomeFeature
- [ ] 수동(DEBUG): crossDissolve 열림·배경/X 닫힘·리스트/엠티·취소 opacity·CTA 이동·로드실패 화면에서도 DEBUG 오픈

## 영향 범위
- `Projects/HomeFeature/Sources/Home/Store/CalendarHomeStore.swift`
- `Projects/HomeFeature/Sources/Home/` — presentation 모델·정렬 함수 (HomeFeature 한정)
- `Projects/HomeFeature/Tests/` — Store·정렬 테스트
- `Projects/HomeFeature/Sources/Home/View/Calendar/` — 모달·카드 Subview, ContentView 배선
- DesignSystem — 기존 `.crossDissolve` / `LivithEmptyView` / 토큰만 사용
- Domain / Networking / Repository / WebView 브릿지 — **변경 없음**
- 트러블슈팅: `docs/archives/LIVD-439-calendar-day-schedule-modal-troubleshooting.md` (골격 트러블슈팅과 분리)

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 이번 범위 | UI만 / UI+브릿지 / 골격만 | **네이티브 모달 UI + 정렬/취소/엠티** | deep-interview A |
| presentation | sheet / crossDissolve | **`.crossDissolve`**, `dismissOnTapOutside: true` | 유저 확정 + Figma 배경 탭 닫힘 |
| 데이터 | mock / API / 빈 상태만 | **mock fixture** | deep-interview A |
| 상태 소유 | CalendarHomeStore / 별도 Store / View State | **`CalendarHomeStore`** | deep-interview A |
| 오픈 트리거 | DEBUG 버튼 / 머지 전 제거 / Preview만 | **`#if DEBUG` 버튼** | deep-interview A |
| 네비게이션 | CTA+카드 / CTA만 / 둘 다 후속 | **CTA만 Router (`.update`)**, 카드 상세는 후속 | deep-interview B + 홈 `onChangeTap` 동일 |
| 카드 탭 Intent | 추가 / 미추가 | **미추가** | YAGNI, 상세 네비 후속 |
| 모델 위치 | Domain / HomeFeature | **HomeFeature presentation만** | architecture + 영향 범위 Domain 미변경 |
| 정렬 우선순위 | Figma 하단만 / 추후발표→취소 고정 | **활성+시간 → 활성+무시간 → 취소** | 계획 리뷰 Blocking |
| 모달 엠티 레이아웃 | containerRelativeFrame / 모달 본문 중앙 | **모달 본문 세로 중앙**, relative 미사용 | 로드실패 Empty와 분리 |
| WebView 브릿지 | 포함 / 제외 | **제외** | 현재 `about:blank` |
| Store 중첩 리팩터 | 이번 / 후속 | **후속** (유저가 직접) | 이전 합의 |

## 주의 사항
- TDD: 정렬·Store 상태 변경은 `docs/rules/tdd.md` 준수. 순수 레이아웃은 예외 가능.
- 로드 실패 엠티(`isLoadFailed`)와 **일자 일정 엠티**를 혼동하지 말 것. 후자는 모달 내부.
- `containerRelativeFrame(.vertical)`은 **캘린더 로드실패 Empty 전용**. 모달 엠티에는 쓰지 않는다.
- Pressed/Hover는 iOS에서 Button pressed 스타일로 최소 반영(과도한 커스텀 금지).
- 실패·피드백 시 `docs/archives/LIVD-439-calendar-day-schedule-modal-troubleshooting.md`에 기록.
- 1차 골격 계획(`docs/archives/LIVD-439-home-calendar-ui.md`)과 병행. 완료 후 archives로 이동.

## 검증 방법
- 자동화: 정렬 테스트(가나다·취소·추후발표), `CalendarHomeStore` 모달 Intent 테스트, HomeFeature test scheme
- 수동(DEBUG): 리스트 fixture 모달 · 엠티 fixture · X/배경 dismiss · 취소 카드 탭 불가 · CTA → 관심 콘서트 설정 · 로드실패 화면에서도 DEBUG 오픈

## 후속(비범위)
- WebView 날짜 클릭 → 네이티브 모달 브릿지
- API/Repository 연동
- 카드 → 공연 상세 이동 (`dayScheduleItemTapped` 등)
- HomeStore nested State/Intent 리팩터
