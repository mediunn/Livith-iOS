# LIVD-377 관심 콘서트 홈 QA 반영

## 배경
- 관심 콘서트가 설정된 유저의 홈 화면에서 관심 콘서트 섹션 QA 피드백이 발생했다.
- 현재 홈 관심 콘서트 섹션의 기본 정렬, 카드 탭 이동, 진행중 콘서트 표시 문구, 타이틀 폰트가 QA 기준과 일부 다르다.

## 목표
- 관심 콘서트가 설정된 유저의 홈 UI에서 기본 정렬을 예매일 기준으로 표시한다.
- 홈 관심 콘서트 카드를 탭하면 해당 콘서트 상세 화면으로 이동한다.
- 진행중인 관심 콘서트 카드는 배지를 `공연 D-Day`, 하단 문구를 `콘서트 진행중`으로 표시한다.
- 홈 관심 콘서트 섹션 타이틀 폰트를 `headSemibold`로 변경한다.

## 작업 항목
- [x] 홈 관심 콘서트 기본 정렬을 예매일로 변경한다.
  - `HomeState.interestConcertSort` 기본값을 `.ticketing`으로 변경한다.
  - `InterestConcertListFilter.homeSection` 기본 sort를 `.ticketing`으로 변경한다.
  - 홈 관심 콘서트 정렬 옵션 표시 순서를 `[.ticketing, .concert]`로 변경한다.
- [x] 홈 관심 콘서트 카드 탭 이동을 연결한다.
  - `HomeInterestConcertSectionView`에 `onConcertTap: (InterestConcert) -> Void` 콜백을 추가한다.
  - 현재 표시 중인 `currentPage`의 `InterestConcert` 카드 탭 시 `onConcertTap`으로 해당 값을 전달한다.
  - `HomeView`에서 전달받은 관심 콘서트의 `concert.id`로 `HomeCoordinator.showConcertDetail(concertID:)`를 호출한다.
  - 카드 외부의 타이틀 탭, 변경하기 버튼, 정렬 옵션 동작은 기존 역할을 유지한다.
- [x] 진행중 관심 콘서트 표시 문구를 수정한다.
  - `InterestConcertDisplayText.badge(for:)`에서 `ConcertStatus.ongoing`이면 `공연 D-Day`를 반환한다.
  - `InterestConcertDisplayText.bottom(for:)`에서 `ConcertStatus.ongoing`이면 `콘서트 진행중`을 반환한다.
  - 진행중 판정은 `daysLeft == 0`이 아니라 `concert.status == .ongoing` 기준으로 고정한다.
- [x] 홈 관심 콘서트 섹션 타이틀 폰트를 변경한다.
  - `HomeInterestConcertSectionView`의 `관심 콘서트` 타이틀 텍스트 폰트를 `.headSemibold`로 변경한다.
- [x] 자동 테스트로 QA 반영을 검증한다.
  - `HomeState` 초기 기본 정렬이 `.ticketing`인지 검증한다.
  - `HomeIntent.onAppear`의 관심 콘서트 조회 필터가 sort `.ticketing`, limit `5`를 사용하는지 검증한다.
  - `InterestConcertListFilter.homeSection()` 기본 sort가 `.ticketing`인지 검증한다.
  - `ConcertStatus.ongoing` 관심 콘서트의 배지가 `공연 D-Day`인지 검증한다.
  - `ConcertStatus.ongoing` 관심 콘서트의 하단 문구가 `콘서트 진행중`인지 검증한다.
  - `.upcoming`이면서 `daysLeft == 0`인 관심 콘서트가 `콘서트 진행중` 하단 문구로 표시되지 않는지 검증한다.
- [ ] 관심 콘서트가 있는 홈에서 수동 확인한다.
  - 관심 콘서트가 있는 홈에서 정렬 라벨, 카드 탭 이동, 진행중 문구, 타이틀 폰트를 확인한다.

