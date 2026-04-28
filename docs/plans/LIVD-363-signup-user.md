# LIVD-363 회원가입 API 및 유저 도메인 모델 수정

## 배경
- 회원가입 API 응답의 유저 DTO 스펙이 변경되었다.
- 변경된 응답에서는 `interestConcertId`, `preferredGenres`, `preferredArtists`가 제거되고 `hasPreferredGenre`가 추가된다.
- `providerId`는 nullable로 내려올 수 있다.
- 유저 도메인 모델에서 관심 콘서트 아이디를 제거하고, 관심 콘서트 상태를 유저 정보와 분리해야 한다.

## 목표
- 회원가입 API 응답 DTO와 매핑 로직을 새 스펙에 맞춘다.
- `User` 도메인 모델에서 `interestConcertID`를 제거한다.
- `User.providerID`를 nullable로 반영한다.
- 관심 콘서트 상태 판단을 `User` 모델이 아닌 관심 콘서트 조회/캐시 흐름으로 분리한다.
- 각 단계 구현 완료 후 계획 문서를 기준으로 서브에이전트 리뷰를 받고, 지적 사항을 모두 수정한 뒤 사용자에게 보고한다.
- 수정 대상 테스트가 기존 `XCTest` 기반이면 `Swift Testing` 기반으로 전환하되, 같은 테스트 타입 또는 함수 안에서 `XCTest`와 `Testing`을 혼용하지 않는다.

## 단계별 원칙
- 각 단계는 `red -> verify red -> green -> verify green -> refactor` 순서로 진행한다.
- 생산 코드 변경 전 실패 테스트를 먼저 작성하고, 컴파일 성공 상태에서 실제 실행해 기대 동작 부재로 실패하는지 확인한다.
- 컴파일 실패는 `red`로 간주하지 않는다.
- 시그니처 변경 때문에 테스트가 컴파일되지 않으면 컴파일에 필요한 최소 선언만 먼저 추가하고, 동작 구현 없이 런타임 실패를 확인한다.
- 각 단계의 `green`과 `refactor` 이후에는 영향 범위 보호 테스트를 다시 실행한다.
- 서브에이전트가 명시적으로 리뷰 통과를 판정하기 전에는 사용자에게 단계 완료 보고를 하지 않는다.

## 작업 항목
- [ ] 1단계: 회원가입 API 수정
  - [ ] 변경된 회원가입 응답의 유저 DTO 스펙을 반영하는 실패 테스트를 작성하고 실패 원인을 확인한다.
  - [ ] `DTO.Response.Signup` 전체 응답 디코딩 테스트를 추가해 `accessToken`, `refreshToken`, `user.providerId == null`, `user.hasPreferredGenre`, 제거된 `interestConcertId/preferredGenres/preferredArtists` 미포함 응답을 검증한다.
  - [ ] `DTO.Response.Signup` 및 연관 DTO 디코딩이 `hasPreferredGenre`, nullable `providerId`를 처리하도록 확인한다.
  - [ ] `AuthRepositoryImpl.handleSignup`과 `AuthMapper`가 변경된 회원가입 응답을 정상적으로 도메인에 매핑하도록 수정한다.
  - [ ] 이 단계에서는 `User.interestConcertID` 제거와 `User.providerID` nullable 변경을 수행하지 않고, API 응답 변경에 필요한 최소 수정만 적용한다.
  - [ ] 1단계에서 `providerId == null`은 DTO 디코딩까지 검증하고, 기존 non-null `User.providerID`에는 임시 어댑팅을 유지한다.
  - [ ] 빈 문자열 대체 임시 어댑팅은 2단계에서 `User.providerID: String?`로 변경하면서 제거한다.
  - [ ] 관련 테스트를 실행해 통과를 확인한다.
- [ ] 1단계 리뷰 및 보고
  - [ ] 1단계 구현 완료 후 서브에이전트에게 이 계획 문서를 기준으로 구현 내용을 리뷰 요청한다.
  - [ ] 리뷰 지적 사항을 모두 수정하고 관련 테스트를 다시 실행한다.
  - [ ] 리뷰가 통과될 때까지 수정과 재검증을 반복한다.
  - [ ] 서브에이전트가 명시적으로 통과 판정을 내리기 전에는 사용자에게 1단계 완료를 보고하지 않는다.
  - [ ] 1단계 리뷰 통과 후 사용자에게 1단계 완료를 보고한다.
- [ ] 2단계: 유저 도메인 모델 수정
  - [ ] `Domain.User`에서 `interestConcertID` 프로퍼티, initializer 파라미터, `CodingKeys`를 제거하는 실패 테스트를 작성하고 실패 원인을 확인한다.
  - [ ] `Domain.User.providerID`를 `String?`로 변경한다.
  - [ ] `AuthMapper`, `UserMapper`, `UpdateUserNickname` 매핑에서 `interestConcertID` 의존을 제거하고 nullable `providerID`를 그대로 전달한다.
  - [ ] `AuthMapperTests`, `UserMapperTests`에서 null `providerId` 기대값을 빈 문자열이 아닌 `nil`로 변경한다.
  - [ ] `UpdateUserNickname` 응답 DTO의 서버 스펙을 확인하고, 새 유저 DTO 스펙과 동일하다면 `interestConcertId` 제거, `providerId` nullable, `hasPreferredGenre` 추가를 DTO와 테스트에 반영한다.
  - [ ] `UpdateUserNickname` 응답 DTO 스펙이 변경되지 않았다면 DTO는 유지하고, `UserMapper`에서 `interestConcertID`를 도메인에 전달하지 않도록만 수정한다.
  - [ ] `UserRepositoryImpl`에서 관심 콘서트 변경 시 `User` 캐시를 수정하던 로직을 제거한다.
  - [ ] `HomeState`에 관심 콘서트 조회 결과 상태를 추가하고, `HomeStore`에서 `UserRepository.fetchInterestedConcert()` 결과로 홈 헤더 분기 상태를 갱신한다.
  - [ ] `HomeView`의 관심 콘서트 섹션 분기를 `User.interestConcertID`가 아닌 `HomeState`의 관심 콘서트 상태 기반으로 변경한다.
  - [ ] `HomeInterestConcertSectionView`의 mock 기반 표시가 실제 관심 콘서트 상태와 충돌하지 않는지 확인하고, 필요한 최소 연결만 수행한다.
  - [ ] `HomeStoreTests`의 `interestConcertID` 기반 테스트를 관심 콘서트 조회 결과 기반 테스트로 재작성한다.
  - [ ] `ConcertStore`에서 `currentUser.interestConcertID`를 직접 읽고 쓰는 `UserDefaultsStorage` 접근을 제거한다.
  - [ ] 콘서트 상세 화면의 현재 관심 콘서트 판단은 `UserRepository.fetchInterestedConcert()`를 통해 조회하고, Repository 내부의 기존 관심 콘서트 캐시를 활용하도록 한다.
  - [ ] 관련 Mock과 테스트의 `User` 생성부 및 기대값을 갱신한다.
  - [ ] 수정 대상 테스트가 `XCTest` 기반이면 해당 영향을 받는 테스트를 `Swift Testing` 기반으로 전환한다.
  - [ ] 관련 테스트와 빌드를 실행해 통과를 확인한다.
- [ ] 2단계 리뷰 및 보고
  - [ ] 2단계 구현 완료 후 서브에이전트에게 이 계획 문서를 기준으로 구현 내용을 리뷰 요청한다.
  - [ ] 리뷰 지적 사항을 모두 수정하고 관련 테스트를 다시 실행한다.
  - [ ] 리뷰가 통과될 때까지 수정과 재검증을 반복한다.
  - [ ] 서브에이전트가 명시적으로 통과 판정을 내리기 전에는 사용자에게 최종 완료를 보고하지 않는다.
  - [ ] 2단계 리뷰 통과 후 사용자에게 최종 완료를 보고한다.
