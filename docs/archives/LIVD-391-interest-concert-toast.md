# LIVD-391 관심 콘서트 토스트

## 배경
- 홈 진입 시 서버가 관심 콘서트 토스트 노출 필요 여부를 판단해 전달한다.
- 사용자는 종료된 관심 콘서트가 자동 정리되었음을 홈 화면 토스트로 안내받아야 한다.
- 토스트가 노출된 뒤에는 서버에 노출 처리 API를 호출해 반복 노출을 방지해야 한다.

## 목표
- `HomeEndpoint`에 관심 콘서트 토스트 조회/노출 처리 API를 추가한다.
- 홈 화면 진입 시 토스트 노출 여부를 조회하고, 필요한 경우 `종료된 공연이 자동 정리됐어요` 성공 토스트를 표시한다.
- 토스트 표시가 결정되면 관심 콘서트 토스트 노출 처리 API를 호출한다.
- 레포지토리 구현체 자체는 테스트 대상에 포함하지 않고, endpoint/DTO와 `HomeStore` 동작만 테스트한다.

## 작업 항목
- [x] 네트워크 endpoint와 DTO 추가
  - `HomeEndpoint`에 `GET /users/interest-concerts/toast` 조회 case를 추가한다.
  - `HomeEndpoint`에 `PATCH /users/interest-concerts/toast` 노출 처리 case를 추가한다.
  - 두 endpoint 모두 인증 인터셉터를 사용한다.
  - `DTO.Response.FetchInterestConcertToast`에 `needsToShow: Bool`을 추가한다.
  - `DTO.Response.UpdateInterestConcertToast`에 `success: Bool`을 추가한다.
  - 관심 콘서트 토스트 DTO는 별도 파일로 분리한다.
- [x] Domain repository 프로토콜 확장
  - `UserRepository`에 `fetchInterestConcertToastNeedsToShow() async throws(UserError) -> Bool`을 추가한다.
  - `UserRepository`에 `markInterestConcertToastShown() async throws(UserError)`를 추가한다.
  - 추가 도메인 모델은 만들지 않고 `Bool`과 성공/실패만 사용한다.
  - `UserRepository`를 채택하는 모든 mock과 구현체를 함께 수정해 프로토콜 변경에 따른 컴파일 실패를 방지한다.
- [x] Data repository 구현 연결
  - `UserRepositoryImpl`에서 `HomeService`로 토스트 조회 API를 호출하고 `needsToShow`를 반환한다.
  - `UserRepositoryImpl`에서 `HomeService`로 토스트 노출 처리 API를 호출한다.
  - PATCH 응답의 `success`는 도메인으로 노출하지 않고, 요청 실패만 `UserError`로 매핑한다.
- [x] 홈 상태와 Store 동작 추가
  - `HomeState`에 관심 콘서트 성공 토스트 메시지 상태를 추가한다.
  - `HomeIntent`에 성공 토스트 dismiss intent, 내부 토스트 조회 결과 intent, 내부 토스트 노출 처리 결과 intent를 추가한다.
  - 토스트 조회 결과는 `_fetchInitialHomeDataResult` tuple에 포함하지 않고 별도 내부 intent로 처리한다.
  - `onAppear`의 초기 홈 데이터 병렬 조회에는 토스트 조회를 포함하지 않는다.
  - 홈 초기 데이터와 홈 섹션 데이터가 성공적으로 상태에 반영된 뒤 토스트 조회를 수행한다.
  - 홈 섹션 데이터 조회가 실패하면 성공 토스트 조회를 수행하지 않는다.
  - 토스트 조회 실패는 홈 초기 데이터 실패로 전파하지 않는다.
  - `needsToShow == true`일 때 성공 토스트 메시지를 `종료된 공연이 자동 정리됐어요`로 설정한다.
  - 토스트 조회 결과 처리 시점에 `errorMessage`가 비어 있지 않으면 성공 토스트 메시지를 설정하지 않고 해당 성공 토스트는 폐기한다.
  - 오류가 발생해 `errorMessage`를 설정하는 경우 이미 대기 중인 관심 콘서트 성공 토스트 메시지를 비운다.
  - 토스트 표시가 결정된 경우 PATCH 노출 처리 API를 호출한다.
  - 성공 토스트가 충돌 정책으로 폐기된 경우 실제로 표시되지 않았으므로 PATCH 노출 처리 API를 호출하지 않는다.
  - PATCH 실패는 사용자에게 오류 토스트로 노출하지 않는다.
