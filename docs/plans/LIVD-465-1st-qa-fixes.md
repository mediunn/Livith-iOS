# LIVD-465 1차 QA 이슈 대응

## 배경
- 홈 관심 콘서트 탭에서 목록 조회 실패 시, 미설정 CTA(`EmptyInterestConcertSectionView`)와 `errorMessage` 토스트가 뜬다.
- Figma(`47:4093` 관심 콘서트 엠티뷰)는 로드 실패 전용 `LivithEmptyView`("콘서트 목록을\n불러오지 못했어요")를 요구한다.
- 캘린더 탭은 이미 `isLoadFailed` + `LivithEmptyView` 패턴을 사용한다.

## 목표
- 관심 콘서트 목록 조회 실패를 토스트가 아닌 엠티뷰로 표시한다.
- 목록이 비어 있는 실패 상태에서는 미설정 CTA를 보여주지 않는다.
- 관심 콘서트 설정 화면에 정보 요청 버튼과 툴팁을 노출한다.
- 캘린더 WebView 브릿지 계약을 최신 웹 스펙에 맞춘다 (`setCalendarData` 배열, `calendarMonthChanged`의 startDate/endDate).

## 권한·범위
- 정본(반드시 참이어야 하는 동작·불변조건):
  - 관심 콘서트 목록 조회 실패이고 목록이 비어 있으면 `LivithEmptyView(text: "콘서트 목록을\n불러오지 못했어요")`를 표시한다.
  - 위 실패 상태에서는 관심 헤더·추천·콘서트 섹션을 모두 숨기고 탭 콘텐츠를 엠티뷰만 보여준다.
  - 위 실패 경로에서는 `errorMessage` 토스트를 올리지 않는다.
  - `isInterestListLoadFailed`이면 관심 콘서트 결과 시트를 띄우지 않는다.
  - 목록이 이미 있는 상태에서 재조회(정렬 등)가 실패하면 기존 목록을 유지하고, 엠티뷰로 전체 화면을 덮지 않는다.
  - ScrollView 안 엠티뷰는 `containerRelativeFrame(.vertical)`로 배치한다 (고정 `padding(.vertical, 160)` 금지).
  - 성공 재조회 시 실패 플래그/메시지를 해제하고 정상 UI로 복귀한다.
  - 엠티뷰 상태에서 pull-to-refresh와 interest appear 재진입 시 관심 목록을 다시 조회한다.
  - 재조회 중 UI: pull-to-refresh는 시스템 스피너만 사용하고 커스텀 로딩으로 바꾸지 않는다. appear 재조회일 때만 로딩 인디케이터로 교체한다.
  - 관심 콘서트 설정 네비 우측에 `LivithReportButton("정보 요청", variant: .info)`를 둔다.
  - 버튼 아래 툴팁 `"찾는 콘서트가 없다면?"`(Yellow30)를 기본 노출한다.
  - 정보 요청(FR-06)으로 갔다가 돌아온 뒤에만 툴팁을 숨긴다. 그 외 재진입·다른 화면 왕복은 숨기지 않는다(뷰가 살아 있으면 계속 표시, 설정 화면을 완전히 pop 후 재진입하면 다시 표시).
  - 정보 요청 탭 시 Amplitude `click_concert_request` 후 `homeRouter.push(.concertRequest)`.
- 이번 범위 밖:
  - `LivithEmptyView` 공통 텍스트 색(Black50) 변경
  - 홈 섹션/추천 조회 실패 UX 변경
  - 세그먼트 탭 타이틀("관심 콘서트"/"캘린더") 변경
  - `InstagramManualSearchView` 툴팁 표시 조건 변경(항상 노출 유지)
  - `CalendarRepository` / 월·일 API 쿼리 계약 변경
  - `CALENDAR_WEB_URL`을 `BASE_URL`에서 파생하는 작업 (보류)
  - WebView 높이 측정·MonthChangeGate 동작은 변경하지 않음 (브릿지 계약 필드만 변경)
