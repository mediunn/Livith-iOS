# LIVD-364 관심 콘서트 목록 API 및 콘서트 도메인 모델 수정

## 배경
- 관심 콘서트 조회 API가 단일 콘서트 조회에서 목록 조회 API로 변경되었다.
- 새 API는 `sort`, `size`, `cursorDate`, `cursorId` 쿼리 파라미터를 사용한다.
- 응답은 `data.data` 목록과 `data.cursor`를 포함하며, 관심 콘서트가 없으면 `data: null`을 반환한다.
- 관심 콘서트 응답의 기존 콘서트 필드 중 일부가 nullable로 변경되었다.
- `preSaleDate`, `generalSaleDate`는 관심 콘서트 목록에서만 필요한 예매 일정 필드다.

## 목표
- 변경된 관심 콘서트 목록 조회 API를 iOS 네트워크, 데이터, 도메인, 화면 흐름에 반영한다.
- `Concert` 도메인 모델의 공통 nullable 필드를 Optional로 변경한다.
- 관심 콘서트 전용 예매 일정 필드는 `Concert`에 직접 넣지 않고 별도 관심 콘서트 도메인 모델로 분리한다.
- 서버가 내려주는 cursor는 배열의 마지막 항목에서 재계산하지 않고 관심 콘서트 목록 조회 결과의 페이지네이션 메타데이터로 유지한다.
- 관심 콘서트 목록 조회 조건은 Domain에서 API request가 아닌 `InterestConcertListQuery` 값 객체로 표현한다.
- 콘서트 nullable 필드의 표시 fallback은 새 Shared 모듈 `DisplaySupport`에서 공통 관리한다.
- 관심 콘서트 섹션의 표시 문구는 일반 콘서트 표시 정책과 분리해 `InterestConcertDisplayText`에서 별도 관리한다.
- 기존 단일 관심 콘서트 의존 흐름을 목록 기반 흐름으로 전환한다.
- App 시작 시점 관심 콘서트 preload를 제거하고, 홈 화면 진입 후 `HomeStore`가 유저 정보와 관심 콘서트 목록을 구조적 동시성으로 함께 조회한다.
- 변경 대상 동작은 테스트를 먼저 작성하고 `red -> verify red -> green -> verify green -> refactor` 순서로 진행한다.
- 각 단계 구현 완료 후 계획 문서를 기준으로 서브에이전트 리뷰를 받고, `통과` 판정 전에는 사용자에게 단계 완료를 보고하지 않는다.

## 단계별 완료 기준
- 각 단계의 구현이 끝나면 해당 단계 영향 범위의 테스트 또는 빌드를 실행한다.
- 새 DTO, Endpoint case, Repository 시그니처가 없어 테스트가 컴파일되지 않으면 동작 구현 없는 최소 선언만 먼저 추가한 뒤 테스트를 실행해 기대한 런타임 실패를 확인한다.
- 검증 후 서브에이전트에게 이 계획 문서를 기준으로 구현 내용을 리뷰 요청한다.
- 서브에이전트가 지적한 사항은 모두 수정하고 관련 테스트 또는 빌드를 다시 실행한다.
- 서브에이전트가 명시적으로 `통과` 판정을 내릴 때까지 수정, 재검증, 재리뷰를 반복한다.
- `통과` 판정 후에만 사용자에게 해당 단계 완료를 보고한다.
- 리뷰 중 계획 변경이 필요하면 먼저 이 문서를 수정하고 사용자 확인을 받은 뒤 진행한다.

## 작업 항목
- [x] 1단계: API 계약 테스트 추가
  - `LivithNetwork`에 관심 콘서트 목록 응답 DTO 디코딩 테스트를 추가한다.
  - `data.data`, `data.cursor`, `data: null` 응답을 검증한다.
  - optional 필드 누락 또는 null 응답이 디코딩되는지 검증한다.
  - `HomeEndpoint`의 query 생성 보호 테스트를 추가한다.