- [x] 홈 View 토스트 표시 연결
  - `HomeView`에 성공 토스트 표시 상태를 추가한다.
  - `HomeStore`의 성공 토스트 메시지가 비어 있지 않으면 `.livithToast(type: .success)`를 표시한다.
  - 성공 토스트가 닫히면 Store에 dismiss intent를 보내 메시지를 비운다.
  - 실패 토스트와 성공 토스트가 동시에 표시 조건을 만족하면 실패 토스트를 우선 표시하고 성공 토스트는 이후에도 순차 표시하지 않는다.
  - View 바인딩에서도 성공 토스트는 실패 토스트가 표시 중이 아닐 때만 표시되도록 방어한다.
- [x] 테스트 추가/수정
  - `LivithNetworkTests`에서 조회/노출 처리 endpoint의 path, method, interceptor를 검증한다.
  - `LivithNetworkTests`에서 `BaseResponse<DTO.Response.FetchInterestConcertToast>`와 `BaseResponse<DTO.Response.UpdateInterestConcertToast>` 디코딩을 검증한다.
  - `HomeFeatureTests`의 `MockUserRepository`에 토스트 조회/노출 처리 stub과 호출 카운트를 추가한다.
  - `Shared/NicknameEditFeature` 테스트 내부 `MockUserRepository`에 새 프로토콜 메서드를 최소 구현하고, 기존 `UserRepository` 요구사항 누락 여부도 함께 확인한다.
  - `Data/UserData`의 DEBUG `MockUserRepository`에 새 프로토콜 메서드를 최소 구현한다.
  - `HomeStoreTests`에서 `needsToShow == true`이면 성공 토스트 메시지가 설정되고 PATCH가 호출되는지 검증한다.
  - `HomeStoreTests`에서 `needsToShow == false`이면 성공 토스트 메시지가 비어 있고 PATCH가 호출되지 않는지 검증한다.
  - `HomeStoreTests`에서 홈 섹션 데이터가 반영되기 전에는 토스트 조회를 수행하지 않는지 검증한다.
  - `HomeStoreTests`에서 홈 섹션 데이터 조회가 실패하면 토스트 조회를 수행하지 않는지 검증한다.
  - `HomeStoreTests`에서 토스트 조회 실패가 홈 초기 로딩을 실패시키지 않는지 검증한다.
  - `HomeStoreTests`에서 실패 메시지가 있는 상태에 토스트 조회 성공 결과가 들어오면 성공 토스트 메시지를 설정하지 않고 PATCH도 호출하지 않는지 검증한다.
  - `HomeStoreTests`에서 오류가 발생하면 이미 대기 중인 관심 콘서트 성공 토스트 메시지를 비우는지 검증한다.
  - `HomeStoreTests`에서 PATCH 실패가 `errorMessage`를 설정하지 않고 성공 토스트 메시지를 유지하는지 검증한다.
  - `HomeStoreTests`에서 토스트 dismiss intent가 성공 토스트 메시지를 비우는지 검증한다.
  - `UserRepositoryImpl` 자체 테스트는 추가하지 않는다.

## 영향 범위
- Core Network
  - `Projects/Core/LivithNetwork/Sources/Endpoint/HomeEndpoint.swift`
  - `Projects/Core/LivithNetwork/Sources/DTO/HomeFeature/InterestConcertToast.swift`
  - `Projects/Core/LivithNetwork/Tests/HomeFeatureDTOTests.swift`
- Domain
  - `Projects/Domain/Sources/Repository/UserRepository.swift`
- Data
  - `Projects/Data/UserData/Sources/Repository/UserRepositoryImpl.swift`
  - `Projects/Data/UserData/Sources/Mock/MockUserRepository.swift`
- HomeFeature
  - `Projects/HomeFeature/Sources/Home/Store/HomeStore.swift`
  - `Projects/HomeFeature/Sources/Home/View/HomeView.swift`
  - `Projects/HomeFeature/Tests/HomeStoreTests.swift`
  - `Projects/HomeFeature/Tests/Mock/MockUserRepository.swift`
