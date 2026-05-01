# LIVD-362 관심 콘서트 설정 UI 및 API 반영

## 배경
- 관심 콘서트 설정/변경 화면을 기존 단일 콘서트 검색 UI에서 다중 콘서트 선택 UI로 교체한다.
- 서버 API가 단일 관심 콘서트 설정에서 다중 관심 콘서트 설정/수정 구조로 변경되었다.
- 새 설정 UI는 별도 콘서트 목록 조회 API를 사용해 페이지네이션 목록을 표시해야 한다.

## 목표
- 홈, 알림, 딥링크에서 진입하는 관심 콘서트 설정 흐름을 새 다중 선택 UI로 연결한다.
- `GET /concerts` 기반 콘서트 목록 조회 API와 `PUT /users/interest-concerts` 기반 관심 콘서트 설정/수정 API를 앱 구조에 반영한다.
- 기존 관심 콘서트가 있는 경우 변경 화면에서 기존 선택값을 유지하고, 선택 변경 후 서버에 반영한다.
- 변경된 DTO와 Store 동작을 테스트로 보호하고, Repository 계층은 컴파일 확인으로 검증한다.

## 작업 항목
- [x] API 스펙에 맞춰 콘서트 목록 조회 모델을 수정한다.
  - `FetchConcertList` DTO의 optional 필드와 optional cursor를 문서 스펙에 맞춘다.
  - Domain에 목록 조회 결과를 표현하는 공통 모델을 `Projects/Domain/Sources/Entity/List/ListResult.swift`에 작성한다.
  - 공통 모델 이름은 `ListResult<Item>`와 `NextToken`을 사용하고, `NextToken`은 `ListResult.swift` 안에서 `MARK`로 구분한다.
  - `ListResult`는 `items`와 `nextToken`만 노출하고, `nextToken`의 구체 타입은 Domain과 Presentation에서 알 수 없도록 한다.
  - 콘서트 목록 조회 결과는 `ListResult<Concert>`로 반환하도록 Repository 반환 타입을 정리한다.
  - Data 레이어에서만 API cursor 값을 `NextToken` 구현체로 구체화하고, 구체 토큰은 `Projects/Data/ConcertData/Sources/Model/` 아래에 둔다.
  - Data 레이어는 다음 요청 시 전달받은 `NextToken`을 구체 토큰으로 변환해 API cursor로 사용한다.
  - Mapper가 optional 날짜, 포스터, 티켓 정보 때문에 유효한 콘서트를 버리지 않도록 수정한다.
  - 구현 후 계획 대비 구현 내용을 리뷰받고 `통과` 결과를 확인한 뒤 유저에게 알린다.
- [x] API 스펙에 맞춰 관심 콘서트 설정/수정 API를 교체한다.
  - `PUT /users/interest-concerts` endpoint를 추가하거나 기존 단일 설정 endpoint를 대체한다.
  - 요청 body를 `concertIds` 배열로 변경한다.
  - 응답의 `[Concert]?`를 Domain의 `[Concert]`로 매핑하고 `data: null`은 빈 목록으로 처리한다.
  - 구현 후 계획 대비 구현 내용을 리뷰받고 `통과` 결과를 확인한 뒤 유저에게 알린다.
- [x] Repository 인터페이스와 구현체를 다중 관심 콘서트 기준으로 갱신한다.
  - 기존 단일 `updateInterestedConcert(_:)` 흐름은 상세 화면 영향 방지를 위해 유지한다.
  - 다중 ID 설정 API용 별도 Repository 메서드를 추가한다.
  - 관련 mock repository와 테스트 더블은 컴파일을 위해 필요한 범위만 갱신한다.
  - 구현 후 계획 대비 구현 내용을 리뷰받고 `통과` 결과를 확인한 뒤 유저에게 알린다.
