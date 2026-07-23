# LIVD-452 홈 캘린더 일정 API 연동

## 배경
- LIVD-439에서 홈 캘린더 **필터 칩 + 빈 WebView + 일자 일정 모달(mock/fixture)** 까지 올렸다.
- 서버 캘린더 API 2종이 준비되어 있다 (iOS 연결 Not started).
  - 월별: `GET /api/v7/calendar?year&month&scheduleTypes&concertType`
  - 날짜별: `GET /api/v7/calendar/events?date&scheduleTypes&concertType`
- 월 헤더·그리드는 WebView 소속이며, 이번 이슈에서는 **브릿지·실 URL을 넣지 않는다**.
- deep-interview로 기능 범위·경계를 확정했고, Domain·Data는 grill로 합의했다 (브랜치: `feat/LIVD-452-home-calendar-api`).
- Domain Entity는 타입 의미 유지 하에 파일 4개로 통합했다 (`CalendarMonth` / `CalendarDaySchedule` / `CalendarEvent` / `CalendarFilter`).

## 목표
- 월별·날짜별 캘린더 API를 Domain → Data → `CalendarHomeStore`까지 연동한다.
- 필터·탭 진입·pull-to-refresh에 맞춰 월별 조회를 호출하고, 실패 시 기존 엠티뷰를 쓴다.
- 일자 모달은 Domain `CalendarDayEvent`를 쓰고, Show용 표시는 HomeFeature `extension`으로 둔다.
- WebView는 `about:blank` 슬롯을 유지한다 (URL·브릿지 없음).

## 작업 항목

### 1. Domain (TDD)
- [x] Value / Enum
  - `CalendarEventID` — 합성 identity struct (`concertID` + type 등). 빈혈 지양, 비교·해시는 타입으로
  - `CalendarEventTime` — `hour` / `minute` (날짜 없는 시각)
  - `CalendarEventDetail` — associated value: `.ticketOffice(String)` / `.venue(String)` + `make(text:aligningWith:)`
  - `CalendarMonthEventType` — `TICKETING` | `CONCERT` (기존 `ScheduleType` 비침범)
  - `CalendarDayEventType` — `GENERAL_TICKETING` | `PRE_TICKETING` | `ADD_TICKETING` | `CONCERT`
  - `CalendarDayEventStatus` — `ONGOING` | `UPCOMING` | `COMPLETED` | `CANCELLED` (기존 `ConcertStatus` 비침범)
  - `CalendarScheduleTypeFilter` — `ticketing` / `concert` (쿼리 `scheduleTypes`)
  - `CalendarConcertTypeFilter` — `all` / `interest` (쿼리 `concertType`)
- [x] Entity
  - `CalendarMonth` — `year: Int`, `month: Int`, `dayList: [CalendarMonthDay]` (**sparse**)
  - `CalendarMonthDay` — `date: Date`, `eventList`, `Identifiable` (`id == date`)
  - `CalendarMonthEvent` — `id: CalendarEventID`, `concertID`, `artist`, `type`, `Identifiable`
  - `CalendarDaySchedule` — `date`, `eventList: [CalendarDayEvent]`
  - `CalendarDayEvent` — `id`, `concertID`, `title?`, `type`, `status`, `time?`, `detail?`, `Identifiable`
- [x] 동작 (빈혈 Domain 지양)
  - `CalendarEventID` / `CalendarEventDetail` / `CalendarEventTime` / `status.isCancelled` 등
  - 알 수 없는 type/status 문자열 처리는 **Mapper에서 해당 이벤트 스킵** (후속)
- [x] `CalendarError` — 공통 세트
- [x] `CalendarRepository` 프로토콜
- [x] Domain 단위 테스트 (`CalendarDomainModelTests` 8개 통과)

### 2. Networking (먼저) → CalendarData (TDD: Mapper 중심)

Data grill 합의: **Networking(API+DTO) 확정·커밋 후** CalendarData(Mapper → Impl → Assembler)로 진행한다.

#### 2-1. Networking
- [ ] `LivithNetworking`에 `CalendarAPI` 추가 (Domain 비의존, 쿼리 인자는 `String` / `[String]`)
  - `fetchMonth(year:month:scheduleTypes:concertType:)` → `/calendar`
  - `fetchDayEvents(date:scheduleTypes:concertType:)` → `/calendar/events`
  - `scheduleTypes`는 SearchAPI와 같이 동일 key 반복 `URLQueryItem`
  - **auth:** `concertType == "INTEREST"` 일 때만 `.required`, 그 외(ALL)는 `.none` (문자열 비교 유지)