- [ ] 마무리
  - [ ] 모든 작업 항목이 완료되면 계획 문서를 `docs/archives/`로 이동한다.
  - [ ] 작업 중 실패, 피드백, 접근 방식 변경이 발생하면 `docs/troubleshooting/LIVD-363-signup-user.md`에 최신순으로 기록한다.
  - [ ] 트러블슈팅 문서가 생성된 경우 계획 문서 아카이빙 시 함께 `docs/archives/`로 이동한다.

## 영향 범위
- `Projects/Core/LivithNetwork/Sources/DTO/OnboardingFeature/Signup.swift`
- `Projects/Core/LivithNetwork/Sources/DTO/OnboardingFeature/FetchUserInfo.swift`
- `Projects/Core/LivithNetwork/Sources/DTO/UserFeature/UpdateUserNickname.swift`
- `Projects/Core/LivithNetwork/Tests/OnboardingFeatureDTOTests.swift`
- `Projects/Data/AuthData/Sources/Repository/AuthRepositoryImpl.swift`
- `Projects/Data/AuthData/Sources/Mapper/AuthMapper.swift`
- `Projects/Data/AuthData/Tests/AuthMapperTests.swift`
- `Projects/Domain/Sources/Entity/User/User.swift`
- `Projects/Data/UserData/Sources/Mapper/UserMapper.swift`
- `Projects/Data/UserData/Sources/Repository/UserRepositoryImpl.swift`
- `Projects/Data/UserData/Tests/UserMapperTests.swift`
- `Projects/HomeFeature/Sources/Home/Store/HomeStore.swift`
- `Projects/HomeFeature/Sources/Home/View/HomeView.swift`
- `Projects/HomeFeature/Sources/Home/View/Subview/InterestConcertSection/HomeInterestConcertSectionView.swift`
- `Projects/HomeFeature/Tests/HomeStoreTests.swift`
- `Projects/ConcertFeature/Sources/Store/ConcertStore.swift`
- `Projects/Shared/NicknameEditFeature/Tests/NicknameEditStoreTests.swift`
- `Projects/App/Sources/View/AppRootView.swift`
- `Projects/App/Sources/Service/NotificationService.swift`
- 관련 테스트 및 Mock 파일

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 작업 분리 | 한 번에 수정 또는 2단계 분리 | 2단계 분리 | API 계약 변경과 도메인 모델 리팩터링의 리스크를 분리한다. |
| 1단계 범위 | DTO/회원가입 흐름만 수정 또는 User 모델까지 수정 | DTO/회원가입 흐름만 수정 | 회원가입 API 변경을 먼저 안정화하고 테스트 범위를 좁힌다. |
| 1단계 `providerID` 처리 | 임시 어댑팅 유지 또는 User nullable 변경 선반영 | 임시 어댑팅 유지 | 1단계에서 도메인 모델 리팩터링을 섞지 않는다. |
| 2단계 `providerID` 처리 | 빈 문자열 대체 또는 nullable 유지 | nullable 유지 | 서버 스펙의 nullable을 도메인 모델에 그대로 반영한다. |
| 관심 콘서트 상태 | `User.interestConcertID` 유지 또는 별도 상태로 분리 | 별도 상태로 분리 | 관심 콘서트는 유저 정보 응답에서 제거된 상태이며, 별도 API/캐시가 이미 존재한다. |
| 홈 관심 콘서트 분기 | User 필드, Presentation 캐시 직접 접근, Repository 조회 | Repository 조회 결과 기반 | Presentation은 Data 캐시에 직접 의존하지 않고 Domain Repository를 통해 상태를 얻는다. |
| 콘서트 상세 관심 여부 | currentUser 직접 조회 또는 Repository 조회 | Repository 조회 | `User.interestConcertID` 제거 후에도 Repository 내부 캐시를 활용해 관심 콘서트 상태를 판단한다. |
| 기존 XCTest 처리 | 유지, 혼용, Swift Testing 전환 | Swift Testing 전환 | 수정 대상 테스트는 사용자 요청에 따라 Swift Testing 기반으로 맞추고 혼용을 피한다. |
| 단계별 리뷰 | 구현 후 즉시 사용자 보고 또는 서브에이전트 리뷰 후 보고 | 서브에이전트 리뷰 후 보고 | 계획 문서 기준으로 구현 누락과 회귀 위험을 점검한 뒤 보고한다. |

