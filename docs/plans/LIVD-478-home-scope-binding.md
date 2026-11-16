# LIVD-478 Scope 바인딩화

## 배경
- `HomeStore.reduce(keyPath:body:)`가 복사→변형→쓰기백으로 동작해서, `body` 안 동기 `send`가 오면 진짜 state 변경이 조용히 증발한다(PR #306 리뷰 5번).
- assert안은 디버그에서만 터지고 릴리즈에선 여전히 증발해서 기각했다.
- 바닐라 SwiftUI의 SSOT 수단(`Binding` 투영)을 쓰면 복사 과정 자체가 없어져 증발이 성립 안 한다.

## 목표
- View가 보는 `HomeScope`는 읽기 전용 그대로 두고, Store→Reducer 채널만 `Binding`으로 바꾼다.
- `reduce` 헬퍼를 삭제한다.
- View 코드 0 변경, MVI 유지(View는 Intent로만), View 직접 쓰기는 컴파일러 차원에서 불가 유지.

## 권한·범위
- 정본(반드시 참이어야 하는 동작·불변조건):
  - `HomeState`가 유일한 저장소다(SSOT).
  - View는 상태를 직접 쓸 수 없다(값 스냅샷 + `let`, 컴파일러 보장).
  - Reducer가 받은 `Binding`은 동기 구간에서만 쓰고 저장·Task 캡처하지 않는다(기존 규율 유지).
  - 비동기 결과는 Intent로 회신한다(4번까지의 Task 규율 유지).
  - 1~4번 수정(취소 전파·user 이전·캘린더 가드·보존 플래그)의 동작이 그대로 유지된다.
- 이번 범위 밖:
  - View 파일 변경.
  - Domain/API 계약 변경, 캘린더 로직.
  - `@Observable` 전환(렌더링 범위 이슈와 별개, 직교).
  - Reducer 소유권 이동(셸 소유 유지. 자식 뷰 소유 시 탭 전환에 상태 증발).
- 코드에서 복원 불가능한 의도(있으면):
  - 없음.

## 작업 항목
- [x] `HomeScope`는 그대로 두기 (View용 읽기 전용, 변경 없음)
- [x] `HomeStore.scope()`는 그대로 두기 (스냅샷 + lifted send, 변경 없음)
- [x] `HomeStore.send`의 Reducer 호출을 `Binding` 투영으로 교체, `reduce` 헬퍼 삭제
  - 결과: Reducer가 `@Binding`을 프로퍼티로 품는 형태. 파라미터 방식은 dynamicMember가 값을 주지 않아 기각.
  - `interestReducer`·`calendarReducer` lazy init에서 `Binding(get:set:)` 주입 (`[weak self]`, MainActor 캡처 문제 없음 확인).
- [x] `InterestHomeReducer` 시그니처 `inout` → `@Binding` 프로퍼티 (본문·헬퍼 `state.X` 문법 유지, `state:` 파라미터 삭제)
- [x] `CalendarHomeReducer` 시그니처 `inout` → `@Binding` 프로퍼티 (동일)
- [x] `HomeScope.swift`에 `import SwiftUI`가 필요하면 추가 (Scope 자체는 불변이라 불필요할 가능성 높음)
  - 결과: 불필요. 대신 `HomeStore`·양 Reducer에 `import SwiftUI` 추가.
- [x] 전체 테스트로 동작 보존 검증 (보호 테스트 174개 전·후 동일 통과)

## 영향 범위
- 변경 모듈: `HomeFeature` 단일 모듈.
- 파일:
  - `Projects/HomeFeature/Sources/Home/Store/HomeStore.swift`
  - `Projects/HomeFeature/Sources/Home/Store/Interest/InterestHomeReducer.swift`
  - `Projects/HomeFeature/Sources/Home/Store/Calendar/CalendarHomeReducer.swift`
  - `Projects/HomeFeature/Sources/Home/Store/HomeScope.swift` (import만 가능)
- 레이어: Presentation(Store). Domain/Data/View/Mock 무변경. 테스트 코드 무변경 예상.

## 기술 결정
- 구현 직전에 선택이 필요한 사항과 그 결정 근거를 작성한다.

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| View용 Scope 형태 | 값 스냅샷 유지 또는 Binding 노출 | 값 스냅샷 유지 | View 직접 쓰기를 컴파일러 차원에서 불가하게 유지. 읽기·쓰기 통로 분리 |
| Reducer 상태 전달 | `inout` 유지 또는 `Binding` | `Binding` | 복사-쓰기백 제거로 증발 원천 해소. `state.X` 문법 그대로라 본문 변경 최소 |
| `Binding(get:set:)`+`@MainActor` 충돌 시 | 중단 또는 폴백 | 폴백: View에서 `$store.state.interest`로 직접 묶기 | dynamic member 투영은 확실히 컴파일됨. `store.scope()`는 테스트용으로 유지 |
| Reducer 소유권 | 셸 유지 또는 자식 뷰로 이동 | 셸 유지 | 자식 소유 시 탭 전환에 Reducer 파괴·상태 증발. 단방향 소유 유지 |
| 중첩 send 처리 | 큐잉(B안) 또는 Binding으로 해소 | Binding으로 해소 (큐 불필요) | 쓸 곳이 원본 하나뿐이라 증발 불가. assert·주석·큐 모두 불필요 |

## 주의 사항
- Reducer 본문·Task에서 `Binding` 자체를 캡처하지 않는다. Task에는 값·플래그만 (4번 교훈).
- `scheduleFetchMonth`·`performFetchDayEvents(date:state:)`처럼 값을 받던 헬퍼는 `state.wrappedValue` 스냅샷을 명시 전달한다.
- `send` 클로저(`[weak self]`→셸)의 순환참조 구조는 그대로라 추가 조치 없음.
- 퍼블리시 타이밍이 바뀐다(마지막 일괄 발행 → 쓰기마다 발행). Reducer 본문은 서스펜션 없는 동기 구간이라 같은 틱에 몰려 단일 렌더로 coalesce되지만, 검증 때 탭 전환·새로고침 이상 렌더를 눈으로 확인한다.

## 검증 방법
- [x] 명령: `xcodebuild test -workspace "Livith-iOS.xcworkspace" -scheme "HomeFeature" -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5'` (destination은 `xcodebuild -showdestinations`로 재확인)
- [x] 기대 신호: 변경 전 174개·15스위트 통과 → 변경 후 동일하게 통과 (동작 보존)
- [x] 실제 결과: 174개·15스위트 통과. 테스트 코드 무변경.
- [ ] 눈 검증: 관심↔캘린더 탭 전환, 당겨서 새로고침 시 이상 렌더·깜빡임 없음
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
