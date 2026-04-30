# LIVD-367 관심 콘서트 목록 화면

## 배경
- 홈의 관심 콘서트 섹션에서 타이틀을 눌렀을 때 유저가 설정한 관심 콘서트 전체 목록을 확인할 수 있는 화면이 필요하다.
- 현재 홈 섹션은 제한된 개수만 보여주므로, 전체 목록은 별도 화면에서 페이징으로 조회해야 한다.
- 디자인 시안(`tmp/interest_concert_list_ui.png`) 기준으로 추천 콘서트 목록 그리드와 유사한 레이아웃에 정렬 필터와 변경하기 버튼이 추가된다.

## 목표
- 홈 관심 콘서트 타이틀 탭 시 관심 콘서트 전체 목록 화면으로 이동한다.
- 관심 콘서트 목록 화면에서 공연 일정순/예매일순 정렬을 선택할 수 있다.
- 관심 콘서트 목록을 커서 기반 페이징으로 추가 조회한다.
- 최초 조회 실패로 표시할 목록이 없을 때 `LivithEmptyView`에 오류 메시지를 표시한다.

## 진행 방식
- 모든 작업 항목을 한 번에 구현하지 않는다.
- Store 테스트/Store 구현, 목록 화면 구현, 라우팅 연결, 검증 및 정리처럼 단계별로 나누어 진행한다.
- 각 단계 구현이 끝나면 다음 단계로 넘어가기 전에 서브에이전트에게 계획 문서를 기준으로 구현 내용을 리뷰받는다.
- 서브에이전트 리뷰에서 발견된 문제는 해당 단계 안에서 먼저 수정하고 다시 리뷰받는다.
- 서브에이전트 리뷰가 통과되면 다음 단계를 바로 실행하지 않고 사용자에게 통과 사실과 다음 단계 진행 여부를 알린다.

## 작업 항목
- [x] 관심 콘서트 목록 Store 테스트 작성
  - 초기 조회 시 기본 정렬과 페이지 크기 12개로 관심 콘서트 목록을 조회하는지 검증한다.
  - 다음 페이지 요청 시 서버 응답의 `nextCursor`를 포함해 조회하고 기존 목록 뒤에 추가하는지 검증한다.
  - 첫 페이지 조회 시 cursor를 생략하는지 검증한다.
  - 더 이상 페이지가 없거나 로딩 중일 때 중복 조회하지 않는지 검증한다.
  - 정렬 변경 시 목록과 커서를 초기화한 뒤 선택한 정렬로 다시 조회하는지 검증한다.
  - 정렬 변경 조회 실패 시 기존 목록, 기존 정렬, 기존 커서를 유지하고 오류 메시지만 설정하는지 검증한다.
  - 최초 조회 실패 시 목록은 비어 있고 오류 메시지가 설정되는지 검증한다.
  - 다음 페이지 조회 실패 시 기존 목록은 유지하고 오류 메시지가 설정되는지 검증한다.
  - 조회 성공 시 이전 오류 메시지가 비워지는지 검증한다.
  - `MockUserRepository`는 query history와 cursor별 `InterestConcertPage` stub을 지원하도록 확장한다.
- [x] 관심 콘서트 목록 Store 구현
  - `InterestConcertListState`, `InterestConcertListIntent`, `InterestConcertListStore`를 추가한다.
  - `InterestConcertListState`는 `interestConcertList`, `selectedSort`, `nextCursor`, `hasMorePages`, `isInitialLoading`, `isLoadingMore`, `errorMessage`를 가진다.
  - `UserRepository.fetchInterestedConcertList(query:)`를 사용해 `InterestConcertListQuery` 기반으로 페이지당 12개씩 조회한다.
  - 첫 페이지 조회는 `InterestConcertListQuery(sort: selectedSort, pageSize: 12, cursor: nil)`로 요청한다.
  - 다음 페이지 조회는 `hasMorePages == true`, `isInitialLoading == false`, `isLoadingMore == false`일 때만 수행한다.
  - `InterestConcertPage.nextCursor`로 다음 페이지 여부와 요청 커서를 관리한다.
  - 응답의 `nextCursor == nil`이면 `hasMorePages = false`로 설정한다.
  - 최초 조회 실패 시 목록을 비우고 `nextCursor = nil`, `hasMorePages = false`, `errorMessage`를 설정한다.
  - 다음 페이지 조회 실패 시 기존 목록과 `nextCursor`는 유지하고 `errorMessage`를 설정해 재시도 가능하게 한다.
  - 정렬 변경 조회 실패 시 기존 목록, 기존 정렬, 기존 커서를 유지하고 오류 메시지만 설정한다.
  - 조회 성공 시 이전 `errorMessage`를 비운다.
  - 정렬 변경 또는 새 첫 페이지 요청 시 이전 페이지 요청을 취소하거나, 응답의 정렬 기준이 현재 상태와 다르면 무시한다.