- Shared
  - `Projects/Shared/NicknameEditFeature/Tests/NicknameEditStoreTests.swift`

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| Repository 위치 | `UserRepository` 또는 `ConcertRepository` | `UserRepository` | API path가 `/users/interest-concerts/toast`이고 기존 관심 콘서트 목록/설정도 `UserRepository`가 담당한다. |
| 도메인 모델 추가 | 전용 모델 추가 또는 `Bool` 사용 | `Bool` 사용 | 화면에 필요한 값은 노출 여부뿐이고 장기 보존할 도메인 개념이 아니다. |
| PATCH 반환값 처리 | `Bool` 반환 또는 성공 시 반환 없음 | 반환 없음 | PATCH의 `success`는 요청 성공 여부를 중복 표현하므로 도메인으로 노출하지 않는다. |
| PATCH `success == false` 처리 | 오류 처리 또는 무시 | 무시 | 2xx 응답 수신 자체를 노출 처리 요청 성공으로 보고, `success` 값은 사용자 오류로 표시하지 않는다. |
| 토스트 문구 | 서버 응답 사용 또는 클라이언트 고정 문구 | 클라이언트 고정 문구 | API 응답에는 노출 여부만 있고 요구 문구가 `종료된 공연이 자동 정리됐어요`로 확정됐다. |
| PATCH 호출 시점 | 토스트 표시 결정 직후 또는 토스트 dismiss 후 | 표시 결정 직후 | 사용자 요구가 토스트 표시와 PATCH까지이며 반복 노출 방지가 우선이다. |
| 토스트 조회 시점 | 초기 홈 데이터와 병렬 조회 또는 홈 섹션 반영 후 조회 | 홈 섹션 반영 후 조회 | 홈 데이터가 렌더링되는 중간에 성공 토스트가 먼저 노출되지 않도록 한다. |
| 토스트 조회 실패 처리 | 홈 초기 실패로 전파 또는 무시 | 무시 | 부가 안내 기능이므로 홈 진입 자체를 막지 않는다. |
| PATCH 실패 처리 | 오류 토스트 노출 또는 무시 | 무시 | 이미 사용자에게 성공 안내가 노출된 뒤의 서버 상태 갱신 실패이며, 오류 토스트를 띄우면 홈 UX가 흔들린다. |
| 성공/실패 토스트 충돌 | 성공 우선, 실패 우선, 순차 표시 | 실패 우선 및 성공 폐기 | 기존 오류 토스트가 사용자 조치가 필요한 정보를 담으므로 실패 토스트를 우선하고, 충돌한 성공 토스트는 뒤늦게 표시하지 않는다. |
| 토스트 조회 작업 취소 | 기존 초기 로딩 task에 포함 또는 홈 섹션 성공 이후 별도 task 실행 | 홈 섹션 성공 이후 별도 task 실행 | 홈 섹션 상태 반영 이후에만 조회해 렌더링 중 토스트 노출을 방지한다. |
| 레포지토리 테스트 | `UserRepositoryImpl` 테스트 추가 또는 제외 | 제외 | 현재 레포지토리 구현체가 테스트 가능한 구조가 아니므로 이번 범위에서 제외한다. |

## 주의 사항
- endpoint path는 기존 `HomeEndpoint` 관례대로 `/api/v6` prefix 없이 `/users/interest-concerts/toast`로 작성한다.
- 기존 `onAppear` 초기 로딩에서 유저 조회 실패만 홈 초기 데이터 실패로 전파되는 정책을 유지한다.
- 관심 콘서트 목록 조회 실패, 알림 수 조회 실패, 토스트 조회 실패는 홈 초기 데이터 실패로 전파하지 않는다.
- 토스트 조회는 홈 섹션 데이터 조회 성공 후 상태 반영까지 끝난 뒤 수행한다.
- 홈 섹션 데이터 조회가 실패하면 성공 토스트 조회를 수행하지 않는다.
- 성공 토스트와 기존 오류 토스트는 각각 별도 상태로 관리하되, 동시에 표시 조건을 만족하면 실패 토스트를 우선하고 성공 토스트는 폐기한다.
- 성공 토스트가 충돌 정책으로 폐기된 경우 토스트가 실제 표시되지 않았으므로 PATCH 노출 처리 API도 호출하지 않는다.
- `HomeStore`의 토스트 조회는 `performFetchInitialHomeData()` 안의 `async let`에 포함하지 않는다.
- `UserRepository` 프로토콜이 확장되므로 모든 conformer를 함께 수정한다.
- `UserRepositoryImpl` 자체 테스트는 만들지 않지만, 프로토콜 메서드 구현은 실제 앱 빌드를 위해 필요하다.

## 검증 방법
- `LivithNetworkTests`를 실행해 endpoint와 DTO 계약을 확인한다.
- `HomeFeatureTests`를 실행해 홈 진입 시 토스트 상태와 PATCH 호출 조건을 확인한다.
- `NicknameEditFeatureTests` 또는 전체 테스트 빌드를 통해 `UserRepository` 테스트 mock 컴파일을 확인한다.
- 테스트를 실행할 때는 `xcodebuild`를 사용하고, 시뮬레이터 destination은 `platform=iOS Simulator,name=iPhone 17,OS=26.4.1`로 지정한다.
- 가능하면 전체 빌드를 실행해 `UserRepository` 프로토콜 변경에 따른 컴파일 누락을 확인한다.