- [x] 2단계: DTO 및 Endpoint 변경
  - `DTO.Request.FetchInterestConcertList`를 추가해 API query 파라미터를 표현한다.
  - `DTO.Response.FetchUserInterestConcert`를 목록 응답 구조로 변경한다.
  - `preSaleDate`, `generalSaleDate` 필드를 추가한다.
  - 문서상 필수 X인 필드를 Optional로 변경한다.
  - `sort`는 `CONCERT`, `TICKETING`만 허용하고, 기본값은 `CONCERT`로 둔다.
  - `pageSize` 기본값은 20으로 두고, API query 전송 시 `size`로 변환한다.
  - `cursorDate`, `cursorId`는 `InterestConcertPage.nextCursor` 값이 있을 때만 query에 포함한다.
  - 첫 페이지 요청에서는 cursor query를 생략한다.
  - `HomeEndpoint.fetchInterestedConcert`를 `fetchInterestedConcertList(DTO.Request.FetchInterestConcertList)` 형태로 변경한다.
  - 경로를 `/users/interest-concerts`로 변경한다.
  - query 파라미터를 기존 `NetworkEndpoint.query`로 전달한다.
- [x] 3단계: 도메인 모델 변경
  - `Concert`의 공통 nullable 필드를 Optional로 변경한다.
  - `InterestConcert`, `InterestConcertTicketingSchedule`, `InterestConcertPage`, `InterestConcertPageCursor`, `InterestConcertListQuery`, `InterestConcertSort` 도메인 모델을 추가한다.
  - `preSaleDate`, `generalSaleDate`는 `Concert`가 아닌 `InterestConcertTicketingSchedule`에 둔다.
  - `InterestConcertPageCursor`는 핵심 엔티티가 아닌 `InterestConcertPage`의 페이지네이션 메타데이터로 둔다.
  - `InterestConcertListQuery`는 API request가 아닌 관심 콘서트 목록 조회 조건 값 객체로 둔다.
- [x] 4단계: DisplaySupport 모듈 추가
  - `Projects/Shared/DisplaySupport` 모듈을 추가한다.
  - `SharedModule`에 `displaySupport` case를 추가한다.
  - `TargetID.sharedSourcePath`에 `DisplaySupport/Sources/**` 매핑을 추가한다.
  - `Projects/Shared/Project.swift`에 `DisplaySupport` framework target을 추가한다.
  - `DisplaySupport`는 향후 다른 도메인의 표시 정책도 수용할 수 있도록 콘서트 전용 모듈명으로 만들지 않는다.
  - `DisplaySupport`는 `Domain`, `LivithFoundation`에만 의존한다.
  - `DisplaySupport`는 `SwiftUI`, `LivithDesignSystem`, Feature 모듈에 의존하지 않는다.
  - `ConcertDisplayText`에서 콘서트 표시용 fallback 문구와 날짜 표시 정책을 제공한다.
  - 기존 `LivithFoundation.DateFormatter.formatDateRange(from:to:)`는 이동하지 않고 `ConcertDisplayText`에서 감싸서 사용한다.
  - Home, Search, Concert Feature가 `DisplaySupport`에 의존하도록 Project 설정을 갱신한다.
  - `DisplaySupportTests` unit test target을 추가한다.
  - 기존 `HomeFeatureTests`의 `ConcertDisplayText` fallback 정책 단위 테스트는 `DisplaySupportTests`로 이동한다.
  - Search, Concert Feature는 테스트 타겟이 없으므로 각 Feature 빌드로 `DisplaySupport` import와 적용 누락을 검증한다.
- [x] 5단계: Mapper 변경
  - `UserMapper`가 새 DTO를 `InterestConcertPage`로 변환하도록 변경한다.
  - `preSaleDate`, `generalSaleDate`는 ISO8601 date-time으로 파싱한다.
  - `startDate`, `endDate`는 값이 있을 때만 `Date`로 변환한다.
  - `preSaleDate`, `generalSaleDate` 파싱 실패는 항목 제외가 아니라 해당 예매 일정만 nil로 처리한다.
  - 필수 필드인 `id`, `status`, `artist`, `introduction`이 유효하지 않으면 해당 항목을 제외하거나 invalid response 처리한다.
- [x] 6단계: Repository 변경 및 관심 콘서트 캐시 제거
  - `UserRepository.fetchInterestedConcert()`를 `InterestConcertListQuery`를 받는 목록 조회 메서드로 변경한다.
  - 다음 페이지 요청은 배열의 마지막 항목에서 cursor를 재계산하지 않고 `InterestConcertPage.nextCursor`를 사용한다.
  - `UserRepositoryImpl`에서 `InterestConcertListQuery`를 `DTO.Request.FetchInterestConcertList`로 변환한다.
  - `UserRepositoryImpl`에서 새 Endpoint와 Mapper를 사용한다.
  - `NetworkService`가 관심 콘서트 목록 `data: null` 응답을 `NetworkError.noData`로 반환하면 `UserRepositoryImpl`에서 빈 `InterestConcertPage`로 변환한다.
  - 관심 콘서트 목록은 캐시하지 않고 매번 네트워크에서 조회한다.
  - 기존 `InterestConcertCache`와 관심 콘서트용 `UserDefaultsStorage` 키를 제거한다.
  - 관심 콘서트가 없을 때 `data: null`은 빈 목록 페이지로 변환한다.
- [x] 7단계: Presentation 변경
  - `AppRootView`의 시작 시점 관심 콘서트 preload 호출을 제거한다.
  - `HomeState.interestedConcert`를 목록 기반 상태로 변경한다.
  - `HomeStore`는 유저 정보 조회 성공 후 관심 콘서트를 순차 조회하지 않는다.
  - `HomeStore` 초기 조회는 하나의 Task 안에서 `async let` 기반 구조적 동시성으로 `fetchUser()`와 `fetchInterestConcertList(query:)`를 동시에 실행한다.
  - 두 요청 결과는 `Result`로 분리 수집해 관심 콘서트 목록 실패가 유저 정보 실패처럼 전파되지 않도록 한다.
  - 유저 정보 조회 실패만 홈 초기 데이터 실패로 처리하고, 관심 콘서트 목록 조회 실패 또는 `data: null`은 빈 목록 페이지로 처리한다.
  - 홈 섹션 및 추천 콘서트 조회는 유저 정보의 `hasPreferences` 반영 이후 기존 흐름을 유지한다.
  - `HomeInterestConcertSectionView`가 관심 콘서트 목록을 표시하도록 변경한다.
  - Optional 날짜, 포스터, 제목, 장소에 대한 UI fallback은 `ConcertDisplayText`를 통해 적용한다.
  - `ConcertStore`의 현재 콘서트 관심 여부 판단 로직은 구현 전에 서버 계약 또는 UI 상태 정책을 확인한 뒤 새 목록 구조에 맞게 변경한다.
- [ ] 8단계: 관심 콘서트 표시 정책 분리 및 테스트 타겟 추가
  - `SharedModule`에 `displaySupportTests` case를 추가한다.
  - `TargetID.sharedSourcePath`에 `DisplaySupport/Tests/**` 매핑을 추가한다.
  - `Projects/Shared/Project.swift`에 `DisplaySupportTests` unit test target을 추가한다.
  - 기존 `Projects/HomeFeature/Tests/ConcertDisplayTextTests.swift`를 `Projects/Shared/DisplaySupport/Tests/ConcertDisplayTextTests.swift`로 이동한다.
  - 관심 콘서트 전용 표시 정책은 `InterestConcertDisplayText`로 분리하고 `DisplaySupportTests` 단위 테스트로 검증한다.
  - `HomeInterestConcertSectionView`는 `InterestConcertDisplayText`를 사용하고, 관심 콘서트 표시 문구 계산 helper를 직접 보유하지 않는다.
  - 영향받는 테스트와 빌드를 실행한다.

