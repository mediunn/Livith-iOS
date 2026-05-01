# LIVD-362 관심 콘서트 설정 검색 API 전환

## 배경
- 관심 콘서트 설정 화면은 현재 최초 콘서트 목록을 받은 뒤 로컬 필터링으로 검색 결과를 표시한다.
- 실제 관심 콘서트 검색은 서버 검색 API를 사용해야 하며, 검색어 입력 후 debounce를 적용한 뒤 API를 호출해야 한다.
- 관심 콘서트 검색에서는 진행 중/예정 공연만 노출해야 하므로 검색 API 호출 시 `ONGOING`, `UPCOMING` 상태를 고정으로 전달해야 한다.
- 검색 응답의 일부 표시 필드는 null이 올 수 있어 현재 `FetchFilterSearchResult` DTO와 Mapper의 필수 필드 가정이 과도하다.

## 목표
- 관심 콘서트 설정 화면 검색을 로컬 필터링에서 `SearchRepository.fetchFilterSearchResult` 기반 서버 검색으로 전환한다.
- 검색어 입력 시 300ms debounce 후 검색 API를 호출하고, 검색 결과와 검색 pagination을 화면에 반영한다.
- 검색어를 지우면 이미 받아둔 기본 콘서트 목록으로 복귀한다.
- 검색 결과가 없으면 empty view를 보여주고, 검색 실패 시 빈 화면과 에러 토스트를 보여준다.
- 검색 응답 DTO와 Mapper가 null 표시 필드 때문에 유효한 콘서트를 버리지 않도록 수정한다.

## 작업 항목
- [x] 검색 API DTO와 Mapper를 nullable 응답에 맞게 수정한다.
  - `DTO.Response.FetchFilterSearchResult.FilteredConcert`의 표시 필드 nullable을 반영한다.
  - `id`, `status`, `artist`, `introduction`은 non-null로 유지한다.
  - `SearchMapper`가 nullable 날짜, 포스터, 장소, 티켓 정보 때문에 유효한 콘서트를 버리지 않도록 수정한다.
  - `ConcertMapper`의 `FetchFilterSearchResult.FilteredConcert` mapper도 같은 nullable 정책에 맞춘다.
  - 구현 후 계획 대비 구현 내용을 리뷰받고 `통과` 결과를 확인한 뒤 유저에게 알린다.
- [x] 관심 콘서트 설정 Store 검색 흐름을 서버 검색 API 기반으로 전환한다.
  - `InterestConcertSettingStore`에 `SearchRepository`를 주입한다.
  - 화면 표시 목록 이름을 `filteredConcertList`에서 `displayedConcertList`로 변경한다.
  - 기본 목록 상태와 검색 상태를 Store private property로 분리한다.
  - 검색어 입력 시 원문은 즉시 `state.searchText`에 반영하고, trim한 keyword가 비어 있지 않을 때 300ms debounce 후 검색 API를 호출한다.
  - 관심 콘서트 검색 API 호출 시 `status: [.ongoing, .upcoming]`을 항상 전달한다.
  - 검색 요청 응답 반영 전에 현재 trim keyword와 요청 keyword를 비교해 stale response를 무시한다.
  - 검색어 clear 또는 trim 결과가 빈 문자열이면 검색 task를 취소하고 이미 받아둔 기본 목록으로 복귀한다.
  - 구현 후 계획 대비 구현 내용을 리뷰받고 `통과` 결과를 확인한 뒤 유저에게 알린다.
- [x] 검색 pagination과 실패/empty 상태를 정리한다.
  - 검색어가 없을 때는 기존 `NextToken` 기반 기본 목록 pagination을 사용한다.
  - 검색어가 있을 때는 `SearchResult.cursor`의 `Int?` cursor 기반 검색 pagination을 사용한다.
  - 검색 첫 요청 중에는 로딩 상태를 표시하고 empty view가 먼저 깜빡이지 않도록 한다.
  - 검색 성공 결과가 빈 배열이면 기존 empty view 문구인 `검색 결과가 없어요`를 표시한다.
  - 검색 실패 시 `displayedConcertList`를 비우고 에러 토스트를 표시한다.
  - 구현 후 계획 대비 구현 내용을 리뷰받고 `통과` 결과를 확인한 뒤 유저에게 알린다.
- [x] 테스트를 갱신하고 추가한다.
  - `LivithNetworkTests`에 `FetchFilterSearchResult` nullable 필드 디코딩 테스트를 추가한다.
  - `LivithNetworkTests`에 `SearchEndpoint.fetchFilterSearchResult`의 path, method, query 생성 테스트를 추가한다.
  - `SearchData` mapper 테스트에 nullable 표시 필드가 있어도 콘서트를 drop하지 않는 테스트를 추가한다.
  - `HomeFeatureTests`에 `MockSearchRepository`를 추가하고 DI 등록을 갱신한다.
  - `InterestConcertSettingStoreTests`에 debounce 전 API 미호출, debounce 후 API 호출, 고정 status 전달, 검색 결과 반영, 검색 실패, clear 시 기본 목록 복귀, 검색 다음 페이지 append 테스트를 추가한다.
  - 구현 후 계획 대비 구현 내용을 리뷰받고 `통과` 결과를 확인한 뒤 유저에게 알린다.
- [x] 변경 범위 검증을 수행한다.
  - `HomeFeature`, `LivithNetwork`, `SearchData`, `ConcertData` 컴파일 또는 관련 테스트를 확인한다.
  - `HomeFeatureTests`는 기존 테스트 runner 이슈가 있으므로 빌드/링크 성공과 실제 테스트 실행 성공 여부를 분리해서 기록한다.
  - 검증 중 환경 문제나 테스트 실행 제한이 발생하면 트러블슈팅 문서에 기록한다.
  - 검증 후 계획 대비 구현 내용을 리뷰받고 `통과` 결과를 확인한 뒤 유저에게 알린다.