- [x] 관심 콘서트 목록 화면 구현
  - `InterestConcertListView`를 추가한다.
  - 시안에 맞춰 뒤로가기, 타이틀, 변경하기 버튼이 있는 상단 영역을 구성한다.
  - `RecommendedConcertGridView`와 같은 3열 그리드 레이아웃을 사용한다.
  - `LivithCard` 카드 매핑은 `title: InterestConcertDisplayText.title(for:)`, `subtitle: InterestConcertDisplayText.dateRange(for:)`, `secondaryText: interestConcert.concert.artist`, `badge: InterestConcertDisplayText.badge(for:)`로 고정한다.
  - 관심 콘서트 카드 탭 시 `HomeCoordinator.showConcertDetail(concertID:)`로 콘서트 상세 화면을 연다.
  - 마지막 카드 노출 시 다음 페이지를 요청하고 로딩 중이면 하단에 `ProgressView`를 표시한다.
- [x] 정렬 필터 UI 구현
  - 우측 상단에 현재 정렬 텍스트와 화살표 아이콘을 표시한다.
  - 팝오버는 기존 `LivithOptionButton` 패턴을 재사용한다.
  - 정렬 선택 시 팝오버를 닫고 Store에 정렬 변경 intent를 전달한다.
- [x] 빈/오류 상태 구현
  - 최초 조회 실패 등으로 목록이 비어 있고 오류 메시지가 있으면 `LivithEmptyView(text: errorMessage)`를 표시한다.
  - `ScrollView` 내부에서 빈 화면 높이를 확보하기 위해 `LivithEmptyView(text: errorMessage).frame(maxWidth: .infinity).containerRelativeFrame(.vertical)` 형태로 적용한다.
  - 기획상 정상 빈 상태는 없으므로 별도 기본 빈 문구는 추가하지 않는다.
- [x] 홈 라우팅 연결
  - `HomeRoute`에 관심 콘서트 목록 route를 추가한다.
  - `HomeCoordinator`에서 관심 콘서트 목록 화면을 생성하고 `hidesBottomBarWhenPushed = true`를 적용한다.
  - `HomeView`의 `HomeInterestConcertSectionView.onTitleTap`에서 관심 콘서트 목록 route로 이동한다.
  - 목록 화면의 변경하기 버튼은 기존 관심 콘서트 검색 화면으로 이동한다.
- [ ] 검증 및 정리
  - 추가/수정한 Store 테스트를 실행한다.
  - HomeFeature 빌드 또는 관련 테스트 타겟 실행으로 컴파일을 확인한다.
  - 작업 완료 후 계획 문서를 `docs/archives/`로 이동한다.

