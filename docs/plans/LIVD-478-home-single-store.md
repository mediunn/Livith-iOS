# LIVD-478 홈 단일 Store + child Reducer

## 배경
- 홈은 `HomeView` 세그먼트로 **관심 콘서트** / **캘린더** 두 모드를 가지며, 현재 `HomeStore`와 `CalendarHomeStore`가 각각 `@StateObject`로 존재한다.
- Store가 화면 단위로 분열되면 SSOT가 둘로 나뉘고, 셸(탭·네비)·관심·캘린더 간 상태 소유와 Intent 진입점이 분산된다.
- 홈 Feature 안에서만, TCA를 도입하지 않고 **가벼운 합성**으로 단일 Store + child Reducer + View Scope 형태로 정리한다.
- 그릴(2026-08-11)로 합성 API·소유권·구현 순서를 확정했다. 초기 초안의 “View가 HomeStore를 직접 구독” 가정은 폐기한다.

## 목표
- `HomeView`가 `@StateObject`로 **단일 `HomeStore`만** 소유한다 (SSOT).
- `CalendarHomeStore`(ObservableObject)는 제거한다.
- 관심/캘린더 탭 View는 `HomeStore` 타입을 모른다. **Scope**(`state` + `send` + 관심만 표시용 `user`)만 받는다.
- 관심/캘린더는 `@Injected` Repository를 가진 child **Reducer**가 Intent를 처리한다. Effect enum은 두지 않는다.
- 기존 홈·캘린더 동작과 테스트 커버리지를 유지한 채 그린한다.

## 권한·범위
- 정본(반드시 참이어야 하는 동작·불변조건):
  - Store 외부 Intent 진입점: `HomeStore.send(_ intent: HomeIntent)` 하나.
  - `HomeIntent` = 셸 케이스 + `.interest(InterestHomeIntent)` + `.calendar(CalendarHomeIntent)`.
  - `HomeState` = 루트에 평평한 셸 필드(`selectedHomeTab`, `user`, `hasNewNotice`) + `interest: InterestHomeState` + `calendar: CalendarHomeState`.
  - 셸 State에 두지 않는 것: 관심 에러 토스트·관심 결과 시트 관련 필드 → `InterestHomeState`.
  - 셸 Intent 처리 로직은 `HomeStore`에 유지한다 (`HomeShellReducer` 없음).
  - child: `InterestHomeReducer` / `CalendarHomeReducer`.
    - Repository는 child에 `@Injected`.
    - CancelID·Task 맵은 각 child가 소유.
    - Store가 생성 시 넘긴 `send` 클로저로 nested Intent를 재진입 (`._fetchResult` 패턴 유지).
    - `InterestHomeReducer.reduce`는 shell context를 **읽기 전용**으로 받는다 (`user` 등 복사하지 않음).
  - 탭 View:
    - `InterestHomeScope`: `state: InterestHomeState`, `user: User?`(표시용), `send: (InterestHomeIntent) -> Void`.
    - `CalendarHomeScope`: `state: CalendarHomeState`, `send: (CalendarHomeIntent) -> Void`.
    - Scope의 `send`는 `HomeView`가 `{ store.send(.interest($0)) }` / `{ store.send(.calendar($0)) }`로 감싼다.
  - 탭 전환·필터·로드 실패·모달·토스트 등 기존 UX 동작은 동일하다.
  - Store/Reducer 관련 테스트가 그린이다 (스위트 이름은 이동에 맞게 조정 가능).
  - TDD: state 변경·Intent 위임은 red → green을 따른다.
  - 구현 순서: **캘린더 흡수 먼저** → 관심 nest 추출.
- 이번 범위 밖:
  - 프로젝트 공통 `Scope`/`Reducer` protocol·Effect 시스템·TCA 도입
  - `architecture.md` / 컨벤션에 패턴 승격 (패턴이 2~3 Feature에서 반복된 뒤 별도 이슈)
  - 홈 외 Feature, API/Domain/Repository 계약 변경
  - 관심/캘린더 UI 리디자인, 세그먼트 UX 변경
- 코드에서 복원 불가능한 의도(있으면):
  - “Reducer” 명칭을 쓰지만 **순수 reduce가 아니다**. 비동기·Repo 호출을 child가 직접 수행한다 (Effect enum 없음).
  - SSOT는 Store/state 하나이며, child Reducer 복수 ≠ SSOT 위반이다.
  - 다른 Feature에서 같은 형태가 필요해져도 이번 이슈에서 공용 프레임워크로 올리지 않는다. 반복 후 `Scope` 정도만 승격한다.

