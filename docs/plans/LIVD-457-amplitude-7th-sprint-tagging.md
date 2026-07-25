# LIVD-457 7차 스프린트 앰플리튜드 태그 태깅

## 배경
- Amplitude Event 명세서(26.04.11) 기준 "01. 태깅 요청" 상태 이벤트 27개가 존재하나, 일부는 코드에 미반영되어 있다.
- 명세서상 iOS DB 이벤트명은 접두사 없이 정의되며, 최종 태그명은 앱에서 `ios_` 접두사를 붙여 전송한다.
- 요구사항: (1) 태깅 안 된 이벤트 반영, (2) 기존/신규 모든 이벤트가 `ios_` 접두사를 갖도록 보장.

## 목표
- 명세서 "01. 태깅 요청" 이벤트 중 대응 UI가 구현된 이벤트를 `AmplitudeService.trackEvent(tag:)`로 연결한다.
- 모든 이벤트가 `ios_` 접두사를 갖는 것을 보장한다.
- "100. 삭제" 이벤트의 잔존 코드를 제거한다.

## 현황 분석

### `ios_` 접두사
- `AmplitudeService.EventTag.value`가 `Self.prefix("ios_") + rawValue` 형태로 **중앙에서 접두사를 부여**한다.
- 코드베이스 전수 조사 결과 `AmplitudeService`를 우회한 직접 `amplitude.track`/`logEvent` 호출은 없다.
- 결론: 기존·신규 이벤트 모두 `ios_` 접두사가 자동 적용되므로 추가 조치 불필요. (검증만 수행)

### 이미 태깅 완료 (명세서 상태만 stale, 조치 불필요)
- `click_genre_all/jpop/rock_metal/rap_hiphop/pop/indie` → `ExploreView` genreTabButton
- `click_booking_schedule_notification`, `click_pre_booking_schedule_notification` → `NoticeView`
- `click_push_pre_booking_schedule` → `DeepLinkService`

### 신규 태깅 대상 (UI 구현 완료 → 이번 작업 범위)
| 이벤트명(raw) | 화면 | 연결 위치 |
|---|---|---|
| click_interest_concert_tab | 홈 메인 | `HomeView` segmentedTabBar `.interestConcert` 선택 |
| click_interest_calendar_tab | 홈 메인 | `HomeView` segmentedTabBar `.calendar` 선택 |
| click_ios_ig_parsing_success | 인스타 파싱 | `InstagramMatchConfirmView` 등록하기 |
| click_ios_ig_parsing_fail | 인스타 파싱 | `InstagramMatchConfirmView` 취소 팝업 "지금은 그만할래요" |
| click_ios_ig_search | 인스타 파싱 | `InstagramMatchConfirmView` "직접 찾아볼게요" |
| click_ios_ig_search_success | 인스타 파싱 | `InstagramManualSearchView` 등록하기 |
| click_concert_request | 공연 요청 | "정보 요청" 진입 버튼 |
| click_concert_request_comfirm | 공연 요청 | `ConcertRequestView` submitButton("요청하기") |
| click_concert_request_added | 공연 요청 | 요청 결과 모달 > 관심 콘서트 자동 등록 |
| click_concert_request_retry | 관심 콘서트 소식 | 요청 실패 콘서트 > "재요청" |

### 캘린더 필터 (네이티브 UI 존재 → 이번 작업 범위)
`CalendarFilterBarView`(네이티브 필터바) 내부의 칩/스코프 버튼은 태깅 가능하다.
| 이벤트명(raw) | 연결 위치 |
|---|---|
| click_chip_concert_date | `CalendarFilterBarView` 공연일 칩(`.performanceDateTapped`) |
| click_chip_booking_date | `CalendarFilterBarView` 예매일 칩(`.ticketingDateTapped`) |
| click_toggle_all_concert | `CalendarFilterBarView` "전체 공연"(`.allConcertsTapped`) |
| click_toggle_my_concerts | `CalendarFilterBarView` "내 공연"(`.myConcertsTapped`) |

