# [LIVD-375] 관심 콘서트 무한 정책 1차 클라이언트 대응

## 배경
- 관심 콘서트 설정/변경 정책이 무한 선택으로 변경되면서, 변경 화면 진입 시 유저의 기존 관심 콘서트 전체를 안정적으로 초기 선택값에 반영해야 한다.
- 현재 `update` 모드는 기존 관심 콘서트를 페이지당 20개씩 순차 조회하므로 관심 콘서트 수가 많아질수록 초기 로딩 시간이 길어질 수 있다.
- 하단 선택 칩은 수평 `ScrollView` 안에서 일반 `HStack`으로 전체 칩을 렌더링하므로, 선택 개수가 많아질 때 렌더링 부담이 커질 수 있다.

## 목표
- 서버/API 계약 변경 없이 클라이언트에서 1차 성능 대응을 적용한다.
- 변경 화면 초기 선택값 조회 단위를 20개에서 50개로 늘려 네트워크 호출 횟수를 줄인다.
- 하단 선택 칩의 기존 UX는 유지하면서 `LazyHStack`으로 렌더링 비용을 낮춘다.
- 기존 초기 선택값 동기화, 실패 처리, 제출 동작은 유지한다.

## 작업 항목
- [x] 초기 선택값 조회 단위 테스트 수정
  - `InterestConcertSettingStoreTests`에서 `update` 모드 초기 관심 콘서트 조회의 `limit` 기대값을 20에서 50으로 변경한다.
  - 생산 코드 변경 전 테스트를 실행해 기대한 실패를 확인한다.
- [x] 초기 선택값 조회 단위 변경
  - `InterestConcertSettingStore.Constants.initialSelectionPageSize`를 50으로 변경한다.
  - `fetchInitialSelectionPageList`의 전체 페이지 순차 조회 방식과 실패 시 부분 선택값 미반영 정책은 유지한다.
- [x] 하단 선택 칩 렌더링 최적화
  - `InterestConcertSelectionBottomSectionView`의 수평 칩 컨테이너를 `HStack`에서 `LazyHStack`으로 변경한다.
  - 선택 칩 노출 개수, 문구, 삭제 인터랙션은 변경하지 않는다.
- [x] 검증 및 계획 문서 정리
  - `tuist test HomeFeature`를 실행해 관련 Store 테스트와 빌드 회귀를 확인한다.
  - 구현 완료 후 이 계획 문서를 기준으로 전체 구현 내용을 서브에이전트에게 리뷰받는다.
  - 작업 완료 후 이 문서의 체크박스를 완료 상태로 갱신한다.

## 영향 범위
- `Projects/HomeFeature/Sources/Interest/Store/InterestConcertSettingStore.swift`
  - 초기 선택값 조회 page size 상수 변경
- `Projects/HomeFeature/Sources/Interest/View/Subview/InterestConcertSelectionBottomSectionView.swift`
  - 선택 칩 수평 레이아웃 lazy 렌더링 적용
- `Projects/HomeFeature/Tests/InterestConcertSettingStoreTests.swift`
  - 초기 선택값 조회 limit 기대값 변경

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 서버/API 변경 포함 여부 | 클라이언트만 변경 / ID 전용 API 추가 / 둘 다 설계 | 클라이언트만 변경 | 이번 작업은 1차 대응이며 서버 계약 변경 없이 적용 가능한 범위로 제한한다. |
| 초기 선택값 조회 단위 | 50 / 100 / 서버 최대값 | 50 | full `Concert` payload 응답 크기 리스크를 과도하게 키우지 않으면서 순차 호출 수를 줄이는 보수적 상향이다. |
| 하단 칩 UX | `LazyHStack`만 적용 / 표시 개수 제한 / 칩 영역 재설계 | `LazyHStack`만 적용 | 기존 UX와 동작을 유지하면서 렌더링 비용만 줄인다. |
| Store 선택 상태 최적화 | 제외 / 일부 포함 / 전반 포함 | 제외 | 이번 PR 범위를 page size와 렌더링 최소 변경으로 제한해 리뷰 리스크를 낮춘다. |

## 주의 사항
- 서버가 `size=50`을 허용한다는 전제로 진행한다.
- 초기 선택값 조회는 여전히 기존 관심 콘서트 전체를 가져와야 하며, `nextToken`이 없어질 때까지 반복 조회해야 한다.
- 초기 선택값 조회 중 일부 페이지가 실패하면 현재 정책대로 부분 선택값을 반영하지 않는다.
- `LazyHStack` 변경은 렌더링 비용 완화이며, `selectedConcertList` 전체 배열 생성 비용이나 grid의 선택 여부 조회 비용까지 해결하지는 않는다.
- 선택 칩 표시 개수 제한, ID 전용 API, 선택 상태 `Set` 캐시 등은 후속 개선 범위로 둔다.

## 검증 방법
- 생산 코드 변경 전, 테스트 기대값만 50으로 바꾼 뒤 `tuist test HomeFeature` 또는 관련 테스트 실행으로 실패를 확인한다.
- 생산 코드 변경 후 `tuist test HomeFeature`를 실행한다.
- 테스트 통과 후 이 계획 문서를 리뷰 기준으로 제공해 서브에이전트에게 구현 누락, 범위 초과, 회귀 위험을 검토받는다.
- 중점 확인 테스트:
  - `update 모드는 저장된 관심 콘서트를 조회해 초기 선택값으로 사용해야 한다`
  - `update 모드는 저장된 관심 콘서트 다음 token이 없을 때까지 조회해 초기 선택값으로 사용해야 한다`
  - `update 모드는 관심 콘서트 전체 조회가 끝날 때까지 초기 로딩 상태를 유지해야 한다`
  - `update 모드는 관심 콘서트 다음 페이지 조회 실패 시 부분 선택값을 반영하지 않아야 한다`
