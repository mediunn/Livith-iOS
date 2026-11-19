# [#330] 공연 요청 화면의 Environment DI와 Observable MVVM 적용

기준 `develop` `aaed2d4` · 브랜치 `refactor/#330-concert-request-mvvm-pilot` · [GitHub 이슈 #330](https://github.com/mediunn/Livith-iOS/issues/330)

## 배경

현재 `ConcertRequestView`가 공연명·URL·추가 설명을 보유하고, `ConcertRequestStore`가 제출 상태를 관리한다. Store와 테스트는 Repository를 받기 위해 전역 컨테이너에 접근한다. 공연 요청 한 경로에서 생성자 주입과 Observation을 적용해 의존성 전달과 화면 상태 소유권을 검증한다.

## 목표

- App이 조립한 `ConcertRequestRepository`를 Home 경로로 전달하고, 화면별 모델은 Domain 프로토콜을 생성자로 받는다.
- 공연명·URL·추가 설명과 제출 상태는 화면별 ViewModel 한 인스턴스에서 관리한다. View는 포커스와 시트·모달 표시, 외부 콜백을 담당한다.
- 기존 입력 정규화, 선택 입력의 `nil` 처리, 자동 등록 선택, 중복 제출 차단, 실패 토스트, 성공·닫기 동작을 유지한다.

## 권한·범위

- 변경 대상은 iOS App의 Repository 전달, Home의 공연 요청 진입점, ShareFeature의 공연 요청 화면·모델·테스트다.
- 현재 작업은 이슈·브랜치·계획 준비까지다. 아래 구현 항목은 후속 작업이다.
- 앱 전체의 `@Injected`와 `DIContainer.shared` 제거, 공용 Environment 타깃, `ShareFeature` 이름 변경, 세션 사용자 상태와 디스크 캐시 정리, 서버·Domain 계약 변경은 후속 범위다.

## 작업 항목

- [ ] 구현에 앞서 공연 요청 화면에 적용할 아키텍처 규칙 예외를 문서에 반영한다.
- [ ] 첫 구현 커밋에서 HomeFeature에 `ConcertRequestRepository`용 Environment 키를 선언한다. App은 기존 Assembler 등록을 완료한 뒤 Repository를 조회해 루트 View에 주입한다.
- [ ] `HomeCoordinatorView`에서 Environment 값을 읽고 `ConcertRequestView`를 통해 기존 Store 생성자로 전달한다. 기존 `Intent`와 `send(_:)`를 유지한 상태에서 Store 테스트를 mock 직접 주입으로 옮긴다. Preview에서도 명시적으로 의존성을 제공한다.
- [ ] 두 번째 구현 커밋에서 Store를 `@MainActor @Observable` ViewModel로 전환한다. 화면이 `@State`로 ViewModel을 소유하고, 초안과 제출 단계는 ViewModel에 둔다. View는 기존 성공·닫기 콜백을 호출한다.
- [ ] 테스트와 빌드, 시뮬레이터 검증 결과를 기록한다.

### 첫 구현 커밋에서 연결할 주입 경로

1. `HomeFeature`에 `EnvironmentValues.concertRequestRepository`를 공개한다. 값은 Domain의 `any ConcertRequestRepository`이며, 키의 기본값은 `nil`이다.
2. `LivithApp`은 기존 `registerDependency()`가 끝난 뒤 Repository를 조회하고 `AppRootView`에 한 번 전달한다. App은 이미 HomeFeature에 의존하므로 키 접근을 위해 `ShareFeature`를 직접 참조할 필요가 없다.
3. `HomeCoordinatorView`의 `.concertRequest` 분기에서 값을 읽어 화면에 넘긴다. 누락 시 공연 요청 화면을 열 수 없다는 상태를 표시한다. 화면의 공개 생성자는 Repository와 기존 `onDismiss`, `onRequestSuccess`를 받는다.
4. `ConcertRequestStore`는 Repository를 생성자로 받아 보관한다. 단위 테스트와 독립 Preview는 각자 사용할 mock 또는 Preview용 대역을 명시한다. 이 단계에서 기존 `Intent`와 `send(_:)`로 제출 흐름을 먼저 확인한다.

### 두 번째 구현 커밋에서 옮길 상태

| 상태·동작 | 구현과 유지할 동작 |
| --- | --- |
| 공연명·URL·추가 설명 | 화면의 `@State`에 담긴 ViewModel이 초안을 소유한다. 입력은 같은 프로퍼티에 바인딩하고 제출 가능 여부와 이탈 확인 필요 여부를 초안에서 계산한다. Preview의 초기 입력도 ViewModel로 전달한다. |
| 제출 | 확인 시트 선택이 `submit(shouldAutoRegister:)`를 호출한다. 기존 `ConcertRequest`가 입력 검증과 정규화를 담당한다. 제출 중 다시 누르면 Repository 호출을 추가하지 않는다. |
| 실패·재시도 | 실패는 제출 상태에서 토스트에 연결한다. 토스트가 사라지면 실패 표시를 초기화한다. 초안을 유지하고 열린 시트에서 다시 제출할 수 있다. |
| 성공·이탈 | 성공 전이 때 시트를 닫고 `onRequestSuccess`를 한 번 호출한다. Home의 루트 복귀와 성공 토스트, 입력 유무에 따른 닫기 확인, 확인 시트와 자동 등록 선택의 기존 분석 이벤트를 유지한다. |

## 영향 범위

`LivithApp`에서 생성한 의존성이 `HomeCoordinatorView`를 거쳐 `ConcertRequestView`와 그 모델에 전달된다. `ConcertDataAssembler`의 구현 등록과 `ConcertRequestRepository` 계약은 재사용한다. 현재 공개 화면의 성공·닫기 콜백은 Home 탐색 흐름을 계속 결정한다.

## 기술 결정

| 선택 사항 | 대안 | 결정·근거 | 확인 상태 |
| --- | --- | --- | --- |
| Repository 전달 | 각 화면에서 전역 조회, 루트부터 생성자만 사용 | App에서 조회하고 Home의 Environment 키로 전달한다. 화면 진입점에서 생성자 주입으로 연결한다. | 합의 |
| Environment 키 위치 | 공용 타깃, ShareFeature | Home이 직접 읽는 첫 경로이므로 HomeFeature에 한 번 선언한다. 여러 Feature가 직접 읽을 때 공용 위치를 검토한다. | 합의 |
| 상태 소유 | View와 모델에 초안 분산, 화면 모델에 초안과 제출 상태 집중 | 화면별 ViewModel에 초안과 제출 단계를 두고 View의 표시 상태와 수명을 구분한다. | 합의 |

## 주의 사항

- [현재 아키텍처 규칙](../rules/architecture.md)은 MVI의 `ObservableObject`, `@Published private(set)`, `send(_:)`와 `@Injected` 사용을 명시한다. 계획은 현재 규칙을 변경하지 않으며 구현 전에 공연 요청 범위의 예외를 승인·반영한다.
- Environment 키 기본값에 실제 Repository를 두면 주입이 빠진 Preview도 실제 API를 호출할 수 있다. 앱 경로의 주입을 검증하고 독립 Preview에는 mock을 명시한다.
- ViewModel 초기화는 저장된 프로퍼티 초기화로 끝낸다. 제출만 Repository를 호출하며 제출 상태 변경은 `@MainActor`에서 수행한다.

## 인수인계

- 세션 사용자 SSOT의 후속 완료 기준은 닉네임 변경이 별도 재조회 없이 Home과 User에 반영되고, 계정 전환 시 이전 사용자의 상태가 남지 않는 것이다. 푸시와 콜드 스타트의 `.currentUser` 사용을 확인한 뒤 디스크 저장 정책을 결정한다.
- `ShareFeature`를 `ConcertRequestFeature`로 정리하는 작업과 전역 DI 제거는 파일럿 결과를 바탕으로 각각 진행한다.

## 검증 방법

| 방법·명령 | 기대 신호 | 실제 결과·미확인 사항 |
| --- | --- | --- |
| 계획 문서 링크 및 `git diff --check` | 계획 목록에서 문서로 이동할 수 있고 변경분에 공백 오류가 없다. | 목록과 계획의 로컬 링크 및 변경분 공백 검사 통과 |
| `tuist generate --no-open` 및 `xcodebuild -list` | 프로젝트를 생성하고 ShareFeature 테스트가 포함된 스킴을 확인한다. | 구현 후 실행 |
| 해당 스킴의 `xcodebuild test` | 유효한 입력과 선택 입력 `nil` 전달, 성공·실패, 중복 제출 차단, 실패 토스트 초기화를 mock 직접 주입으로 검증한다. | 구현 후 실행 |
| `xcodebuild build -scheme Livith-iOS-Dev` | App에서 Home과 ShareFeature까지 컴파일하고 연결한다. | 구현 후 실행 |
| 시뮬레이터 및 독립 Preview | 홈에서 요청 화면 진입, 확인 시트 선택, 성공 후 이동, 실패 후 재시도, 닫기 흐름을 확인한다. Preview는 mock으로 동작한다. | 구현 후 확인 |
