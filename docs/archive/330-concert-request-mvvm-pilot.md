# [#330] 공연 요청 화면의 Environment DI와 Observable MVVM 적용 — 작업 아카이브

## 결과·범위

App에서 기존 Assembler를 등록한 뒤 `ConcertRequestRepository`를 조회해 Home의 SwiftUI Environment에 전달한다. `HomeCoordinatorView`는 공연 요청 경로에서 값을 읽어 화면 모델에 생성자로 전달한다. 미주입 경로에서는 이전 화면으로 돌아갈 수 있다. 독립 Preview와 테스트는 각각 대역을 직접 제공한다.

화면별 `@MainActor @Observable` ViewModel이 입력 초안과 제출 단계를 소유한다. 기존 도메인 입력 정규화와 자동 등록 선택을 사용한다. 화면은 포커스, 확인 시트, 실패 토스트와 닫기 모달을 표시하고 성공·닫기 콜백을 호출한다. DI 이전과 ViewModel 전환은 별도 커밋으로 남겼다.

## 남긴 결정

- Environment 키는 직접 읽는 첫 경로인 HomeFeature가 소유한다. 여러 Feature가 같은 값을 직접 읽을 때 공용 키 위치를 검토한다.
- ViewModel을 화면의 `@State`에 보관하고 성공하면 기존 Home 루트 복귀와 성공 토스트를 호출한다. 실패한 초안은 유지하며, 토스트를 닫고 다시 제출할 수 있다.

## 검증 결과

| 방법·명령 | 기대 신호 | 실제 결과 |
| --- | --- | --- |
| Swift 6.2.3의 `swiftc -frontend -parse` | 변경한 Swift 소스의 구문 파싱 | 통과 |
| Linux의 임시 SwiftPM 패키지에서 `swift test` | 실제 Domain 계약·ViewModel·테스트로 입력 정규화, 선택 입력, 성공·실패, 중복 호출, 재시도 검증 | Swift 6.2.3의 Swift 5·Swift 6 언어 모드에서 각각 5건 통과 |
| 전체 Domain 소스의 `swiftc -swift-version 6 -emit-module` | 전체 Domain의 동시성 검사 | 기존 `Nickname.regex`의 `Regex<Substring>` 공유 저장 진단으로 실패. 변경 전 커밋에서도 재현 |
| `tuist generate --no-open`, Xcode의 ShareFeature 테스트와 Dev 앱 빌드 | iOS 모듈 연결과 실제 테스트 타깃 확인 | Linux 실행 환경에서 미실행 |
| iOS 시뮬레이터와 독립 Preview | 진입·닫기, 성공 후 이동과 실패 후 재시도 확인 | 미확인 |

## 교훈·규칙 반영

- 아키텍처 문서에 #330 화면에 한정해서 Environment·생성자 주입과 Observation 상태 소유권을 명시했다.
- 공연 요청 Repository와 불변 요청 값에 `Sendable`을 명시해 MainActor와 비격리 비동기 호출 사이의 전달 계약을 표현한다. 테스트 대역의 가변 상태와 콜백은 `@MainActor`에 둔다.

## 미해결·후속 사항

- Xcode 앱 빌드와 시뮬레이터 검증이 남아 있다. 전체 Domain의 Swift 6 전환에는 기존 `Nickname.regex` 진단을 별도로 해결해야 한다.
- 세션 사용자 상태는 홈과 프로필이 같은 `currentUser`를 읽도록 후속 작업에서 다룬다. 콜드 스타트 및 푸시의 `.currentUser` 사용을 확인한 뒤 디스크 저장 정책을 결정한다.
- 앱 전체 전역 DI 제거, 공용 Environment 타깃 도입, `ShareFeature` 이름 변경은 후속 범위다.

## 참조

- [GitHub 이슈 #330](https://github.com/mediunn/Livith-iOS/issues/330)
- 통합한 계획 `docs/plans/330-concert-request-mvvm-pilot.md`
