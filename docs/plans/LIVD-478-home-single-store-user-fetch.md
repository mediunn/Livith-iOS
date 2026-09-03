# LIVD-478 user 조회 관심 탭 이전

## 배경
- `user`의 생산자(`fetchUser`)는 셸(`HomeStore.performHomeAppear`)에, 소비자는 전부 관심 탭(추천 게이트·배너·닉네임)에 있다.
- 생산자→소비자 전달용 핸드셰이크(`_homeAppearStarted`·`_userLoaded`·`_homeAppearFailed` + `pendingInterestSectionList` + `isHomeAppearUserResolved`)가 PR #306 리뷰 1·2번 버그의 진원지다.
- 관심 Reducer는 이미 `UserRepository`를 주입받고 있어 `.onAppear`에서 user 조회까지 직접 수행할 수 있다. `hasNewNotice`만 셸에 남는다(`HomeView` 배지용).

## 목표
- `fetchUser`를 `InterestHomeReducer`로 이전하고 핸드셰이크 Intent 3종을 삭제한다.
- 셸 `homeAppear`는 알림 수 조회만 수행한다.
- 유저 조회 실패 시 다음 `onAppear`에 자동 재시도하지 않고, 당겨서 새로고침으로만 복구한다(사용자 확정).

## 권한·범위
- 정본(반드시 참이어야 하는 동작·불변조건):
  - `HomeState.interest.user`가 user의 유일한 저장소다(SSOT 유지, Reducer에 user 복제 금지).
  - 유저 조회 실패 시 섹션 결과를 반영하지 않는다(기존 불변식 유지).
  - 추천은 `hasPreferences == true`인 유저에게만 조회한다.
  - 추천 Task 취소 전파(1번 수정)와 캘린더 가드 순서(3번 수정)는 유지된다.
- 이번 범위 밖:
  - 4번 디테일(새로고침 시 nil user의 추천·배너 처리 방식).
  - 5번(중첩 동기 `send` 방어).
  - View 변경, Domain/API 계약 변경, 캘린더 로직.
  - `onRefresh`의 `wait()`가 합류 추천까지 기다리게 하기(4번 작업과 함께 정리).
- 코드에서 복원 불가능한 의도(있으면):
  - 없음. `user == nil`은 "모름", `hasPreferences == false`는 "없음"으로 구분한다.

## 작업 항목
- [x] Red 테스트 3건 작성·실패 확인 (`HomeStoreTests`)
  - `onAppear` 단독으로 유저·관심목록·섹션을 모두 조회한다.
  - 유저 실패 시 섹션 결과를 폐기하고 다음 `onAppear`에 재조회하지 않는다.
  - user 미보유 `onRefresh`는 user 조회부터 시작한다.
  - 결과: 3건 모두 red 확인, 나머지 54건 통과.
- [x] `HomeStore` 셸 정리
  - `HomeIntent._homeAppearResult` 삭제, `.homeAppear`는 `performFetchUnreadCount()`만 호출.
  - `performHomeAppear`·`fetchUser`·`fetchHasNewNotice`·`hasNewNotice(from:)`·`CancelID.homeAppear`·`userRepository` 주입 삭제. `import Domain`은 `NotificationRepository` 때문에 유지.
- [x] `InterestHomeReducer` 이전
  - `_homeAppearStarted`·`_userLoaded`·`_homeAppearFailed` 삭제, `._userResult(Result<User, Error>)` 추가.
  - `CancelID.user` 추가, `isHomeAppearUserResolved` 삭제, `userLoadFailed`(reducer-private 시도 여부 플래그) 추가.
  - `.onAppear`에서 `state.user == nil && !userLoadFailed`일 때만 user 조회 Task 시작(cancel-restart).
  - `._userResult(.success)`는 `state.user` 저장 + `userLoadFailed = false` + 대기 중 섹션 합류(`flushPendingSections` 재사용).
  - `._userResult(.failure)`는 `userLoadFailed = true` + 대기 중 섹션 폐기 + `applyError`.
  - `._sectionsFetched` 3분기 유지(`if let user` → 합류, `else if userLoadFailed` → 폐기, `else` → 대기).
  - `.onRefresh`에 user 미보유 시 user 조회 시작 연결(복구 경로). 추천·배너 nil 처리는 건드리지 않음.