- 코드에서 복원 불가능한 의도(있으면):
  - Figma 문구·레이아웃이 로드 실패 엠티뷰의 정본이다.
  - Figma `47:5468` 툴팁 조건 중 「정보 요청 갔다가 돌아온 경우만 표시x」로 해석·확정.

## 작업 항목
- [x] 이슈1: 관심 콘서트 로드 실패 엠티뷰 (Store)
  - `HomeState`에 관심 목록 로드 실패를 표현하는 상태 추가 (캘린더의 `isLoadFailed` 패턴 권장)
  - `_interestListResult` 실패 시: 목록이 비어 있으면 실패 상태 설정 + `errorMessage`는 비움 / 목록이 있으면 기존 목록 유지(토스트 유지 여부: 기술 결정 표)
  - 성공 시 실패 상태 해제
  - TDD: red → green
- [x] 이슈1: 관심 콘서트 로드 실패 엠티뷰 (View)
  - `InterestHomeContentView`에서 실패 상태면 CTA/섹션 대신 `LivithEmptyView` 표시
  - 실패 경로에서 토스트가 뜨지 않도록 Store와 맞춤
- [x] 이슈1: 기존 테스트 갱신
  - 목록 비어 있는 실패 → 엠티뷰용 상태, `errorMessage` 비움
  - 목록 있는 재조회 실패 → 기존 목록 유지
- [x] 이슈2: 관심 콘서트 결과 시트 아이콘 컬러·문장
  - Figma `47:5737` 기준 chevron: `rightLineSmall` + template + black50
  - 요청 결과 공연명 말줄임: 공백 포함 24자 초과 시 `...` (Figma 플레이스홀더 24자와 정합)
  - UI 확인: `Livith-iOS-EntryAlertsTest` (`STUB_ENTRY_ALERTS`)
- [x] 이슈3: 관심 콘서트 설정 정보 요청 버튼·툴팁
  - 네비: 기존 back+title 유지 + 우측 `LivithReportButton` `.info`
  - 툴팁: 인스타 검색과 동일 비주얼, FR-06 왕복 후에만 숨김(`@State`)
  - 탭 → Amplitude + `concertRequest` 푸시
- [x] 이슈4: 캘린더 상세 모달 일정명 타이포
  - Figma `47:3002` Body3-sm → `body3Semibold` (기존 `body2Semibold`)
- [x] 이슈5: 홈 로고·탭 배경 black100 고정
  - 관심 목록 empty여도 `HomeView` 배경을 black90으로 바꾸지 않음 (Figma `47:5815`)
  - 미설정 CTA 블록 좌측 하단 corner radius 20 (background fill, clipShape 금지)
  - empty 헤더 top padding 0으로 탭과 붙임
  - CTA 블록 상·하 padding 30 (Figma `47:5818`)
- [x] 이슈6: 캘린더 WebView 브릿지 계약 정합
  - iOS→Web `setCalendarData`: 루트를 `{ year, month, days }`가 아닌 **day 배열** `[{ date, events }]`로 직렬화
  - event 필드 `id` / `artist` / `type`(`CONCERT`|`TICKETING`) 유지
  - 로드 완료 후 `window.setCalendarData(JSON.parse(...))` 호출 패턴 유지
  - Web→iOS `calendarDateSelected` `{ date }`는 유지 (변경 없음)
  - Web→iOS `calendarMonthChanged`: `{ year, month }` → `{ startDate, endDate }` (`yyyy-MM-dd`)
  - Store Intent: `monthChanged(startDate:endDate:)` (이슈8에서 기간 기반으로 통일)
  - TDD: PayloadMapper / MonthChangedParser 테스트 red→green