- [ ] DTO 2파일 유지 (월/일 API index 분리 관례)
  - `DTO.Response.FetchCalendarMonth` (`year`, `month`, `days[]` → `date`, `events[]` → `id`, `artist`, `type`)
  - `DTO.Response.FetchCalendarDayEvents` (`date`, `events[]` → `id`, `title?`, `type`, `status`, `time?`, `detail?`)
  - enum 필드는 DTO에서 **`String` raw** (매핑은 Mapper)
- [ ] CalendarAPI **전용 단위 테스트 없음** (기존 API enum과 동일). 매핑·스킵 검증은 CalendarData Mapper 테스트

#### 2-2. CalendarData
- [ ] Tuist `DataModule`에 `calendarData` / `calendarDataTests` 추가
- [ ] `Projects/Data/Project.swift`에 `CalendarData` / `CalendarDataTests` 타깃 등록
- [ ] App 의존성·`LivithApp+InjectDependency`에 `CalendarDataAssembler` 등록
- [ ] `CalendarMapper` 1개 + `CalendarErrorMapper` 1개
  - `toDomain(from: FetchCalendarMonth)` / `toDomain(from: FetchCalendarDayEvents)`
  - `yyyy-MM-dd` → day `Date` (`DateFormatType.dashDate`)
  - date 파싱 실패 → **그 day 전체 스킵**
  - 알 수 없는 type/status → **그 event만 스킵**
  - `HH:mm` 파싱 실패·이상 값 → **`time = nil`**, 이벤트는 유지
  - `detail` null/빈 문자열 → `nil`; 값 있으면 `CalendarEventDetail.make(text:aligningWith: type)` (type 기준)
  - 스킵 후 dayList가 비어도 **빈 `CalendarMonth` 성공** (year/month 유지). 네트워크/디코드 실패만 Error
- [ ] `CalendarRepositoryImpl`
  - Domain → 쿼리 변환은 **Impl** (`rawValue`, `Date`→`yyyy-MM-dd` via `DateFormatterService`)
  - `CalendarAPI` 호출 + Mapper + ErrorMapper
- [ ] Mock `CalendarRepository`는 **HomeFeature Tests**에 (Store 연동 시). CalendarData 단계 필수 아님
- [ ] Mapper 테스트 (TDD) + `tuist generate --no-open`

### 3. Feature · Store 연동 (TDD)
- [ ] **`CalendarDayScheduleItem` 제거** (mock/쇼 전용 모델로 간주). 모달·정렬·Row는 Domain `CalendarDayEvent` 사용
- [ ] Show용 표시는 `HomeFeature`에서 `extension CalendarDayEvent` (및 필요 시 관련 Domain 타입)로 추가
  - 예: `timeLabel`, 취소 여부 파생, 카드 kind 등 — Domain 규칙을 깨지 않는 범위
- [ ] `CalendarDayScheduleSorter` — **HomeFeature**에 유지·시그니처를 `[CalendarDayEvent]` 기준으로 변경 (모달 Show 규칙)
- [ ] 필터 → 쿼리 매핑 (Store 또는 순수 헬퍼)
  - 칩 → `CalendarScheduleTypeFilter` / `CalendarConcertTypeFilter` (Feature `CalendarConcertScope`와 이름 비공유, 매핑만)
- [ ] `CalendarHomeStore`에 Repository 주입 (`@Injected` 또는 기존 Home 패턴)
- [ ] State
  - `selectedYear` / `selectedMonth` — 초기값 = 기기 오늘
  - 월별 성공 결과 (`calendarMonth`) — WebView 미전달
  - `dayScheduleEventList: [CalendarDayEvent]` (기존 itemList 대체)
  - `isLoadFailed` — 월별 실패 시 true / 성공 시 false
- [ ] Intent / 비동기
  - 탭 진입(appear) · 필터 변경 · `performRefresh` → 월별 refetch
  - 일자 모달 오픈: `date`로 날짜별 fetch → Feature 정렬 → 모달 present
  - CancelID로 동일 작업 재요청 시 이전 Task 취소
- [ ] 월별 실패 → 엠티뷰. 날짜별 실패는 구현 시 모달 미표시 또는 빈 목록 중 하나로 고정·테스트
- [ ] DEBUG: fixture 주입 제거 → 오늘 date로 날짜별 fetch Intent
- [ ] Fixture·Sorter·Store·Row/Modal 테스트를 Domain 타입 기준으로 갱신
- [ ] `CalendarHomeStoreTests` red→green (Mock Repository)