- [x] 기존 테스트 재작성
  - `homeAppear`·`._homeAppearResult` 기반 약 10개를 `userStub`+`onAppear` 또는 `.interest(._userResult(.success))` 직접 전송으로 교체.
  - `testInterestAppearDoesNotFetchUser`는 "조회한다"로 뒤집기.
  - 셸 테스트는 "`homeAppear`는 알림 수만 조회한다"로 축소.
  - 구 `testStaleUserDoesNotApplySectionsAfterUserFailure` 삭제(시나리오 소멸, 신규 실패 테스트로 대체).
  - 실패 후 복구 테스트를 onRefresh 방식(`testOnRefreshRecoversHomeSectionLoadAfterUserFailure`)으로 교체.
- [x] 검증 후 기존 archive(`docs/archives/LIVD-478-home-single-store.md`)에 추가 기록

## 영향 범위
- 변경 모듈: `HomeFeature` 단일 모듈.
- 파일:
  - `Projects/HomeFeature/Sources/Home/Store/HomeStore.swift`
  - `Projects/HomeFeature/Sources/Home/Store/Interest/InterestHomeReducer.swift`
  - `Projects/HomeFeature/Tests/HomeStoreTests.swift`
- 레이어: Presentation(Store). Domain/Data/View 무변경. Mock 무변경.

## 기술 결정
- 구현 직전에 선택이 필요한 사항과 그 결정 근거를 작성한다.

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 실패 시 재시도 정책 | 다음 onAppear 자동 재조회 또는 수동 새로고침만 | 수동 새로고침만 | 사용자 확정. 실패 메모(`userLoadFailed`)로 다음 onAppear 건너뜀 |
| 실패 메모 위치 | Reducer-private 플래그 또는 State에 두기 | Reducer-private 플래그 | user 복제가 아니라 시도 여부라 SSOT 유지. `pendingInterestSectionList` 선례와 동일 |
| onRefresh 복구 연결 | user 미보유 시 조회 시작 또는 손대지 않기 | 조회 시작 연결 | 자동 재시도를 끄면 복구 경로가 새로고침밖에 없음. 추천·배너 nil 디테일은 4번에 위임 |
| 분기 순서 | `_sectionsFetched` 순서 변경 또는 유지 | 유지 | 2번 수정에서 확인: 리셋 기반 불변식 하에서 `if let user` 선행이 정상 경로를 살림 |

## 주의 사항
- 1번 수정(`.completeSection` 취소 전파)과 충돌하지 않게 `performCompleteSectionSuccess`·`flushPendingSections` 호출부는 그대로 둔다.
- `.onAppear`에서 user 조회 여부 판단은 동기 시점의 `state.user`로 한다(비동기 작업에 값을 미리 캡처하지 않기 — 4번 교훈).
- `#4` 작업과 경계: `._sectionLoadResult` 성공 핸들러의 `nil ?? []`·`?? false`는 건드리지 않는다.
- `testInterestAppearDoesNotFetchUser`를 비롯한 기존 테스트가 의도적으로 깨진다. 재작성 목록에漏れがないか 확인한다.

## 검증 방법
- [x] 명령: `tuist generate --no-open`
- [x] 기대 신호: 생성 성공 (Swift 파일 추가·이동·삭제 없어 기존 생성 상태 유지, 별도 실행 생략)
- [x] 실제 결과: 해당 없음(편집만 변경)
- [x] 명령: `xcodebuild test -workspace "Livith-iOS.xcworkspace" -scheme "HomeFeature" -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -only-testing:HomeFeatureTests/HomeStoreTests` (destination은 `xcodebuild -showdestinations`로 재확인)
- [x] 기대 신호: 신규 3건 red 확인 후 green 통과, 기존 재작성 테스트 전부 통과
- [x] 실제 결과: red에서 신규 3건만 실패·기존 54건 통과. green에서 56건 통과.
- [x] 명령: 동일 workspace/scheme 전체 테스트 (스위트 필터 없이)
- [x] 기대 신호: HomeFeature 전체 통과
- [x] 실제 결과: 173개·15스위트 통과.

## 컴파운딩 (아카이브 전)
- [ ] 교훈 분류 완료
- rules 반영 (`기본 승격 규칙`):
  -
- 분리 확인 제안 (`architecture` / `security`, 있으면):
  -
- archive만 유지:
  -
- 반영 없음 / 사유:
