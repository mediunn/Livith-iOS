# [LIVD-000] 관심 콘서트 정리 정책 반영

## 배경
- 관심 콘서트 토스트 조회 API가 `needsToShow`와 함께 `type`을 내려준다.
- 현재 앱은 `needsToShow`만 DTO/Domain/Store에 반영하고 있어 취소/완료/혼합 상태별 정리 정책을 처리할 수 없다.
- Domain 모델에 `Toast`라는 UI 표현을 노출하지 않고, 관심 콘서트 정리 결과를 정책으로 표현한다.

## 목표
- Network DTO에서 API 응답의 `type` 필드를 디코딩한다.
- Domain 레이어에 관심 콘서트 정리 정책을 표현하는 모델을 추가한다.
- Data 레이어에서 DTO를 Domain 정책 모델로 매핑한다.
- Home Store/View 흐름에서 정책별 사용자 안내 메시지를 처리한다.

## 작업 항목
- [x] Network DTO와 디코딩 테스트 수정
  - `FetchInterestConcertToast`에 `type` 필드를 추가하고 `CANCELED`, `COMPLETED`, `BOTH` 케이스를 검증한다.
- [x] Domain 모델과 Repository 계약 수정
  - `InterestConcertCleanupPolicy` enum을 추가하고, `UserRepository` 반환 타입을 Bool에서 정책 모델로 변경한다.
- [x] Data 매핑과 Repository 구현 수정
  - `UserMapper`에서 DTO 타입 문자열을 Domain 정책 enum으로 변환하고, `needsToShow == false`일 때 `.none`으로 정규화한다.
- [x] Home Store 토스트 상태 처리 수정
  - Store가 Domain 정책을 받아 타입별 메시지를 설정하도록 변경한다.
- [x] 테스트 더블과 Home Store 테스트 수정
  - Mock Repository와 기존 Home 테스트를 새 계약에 맞추고 정책별 메시지 테스트를 추가한다.
- [x] 영향 범위 검증
  - `LivithNetwork`, `Domain`, `UserData`, `HomeFeature` 관련 테스트를 실행한다.

## 영향 범위
- Network: `Projects/Core/LivithNetwork/Sources/DTO/HomeFeature/InterestConcertToast.swift`, `Projects/Core/LivithNetwork/Tests/HomeFeatureDTOTests.swift`
- Domain: `Projects/Domain/Sources/Entity/Concert/*`, `Projects/Domain/Sources/Repository/UserRepository.swift`
- Data: `Projects/Data/UserData/Sources/Mapper/UserMapper.swift`, `Projects/Data/UserData/Sources/Repository/UserRepositoryImpl.swift`, Mock/Tests
- HomeFeature: `Projects/HomeFeature/Sources/Home/Store/HomeStore.swift`, `Projects/HomeFeature/Sources/Home/View/HomeView.swift`, Tests/Mocks
- 기타 UserRepository mock 구현체

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| Domain 모델 형태 | Bool + Optional type / 정책 enum | `InterestConcertCleanupPolicy` enum | UI 표현인 Toast를 Domain에 노출하지 않고 정리 정책으로 의미를 표현하기 위함 |
| 타입 enum 위치 | User Entity / Concert Entity | Concert Entity 하위 | 관심 콘서트 상태 정리 정책이므로 Concert 도메인에 더 가깝다 |
| `needsToShow == false`의 type | nil 허용 / `.none` 정규화 | `.none` | PDF 예시에서 토스트가 없을 때 `type`이 내려오지 않으며, Domain에서는 조합 상태를 숨기기 위함 |
| 타입별 메시지 위치 | Domain / Store Constants | HomeStore Constants | 문구는 화면 표현 정책이며 Domain 모델은 의미만 보관한다 |
| 알 수 없는 type 처리 | invalidResponse / nil 변환 | `invalidResponse` | 서버 계약 변경 또는 오타를 조기에 감지하기 위함 |

## 주의 사항
- Domain 레이어는 외부 프레임워크 의존성을 추가하지 않는다.
- DTO 타입을 HomeFeature로 노출하지 않는다.
- Domain 모델 이름에는 `Toast` 대신 `Policy`를 사용한다.
- 기존 에러 토스트가 관심 콘서트 성공 토스트보다 우선하는 흐름은 유지한다.
- `needsToShow == false`이면 `type`이 없어도 `.none`으로 처리한다.
- `needsToShow == true`인데 `type`이 없거나 유효하지 않으면 invalid response로 처리한다.

## 검증 방법
- `xcodebuild test -workspace Livith-iOS.xcworkspace -scheme LivithNetwork -destination 'platform=iOS Simulator,name=iPhone 17'`
- `xcodebuild test -workspace Livith-iOS.xcworkspace -scheme Domain -destination 'platform=iOS Simulator,name=iPhone 17'`
- `xcodebuild test -workspace Livith-iOS.xcworkspace -scheme UserData -destination 'platform=iOS Simulator,name=iPhone 17'`
- `xcodebuild test -workspace Livith-iOS.xcworkspace -scheme HomeFeature -destination 'platform=iOS Simulator,name=iPhone 17'`