## 작업 항목
- [ ] (슬라이스 1) 캘린더를 단일 Store 합성으로 흡수
  - `CalendarHomeState` / `CalendarHomeIntent` 유지·정리
  - `CalendarHomeReducer` 도입: `@Injected` CalendarRepository, CancelID/Task, `send` 클로저 재진입
  - `HomeState.calendar` / `HomeIntent.calendar` / `HomeStore` 위임
  - `CalendarHomeScope` + `CalendarHomeContentView` Store 비의존
  - `HomeView`에서 `calendarStore` `@StateObject` 제거
  - `CalendarHomeStore` ObservableObject 삭제
  - 캘린더 테스트 mid 경로를 `HomeStore` + `.calendar` / Reducer로 이전
- [ ] (슬라이스 2) 관심 nest + InterestHomeReducer
  - `InterestHomeState` / `InterestHomeIntent` 분리 (토스트·결과 시트 포함)
  - `InterestHomeReducer`: Repo·CancelID·`send` 클로저·shell 읽기 context
  - 셸 필드는 `HomeState` 루트에 평평히 유지, 셸 로직은 `HomeStore`
  - `InterestHomeScope` + `InterestHomeContentView` Store 비의존
  - `UserAvailability` / `homeAppear`↔`interestAppear` 순서 유지
  - `HomeStoreTests` nested Intent·Scope 계약에 맞게 수정
- [ ] 검증
  - Swift 파일 변경 후 `tuist generate --no-open`
  - `HomeFeature` 관련 `xcodebuild test`로 그린 확인

## 영향 범위
- 모듈: `HomeFeature` only (Presentation)
- 주요 파일(예상):
  - `Projects/HomeFeature/Sources/Home/Store/HomeStore.swift`
  - `Projects/HomeFeature/Sources/Home/Store/CalendarHomeStore.swift` → State/Intent 분리 후 ObservableObject 삭제, Reducer 파일 신규
  - `InterestHomeState` / `InterestHomeIntent` / `InterestHomeReducer` / `InterestHomeScope` (신규·분리)
  - `CalendarHomeReducer` / `CalendarHomeScope` (신규)
  - `HomeView.swift`, `InterestHomeContentView.swift`, `CalendarHomeContentView.swift` 및 하위 View
  - `Projects/HomeFeature/Tests/HomeStoreTests.swift`
  - `Projects/HomeFeature/Tests/CalendarHomeStoreTests.swift` (이전·rename 가능)
- Domain / Data / API: 변경 없음

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 작업 범위 | 홈만 / 공통 헬퍼 포함 | 홈만 | 패턴 검증 후 공통화 |
| View 구독 | Store 전달 / Scope / facade ObservableObject | **Scope** (`state` + `send`, 관심은 `user` 포함) | 탭 View가 Store를 모르게 (가벼운 TCA) |
| child 비동기 | Effect enum / child에 Repo 주입 / 혼용 | **child Reducer에 `@Injected` Repo** | Effect 타입 비용↓, 현 Store `perform*` 이전과 유사 |
| child 이름 | Handler / Processor / Logic / Reducer | **`InterestHomeReducer` / `CalendarHomeReducer`** | TCA 어휘 유지, 순수하지 않음은 감수 |
| 결과 재진입 | send 클로저 / weak Store / Store만 Task | **Store가 넘긴 `send` 클로저** | child가 `HomeStore` 타입에 비의존 |
| CancelID·Task | 각 Reducer / Store 단일 맵 | **각 Reducer 소유** | 비동기 생명주기를 child에 모음 |
| 셸 `user` — View | Scope에 포함 / interest에 복사 / Reducer만 | **Scope에 표시용 `user`** | 닉네임 등 표시 |
| 셸 `user` — Reducer | shell context 읽기 / interest 복사 / 셸에 로직 잔류 | **reduce에 shell context 읽기 전용** | `UserAvailability`·배너 로직, 복사 방지 |
| 셸 로직 위치 | HomeStore / HomeShellReducer | **HomeStore** | 셸이 얇아 타입 추가 이득 작음 |
| 셸 State 형태 | 루트 평평 / `shell: HomeShellState` nest | **루트 평평** | 필드 소수 |
| 관심 UX 소유 | 토스트·시트를 셸 / interest | **interest** | 도메인 기준 경계 |
| 구현 순서 | 캘린더 먼저 / 관심 먼저 / 타입 일괄 | **캘린더 먼저** | 이미 child 형태, 결합도 낮음 |
| 완료 기준 | 동작동일+테스트 / 문서포함 / 최소 컴파일 | 동작 동일 + `CalendarHomeStore` 제거 + 테스트 그린 | 회귀 방지 |