## 단계별 리뷰 게이트
- 각 작업 항목 구현이 끝나면 해당 구현 내용과 이 계획 문서의 작업 항목, 영향 범위, 기술 결정, 주의 사항을 비교한다.
- 비교 결과를 바탕으로 서브에이전트에게 읽기 전용 리뷰를 요청하고, 리뷰 결과가 `통과`인지 확인한다.
- 리뷰 결과가 `통과`가 아니면 지적 사항을 반영하고 같은 단계의 리뷰를 다시 요청한다.
- `통과`를 받은 단계만 작업 항목 체크박스를 완료 처리한다.
- 각 단계의 `통과` 결과와 주요 구현 내용을 유저에게 알린 뒤 다음 단계로 진행한다.

## 영향 범위
- `Projects/Core/LivithNetwork`
  - `FetchFilterSearchResult` DTO, `SearchEndpoint`, 네트워크 테스트
- `Projects/Data/SearchData`
  - `SearchMapper`, mapper 테스트
- `Projects/Data/ConcertData`
  - `ConcertMapper`
- `Projects/Domain`
  - `SearchRepository`, `SearchResult`, `ConcertStatus` 사용 정책 확인
- `Projects/HomeFeature`
  - `InterestConcertSettingStore`, `InterestConcertSettingView`, `InterestConcertSelectionGridView`, 테스트 더블, Store 테스트

## 기술 결정
- 구현 과정에서 선택이 필요한 사항과 그 결정 근거를 작성한다.

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 관심 콘서트 설정 검색 API | `GET /concerts` 확장 또는 `GET /search/concerts` 재사용 | `SearchRepository.fetchFilterSearchResult` 재사용 | 기존 검색 API가 keyword, status, cursor, size를 지원하므로 새 endpoint 없이 관심 콘서트 검색에 사용할 수 있다. |
| 관심 콘서트 검색 status | 전체 상태 또는 진행/예정 상태 고정 | `[.ongoing, .upcoming]` 고정 | 관심 콘서트 설정 대상은 진행 중/예정 공연이어야 하므로 Store에서 항상 해당 상태만 전달한다. |
| 검색어 입력 처리 | 입력마다 즉시 API 호출 또는 debounce 후 API 호출 | 300ms debounce 후 API 호출 | 타이핑 중 불필요한 요청과 grid 갱신을 줄이고 검색 UX를 안정화한다. |
| 검색어 저장 방식 | trim 값을 TextField 상태에 저장 또는 원문 저장 | 원문 저장, API keyword만 trim | 사용자가 입력한 공백을 UI에서 임의로 제거하지 않고 검색 요청 판단에만 trim 값을 사용한다. |
| 검색어 clear 동작 | 기본 목록 재조회 또는 기존 기본 목록 복귀 | 기존 기본 목록 복귀 | 이미 받아둔 기본 목록이 있으므로 불필요한 API 호출 없이 검색 전 상태로 돌아간다. |
| 검색 실패 표시 | 기본 목록 유지 또는 빈 화면 + 토스트 | 빈 화면 + 에러 토스트 | 검색어가 남아 있는 상태에서 기본 목록을 보여주면 검색 결과처럼 오해할 수 있으므로 실패 상태를 명확히 보여준다. |
| 검색 pagination cursor | JSON 문자열 cursor 또는 `Int?` cursor | `Int?` cursor | develop 병합 후 검색 API와 `SearchResult`가 `Int?` cursor를 사용한다. |
| 검색 응답 nullable 정책 | 모든 표시 필드 필수 또는 표시 필드 optional | 표시 필드 optional | 관심 콘서트 검색 응답에서 날짜, 포스터, 장소, 티켓 정보 등이 null일 수 있으므로 해당 필드 때문에 항목 전체를 drop하지 않는다. |

## 주의 사항
- 검색 API 호출 시 추천 키워드 API는 사용하지 않는다.
- 검색 API 응답의 `status`, `artist`, `introduction`, `id`는 non-null로 유지한다.
- 검색 응답의 optional 날짜와 포스터 URL은 UI 표시 정책에 맞춰 nil을 허용한다.
- 기본 목록의 `NextToken`과 검색 목록의 `Int?` cursor를 섞지 않는다.
- 검색 task 취소와 stale response 방지를 함께 처리해 이전 검색 결과가 새 검색어 화면을 덮어쓰지 않게 한다.
- `displayedConcertList`는 View 렌더링용 상태로만 사용하고, 기본 목록과 검색 cursor 같은 내부 구현 값은 Store private property로 관리한다.
- Repository 계층의 새 테스트는 현재 범위에서 추가하지 않고, HomeFeature Store 테스트와 Mapper/Network 테스트로 보호한다.

## 검증 방법
- `tuist build HomeFeature`
- `tuist build SearchData`
- `tuist build ConcertData`
- `tuist test LivithNetwork` 또는 생성된 Xcode scheme 기준 `LivithNetworkTests` 실행
- `tuist test SearchData` 또는 생성된 Xcode scheme 기준 `SearchDataTests` 실행
- `tuist test HomeFeature` 또는 생성된 Xcode scheme 기준 `HomeFeatureTests` 실행
- `git diff --check`
- 테스트/빌드 실행이 환경 제약으로 실패하면 실패 명령, 오류 요약, 미검증 범위를 최종 보고와 트러블슈팅 문서에 남긴다.