### 차단 (UI 미구현 → 이번 범위 제외, 별도 처리 필요)
- `click_signup_banner_main`: 대응하는 회원가입 배너 UI가 코드에 없음.
- 캘린더 그리드 3개(`click_calendar_month`, `click_calendar_today`, `click_calendar_date`): 캘린더 그리드는 `CalendarWebView`(빈 WKWebView) 플레이스홀더로, 월 이동/오늘/일자 클릭 인터랙션이 웹 콘텐츠 내부라 네이티브 태깅 지점이 없음.

### 삭제 대상 (100. 삭제)
- `interestRecommendedConcert`(`click_interest_recommended_concert`): enum 정의(AmplitudeService)만 존재하고 호출처 없음 → enum 케이스 제거.
- `click_first_concert_cell`, `click_second_concert_cell`: 코드에 부재 → 조치 없음.

## 작업 항목
- [x] `AmplitudeService.ClickEvent`에 신규 케이스 14개 추가 (raw 값은 명세서와 동일)
- [x] `AmplitudeService.ClickEvent`에서 `interestRecommendedConcert` 제거
- [x] `HomeView` 탭 선택 2개 + 재요청 1개 이벤트 연결
- [x] `InstagramMatchConfirmView` / `InstagramManualSearchView` 버튼에 IG 4개 + 공연 요청 진입 1개 연결
- [x] `ConcertRequestView` 요청하기/자동등록 2개 연결 (+ ShareFeature에 `.core(.amplitude)` 의존성 추가)
- [x] `CalendarFilterBarView` 칩/스코프 4개 연결
- [x] `tuist generate` 후 빌드 검증 (HomeFeature / ShareFeature Build Succeeded)

## 영향 범위
- `Projects/Core/Amplitude/Sources/AmplitudeService.swift` (enum 추가/삭제)
- `Projects/HomeFeature/Sources/Home/View/HomeView.swift`
- `Projects/HomeFeature/Sources/InstagramMatch/View/InstagramMatchConfirmView.swift`, `InstagramManualSearchView.swift`
- `Projects/HomeFeature/Sources/Home/View/Calendar/Subview/CalendarFilterBarView.swift`
- `Projects/ShareFeature/Sources/ConcertRequest/ConcertRequestView.swift`
- `Projects/ShareFeature/Project.swift` (`.core(.amplitude)` 의존성 추가 → 프로젝트 재생성)

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|---|---|---|---|
| `ios_` 접두사 처리 | 신규로 붙임 / 기존 중앙 로직 유지 | 중앙 로직 유지 | `EventTag.value`가 이미 전 이벤트에 부여, 우회 태깅 없음 |
| `comfirm` 오타 처리 | 명세서 그대로(comfirm) / 정정(confirm) | 명세서 그대로(comfirm) | 사용자 확인: 대시보드 이벤트명과 일치해야 데이터 정상 수집. Swift 케이스명은 `concertRequestConfirm`, raw만 오타 유지 + 주석 |
| 캘린더 이벤트 범위 | 전체 7개 / 필터 4개만 | 필터 4개만 | 그리드(월/오늘/일자)는 `CalendarWebView` 내부라 태깅 불가, 필터바는 네이티브 |
| value 검증 테스트(TDD) | 신규 테스트 타깃 생성 / 생략 | 생략 | Core에 테스트 타깃 전무 + 공유 Tuist 타깃 enum 변경 필요(과도). tdd.md상 enum 상수 데이터·트랙 호출 삽입은 UI/데이터 배치로 TDD 예외. raw 값은 명세서와 문자 단위 대조로 보증 |

## 주의 사항
- raw 값은 반드시 명세서와 문자 단위로 일치해야 한다(대시보드 이벤트명 매칭).
- 명세서 텍스트의 공백/오타(`click_concert_request_ added`, `click_ concert_request_retry`)는 렌더링 아티팩트로 판단, 정규 snake_case로 정리한다.
- IG 이벤트 raw 값에는 명세서 정의상 `ios_ig`가 포함되어, 최종 태그는 `ios_click_ios_ig_*` 형태가 된다(의도된 명세).

## 검증 방법
- `EventTag.value` 단위 테스트로 신규 이벤트의 최종 태그 문자열 검증.
- 프로젝트 빌드 성공.
- 각 연결 지점이 실제 사용자 액션 경로에 있는지 코드 리뷰로 확인.