## 영향 범위
- `Projects/HomeFeature/Sources/Home/View/HomeView.swift`
- `Projects/HomeFeature/Sources/Coordinator/HomeRoute.swift`
- `Projects/HomeFeature/Sources/Coordinator/HomeCoordinator.swift`
- `Projects/HomeFeature/Sources/Interest/View/**`
- `Projects/HomeFeature/Sources/Interest/Store/**`
- `Projects/HomeFeature/Tests/**`
- `docs/plans/LIVD-367-interest-concert-list.md`

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 목록 데이터 소스 | 홈 섹션 상태 전달 또는 별도 조회 | 별도 조회 | 전체 관심 콘서트 데이터는 페이징이 필요하고 홈 섹션은 5개 제한 조회이므로 화면 진입 후 독립 조회가 적합하다. |
| 페이징 방식 | 마지막 아이템 `onAppear` 또는 수동 버튼 | 마지막 아이템 `onAppear` | 기존 검색/알림 목록에서 사용하는 패턴과 일관성이 있고 시안에 별도 버튼이 없다. |
| 페이징 요청 cursor | 서버 `nextCursor` 재사용 또는 클라이언트 생성 | 서버 `nextCursor` 재사용 | 서버가 다음 페이지 요청에 필요한 cursor를 응답으로 제공하므로 클라이언트에서 임의로 cursor를 재계산하지 않는다. |
| 카드 UI | 전용 카드 신규 구현 또는 `LivithCard` 재사용 | `LivithCard` 재사용 | 추천 콘서트 그리드와 유사한 레이아웃이며 디자인 시스템 컴포넌트로 충분히 표현 가능하다. |
| 카드 정보 매핑 | 장소/예매 정보/아티스트 중 선택 | 아티스트 표시 | `LivithCard.secondaryText`는 기존 추천 콘서트 그리드와 동일하게 아티스트명을 표시한다. |
| 카드 탭 동작 | 탭 없음 또는 상세 이동 | 상세 이동 | 사용자가 카드에서 콘서트 정보를 더 확인할 수 있도록 기존 홈/추천 그리드와 동일하게 상세 화면으로 이동한다. |
| 정렬 옵션 UI | 신규 컴포넌트 또는 기존 옵션 팝오버 패턴 | 기존 옵션 팝오버 패턴 | 홈 관심 콘서트 섹션과 검색 화면에서 이미 같은 성격의 UI를 사용한다. |
| 정렬 변경 실패 처리 | 기존 목록 유지 또는 빈 오류 화면 표시 | 기존 목록 유지 | 정렬 조회 실패가 기존에 표시 중인 관심 콘서트 목록을 제거할 이유는 없으므로 기존 상태를 보존하고 오류만 표시한다. |
| 페이지 크기 | 20개 또는 12개 | 12개 | 3열 그리드에서 4행 단위로 끊겨 시각적으로 자연스럽고, 한 번에 로드되는 카드 수가 화면 밀도에 적합하다. |
| 오류 빈 화면 | 토스트 또는 `LivithEmptyView` | `LivithEmptyView` | 최초 조회 실패로 표시할 목록이 없을 때 화면 본문에 오류 메시지를 보여달라는 요구사항에 맞다. |
| 빈 화면 높이 처리 | `LivithEmptyView` 자체 수정 또는 호출부 프레임 지정 | 호출부 프레임 지정 | 디자인 시스템 공용 컴포넌트의 전역 동작을 바꾸지 않고, `ScrollView` 내부에서 필요한 화면에만 `containerRelativeFrame(.vertical)`을 적용한다. |
| TDD 적용 | UI 포함 전체 테스트 또는 Store 테스트 중심 | Store 테스트 중심 | 순수 UI 배치는 TDD 규칙상 제외되며, 페이징/정렬/오류 상태는 Store 테스트로 검증한다. |

## 주의 사항
- 관심 콘서트 정상 빈 상태는 기획상 없으므로 임의의 기본 빈 상태 문구를 추가하지 않는다.
- 다음 페이지 조회 실패 시 기존 목록을 지우지 않는다.
- 첫 페이지 조회 시 cursor를 보내지 않는다.
- 다음 페이지 조회 시 서버 응답의 `nextCursor`를 요청 cursor로 그대로 사용한다.
- 정렬 변경 성공 시 이전 정렬의 목록과 커서를 재사용하지 않는다.
- 정렬 변경 실패 시 기존 목록, 기존 정렬, 기존 커서를 유지한다.
- 정렬 변경과 다음 페이지 요청이 겹칠 수 있으므로 이전 요청 취소 또는 stale response 무시 처리를 포함한다.
- 단계별 구현 후 서브에이전트 리뷰가 통과되기 전까지 다음 단계로 넘어가지 않는다.
- 서브에이전트 리뷰 통과 후에는 다음 단계를 자동 진행하지 않고 사용자에게 먼저 보고한다.
- 홈 섹션의 5개 제한 조회 로직은 변경하지 않는다.
- 전체 관심 콘서트 목록 화면의 페이징 크기는 12개로 고정한다.
- 화면 전환은 View에서 직접 처리하지 않고 `HomeCoordinator` route를 통해 연결한다.
- 기존 사용자의 변경 사항이 있는 파일은 되돌리지 않는다.

## 검증 방법
- `HomeFeatureTests`에서 관심 콘서트 목록 Store 테스트를 실행한다.
- HomeFeature 또는 앱 타겟 빌드로 신규 목록 화면과 라우팅 컴파일을 확인한다.
- 시뮬레이터 또는 Preview에서 다음 항목을 수동 확인한다.
  - 홈 관심 콘서트 타이틀 탭 시 목록 화면으로 이동한다.
  - 뒤로가기와 변경하기 버튼이 동작한다.
  - 정렬 팝오버가 열리고 선택 시 목록이 갱신된다.
  - 스크롤 마지막 도달 시 다음 페이지가 추가된다.
  - 최초 조회 실패로 목록이 비어 있으면 `LivithEmptyView`에 오류 메시지가 표시된다.