- [x] 이슈7: 월별 캘린더 API 계약 정합 (Notion 61)
  - Query: `year`/`month` → `startDate`/`endDate`
  - Response `data`: `{ year, month, days }` → day 배열 `[{ date, events }]`
  - `/calendar/events` 일자 API는 변경 없음
  - (이슈8에서 Repository·Store를 기간 기반으로 통일, Domain `CalendarMonth.year/month` 제거)
- [x] 이슈8: 월 조회를 `calendarMonthChanged` 기간으로 통일
  - 최초 조회도 웹 `startDate`/`endDate` 사용 (레포에서 월 경계 계산 제거)
  - `onAppear` 즉시 fetch 제거 → WebView 마운트 후 monthChanged 대기
  - 로딩 중에도 WebView 유지 (오버레이). `CalendarWebMonthChangeGate` 제거
  - Repository `fetchMonth(startDate:endDate:…)` · Store에 기간 보관 · 필터/soft refresh 재사용
  - 동일 기간 monthChanged는 no-op (remount 덮어쓰기 완화)
  - Domain `CalendarMonth`에서 `year`/`month` 제거 (`dayList`만 유지)

## 영향 범위
- `Projects/HomeFeature` — 캘린더 Store·WebView·파서·LoadSession, Gate 제거
- `Projects/LivithNetworking` — `CalendarAPI`, `FetchCalendarMonth`
- `Projects/Data/CalendarData` — `CalendarMapper`, `CalendarRepositoryImpl`
- `Projects/Domain` — `CalendarRepository.fetchMonth(startDate:endDate:)`
- App / DesignSystem 변경 없음

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 실패 표현 | A. `isInterestListLoadFailed` 플래그 + 고정 문구 / B. `errorMessage` 재사용 | A | 캘린더와 동일. 토스트와 엠티뷰 채널을 분리 |
| 엠티뷰 트리거 | A. 관심 목록 실패 + 목록 empty만 / B. 섹션·유저 실패 포함 | A | Figma 문구가 콘서트 목록 조회에 한정 |
| 목록 있는 재조회 실패 | A. 기존처럼 `errorMessage` 토스트 / B. 무시 / C. 엠티뷰로 전환 | A | 콘텐츠를 가리지 않음. Figma는 빈 목록 실패 화면 |
| 엠티뷰 문구 | 고정 `"콘서트 목록을\n불러오지 못했어요"` | 고정 | Figma 정본. `localizedDescription` 사용 안 함 |
| 복구 경로 | A. refresh + appear 재조회 / B. refresh만 / C. 별도 재시도 버튼 | A | 캘린더 재시도와 맞춤. Figma에 CTA 없음 |
| 재조회 중 UI | A. 항상 커스텀 로딩 / B. refresh는 시스템 스피너만, appear만 커스텀 로딩 | B | refreshable과 풀스크린 로딩 이중 표시 방지 |
| 결과 시트 | A. 로드 실패 시 미노출 / B. errorMessage만 가드 | A | 실패 화면과 시트 동시 노출 방지 |
| `LivithEmptyView` 색 | 이번 이슈에서 수정 / 보류 | 보류 | 공통 컴포넌트 영향. 별도 QA로 분리 |
| 설정 화면 툴팁 숨김 | A. FR-06 왕복만 / B. 아무 페이지 왕복 / C. 항상 표시(인스타와 동일) | A | 유저 확정. Figma `47:5468` 표시x를 FR-06 왕복으로 해석 |
| 툴팁 상태 위치 | A. View `@State` / B. Store | A | UI 배선만. 화면 인스턴스 수명과 맞춤 |
| `setCalendarData` 루트 | A. day 배열 / B. `{year,month,days}` 유지 | A | 웹 최신 계약 |
| `calendarMonthChanged` body | A. `startDate`+`endDate` / B. `year`+`month` 유지 | A | 웹 최신 계약 |
| 월 식별 | A. `startDate`의 year/month / B. `endDate` / C. Store를 기간 Intent로 변경 | A | Repository는 year/month. Intent 변경 최소화 |
| 구 `{year,month}` 호환 | A. 제거 / B. 폴백 유지 | A | 계약 단일화. 웹이 신계약만 보냄 |
| 월 API query | A. `startDate`+`endDate` / B. `year`+`month` 유지 | A | Notion Query·400 메시지 정본 |
| 월 API 응답 | A. day 배열 / B. `{year,month,days}` 유지 | A | Notion Output 정본 |
| Repository 시그니처 | A. year/month 유지·경계에서 변환 / B. start/end로 변경 | B | 이슈8: 웹 기간이 단일 정본 |
| 초회 월 fetch 트리거 | A. onAppear year/month / B. calendarMonthChanged 기간 | B | 레포 월 경계 계산 제거 |
| MonthChangeGate | A. inject 전 차단 유지 / B. 제거·동일 기간 no-op | B | 초회 monthChanged 필요 |

