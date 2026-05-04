# LIVD-380 관심 콘서트 변경 화면 전체 조회 수정

## 배경
- 관심 콘서트 설정/변경 화면의 update 모드는 기존 관심 콘서트를 초기 선택값으로 보여줘야 한다.
- 현재 변경 화면은 `UserRepository.fetchInterestedConcertList(filter: .all)`을 한 번만 호출한다.
- `.all` 팩토리는 query 생략과 전체 조회 의미가 섞여 있어 페이지 전체 수집 흐름과 구분이 불명확하다.
- 관심 콘서트 목록 API가 페이지네이션을 제공하므로, 한 번의 조회만으로는 저장된 관심 콘서트 전체가 초기 선택값에 반영되지 않을 수 있다.

## 목표
- 변경 화면 진입 시 유저의 관심 콘서트 전체 페이지를 조회해 모든 기존 선택값을 반영한다.
- 기존 Repository 경계와 endpoint 계약은 유지하고, Store가 전체 페이지 수집 흐름을 명확히 담당한다.
- update 모드에서는 유저의 관심 콘서트 전체 조회가 끝날 때까지 로딩뷰를 보여주고 선택 UI를 열지 않는다.
- 조회 조건과 Store 동작을 테스트로 보호한다.

## 작업 항목
- [ ] 관심 콘서트 전체 페이지 조회 조건을 Domain에 추가한다.
  - `InterestConcertListFilter`에 `static func initialSelectionPage(limit: Int, nextToken: (any NextToken)? = nil) -> InterestConcertListFilter`를 추가한다.
  - `initialSelectionPage`는 `sort == nil`, `limit == 전달값`, `nextToken == 전달값`을 가진다.
  - 기존 `InterestConcertListFilter.all` 팩토리는 제거한다.
  - `UserRepository.fetchInterestedConcert()` extension 편의 메서드는 현재 호출처가 없고 `.all`에 의존하므로 제거한다.
- [ ] 변경 화면 Store의 초기 선택 조회를 페이지 전체 수집 방식으로 수정한다.
  - update 모드에서 첫 페이지를 조회한 뒤 `nextToken`이 없을 때까지 다음 페이지를 반복 조회한다.
  - 전체 페이지 수집은 private accumulator에서 수행하고, 모든 페이지가 성공한 뒤 aggregated `ListResult<InterestConcert>`를 한 번만 Store state에 반영한다.
  - 두 번째 이후 페이지에서 실패해도 앞 페이지 결과를 부분 선택값으로 반영하지 않는다.
  - update 모드의 `state.isInitialLoading`은 콘서트 첫 페이지 조회와 초기 선택 전체 조회가 모두 끝날 때까지 유지한다.
  - update 모드에서 유저의 관심 콘서트 전체 조회가 진행 중이면 화면은 기존 `loadingView`를 계속 표시한다.
  - `toggleConcertSelection`, `removeSelectedConcert`, `submit`은 `state.isInitialLoading == true`일 때 무시한다.
  - 조회 실패 시 기존처럼 `errorMessage`를 설정하고, 초기 선택값은 비워 둔다.
- [ ] 테스트를 먼저 추가하고 실패를 확인한 뒤 구현한다.
  - 기존 `InterestConcertListFilter.all` 테스트는 `initialSelectionPage` 테스트로 대체한다.
  - `UserRepository.fetchInterestedConcert()` 제거 후 해당 extension 호출이 남지 않는지 컴파일로 확인한다.
  - update 모드에서 관심 콘서트 첫 페이지에 `nextToken`이 있으면 다음 페이지까지 조회하는지 검증한다.
  - 여러 페이지 결과가 모두 초기 선택값에 포함되는지 검증한다.
  - `MockUserRepository.fetchInterestedConcertListFilterList`로 첫 호출은 `nextToken == nil`, 두 번째 호출은 첫 응답 token, 모든 호출은 `sort == nil`, `limit == 20`인지 검증한다.
  - 두 번째 이후 페이지 실패 시 선택 ID와 선택 콘서트 목록을 부분 반영하지 않는지 검증한다.
  - update 모드에서는 유저의 관심 콘서트 전체 조회 완료 전까지 `state.isInitialLoading == true`이고 grid 대신 로딩 상태가 유지되는지 검증한다.
  - update 모드 초기 로딩 중 선택 변경과 제출 intent가 무시되는지 검증한다.
- [ ] 변경 범위를 검증한다.
  - `tuist test HomeFeatureTests`로 Store 테스트를 실행한다.
  - `tuist test DomainTests`로 조회 조건 테스트를 실행한다.
  - 필요 시 `tuist test LivithNetworkTests`로 query 생성 회귀를 확인한다.

