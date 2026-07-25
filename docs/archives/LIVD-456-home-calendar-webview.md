# LIVD-456 홈 캘린더 WebView 연동

> 통합 아카이브. 기존 분리 계획  
> (`home-calendar-webview` · `calendar-month-changed` · `calendar-month-restore` · `day-event-id-time` · `calendar-webview-split-height`)를 Phase로 합쳤다.  
> 트러블슈팅: `docs/archives/LIVD-456-home-calendar-webview-troubleshooting.md`  
> 브랜치: `feat/LIVD-456-home-calendar-webview`

## 배경
- LIVD-439에서 필터 칩 + 빈 WebView 골격, LIVD-452에서 월·일 API → `CalendarHomeStore`까지 연동했다.
- 월 그리드는 WebView, Store `calendarMonth`는 브릿지로 주입해야 한다.
- 웹 계약: iOS→Web `setCalendarData(객체)`, Web→iOS `calendarDateSelected` / `calendarMonthChanged`.
- 이후 상세 복귀 시 월 리셋, 동일 concertID·다른 time 행 누락을 같은 이슈에서 수정했다.
- 머지 전 개선: Coordinator 비대화·높이 고착·메시지 body 파서 중복을 정리했다.

## 목표 (전체)
- `CALENDAR_WEB_URL`로 WebView 로드 (없/실패 → `about:blank`, 앱 비종료).
- 월 데이터 `setCalendarData` 주입, 날짜 탭 → 일정 모달, 월 이동 ↔ Store `fetchMonth` 동기화.
- 상세·탭 복귀 시 선택 월 유지 + soft refresh (관심 변경 반영).
- 일자 모달에서 동일 concert·다른 시각 행을 모두 표시.
- 일자 일정 → 콘서트 상세 이동. DEBUG 「일정 모달」 버튼 제거.
- WebView Helper 분리·inject 직전 높이 fallback 리셋·메시지 body 파서 공통화 (기존 동작 유지).

---

## Phase 1 — URL · 주입 · 날짜 탭

### 목표
- URL 로드, 월별 `setCalendarData`, `calendarDateSelected` → `.dayScheduleRequested` E2E.
- 필터·PTR 재주입. 실 URL 로드 실패 시 blank 폴백·inject 스킵.

### 작업 항목
- [x] `CALENDAR_WEB_URL` (plist / xcconfig), `CalendarWebConfig` 항상 DI 등록 (`url: nil` 허용, `fatalError` 금지)
- [x] HomeFeature는 Bundle 직접 읽지 않음 — ContentView가 Config/`url` prop 전달
- [x] `CalendarWebMonthPayloadMapper` + 테스트 (`id` Int, 빈 days, 특수문자 artist)
- [x] `CalendarWebView` load/inject 분리, weak message proxy, blank inject 스킵
- [x] `calendarDateSelected` → `.dayScheduleRequested` 연결
- [x] 네이티브 ScrollView + DOM maxBottom 높이 측정 (별도 커밋으로 포함)
- [x] Helper 분리·정리, 검증·아카이브

### Phase 1 기술 결정 (요약)
| 결정 | 내용 |
|------|------|
| URL 실패 | `about:blank`, inject 스킵 |
| `updateUIView` | URL 재load 금지, month는 inject만 |
| JS | `JSON.parse(escapedString)` → 객체 |
| 날짜 탭 | 기존 `.dayScheduleRequested` |
| 월 이동 | Phase 1 시점 **후속** → Phase 2에서 완료 |

---

## Phase 2 — 월 변경 (`calendarMonthChanged`)

### 목표
- Web `calendarMonthChanged` `{year, month}` → Store `monthChanged` → `fetchMonth` → 기존 inject.

### 작업 항목
- [x] `CalendarMonthChangedMessageParser` + 테스트
- [x] `CalendarHomeIntent.monthChanged` (동일월·범위 밖 no-op, 모달 닫기, 일자 fetch 취소, `showInitialLoading: false`)
- [x] 실패 시 `isLoadFailed` 엠티뷰
- [x] WebView 핸들러 + ContentView 연결
- [x] Store 테스트 · 빌드 · 수동 월 이동

### Phase 2 기술 결정 (요약)
| 결정 | 내용 |
|------|------|
| 동일 월 | no-op |
| 실패 | 엠티뷰 (`isLoadFailed`) |
| 열린 일자 모달 | 닫기 + 일자 fetch 취소 |
| iOS→Web 월 맞춤 | `setCalendarData`만 (추가 브릿지 없음) |

---

## Phase 3 — 상세 복귀 시 월 유지

### 목표
- 8월 → 상세 → 뒤로가기 후에도 선택 월 유지. 사용자 월 스와이프 동기화는 유지.

### 작업 항목
- [x] `onAppear`: 로드됨 → soft refresh (`showInitialLoading: false`); 미로드/실패 → 초기 로딩 fetch
- [x] `CalendarWebMonthChangeGate`: 첫 `setCalendarData` 성공 전 `calendarMonthChanged` 무시
- [x] Store·Gate 테스트, 트러블슈팅 기록
- [x] 일자 일정 탭 → `concertDetail` 이동 (동 브랜치 Feat)

