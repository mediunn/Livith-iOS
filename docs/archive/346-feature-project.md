# [#346] Feature·Core·Shared 프로젝트 재배치 — 작업 아카이브

## 결과·범위

흩어져 있던 화면 기능과 기존 `Shared`의 `ConcertSearch`, `PreferenceFeature`, `NicknameEditFeature`를 `Feature.xcodeproj`로 모았다. 하나의 프로젝트에 프레임워크 11개와 테스트 타깃 6개를 두고 기능별 경계를 유지했다. `DisplaySupport`는 Shared에 두고 `LivithDesignSystem`을 Shared로 옮겼다. 네트워크 타깃과 테스트는 `LivithNetwork`로 바꿔 Core로 옮겼다. Core의 `Coordinator`와 `Amplitude`는 각각 `Routing`과 `Analytics`로 바꿨다.

홈에서만 쓰는 알림 시간 문구와 관심 공연 카드의 표시 코드를 `HomeFeature`로 옮겼다. 기존 문구, 날짜 계산, Repository 계약과 타깃 의존 방향은 유지했다.

## 남긴 결정

- Core는 공통 인프라를, Shared는 여러 기능이 공유하는 UI와 표시 보조 코드를 맡는다. 프로젝트에 묶이는 위치와 Swift 타깃 경계는 각각 결정한다.
- 화면 Feature 사이의 직접 의존은 Coordinator가 자식 Feature 화면을 연결할 때 허용한다. Domain은 `Date`, `URL` 같은 Foundation 타입을 사용한다. [아키텍처 규칙](../rules/architecture.md)
- 네트워크 전송과 앱 전용 API·DTO는 `LivithNetwork` 타깃에서 관리한다. `LivithFoundation`의 날짜 유틸리티 분리는 후속 검토 대상으로 남겼다.
- App의 직접 의존 선언은 현재 구조를 유지한다. `FirebaseCore`와 `FirebaseMessaging`을 App에 직접 추가한 임시 Dev 빌드에서 `AuthData`와 앱 바이너리에 Objective-C 클래스 101개가 중복 정의됐다. 실험 변경은 원복했다.
- Swift Package 제품명 `LivithDesignSystem`과 기존 타깃의 번들 식별자를 유지했다. `Analytics`의 Amplitude 설정 조회도 기존 번들 식별자를 사용한다.

## 검증 결과

| 방법 | 결과 |
|---|---|
| Tuist 생성 및 통합 전후 그래프·스킴 비교 | 이름과 프로젝트 경로 변경을 대응시킨 뒤 전체 타깃 144개, 직접 의존성 463개, 스킴 37개 및 기존 번들 식별자 일치. Feature 통합 단계에서 기존 테스트 액션 19개도 일치. |
| iPhone 17, iOS 26.5에서 기존 테스트 실행 | 최종 구성에서 `LivithNetwork` 132건, `DisplaySupport` 15건, `HomeFeature` 203건, 나머지 이동 대상 Feature 5개 타깃 49건으로 총 399건 통과. `NoticeStoreTests`는 별도 집중 실행에서도 2건 통과. |
| `xcodebuild build`와 `swift package describe` | `Livith-iOS-Dev`와 `Analytics` Release 빌드 성공. Dev 앱에서 프레임워크, 에셋, 폰트 확인. SwiftPM에서 디자인 시스템 제품과 이동한 소스·리소스 확인. |
| 기존 구현과 이동된 코드 비교 | 홈 알림 문구와 관심 공연 카드의 계산·문구는 동일. |

## 교훈·규칙 반영

- 전역 ignore의 `Icon` 패턴에 걸린 기존 추적 에셋 135개를 새 경로에서 명시적으로 스테이징했다. 디자인 시스템 소스·리소스 290개의 Git 객체를 이동 전과 비교해 모두 일치함을 확인했다.

## 미해결·후속 사항

- 실기기 화면 표시와 Release 환경의 실제 분석 이벤트 전송은 확인하지 않았다.
- `make module-delete`와 `make module-rollback`은 독립 프로젝트 구조를 사용한다. `make sync-dskit`은 이전 `Projects/DSKit` 경로를 사용한다. 배포 워크플로에서는 이 명령들을 호출하지 않는다.

## 추가 기록

- 현재 Tuist 그래프에서 프로젝트 6개, 앱·프레임워크 타깃 33개, 테스트 타깃 19개와 프로젝트 간 직접 의존을 확인해 [모듈 구조 이미지](../../graph.png)를 갱신했다. README의 모듈 구조 섹션에서 이 파일을 표시한다.
- `make module`은 Data·Feature 타깃을 각 통합 매니페스트에 등록하고 Domain은 기존 타깃의 소스 폴더에 추가한다. 임시 복사본에서 전체·단일 레이어 생성, 중복·잘못된 이름·취소·매니페스트 오류 처리와 `tuist generate --no-open`을 확인했다.
- QA와 Release 워크플로 모두 Tuist로 워크스페이스를 다시 생성한다. Fastlane이 사용하는 `Livith-iOS-Dev`, `Livith-iOS` 스킴이 생성된 워크스페이스에 있어 배포 설정의 경로와 이름은 유지했다. 로컬에서 `Livith-iOS` Release 기기 빌드가 서명 없이 성공했다. GitHub Actions 실행, 배포 서명, 업로드는 확인하지 않았다.

## 참조

- [이슈 #346](https://github.com/mediunn/Livith-iOS/issues/346)
- 통합한 계획 `docs/plans/346-feature-project.md`