## 영향 범위
- `Projects/Domain`
  - `InterestConcertListFilter`와 관련 도메인 테스트
- `Projects/HomeFeature`
  - `InterestConcertSettingStore`와 관련 Store 테스트
- `Projects/Data/UserData`
  - 생산 코드 변경은 계획하지 않는다.
  - 기존 `UserRepositoryImpl.makeFetchInterestConcertListRequest`가 nil sort, limit, nextToken 조합을 이미 DTO request로 변환하므로 Domain factory와 Store 호출 filter 검증으로 보호한다.

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 전체 조회 위치 | Repository 전용 메서드 추가 또는 Store 반복 조회 | Store 반복 조회 | 기존 Repository 인터페이스를 유지하면서 변경 화면에 필요한 전체 수집 정책만 Presentation Store에서 조합한다. |
| 조회 조건 표현 | 기존 `.all` 재사용, `.all` 유지 후 페이지용 팩토리 추가, `.all` 제거 후 페이지용 팩토리 추가 | `.all` 제거 후 페이지용 팩토리 추가 | 관심 콘서트 목록 API가 페이지 기반으로 쓰이므로 query 전체 생략형 팩토리를 남기면 전체 조회 의미를 오해하기 쉽다. |
| 새 팩토리 이름 | `allPage`, `initialSelectionPage`, `pageWithoutSort` | `initialSelectionPage` | 이 조회 조건은 변경 화면의 기존 선택값 로딩 용도이므로 사용 맥락을 이름에 드러낸다. |
| 단일 관심 콘서트 편의 메서드 | 새 filter로 유지 또는 제거 | 제거 | 현재 직접 호출처가 없고 `.all` 제거 후 첫 항목 조회 의미도 불명확하므로 public extension에서 제거한다. |
| 초기 선택 상태 반영 | 페이지마다 즉시 반영 또는 전체 성공 후 한 번 반영 | 전체 성공 후 한 번 반영 | 중간 페이지 실패 시 부분 선택값이 확정되는 문제를 방지한다. |
| update 모드 초기 로딩 UX | 콘서트 grid 먼저 표시 또는 관심 콘서트 전체 조회 완료까지 로딩뷰 유지 | 로딩뷰 유지 | 저장된 기존 선택값이 모두 반영되기 전 사용자가 누락된 선택 상태를 보거나 변경하는 문제를 막는다. |
| 초기 로딩 중 사용자 선택 | 허용 후 병합 또는 무시 | 무시 | 로딩뷰 유지 중에도 intent가 들어올 수 있으므로 Store 차원에서 상태 변경을 막는다. |
| 페이지 크기 | 기존 목록 크기 12, 전체 조회 전용 20, 별도 설정값 | 20 | 초기 선택값 전체 수집은 UI grid 페이지네이션과 목적이 다르므로 호출 횟수를 줄이기 위해 20개 단위로 조회한다. |
| 정렬 조건 | 서버 기본값 사용 또는 클라이언트 정렬 지정 | 서버 기본값 사용 | 초기 선택값은 저장된 전체 ID 확보가 목적이므로 홈/목록 화면 정렬 정책과 분리한다. |

## 주의 사항
- `UserRepository.fetchInterestedConcertList(filter:)` 시그니처와 `HomeEndpoint.fetchInterestedConcertList` path/method는 변경하지 않는다.
- 관심 콘서트 변경 화면의 초기 선택값 순서는 서버 반환 순서를 따른다.
- `InterestConcertListFilter.all` 제거 후 컴파일 에러가 남지 않도록 모든 호출처를 새 조회 조건으로 교체한다.
- `UserRepository.fetchInterestedConcert()`는 호출처가 없는 legacy 편의 API로 보고 제거한다.
- 실패 시 부분 조회 결과를 초기 선택값으로 확정하지 않고 기존 실패 처리 흐름을 유지한다.
- update 모드에서 유저의 관심 콘서트 전체 조회가 끝나기 전에는 grid 대신 로딩뷰가 유지되어야 한다.
- update 모드 초기 로딩 중에는 선택/삭제/제출 동작이 상태를 변경하지 않아야 한다.
- 보안 규칙에 따라 인증 토큰이나 민감한 응답 원문을 로그, 테스트, 문서에 남기지 않는다.

## 검증 방법
- `tuist test HomeFeatureTests`
- `tuist test DomainTests`
- 필요 시 `tuist test LivithNetworkTests`
- 테스트/빌드 실행이 환경 제약으로 실패하면 실패 명령, 오류 요약, 미검증 범위를 최종 보고에 남긴다.