### Phase 3 기술 결정
| 결정 | 내용 |
|------|------|
| 복귀 onAppear | soft refresh (관심 변경 반영) |
| 초기 monthChanged | inject 전 무시 |
| URL year/month 쿼리 | 안 함 |

---

## Phase 4 — 일자 일정 identity (`time`)

### 목표
- 같은 concertID·type·다른 time 행이 모달에 모두 표시.

### 작업 항목
- [x] `CalendarEventID`에 `time: CalendarEventTime?` (month는 nil)
- [x] `CalendarDayEvent` id에 time 포함
- [x] Domain·Mapper 테스트 (1978 @ 12:20·17:00 + 1683 @ 18:00)
- [x] DEBUG 「일정 모달」 버튼 제거 (Chore)

### Phase 4 기술 결정
| 결정 | 내용 |
|------|------|
| identity | ID에 time 포함 |
| month event | time nil 유지 |
| 동일 time 중복 | 비범위 |

---

## Phase 5 — WebView 분리 · 높이 리셋 · 파서 공통화

### 목표
- Representable API·브릿지·Store 동작은 유지한 채 Coordinator를 Helper로 분리한다.
- 새 페이로드 inject 직전 `contentHeight`를 fallback(700)으로 리셋한다.
- WK 메시지 body → dictionary / Int 변환을 공통 Helper로 모은다.

### 작업 항목
- [x] 보호 테스트 확인 후 리팩터링 시작
- [x] `CalendarWebScriptMessageBodyParser` + 테스트 (TDD) — dict / NSDictionary / JSON string, `intValue`
- [x] DateSelected·MonthChanged 파서 슬림화 (순수 `yyyy-MM-dd` 문자열은 DateSelected에 유지)
- [x] `CalendarWebContentHeightMeasurer` 분리 (unlock script · maxBottom 측정 · fallbackHeight)
- [x] `CalendarWebLoadSession` 분리 (load/inject/fail · Gate · inject 직전 높이 리셋)
- [x] `CalendarWebView` 슬림화 — weak proxy 패턴 유지, dismantle에서 handler 이름별 제거
- [x] `tuist generate` · HomeFeature 캘린더 테스트 47 passed · `Livith-iOS-Dev` build 성공 · 아카이브 통합

### Phase 5 기술 결정
| 결정 | 내용 |
|------|------|
| 분리 위치 | Helper 파일 (Representable은 배선만) |
| 높이 리셋 | inject 직전 700, 동일 JSON 스킵 시 리셋 없음 |
| 웹 height 브릿지 | 비범위 |
| 파서 공통화 | BodyParser 포함, 도메인 파싱은 각 파서 유지 |
| TDD | BodyParser red→green, WK 배선·높이 리셋은 예외+보호 테스트 |
| year 범위 검증 | 비범위 (month 1…12만) |

---

## 영향 범위 (전체)
- App: plist, xcconfig 키, `CalendarWebConfig` DI
- HomeFeature: WebView·Helpers(LoadSession·HeightMeasurer·BodyParser 포함)·Store·ContentView·모달 네비게이션
- Domain: `CalendarEventID` / `CalendarDayEvent`
- CalendarData: Mapper 테스트 (계약 스키마 변경 없음)
- 문서: 본 계획 + `LIVD-456-home-calendar-webview-troubleshooting.md`

## 주의 사항
- 실 `CALENDAR_WEB_URL` 원문은 문서·PR·채팅에 남기지 않는다.
- WK 배선은 TDD 예외, 파서·Store·매퍼·Gate·Domain identity·BodyParser는 TDD.
- `setCalendarData`는 실 URL load 완료 전·blank·로드 실패 후 호출하지 않는다.
- remount 시 monthChanged gate 리셋·재inject 필요.
- `WeakScriptMessageHandlerProxy` 패턴 유지 + dismantle에서 handler 이름 제거 (혼동 금지).
- inject 성공 completion에서만 `lastInjected`·Gate 갱신. inject 직전 높이 fallback 리셋.

## 검증 방법
- `tuist generate --no-open` (파일 추가 시)
- Domain / CalendarData / HomeFeature 관련 `xcodebuild test` (simulator: iPhone 17)
- `Livith-iOS-Dev` build
- 수동: URL·주입·날짜 탭·월 이동·상세 복귀 월 유지·동일 콘서트 복수 시각 행·콘서트 상세 이동
- Phase 5 수동: 월 스와이프 시 높이 fallback→재측정, 짧은/긴 달 전환 잘림·공백 없음

## 비범위 (잔여)
- 웹 `calendarReady` 등 추가 메시지
- 네이티브 월 그리드 대체
- `time == nil`인 동일 concert·type 중복 행 identity
- 웹 height `postMessage` 브릿지
- `CalendarWebConfig` 모듈 이동 · year 범위 검증 강화