## 확인 필요 사항
- `UpdateUserNickname` 응답도 회원가입/유저조회 응답과 동일하게 `interestConcertId` 제거, `providerId` nullable, `hasPreferredGenre` 추가 스펙으로 변경되었는지 확인한다.
- 홈 화면의 관심 콘서트 섹션은 이번 작업에서 단일 `fetchInterestedConcert()` 결과 기반 분기까지만 처리하고, 여러 관심 콘서트 카드 표시 API가 별도로 필요하면 후속 작업으로 분리한다.
- 관심 콘서트 알림 탭 시 현재처럼 검색 화면으로 이동하는 동작이 유지 대상인지 확인한다.

## 주의 사항
- 보안 규칙에 따라 인증 응답 원문, 토큰, 민감한 사용자 식별값을 로그나 문서에 남기지 않는다.
- `providerID`는 외부 서비스 사용자 식별값으로 취급하고, 기능상 필요한 범위에서만 보존한다.
- 로그, 문서, 테스트 fixture에는 실제 `providerID` 원문을 남기지 않고 placeholder를 사용한다.
- `currentUser` 또는 UserDefaults 계열 저장소에 `providerID`가 저장되는지 확인하고, 불필요한 저장으로 판단되면 사용자 확인 후 제거한다.
- 1단계에서는 유저 도메인 모델 구조 변경을 섞지 않는다.
- 2단계에서 `User.interestConcertID`를 제거할 때 기존 저장된 `currentUser` 디코딩 영향을 확인한다.
- Presentation 레이어는 관심 콘서트 캐시 구현체나 DTO에 직접 의존하지 않고, Domain Repository 프로토콜을 통해 관심 콘서트 조회 및 상태 판단을 수행한다.
- `UserDefaults`에는 인증 토큰이나 비밀값을 저장하지 않는다.
- 다른 작업자가 만든 변경을 되돌리지 않는다.
- 계획 변경이 필요하면 먼저 이 문서를 수정하고 사용자 확인을 받은 뒤 진행한다.

## 검증 방법
- `LivithNetworkTests`에서 회원가입 및 유저 정보 DTO 디코딩 테스트를 실행한다.
- `AuthDataTests`에서 회원가입 응답 매핑 관련 테스트를 실행한다.
- `UserDataTests`에서 유저 매퍼와 관심 콘서트 캐시/저장소 관련 테스트를 실행한다.
- `HomeFeatureTests`에서 홈 화면 관심 콘서트 상태 분기 테스트를 실행한다.
- 기존 `currentUser` JSON에 `interestConcertId`가 포함된 상태에서도 `User` 디코딩 및 AppRoot 로그인 판정이 유지되는지 검증한다.
- `NotificationService`의 `currentUser` 디코딩 기반 FCM 토큰 등록 흐름에 회귀가 없는지 검증한다.
- 수정 대상 테스트가 기존 `XCTest` 기반이었다면 `Swift Testing` 전환 후 테스트가 동일 동작을 검증하는지 확인한다.
- 필요 시 관련 타겟 빌드 또는 전체 빌드를 실행한다.
- 각 단계 구현 완료 후 서브에이전트 리뷰를 통과했는지 확인한다.