## 영향 범위
- `Projects/Core/LivithNetwork/Sources/DTO/HomeFeature/FetchUserInterestConcert.swift`
- `Projects/Core/LivithNetwork/Sources/Endpoint/HomeEndpoint.swift`
- `Projects/Core/LivithNetwork/Tests/HomeFeatureDTOTests.swift`
- `Tuist/ProjectDescriptionHelpers/Module/Module+Constant.swift`
- `Tuist/ProjectDescriptionHelpers/Module/Module+TargetID.swift`
- `Projects/Shared/Project.swift`
- `Projects/Shared/DisplaySupport/Sources/ConcertDisplayText.swift`
- `Projects/Shared/DisplaySupport/Sources/InterestConcertDisplayText.swift`
- `Projects/Shared/DisplaySupport/Tests/InterestConcertDisplayTextTests.swift`
- `Projects/Domain/Project.swift`
- `Projects/Domain/Sources/Entity/Concert/Concert.swift`
- `Projects/Domain/Sources/Entity/Concert/*`
- `Projects/Domain/Tests/ConcertDomainModelTests.swift`
- `Projects/Domain/Sources/Repository/UserRepository.swift`
- `Projects/Data/ConcertData/Sources/Mapper/ConcertMapper.swift`
- `Projects/Data/ConcertData/Tests/ConcertMapperTests.swift`
- `Projects/Data/SearchData/Sources/Mapper/SearchMapper.swift`
- `Projects/Data/SearchData/Tests/SearchMapperTests.swift`
- `Projects/Data/UserData/Sources/Mapper/UserMapper.swift`
- `Projects/Data/UserData/Sources/Repository/UserRepositoryImpl.swift`
- `Projects/Data/UserData/Sources/DiskCache/InterestConcertCache.swift`
- `Projects/Data/UserData/Sources/Mock/MockUserRepository.swift`
- `Projects/Data/UserData/Tests/UserMapperTests.swift`
- `Projects/Shared/NicknameEditFeature/Tests/NicknameEditStoreTests.swift`
- `Projects/HomeFeature/Project.swift`
- `Projects/App/Sources/View/AppRootView.swift`
- `Projects/HomeFeature/Sources/Home/Store/HomeStore.swift`
- `Projects/HomeFeature/Sources/Home/View/Subview/InterestConcertSection/HomeInterestConcertSectionView.swift`
- `Projects/HomeFeature/Sources/Home/View/Subview/ConcertContentSection/ConcertSectionView.swift`
- `Projects/HomeFeature/Sources/Home/View/Subview/ConcertContentSection/RecommendedConcertSectionView.swift`
- `Projects/HomeFeature/Sources/Home/View/Subview/ConcertContentSection/RecommendedConcertGridView.swift`
- `Projects/HomeFeature/Sources/Interest/View/Subview/ConcertGridView.swift`
- `Projects/HomeFeature/Sources/Interest/View/Subview/SearchResultGridView.swift`
- `Projects/HomeFeature/Sources/Interest/View/Draft/Subview/InterestConcertSelectionGridView.swift`
- `Projects/HomeFeature/Sources/Interest/View/Draft/Subview/InterestConcertSelectionBottomSectionView.swift`
- `Projects/HomeFeature/Sources/Interest/Store/InterestConcertSearchStore.swift`
- `Projects/HomeFeature/Tests/HomeStoreTests.swift`
- `Projects/SearchFeature/Project.swift`
- `Projects/SearchFeature/Sources/Search/View/SearchView.swift`
- `Projects/SearchFeature/Sources/Explore/View/Subview/ConcertSectionView.swift`
- `Projects/SearchFeature/Sources/Extension/Concert+Extension.swift`
- `Projects/ConcertFeature/Project.swift`
- `Projects/ConcertFeature/Sources/Store/ConcertStore.swift`
- `Projects/ConcertFeature/Sources/View/ConcertView.swift`
- 관련 Mock, Preview, 테스트 생성부

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 관심 콘서트 전용 필드 위치 | `Concert` 직접 추가 또는 별도 모델 분리 | 별도 모델 분리 | `preSaleDate`, `generalSaleDate`는 관심 콘서트 목록에서만 의미가 있다. |
| 공통 nullable 필드 | 기존 non-optional 유지 또는 Optional 변경 | Optional 변경 | 새 API에서 공통 콘서트 필드가 nullable이므로 Mapper가 항목 전체를 버리지 않도록 한다. |
| 관심 콘서트 없음 처리 | `nil` 반환 또는 빈 목록 반환 | 빈 목록 반환 | Presentation이 관심 콘서트 없음을 빈 목록으로 다루면 분기와 테스트가 단순해진다. |
| 조회 조건 모델링 | 함수 파라미터 나열, Domain request, Domain query | Domain query | `Request` 명칭은 API 계약에 가깝기 때문에 Domain에서는 조회 조건 값 객체로 표현한다. |
| DTO request 위치 | Domain, Data/Network | Data/Network | `cursorDate`, `cursorId`, `size` 같은 API 파라미터명은 DTO request와 Endpoint에서만 다룬다. |
| nullable 표시 fallback 위치 | Domain computed property, Feature별 helper, Shared helper 모듈 | Shared helper 모듈 | UI 카피와 날짜 표시 정책을 Domain에 넣지 않고 Home/Search/Concert에서 공통 재사용한다. |
| 표시 헬퍼 모듈명 | `ConcertDisplaySupport`, `DisplaySupport` | `DisplaySupport` | 추후 다른 도메인의 표시 정책도 같은 모듈에서 확장할 수 있게 한다. |
| 표시 헬퍼 의존성 | Feature 의존, DesignSystem 의존, Domain/Foundation 의존 | Domain/LivithFoundation 의존 | 표시 문구와 날짜 포맷만 담당하고 UI 타입 의존을 만들지 않는다. |
| DisplaySupport 테스트 타겟 | 즉시 추가 또는 후속 추가 | 즉시 추가 | 관심 콘서트 전용 표시 정책을 `DisplaySupport`로 분리하므로 같은 모듈의 테스트 타겟에서 정책을 고정한다. |
| 관심 콘서트 표시 정책 위치 | `ConcertDisplayText` 통합 또는 별도 타입 분리 | 별도 타입 분리 | 일반 콘서트 도메인 표시 정책과 관심 콘서트 맥락의 예매/하단 문구 정책이 다르므로 `InterestConcertDisplayText`에서 별도 관리한다. |
| 날짜 포맷 유틸 위치 | `LivithFoundation` 유지 또는 Shared로 이동 | `LivithFoundation` 유지 | 기존 날짜 포맷 유틸은 일반 기능이고, nullable fallback만 표시 헬퍼가 감싼다. |
| cursor 모델링 | 배열 마지막 항목에서 재계산 또는 응답 cursor 유지 | 응답 cursor 유지 | 정렬 기준별 fallback과 optional 날짜 정책을 클라이언트에서 중복 구현하지 않는다. |
| cursor 위치 | `Concert` 포함, `InterestConcert` 포함, 페이지 메타데이터 | 페이지 메타데이터 | cursor는 개별 콘서트 속성이 아니라 목록 조회 결과의 다음 페이지 정보다. |
| 관심 콘서트 목록 캐시 | 첫 페이지 캐시 유지 또는 캐시 제거 | 캐시 제거 | 홈 진입 시 최신 관심 콘서트 상태가 중요하고, 목록 API 전환 후 별도 로컬 캐시 무효화 정책을 유지하지 않는다. |
| 현재 콘서트 관심 여부 판단 | 첫 페이지만 확인, 별도 API, 상세 응답 필드, 전체 페이지 조회, unknown 상태 | 별도 API | 목록 API 첫 페이지만으로는 페이지 밖 관심 여부를 안정적으로 `false`로 확정할 수 없어 별도 API 추가 후 연결한다. |