### 목표 구조 (스케치)

```text
HomeView (@StateObject HomeStore)
  ├── InterestHomeContentView(scope: InterestHomeScope)
  └── CalendarHomeContentView(scope: CalendarHomeScope)

HomeState
  ├── selectedHomeTab, user, hasNewNotice   ← 셸 (평평)
  ├── interest: InterestHomeState           ← 토스트·결과시트 포함
  └── calendar: CalendarHomeState

HomeIntent
  ├── homeAppear, homeTabSelected, …        ← HomeStore가 직접 처리
  ├── .interest(InterestHomeIntent)
  └── .calendar(CalendarHomeIntent)

HomeStore.send
  ├── shell → HomeStore 내부
  ├── .interest → InterestHomeReducer.reduce(&state.interest, shell:)
  └── .calendar → CalendarHomeReducer.reduce(&state.calendar)

InterestHomeReducer / CalendarHomeReducer
  ├── @Injected Repository
  ├── CancelID + Task 맵
  └── send 클로저로 nested Intent 재진입
```

### 런타임 주고받기

```text
HomeView → 탭 View : Scope(값)
탭 View → HomeStore : child Intent only (Store 타입 비노출)
HomeStore → Reducer : intent + inout child state (+ interest면 shell context)
Reducer → HomeStore : send 클로저로 ._result Intent
Reducer → Repository : 직접 await
```

## 주의 사항
- **Reducer 수명:** `InterestHomeReducer` / `CalendarHomeReducer`는 **`HomeStore`의 장기 소유 인스턴스**다. View `body`·탭 전환·Scope 재생성마다 `Reducer()`를 만들지 않는다. View/Scope는 Reducer를 갖지 않는다.
  - 위반 시: Task/CancelID가 끊기고, `@Injected`·진행 중 요청이 리셋되며, 불필요한 할당으로 SwiftUI 렌더 비용이 커진다.
  - Scope는 값 타입이라 부모 body마다 다시 만들어도 된다. 비용은 클로저/struct 복사 수준이어야 한다.
- `user`·`hasNewNotice`는 셸 소유. 관심 Reducer는 shell context로 **읽기만** 한다. interest state에 user를 복사하지 않는다.
- 관심 에러 토스트·결과 시트는 `InterestHomeState`에 두고, `HomeView`는 `store.state.interest`를 읽어 시트/토스트를 붙인다.
- `homeAppear`와 `interestAppear`의 `UserAvailability` 순서를 바꾸지 않는다.
- 캘린더 월/일 requestID·CancelID 의미가 바뀌지 않아야 한다.
- Swift 파일 추가/삭제 후 반드시 `tuist generate --no-open` 후에 테스트한다.
- 공통 `Reducer` protocol / Effect 시스템 / Shared `Scope`를 이번 이슈에서 넣지 않는다.
- 브랜치: `refactor/LIVD-478-home-single-store`. `develop`에 직접 커밋하지 않는다.

## 검증 방법
- [ ] 명령: `tuist generate --no-open`
- [ ] 기대 신호: 성공 종료
- [ ] 실제 결과: 
- [ ] 명령: `xcodebuild test -workspace "Livith-iOS.xcworkspace" -scheme "<HomeFeature scheme>" -destination '<confirmed simulator>' -only-testing:HomeFeatureTests/HomeStoreTests` (및 캘린더 관련 스위트; scheme·destination은 실행 직전 확인)
- [ ] 기대 신호: 관련 테스트 통과. `Executed 0 tests`만으로 실패/미실행 단정하지 않음
- [ ] 실제 결과: 
- [ ] 수동/코드 확인: `HomeView`에 `CalendarHomeStore` `@StateObject` 없음, `CalendarHomeStore` 클래스 없음, 탭 View가 `HomeStore` 타입을 import·보유하지 않음

## 컴파운딩 (아카이브 전)
- [ ] 교훈 분류 완료
- rules 반영 (`기본 승격 규칙`):
  - (작업 후 판단) 홈 한정 패턴이면 archive만. `git.md` develop 직접 커밋 금지가 약하면 승격 후보
- 분리 확인 제안 (`architecture` / `security`, 있으면):
  - Feature 전반 합성 패턴으로 쓸 때만 `architecture.md`에 Scope+child Reducer 후보
- archive만 유지:
  - 그릴 결정표, 셸/interest 소유권, send 클로저·CancelID 소유, View=Scope
- 반영 없음 / 사유: 