### 4. View 반영 (최소)
- [ ] `CalendarHomeContentView`: `isLoadFailed` 분기 유지 (성공=WebView 슬롯, 실패=엠티 + refresh)
- [ ] `CalendarDayScheduleModalView` / `ItemRow`: `CalendarDayEvent` (+ Feature extension) 사용
- [ ] WebView URL·브릿지·월 데이터 주입 **금지**

### 5. 검증 · 문서
- [ ] Domain / CalendarMapper / CalendarHomeStore·Sorter 테스트 통과
- [ ] 모듈·파일 추가 후 `tuist generate --no-open`
- [ ] `xcodebuild -list`로 scheme 확인 후 `xcodebuild test` (destination: Available destinations, 기본 `iPhone 17`)
- [ ] 수동: 캘린더 진입·필터·refresh·실패 엠티, DEBUG로 일자 모달 실데이터
- [ ] 완료 후 계획·트러블슈팅을 `docs/archives/`로 이동

## 영향 범위
- `Projects/Domain/` — Calendar Entity, Error, Repository, Domain 테스트
- `Projects/LivithNetworking/Sources/API/CalendarAPI.swift` (신규)
- `Projects/Data/CalendarData/` (신규) + `Projects/Data/Project.swift`
- `Tuist/ProjectDescriptionHelpers/Module/` — `calendarData` 등록
- `Projects/App/Sources/LivithApp+InjectDependency.swift` (+ CalendarData 의존성)
- `Projects/HomeFeature/` — Store, Sorter, Modal/Row, Fixture 제거·extension, 테스트
- WebView 브릿지 / 실 URL — **변경 없음 (비범위)**

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 연동 API | 날짜별만 vs 둘 다 | **월별 + 날짜별** | deep-interview |
| 월 그리드 | 네이티브 교체 vs WebView | **WebView 유지** | LIVD-439 |
| 월별 API 용도 | 브릿지 완결 vs Store까지 | **Domain/Data + Store**, 브릿지/URL 후속 | deep-interview |
| 날짜별 뷰 반영 | 브릿지 E2E vs Store+DEBUG | **Store fetch + DEBUG Intent** | deep-interview |
| fetch 트리거 | 필터 포함 vs 제외 | **진입·필터·PTR → 월별**, 모달 → 날짜별 | deep-interview |
| year/month 소스 | 기기 오늘 vs 브릿지 대기 | **Store = 기기 오늘** | deep-interview |
| Data 위치 | 흡수 vs 신설 | **`CalendarRepository` + `CalendarData` + `CalendarAPI`** | deep-interview |
| 월별 실패 UI | 엠티 vs 토스트 | **`LivithEmptyView` + refresh** | LIVD-439 |
| DEBUG date | fixture vs 오늘 | **오늘** | deep-interview |
| 완료 기준 | 테스트+DEBUG vs 스테이징 | **단위 테스트 + DEBUG 모달** | deep-interview |
| 월/일 이벤트 Entity | 통합 vs 분리 | **분리** (`MonthEvent` / `DayEvent`) | grill |
| 컨테이너 | 통합 vs 분리 | **분리** (`CalendarMonthDay` / `CalendarDaySchedule`) | grill |
| type enum | `ScheduleType` 재사용 vs 전용 | **캘린더 전용** | grill |
| 날짜 표현 | `Date` vs `String` vs value | **`Date` (day)** | grill + Domain 관례 |
| concert id | Int vs String | **`concertID: Int`** | grill |
| 이벤트 Identifiable | 없음 vs 합성 id | **`CalendarEventID` struct + concertID 분리** | grill (빈혈·충돌 회피) |
| time | `Date` vs String vs value | **`CalendarEventTime`** | grill |
| status | `ConcertStatus` vs 전용 | **`CalendarDayEventStatus`** | grill |
| 쿼리 필터 | Domain enum vs raw | **Domain enum**, Feature 칩과 이름 비공유 | grill |
| 알 수 없는 enum | 스킵 vs unknown vs 전체 실패 | **해당 이벤트 스킵** | grill |
| title | `String?` vs `""` | **`String?`** | grill |
| month.days | sparse vs dense | **sparse** | grill |
| fetchMonth 인자 | Int vs Date vs YearMonth | **`year`/`month` Int** | grill |
| scheduleTypes 빈 배열 | 허용 vs Domain 검증 | **허용** (Store 불변식) | grill |
| Feature 목록 모델 | mock 유지 vs Domain | **Domain + Feature extension**, `CalendarDayScheduleItem` 제거 | grill |
| 정렬 위치 | Domain vs Feature | **HomeFeature** | grill |
| detail | String? vs associated | **`CalendarEventDetail` associated** | grill (빈혈 지양) |
| CalendarError | 공통 vs 특화 | **공통 세트 우선** | grill |
| CalendarMonthDay id | date vs 없음 | **`Identifiable`, id = date** | grill |
| Domain Entity 파일 | 타입당 1파일 vs 개념 통합 | **4파일** (Month / DaySchedule / Event / Filter) + MARK | grill |
| Data 구현 순서 | 한 번에 vs 단계 | **Networking 먼저 → CalendarData** | Data grill |
| calendar auth | INTEREST만 vs 항상 | **INTEREST만 `.required`**, ALL `.none` | Data grill |
| DTO 파일 | 합치기 vs 2파일 | **월/일 2파일 유지** | Data grill |
| CalendarAPI 단위 테스트 | 있음 vs 없음 | **없음** | Data grill |
| auth 분기 | 문자열 vs policy 인자 | **`concertType == "INTEREST"`** | Data grill |
| Mapper 구성 | 분리 vs 1+1 | **Mapper 1 + ErrorMapper 1** | Data grill |
| 파싱 실패(day/type/status) | 스킵 vs 전체 실패 | **해당 day/event 스킵** | Data grill |
| 이상 time | nil vs 이벤트 스킵 | **`time = nil`, 이벤트 유지** | Data grill |
| detail 매핑 | type 기준 vs 문자열 추정 | **`make(aligningWith: type)`**, 빈값 nil | Data grill |
| Domain→쿼리 변환 | Impl vs Mapper | **`CalendarRepositoryImpl`** | Data grill |
| Mock Repository 위치 | CalendarData vs HomeFeature Tests | **HomeFeature Tests** (Store 시) | Data grill |
| 전부 스킵된 Month | 빈 성공 vs invalidResponse | **빈 `CalendarMonth` 성공** | Data grill |

