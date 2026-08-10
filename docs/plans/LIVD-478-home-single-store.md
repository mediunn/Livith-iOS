# LIVD-478 홈 단일 Store + nested Reducer

## 배경
- 홈은 `HomeView` 세그먼트로 **관심 콘서트** / **캘린더** 두 모드를 가지며, 현재 `HomeStore`와 `CalendarHomeStore`가 각각 `@StateObject`로 존재한다.
- Store가 화면 단위로 분열되면 셸(탭·네비)·관심·캘린더 간 상태 소유와 Intent 진입점이 분산된다.
- 홈 Feature 안에서만, 화면별 State·Intent는 분리 선언하되 상위 단일 Store로 보내는 합성 형태로 정리한다.

## 목표
- `HomeView`가 `@StateObject`로 **단일 `HomeStore`만** 소유한다.
- `CalendarHomeStore`(ObservableObject)는 제거한다.
- 셸 / 관심 / 캘린더가 각자 State·Intent를 선언하고, View는 `store.send`로 상위 Store에만 Intent를 보낸다.
- 기존 홈·캘린더 동작과 테스트 커버리지를 유지한 채 그린한다.

## 권한·범위
- 정본(반드시 참이어야 하는 동작·불변조건):
  - Store 단일 진입점: `HomeStore.send(_ intent: HomeIntent)`만 외부 Intent 진입점이다.
  - `HomeIntent` = 셸 케이스 + `.interest(InterestHomeIntent)` + `.calendar(CalendarHomeIntent)`.
  - `HomeState` = 셸 필드 + `interest: InterestHomeState` + `calendar: CalendarHomeState`.
  - 관심/캘린더 View는 `HomeStore`를 받고 `state.interest` / `state.calendar`와 `send(.interest(...))` / `send(.calendar(...))`를 사용한다.
  - 탭 전환·필터·로드 실패·모달·토스트 등 기존 UX 동작은 동일하다.
  - `HomeStoreTests` / `CalendarHomeStoreTests`(이름·구조는 이동에 맞게 조정)가 그린이다.
  - TDD: Store 합성·Intent 위임·상태 변경은 red → green을 따른다.
- 이번 범위 밖:
  - 프로젝트 공통 Store/Reducer 합성 헬퍼·프로토콜 도입
  - `architecture.md` / 컨벤션 문서에 패턴 승격
  - 홈 외 Feature, API/Domain/Repository 계약 변경
  - 관심/캘린더 UI 리디자인, 세그먼트 UX 변경
- 코드에서 복원 불가능한 의도(있으면):
  - “분열되는 리듀서”는 **순수 reduce 함수 프레임워크**가 아니라, **파일/타입으로 분리된 State·Intent + Store 내부 위임 핸들러**를 의미한다.
  - 공통화는 홈에서 패턴이 안정된 뒤 별도 이슈로 한다.

## 작업 항목
- [ ] 타입 경계 확정 (컴파일 단위)
  - `InterestHomeState` / `InterestHomeIntent`: 현재 `HomeState`·`HomeIntent`의 관심 전용 필드·케이스를 분리
  - `CalendarHomeState` / `CalendarHomeIntent`: 기존 타입 유지(필요 시 파일 위치만 정리)
  - `HomeState` / `HomeIntent`: 셸 + nested children
- [ ] `HomeStore`로 Calendar 로직 흡수
  - `send`에서 `.interest` / `.calendar`를 child 핸들러로 위임
  - CancelID·Repository·perform*는 단일 Store가 소유
  - `CalendarHomeStore.swift`의 `ObservableObject` Store 삭제
- [ ] View 연결
  - `HomeView`에서 `calendarStore` `@StateObject` 제거
  - `InterestHomeContentView` / `CalendarHomeContentView`가 `HomeStore` + nested state/intent 사용
- [ ] 테스트 이전·보강 (TDD)
  - 관심: 기존 `HomeStoreTests`를 nested intent/state 경로로 맞춤
  - 캘린더: `CalendarHomeStoreTests`를 `HomeStore` + `.calendar` 경로로 이전/수정
  - 셸: `homeTabSelected`, `homeAppear` 등 루트 Intent 회귀 유지
- [ ] 검증
  - Swift 파일 변경 후 `tuist generate --no-open`
  - `HomeFeature` 관련 `xcodebuild test`로 Store 스위트 그린 확인

## 영향 범위
- 모듈: `HomeFeature` only (Presentation)
- 주요 파일(예상):
  - `Projects/HomeFeature/Sources/Home/Store/HomeStore.swift`
  - `Projects/HomeFeature/Sources/Home/Store/CalendarHomeStore.swift` (삭제 또는 State/Intent만 남김)
  - Interest/Calendar State·Intent 분리 파일(신규 가능)
  - `HomeView.swift`, `InterestHomeContentView.swift`, `CalendarHomeContentView.swift` 및 하위 View
  - `Projects/HomeFeature/Tests/HomeStoreTests.swift`
  - `Projects/HomeFeature/Tests/CalendarHomeStoreTests.swift`
- Domain / Data / API: 변경 없음

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 작업 범위 | 홈만 / 공통 헬퍼 포함 | 홈만 | 패턴 검증 후 공통화 |
| Intent API | nested enum / pure reducer / view facade | nested `HomeIntent.interest`·`.calendar` | 기존 `send` 단일 진입점·MVI와 일치 |
| State·View 결합 | nest+Store / slice+closure / flat | `HomeState` nest + View는 `HomeStore` | 기존 `@ObservedObject` 패턴 유지 |
| Intent 경계 | 셸+2 children / 관심 flat+캘린더만 / 3 equal children | 셸 + interest + calendar | 관심도 child로 대칭 |
| 완료 기준 | 동작동일+테스트 / 문서포함 / 최소 컴파일 | 동작 동일 + `CalendarHomeStore` 제거 + 테스트 그린 | 회귀 방지 |
| “리듀서” 의미 | TCA식 pure reduce / Store 내 분리 핸들러 | Store 내 분리 핸들러 + 분리 State/Intent 타입 | 프로젝트에 reduce 프로토콜 없음 |

### 목표 구조 (스케치)

```text
HomeState
  ├── shell: selectedHomeTab, user, hasNewNotice, …
  ├── interest: InterestHomeState
  └── calendar: CalendarHomeState

HomeIntent
  ├── shell: homeAppear, homeTabSelected, …
  ├── .interest(InterestHomeIntent)
  └── .calendar(CalendarHomeIntent)

HomeStore.send
  → shell handler / interest handler / calendar handler
```

## 주의 사항
- `user`·`hasNewNotice`·에러 토스트 등 셸과 관심이 공유하던 필드는 **셸에 두고**, 관심 핸들러가 읽기만 하거나 필요한 값만 interest state로 복제하지 말고 소유권을 한곳에 둔다. 분리 시 네비 벨 아이콘·선호 배너 조건을 깨지 않도록 회귀 테스트를 본다.
- `homeAppear`와 `interestAppear`의 user 대기(`UserAvailability`) 동기화는 단일 Store 안에서 유지한다. Store를 합친다고 순서를 바꾸지 않는다.
- 캘린더 월/일 requestID·CancelID 의미가 바뀌지 않아야 한다.
- Swift 파일 추가/삭제 후 반드시 `tuist generate --no-open` 후에 테스트한다.
- 공통 추상화(`Reducer` protocol 등)를 이번 이슈에서 넣지 않는다.

## 검증 방법
- [ ] 명령: `tuist generate --no-open`
- [ ] 기대 신호: 성공 종료
- [ ] 실제 결과: 
- [ ] 명령: `xcodebuild test -workspace "Livith-iOS.xcworkspace" -scheme "<HomeFeature scheme>" -destination '<confirmed simulator>' -only-testing:HomeFeatureTests/HomeStoreTests` (및 캘린더 Store 스위트; scheme·destination은 실행 직전 확인)
- [ ] 기대 신호: 관련 테스트 통과. `Executed 0 tests`만으로 실패/미실행 단정하지 않음
- [ ] 실제 결과: 
- [ ] 수동/코드 확인: `HomeView`에 `CalendarHomeStore` `@StateObject` 없음, `CalendarHomeStore` 클래스 없음

## 컴파운딩 (아카이브 전)
- [ ] 교훈 분류 완료
- rules 반영 (`기본 승격 규칙`):
  - (작업 후 판단) 홈 한정 패턴이면 archive만
- 분리 확인 제안 (`architecture` / `security`, 있으면):
  - 다음 이슈에서 Feature 전반 합성 패턴으로 쓸 때만 `architecture.md` 후보
- archive만 유지:
  - nested Intent/State 경계, 셸 필드 소유권 결정
- 반영 없음 / 사유: 
