# LIVD-376 관심 콘서트 설정/변경 QA 반영

## 배경
- 관심 콘서트 설정/변경 화면 QA에서 공연 목록 스크롤, 제출 결과 토스트 문구, 설정 화면 뒤로가기 동작 문제가 확인되었다.
- 해당 화면은 `HomeFeature`의 관심 콘서트 설정/변경 UI와 `InterestConcertSettingStore` 상태 로직을 함께 사용한다.
- Store 상태 변경은 테스트로 보호하고, 순수 UI 배치와 네비게이션 모달 동작은 수동 검증을 병행해야 한다.

## 목표
- 공연 목록 마지막 카드가 하단 CTA 영역에 가려지지 않고 최하단까지 스크롤되도록 한다.
- 관심 콘서트 설정/변경 제출 결과 토스트 문구를 QA 요구사항에 맞게 변경한다.
- 관심 콘서트 설정 화면에서는 선택 여부와 관계없이 뒤로가기 확인 모달이 뜨지 않도록 한다.
- 관심 콘서트 변경 화면의 변경사항 이탈 확인 모달 동작은 유지한다.

## 작업 항목
- [ ] Store 제출 결과 문구 테스트 추가
  - `InterestConcertSettingStoreTests`에 설정 성공, 변경 성공, 설정 실패, 변경 실패 문구 검증을 추가한다.
  - 생산 코드 변경 전에 실패 테스트를 먼저 실행해 기대 동작 부재로 실패하는지 확인한다.
- [ ] Store 제출 결과 문구 변경
  - 설정 성공 시 `소식을 받을 공연이 설정되었어요`를 successMessage에 설정한다.
  - 변경 성공 시 `소식을 받을 공연이 변경되었어요`를 successMessage에 설정한다.
  - 설정 제출 실패 시 `소식을 받을 공연 추가에 실패했어요`를 errorMessage에 설정한다.
  - 변경 제출 실패 시 `소식을 받을 공연 변경에 실패했어요`를 errorMessage에 설정한다.
  - 목록 조회, 검색, 페이지네이션 실패는 기존 에러 메시지 흐름을 유지한다.
- [ ] 공연 목록 스크롤 하단 여유 공간 추가
  - `HomeConcertContentSectionView`가 사용하는 하단 여유 기준(`Spacer(minLength: 210)`)에 맞춰 `InterestConcertSelectionGridView`의 grid 하단 여백을 210pt로 확정 적용한다.
  - `InterestConcertSettingView`의 하단 CTA/선택 칩 영역은 overlay 구조로 유지하고, 스크롤 콘텐츠 자체에 충분한 bottom padding을 둔다.
  - 선택 칩이 없는 상태와 있는 상태 모두 마지막 카드 접근이 가능하도록 한다.
- [ ] 설정 화면 뒤로가기 모달 정책 변경
  - Store의 `hasUnsavedChanges`와 `isCTAEnabled` 계산은 변경하지 않는다.
  - `InterestConcertSettingView.handleBackButtonTap()`에서 `InterestConcertSettingMode.initialSetup`이면 선택 여부와 관계없이 즉시 `coordinator?.pop()`한다.
  - `InterestConcertSettingMode.update`에서는 기존처럼 `hasUnsavedChanges`가 있을 때만 이탈 확인 모달을 표시한다.
- [ ] 검증 및 계획 문서 정리
  - 관련 Store 테스트를 실행해 통과를 확인한다.
  - 설정/변경 화면에서 스크롤, 토스트, 뒤로가기 동작을 수동 확인한다.
  - 작업 완료 후 이 계획 문서를 `docs/archives/`로 이동한다.

## 영향 범위
- `Projects/HomeFeature/Sources/Interest/Store/InterestConcertSettingStore.swift`
- `Projects/HomeFeature/Sources/Interest/View/InterestConcertSettingView.swift`
- `Projects/HomeFeature/Sources/Interest/View/Subview/InterestConcertSelectionGridView.swift`
- `Projects/HomeFeature/Tests/InterestConcertSettingStoreTests.swift`

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 제출 실패 문구 적용 범위 | 모든 에러 토스트 변경 또는 제출 실패만 변경 | 제출 실패만 변경 | QA 문구는 관심 콘서트 설정/변경 시도 후 결과 토스트에 대한 요구사항이므로 목록 조회/검색 실패 문구까지 바꾸지 않는다. |
| 스크롤 여유 공간 구현 | grid 고정 bottom padding 또는 bottom section 높이 기반 inset | grid 하단 210pt padding | 홈 화면의 `HomeConcertContentSectionView`가 `Spacer(minLength: 210)`로 하단 스크롤 여유를 확보하므로 QA 기준과 동일한 값을 적용한다. |
| 설정 화면 뒤로가기 | 선택 여부에 따라 모달 표시 또는 항상 즉시 pop | 항상 즉시 pop | QA 요구사항이 설정 UI에서는 선택 여부와 관계없이 모달 미표시이기 때문이다. |
| 변경 화면 뒤로가기 | 설정과 동일하게 즉시 pop 또는 기존 변경사항 확인 유지 | 기존 변경사항 확인 유지 | QA 요구사항은 설정 UI에 한정되어 있고, 변경 화면의 미저장 변경 보호는 기존 의도된 동작이다. |
| 테스트 적용 | Store 문구만 자동화 또는 View까지 자동화 | Store 문구 자동화, UI 동작 수동 검증 | 토스트 문구는 Store 상태로 검증 가능하고, 스크롤/네비게이션 모달은 현재 테스트 구조상 수동 검증이 효율적이다. |

## 주의 사항
- `docs/rules/tdd.md`에 따라 Store 동작 변경은 실패 테스트를 먼저 작성하고 실행한다.
- 순수 UI 배치와 뒤로가기 View 이벤트는 TDD 예외 대상으로 보고 최종 보고에 이유를 명시한다.
- 제출 실패 외의 `error.localizedDescription` 기반 에러 메시지 흐름을 불필요하게 바꾸지 않는다.
- 설정 화면 뒤로가기 모달 제거를 위해 Store의 `hasUnsavedChanges`를 바꾸지 않는다. 해당 값은 설정 CTA 활성화에도 사용된다.
- 변경 화면의 미저장 변경 확인 모달을 실수로 제거하지 않는다.
- 커밋과 푸시는 `docs/rules/git.md`에 따라 사용자에게 명시적으로 승인받은 뒤 수행한다.

## 검증 방법
- `InterestConcertSettingStoreTests`를 실행해 설정/변경 성공 및 실패 문구 테스트가 통과하는지 확인한다.
- 설정 화면에서 공연 선택 전/후 뒤로가기를 눌렀을 때 모달 없이 이전 화면으로 이동하는지 확인한다.
- 변경 화면에서 변경사항이 없으면 즉시 이전 화면으로 이동하고, 변경사항이 있으면 확인 모달이 표시되는지 확인한다.
- 설정/변경 화면에서 선택 칩이 없는 상태와 있는 상태 모두 공연 목록 마지막 카드가 하단 CTA 영역에 가려지지 않고 스크롤되는지 확인한다.