- [x] 관심 콘서트 조회 구조를 `ListResult<InterestConcert>` 기반으로 리팩터링한다.
  - `InterestConcertPage`와 `InterestConcertPageCursor`를 Domain 노출 구조에서 제거한다.
  - `InterestConcertListQuery`를 `InterestConcertListFilter`로 교체한다.
  - `InterestConcertListFilter`는 `sort`, `limit`, `nextToken`을 optional로 가진다.
  - 전체 조회는 `InterestConcertListFilter.all`로 표현하고, 이 경우 Data 레이어는 query parameter를 모두 생략한다.
  - 홈 섹션 조회는 `InterestConcertListFilter.homeSection(sort:)`로 표현한다.
  - 페이지 조회는 `InterestConcertListFilter.page(sort:limit:nextToken:)`로 표현한다.
  - 관심 콘서트 조회 결과는 `ListResult<InterestConcert>`로 반환한다.
  - Data 레이어에만 관심 콘서트 cursor 구체 타입을 두고, Domain과 Presentation에는 `NextToken`만 노출한다.
  - 기존 홈/관심 콘서트 목록/테스트 더블 사용처를 `items`와 private `nextToken` 기반으로 갱신한다.
  - Repository 테스트는 작성하거나 실행하지 않는다.
  - 구현 후 계획 대비 구현 내용을 리뷰받고 `통과` 결과를 확인한 뒤 유저에게 알린다.
- [x] 새 관심 콘서트 설정 UI Store를 실제 데이터와 연결한다.
  - `InterestConcertSettingStore`의 mock concert list를 제거한다.
  - 초기 콘서트 목록 조회, 다음 페이지 조회, 선택/해제, 검색 포커스, CTA 활성화, 제출 성공/실패 상태를 구현한다.
  - update 모드에서는 기존 관심 콘서트 ID 목록을 초기 선택값으로 사용한다.
  - update 모드에서는 `UserRepository.fetchInterestedConcertList(filter: .all)`로 기존 관심 콘서트 전체 목록을 조회한다.
  - `State`에는 View 렌더링과 View 이벤트 판단에 필요한 값만 둔다.
  - 원본 목록, 초기 선택 기준값, `NextToken` 같은 내부 구현 값은 Store private property로 관리한다.
  - `@MainActor` Store 내부 비동기 작업에서 `Task { @MainActor in ... }` 중복 지정은 사용하지 않는다.
  - 구현 후 계획 대비 구현 내용을 리뷰받고 `통과` 결과를 확인한 뒤 유저에게 알린다.
- [x] 새 관심 콘서트 설정 UI를 실제 화면 흐름에 연결한다.
  - `InterestConcertSettingDraftView`와 `Draft` 디렉터리 네이밍을 제거하고 정식 관심 콘서트 설정 화면으로 승격한다.
  - 정식 화면 타입명은 `InterestConcertSettingView`를 사용한다.
  - `HomeRoute.interestConcertSetting(mode:)`를 추가하고 새 화면을 Coordinator에서 생성한다.
  - `InterestConcertSettingView`의 뒤로가기와 CTA를 Coordinator 및 Store 액션에 연결한다.
  - 홈 빈 상태의 설정하기, 홈 관심 콘서트 섹션의 변경하기, 알림 관심 설정, 딥링크 관심 설정 진입점을 새 화면으로 교체한다.
  - 알림 관심 설정과 딥링크 관심 설정 진입은 기존 선택값을 유지할 수 있도록 update 모드로 연결한다.
  - 설정 완료 후 성공 토스트를 표시하고 홈으로 복귀한다.
  - 콘서트 목록 grid의 다음 페이지 로딩 트리거와 로딩 표시를 연결한다.
  - 구현 후 계획 대비 구현 내용을 리뷰받고 `통과` 결과를 확인한 뒤 유저에게 알린다.
- [x] 기존 단일 관심 콘서트 검색 흐름의 처리 방침을 정리한다.
  - `InterestConcertSearchView`와 `InterestConcertSearchStore`를 제거한다.
  - 단일 검색 흐름의 완료 화면인 `InterestConcertCompleteView`를 제거한다.
  - 단일 검색 흐름 전용 subview인 `ConcertGridView`, `SearchResultGridView`, `RecommendedKeywordListView`를 제거한다.
  - `HomeRoute.interestConcertSearch`와 `HomeRoute.interestConcertComplete`를 제거한다.
  - 콘서트 상세 화면 영향 방지를 위해 기존 단일 관심 콘서트 Repository API 자체는 유지한다.
  - 구현 후 계획 대비 구현 내용을 리뷰받고 `통과` 결과를 확인한 뒤 유저에게 알린다.
- [x] 테스트를 갱신하고 추가한다.
  - `LivithNetworkTests`에 새 endpoint path, method, body, optional response 디코딩 테스트를 추가한다.
  - `HomeFeatureTests`에 설정 Store의 조회, 페이지네이션, 선택 변경, CTA 활성화, 제출 성공/실패 테스트를 추가한다.
  - Repository 계층은 현재 테스트하기 좋은 구조가 아니므로 테스트 작성 및 실행 대상에서 제외한다.
  - 구현 후 계획 대비 구현 내용을 리뷰받고 `통과` 결과를 확인한 뒤 유저에게 알린다.