## 표시 정책
- 공연명이 없으면 `"{artist} 내한 예정"`을 표시한다.
- 공연장 정보가 없으면 `"장소 공개 예정"`을 표시한다.
- 공연 시작일 또는 종료일이 없으면 `"추후 발표"`를 표시한다.
- 공연 D-day 값이 없으면 `"공연 예정"`을 표시한다.
- 예매 일정이 없으면 `"예매 오픈 예정"`을 표시한다.

### 관심 콘서트 표시 정책
- 관심 콘서트 표시 정책은 `ConcertDisplayText`와 분리해 `InterestConcertDisplayText`에서 관리한다.
- 공연명 없으면 `"{artist} 내한 예정"`을 표시한다.
- 공연장 정보가 없으면 `"장소 공개 예정"`을 표시한다.
- 공연 시작일 또는 종료일이 없으면 일정 문구는 `"추후 발표"`를 표시한다.
- 공연 D-day 값이 없으면 배지는 `"공연 예정"`을 표시한다.
- 공연 D-day 값이 `0`이면 배지는 `"공연 D-Day"`를 표시한다.
- 공연 D-day 값이 양수이면 배지는 `"공연 D-{daysLeft}"`를 표시한다.
- 공연 D-day 값이 음수이거나 예정 공연이 아니면 배지는 상태 문구를 표시한다.
- 공연 D-day 값이 `0`이면 하단 문구는 티켓 문구 대신 `"공연 진행 중"`을 표시한다.
- 선예매 일정이 있으면 하단 문구는 `"선예매 오픈 · {예매 일자}"`를 표시한다.
- 선예매 일정이 없고 일반 예매 일정이 있으면 하단 문구는 `"일반 예매 오픈 · {예매 일자}"`를 표시한다.
- 선예매와 일반 예매가 모두 있으면 선예매 문구를 우선 표시한다.
- 선예매와 일반 예매가 모두 없으면 하단 문구는 `"예매 오픈 예정"`을 표시한다.
- 공연 이미지가 없거나 로드에 실패하면 관심 콘서트 대체 이미지를 표시한다.