## 주의 사항
- **TDD**: Domain 모델·Mapper·Store·Sorter는 `docs/rules/tdd.md` 준수. Tuist/Assembler/순수 배선·API enum은 예외 허용 가능.
- Domain은 빈혈 모델이 되지 않게 value/Entity에 의미 있는 동작을 둔다. Show-only 문구·스타일은 Feature extension.
- raw value enum에 불필요한 `Hashable` 명시를 다시 넣지 않는다 (자동 합성).
- 월별 `type`과 날짜별 `type`을 Mapper에서 혼용하지 말 것.
- 날짜별 URI 문서의 `&` 누락 표기는 무시하고 쿼리를 각각 보낸다.
- `scheduleTypes` 배열 쿼리 관례는 SearchAPI와 같이 동일 key 반복.
- Networking은 Domain에 의존하지 않는다. Domain→raw 변환은 RepositoryImpl.
- WebView URL·브릿지·월 데이터 주입·날짜 탭 콜백은 **이번 PR 금지**.
- 관심 탭 `interestAppear`·세그먼트 회귀 금지 (LIVD-438).
- `INTEREST` 시 Authorization 필수 (모바일 항상 로그인 전제).
- 실패·피드백·가정 변경 시 `docs/troubleshooting/LIVD-452-home-calendar-api.md`에 즉시 기록.

## 검증 방법
- 자동화
  1. Domain / CalendarMapper / CalendarHomeStore·Sorter 테스트 실패→통과
  2. 모듈·파일 추가 후 `tuist generate --no-open`
  3. `xcodebuild -list`로 scheme 확정 후  
     `xcodebuild test -workspace "Livith-iOS.xcworkspace" -scheme "<확정된 scheme>" -destination 'platform=iOS Simulator,name=iPhone 17'`  
     (`docs/rules/project-operations.md`)
- 수동
  - 홈 → 캘린더: 진입 시 월별 호출(성공 시 WebView 슬롯, 실패 시 엠티)
  - 필터·전체/내 공연 전환 시 월별 refetch
  - pull-to-refresh
  - DEBUG 일정 모달: Domain 이벤트 기반 목록/엠티
  - 관심 ↔ 캘린더 전환 회귀, 필터 유지

## 비범위 (후속)
- WebView 캘린더 URL 로드
- 월별 결과 → WebView 브릿지
- WebView 날짜 탭 → 날짜별 fetch → 모달 E2E
- 네이티브 월 그리드
- year/month를 WebView 월 이동과 동기화