## 영향 범위
- `Projects/HomeFeature`
  - 홈 관심 콘서트 섹션 UI, 홈 Store 상태와 조회 조건, 관련 Store 테스트
- `Projects/Domain`
  - 관심 콘서트 홈 섹션 조회 필터 기본값과 관련 도메인 테스트
- `Projects/Shared/DisplaySupport`
  - 관심 콘서트 표시 문구 정책과 관련 테스트

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 홈 관심 콘서트 기본 정렬 | 공연 일정 또는 예매일 | 예매일 | QA 요구사항이 홈 UI 기본 정렬을 예매일로 명시했다. |
| 홈 섹션 필터 기본값 변경 범위 | `HomeStore` 호출부만 변경 또는 `InterestConcertListFilter.homeSection` 기본값도 변경 | 둘 다 변경 | 호출부 누락 시에도 홈 섹션 기본 정책이 예매일로 유지되도록 도메인 필터 helper까지 맞춘다. |
| 진행중 콘서트 판정 기준 | `ConcertStatus.ongoing`, `daysLeft == 0`, 둘 다 | `ConcertStatus.ongoing` | 사용자 확인 결과 진행중 판정은 status 기준으로 고정한다. |
| 카드 탭 구현 위치 | 카드 View 내부 버튼화 또는 섹션에서 카드에 탭 제스처 적용 | 섹션에서 `onConcertTap: (InterestConcert) -> Void` 콜백 연결 | `InterestConcertCardView`는 표시 전용으로 유지하고, 홈 이동 의존성은 홈 섹션과 `HomeView`가 담당한다. |
| 정렬 옵션 순서 | 기존 `[.concert, .ticketing]` 유지 또는 `[.ticketing, .concert]` 변경 | `[.ticketing, .concert]` | 기본 정렬이 예매일이므로 옵션 표시 순서도 관심 콘서트 목록 화면과 일치시킨다. |

## 주의 사항
- `ConcertStatus.filterText`의 `ongoing` 문구는 검색/필터 등 다른 화면에서도 사용하므로 변경하지 않는다.
- `InterestConcertDisplayText` 변경은 홈 관심 콘서트 섹션과 해당 표시 정책을 재사용하는 preview 또는 후속 호출부에 영향을 줄 수 있다.
- `daysLeft == 0`만으로 진행중 표시를 하지 않는다. 서버 상태가 `.upcoming`이고 `daysLeft == 0`인 데이터는 기존 D-Day 정책을 유지한다.
- 카드 탭 영역이 정렬 옵션 팝오버, 타이틀 탭, 변경하기 버튼 동작을 가로채지 않도록 카드 영역에만 탭 처리를 적용한다.
- QA 문서의 `head1Semibold` 표현은 오타이며, 실제 구현은 기존 디자인 시스템 토큰인 `.headSemibold`를 사용한다.
- 계획 확인 전에는 생산 코드 수정을 진행하지 않는다.

## 검증 방법
- `tuist test HomeFeature`
- `tuist test Domain`
- `tuist test DisplaySupport`
- `DisplaySupport` 테스트 실행 시 Tuist 출력에서 `DisplaySupportTests` 결과가 실제로 통과했는지 확인한다.
- 수동 확인
  - 관심 콘서트가 있는 홈 섹션의 기본 정렬 라벨이 `예매일`인지 확인한다.
  - 홈 관심 콘서트 카드를 탭하면 콘서트 상세 화면으로 이동하는지 확인한다.
  - `ConcertStatus.ongoing` 관심 콘서트 카드의 배지가 `공연 D-Day`인지 확인한다.
  - `ConcertStatus.ongoing` 관심 콘서트 카드의 하단 문구가 `콘서트 진행중`인지 확인한다.
  - 홈 관심 콘서트 섹션 타이틀이 디자인 시스템 `headSemibold` 스타일로 표시되는지 확인한다.