- [x] 변경 범위 검증을 수행한다.
  - Repository 테스트는 실행하지 않는다.
  - 영향 범위의 컴파일 확인과 Store/UI 중심 테스트를 실행하고 실패를 수정한다.
  - 빌드 또는 Store/UI 테스트 실행이 환경 문제로 불가능하면 원인과 미검증 범위를 기록한다.
  - 검증 후 계획 대비 구현 내용을 리뷰받고 `통과` 결과를 확인한 뒤 유저에게 알린다.

## 단계별 리뷰 게이트
- 각 작업 항목 구현이 끝나면 해당 구현 내용과 이 계획 문서의 작업 항목, 영향 범위, 기술 결정, 주의 사항을 비교한다.
- 비교 결과를 바탕으로 리뷰를 요청하고, 리뷰 결과가 `통과`인지 확인한다.
- 리뷰 결과가 `통과`가 아니면 지적 사항을 반영하고 같은 단계의 리뷰를 다시 요청한다.
- `통과`를 받은 단계만 작업 항목 체크박스를 완료 처리한다.
- 각 단계의 `통과` 결과와 주요 구현 내용을 유저에게 알린 뒤 다음 단계로 진행한다.

## 영향 범위
- `Projects/Core/LivithNetwork`
  - `SearchEndpoint`, `HomeEndpoint`, 관심 콘서트 관련 DTO, 콘서트 목록 DTO, 네트워크 테스트
- `Projects/Domain`
  - `ConcertRepository`, `UserRepository`, 공통 목록 결과 모델, 관심 콘서트 설정 반환 모델
- `Projects/Data/ConcertData`
  - `ConcertRepositoryImpl`, `ConcertMapper`
- `Projects/Data/UserData`
  - `UserRepositoryImpl`, `UserMapper`, mock repository
- `Projects/HomeFeature`
  - 관심 콘서트 설정 Store/View, Coordinator route, 홈 관심 콘서트 진입점, 테스트 더블과 Store 테스트
- `Projects/ConcertFeature`
  - 콘서트 상세의 관심 콘서트 설정 버튼은 이번 새 API 연동 범위에서 제외하고 기존 API 흐름을 유지
- `Projects/Shared/NicknameEditFeature/Tests`
  - `UserRepository` mock 구현체 시그니처 변경 영향

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 목록 조회 결과 모델 | 도메인별 page 모델 또는 공통 목록 결과 모델 | `ListResult<Item>` 공통 모델 | 콘서트 외 다른 목록에서도 같은 구조가 반복될 수 있어 공통 모델로 중복과 API 용어 노출을 줄인다. |
| 다음 페이지 식별값 명칭 | `cursor`, `pageToken`, `nextToken` | `nextToken` | 화면은 값을 해석하지 않고 다음 요청에 그대로 넘기는 토큰으로만 알면 되므로 쉬운 용어를 사용한다. |
| 다음 페이지 식별값 구체 타입 | Domain에 `Int` 노출 또는 `NextToken` 프로토콜로 은닉 | `NextToken` 프로토콜 | API cursor 구체 타입은 Data 레이어 세부사항이므로 Domain과 Presentation에서 숨긴다. |
| 관심 콘서트 조회 조건 명칭 | `Query`, `Request`, `Options`, `Filter` | `InterestConcertListFilter` | HTTP query/request 용어를 피하고 도메인 목록 조회 조건이라는 의미를 사용한다. |
| 관심 콘서트 전체 조회 표현 | nil query 직접 전달 또는 명명된 값 | `InterestConcertListFilter.all` | 설정 변경 화면에서 기존 관심 콘서트 전체 조회 의도를 명확히 표현한다. |
| 관심 콘서트 설정 API 모델 | 단일 `concertID` 유지 또는 `concertIDList`로 교체 | `concertIDList`로 교체 | 서버 API가 다중 선택 배열을 필수 요청값으로 받도록 변경되었다. |
| `concertIds` 원소 타입 | `[Int]` 또는 `[String]` | `[Int]` | 유저 확인에 따라 콘서트 ID 정수 배열로 전송한다. |
| 관심 콘서트 전체 삭제 | 별도 DELETE 유지 또는 `concertIds: []` PUT 사용 | 기존 API와 별도로 작성 | 기존 API는 유지하고, 새 설정/수정 API는 별도 메서드로 추가한다. |
| 설정 완료 UX | 완료 화면 이동 또는 성공 토스트 후 홈 복귀 | 성공 토스트 후 홈 복귀 | 유저 확인에 따라 설정 완료 화면은 제거하고 성공 토스트를 띄운 뒤 홈으로 복귀한다. 토스트는 window 기반이므로 화면 복귀 후에도 유지된다. |
| 기존 `InterestConcertSearchView` 처리 | 제거 또는 보류 | 제거 | 유저 확인에 따라 기존 단일 검색 흐름은 새 다중 선택 설정 화면으로 완전히 교체한다. |
| 관심 설정 알림/딥링크 진입 모드 | initialSetup 또는 update | update | 알림/딥링크 진입 시 기존 관심 콘서트가 있을 수 있으므로 기존 선택값을 유지하는 update 모드로 진입한다. |
| 상세 화면 관심 설정 | 현재 콘서트 1개만 PUT 또는 새 설정 화면 이동 또는 제외 | 이번 새 API 연동 범위에서 제외 | 유저 확인에 따라 콘서트 상세 화면의 관심 설정 버튼은 기존 API 흐름을 유지하고 새 API 변경 대상에서 제외한다. |