## 주의 사항
- `preSaleDate`, `generalSaleDate`를 일반 `Concert` 의미로 확장하지 않는다.
- Domain의 `InterestConcertListQuery`는 API 파라미터명인 `size` 대신 의미 중심의 `pageSize`를 사용한다.
- API query 변환은 `UserRepositoryImpl` 또는 Endpoint 경계에서만 수행한다.
- 관심 콘서트 목록은 `UserDefaults`에 저장하지 않는다.
- `InterestConcertPageCursor`는 API 파라미터명인 `cursorDate`, `cursorId`를 그대로 노출하지 않고 의미 중심의 `date`, `id` 값으로 표현한다.
- 서버가 제공한 cursor를 우선 사용하고, 서버 cursor가 없는 API에서만 예외적으로 마지막 항목 기반 cursor 생성을 검토한다.
- `DisplaySupport`는 표시 정책만 담당하고 UI 컴포넌트 타입을 반환하지 않는다.
- Domain은 `DisplaySupport`를 참조하지 않고, `DisplaySupport`만 Domain을 참조한다.
- `DisplaySupport`는 기존 `DateFormatter.formatDateRange(from:to:)`를 대체하지 않고 nullable date fallback을 감싸는 역할만 수행한다.
- `DisplaySupportTests` 타겟을 추가해 표시 정책 단위 테스트를 `HomeFeatureTests`에 의존하지 않도록 한다.
- 관심 콘서트 표시 정책은 일반 콘서트 표시 정책과 다른 도메인 정책으로 보고 `ConcertDisplayText`에 합치지 않는다.
- 작성자가 `김진웅`이 아닌 파일에서는 정책이 아직 확정되지 않아 후속 재검토가 필요한 fallback, nullable 처리, 관심 여부 판단 지점에만 TODO 주석을 남긴다.
- 확정 정책을 단순 반영하는 변경에는 TODO 주석을 남기지 않는다.
- TODO 주석은 단순 변경 기록이 아니라 재검토해야 할 정책을 구체적으로 적는다.
- `Concert` optional 변경은 검색, 추천, 상세, 홈 섹션 UI에 영향을 줄 수 있으므로 fallback을 함께 확인한다.
- `InterestConcertSearchStore`의 페이지네이션 cursor가 `state.concertList.last?.startDate`에 의존하는 경우, `Concert.startDate` Optional 변경으로 nil cursor가 되어 첫 페이지 중복 요청이 발생하지 않도록 서버 cursor 기반 구조로 변경한다.
- 관심 콘서트 목록 API의 pagination 때문에 `ConcertStore`의 관심 여부 판단은 별도 정책 확인이 필요하다.
- `ConcertStore`의 현재 콘서트 관심 여부는 목록 API 첫 페이지만으로 `false` 확정하지 않고, 별도 API가 추가되면 연결한다.
- 보안 규칙에 따라 토큰이나 인증 응답 원문을 로그, 테스트, 문서에 남기지 않는다.
- 다른 작업자의 변경을 되돌리지 않는다.
- 계획 변경이 필요하면 먼저 이 문서를 수정하고 사용자 확인을 받은 뒤 진행한다.

## 검증 방법
- `tuist test Domain`
- `tuist test DisplaySupport`
- `tuist test LivithNetwork`
- `tuist test ConcertData`
- `tuist test SearchData`
- `tuist test UserData`
- `tuist test HomeFeature`
- `xcodebuild build -scheme SearchFeature`
- `xcodebuild build -scheme ConcertFeature`
- `xcodebuild build -scheme Livith-iOS` 또는 실제 App 스킴명