## 주의 사항
- `errorMessage`를 비우는 경로와 토스트 `onChange`가 맞물려 회귀하지 않게 기존 HomeStore 에러 테스트를 함께 확인한다.
- 관심 결과 시트는 `errorMessage.isEmpty` 가드를 쓰므로, 엠티뷰 전환이 시트 노출에 부작용을 주는지 확인한다. 로드 실패 플래그일 때도 시트를 띄우지 않도록 가드를 맞춘다.
- `setCalendarData` 빈 월은 `[]`가 된다 (`{ days: [] }` 아님).
- `startDate`/`endDate` 파싱 실패·날짜 형식 오류 시 monthChanged를 무시한다 (기존 year/month 검증과 동일하게 no-op).
- `CalendarWebMonthChangeGate`(첫 inject 전 monthChanged 무시)는 유지한다.

## 검증 방법
- [x] 명령: `xcodebuild test -workspace "Livith-iOS.xcworkspace" -scheme "HomeFeature" -only-testing:HomeFeatureTests -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5'`
- [x] 기대 신호: 관심 목록 실패·정렬 실패 관련 테스트 통과
- [x] 실제 결과: `HomeStoreTests` 포함 163 tests passed
- [ ] 명령: 수동 — 관심 목록 API 실패 유도 후 홈 관심 탭
- [ ] 기대 신호: CTA/토스트 없이 엠티뷰 문구 표시
- [ ] 실제 결과: 
- [x] 명령: `xcodebuild test -workspace "Livith-iOS.xcworkspace" -scheme "HomeFeature" -only-testing:HomeFeatureTests/CalendarWebMonthPayloadMapperTests -only-testing:HomeFeatureTests/CalendarMonthChangedMessageParserTests -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5'`
- [x] 기대 신호: 배열 payload·startDate/endDate 파서 테스트 통과
- [x] 실제 결과: 7 tests passed
- [x] 명령: `xcodebuild test -workspace "Livith-iOS.xcworkspace" -scheme "CalendarData" -only-testing:CalendarDataTests/CalendarMapperTests -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5'`
- [x] 기대 신호: 월별 배열 응답 매퍼 테스트 통과
- [x] 실제 결과: 8 tests passed
- [x] 명령: `xcodebuild test … -only-testing:HomeFeatureTests/CalendarHomeStoreTests -only-testing:HomeFeatureTests/CalendarMonthChangedMessageParserTests`
- [x] 기대 신호: monthChanged 기간 기반 Store·파서 테스트 통과
- [x] 실제 결과: 26 tests passed
- [ ] 명령: 수동 — 캘린더 탭에서 월 데이터 표시·날짜 탭·월 이동
- [ ] 기대 신호: 마커 표시, 일자 모달, 월 변경 후 재조회·재주입
- [ ] 실제 결과: 

## 컴파운딩 (아카이브 전)
- [ ] 교훈 분류 완료
- rules 반영 (`기본 승격 규칙`):
  - 
- 분리 확인 제안 (`architecture` / `security`, 있으면):
  - 
- archive만 유지:
  - 
- 반영 없음 / 사유: 