## 주의 사항
- `concertIds` 요청 배열은 유저 확인에 따라 `[Int]`로 전송한다.
- 목록 조회의 다음 페이지 식별값은 Domain에서 `cursor`라는 이름과 구체 타입을 노출하지 않는다.
- `NextToken` 구현체는 Data 레이어 내부 타입으로 두고, Presentation은 존재 여부와 그대로 전달하는 역할만 수행한다.
- 관심 콘서트 조회의 HTTP query parameter는 Domain에 노출하지 않고, Domain은 `InterestConcertListFilter`만 다룬다.
- `InterestConcertListFilter.all`은 서버에 sort, size, cursor 관련 query parameter를 보내지 않는 전체 조회를 의미한다.
- `GET /concerts`는 인증이 필요하지 않은 API로 문서화되어 있으므로 기존 `SearchEndpoint.fetchConcertList`의 `requiresInterceptor = false`와 맞는지 유지한다.
- `PUT /users/interest-concerts`는 인증이 필요한 API이므로 interceptor가 필요하다.
- 콘서트 응답의 `status`, `artist`, `introduction`, `id`는 필수이고 나머지 표시 필드는 optional일 수 있다.
- optional 날짜와 포스터 URL은 UI 표시 정책에 맞춰 nil을 허용해야 하며 Mapper에서 항목 전체를 과도하게 drop하지 않는다.
- 기존 단일 관심 콘서트 API는 상세 화면 영향 방지를 위해 유지하고, 새 다중 설정/수정 API는 별도 메서드로 추가한다.
- 기존 단일 검색 기반 관심 콘서트 설정 화면과 완료 화면은 제거하고, 새 다중 선택 설정 화면만 진입점으로 사용한다.
- `Draft` 네이밍은 구현 완료 전 정식 화면 네이밍으로 제거한다.
- 알림과 딥링크의 관심 설정 진입은 update 모드로 연결한다.
- 설정 성공 시 성공 토스트를 표시한 뒤 홈으로 복귀한다.
- Repository 계층은 현재 테스트하기 좋은 구조가 아니므로 Repository 테스트를 새로 작성하거나 실행하지 않는다.
- 보안 규칙에 따라 인증 토큰 값은 코드, 테스트, 로그, 문서에 원문으로 남기지 않는다.

## 검증 방법
- `tuist test HomeFeature` 또는 생성된 Xcode scheme 기준 `HomeFeatureTests`를 실행한다.
- `tuist test LivithNetwork` 또는 생성된 Xcode scheme 기준 `LivithNetworkTests`를 실행한다.
- Repository 테스트는 실행하지 않는다.
- 필요한 경우 관련 feature build를 실행해 `HomeFeature`, `ConcertFeature`, `UserData`, `ConcertData`, `LivithNetwork`의 컴파일을 확인한다.
- 테스트/빌드 실행이 환경 제약으로 실패하면 실패 명령, 오류 요약, 미검증 범위를 최종 보고에 남긴다.
