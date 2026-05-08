# LIVD-298 LivithNetworking 독립 프로젝트 전환

## 배경
- `LivithNetworking`은 Core 하위 타깃이 아니라 독립 Tuist Project로 운영해야 한다.
- 이전 구현에서는 `Projects/Core/LivithNetworking`과 Core 타깃으로 추가했으나, 요구사항 변경으로 별도 프로젝트 구조가 필요하다.
- 독립 프로젝트로 분리하면 후속 통신, 토큰, 캐시 구현을 Core와 분리된 생명주기로 확장할 수 있다.

## 목표
- `LivithNetworking`을 `Projects/LivithNetworking` 독립 프로젝트로 이동한다.
- Core 프로젝트에 추가했던 `LivithNetworking` 타깃과 테스트 타깃을 제거한다.
- `LivithNetworking`, `LivithNetworkingTests` 타깃은 독립 프로젝트에서 선언한다.
- 신규 프로젝트는 외부 라이브러리에 의존하지 않는다.
- 이번 단계에서는 네트워크 기능 타입과 public API를 추가하지 않는다.

## 작업 항목
- [x] Core 하위 타깃 선언 제거
  - `CoreModule`에서 `livithNetworking`, `livithNetworkingTests` case를 제거한다.
  - Core 테스트 소스 경로 매핑에서 `LivithNetworkingTests` 항목을 제거한다.
  - `Projects/Core/Project.swift`에서 `LivithNetworking`, `LivithNetworkingTests` 타깃을 제거한다.
- [x] 독립 프로젝트 helper 선언 추가
  - `ProjectID`에 `livithNetworking`을 추가한다.
  - `LivithNetworkingModule` enum을 추가한다.
  - `TargetID`에 `livithNetworking(LivithNetworkingModule)` case를 추가한다.
  - `TargetDependency`에 후속 의존성 연결용 `livithNetworking(_:)` helper를 추가한다.
- [x] 독립 프로젝트 구성 추가
  - `Projects/LivithNetworking/Project.swift`를 추가한다.
  - `Projects/LivithNetworking/Sources` 디렉터리를 구성한다.
  - `Projects/LivithNetworking/Tests` 디렉터리를 구성한다.
  - 기존 Core 하위 placeholder와 테스트 파일은 독립 프로젝트 위치로 옮긴다.
- [x] 설계 문서 갱신
  - `docs/designs/LIVD-298-livith-networking-boundary.md`의 모듈 위치와 helper 기준을 독립 프로젝트 기준으로 수정한다.
- [x] 검증 및 정리
  - Tuist generate로 독립 프로젝트 인식을 확인한다.
  - `xcodebuild`로 `LivithNetworkingTests`를 실행한다.
  - 설계 문서의 이번 단계 범위를 벗어난 구현이 없는지 확인한다.

## 영향 범위
- `docs/plans/LIVD-298-livith-networking-project.md`
- `docs/designs/LIVD-298-livith-networking-boundary.md`
- `Tuist/ProjectDescriptionHelpers/Module/Module+Constant.swift`
- `Tuist/ProjectDescriptionHelpers/Module/Module+ProjectID.swift`
- `Tuist/ProjectDescriptionHelpers/Module/Module+TargetID.swift`
- `Tuist/ProjectDescriptionHelpers/Module/TargetDependency+Extension.swift`
- `Projects/Core/Project.swift`
- `Projects/Core/LivithNetworking/**`
- `Projects/LivithNetworking/**`

## 기술 결정
- 구현 과정에서 선택이 필요한 사항과 그 결정 근거를 작성한다.

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 프로젝트 위치 | `Projects/Core/LivithNetworking` 또는 `Projects/LivithNetworking` | `Projects/LivithNetworking` | 네트워킹 모듈을 Core와 독립된 생명주기로 확장하기 위해 별도 프로젝트로 둔다. |
| helper 구조 | 직접 문자열 타깃 선언 또는 `ProjectID`/`TargetID` 확장 | helper 확장 | 후속 Data/App 의존성 연결 시 기존 프로젝트 구조와 일관된 방식으로 참조할 수 있다. |
| 첫 구현 범위 | 빈 프로젝트 또는 기초 타입 포함 | 빈 프로젝트 | 후속 설계 없이 `NetworkService` 등 API를 먼저 고정하지 않기 위해 기능 타입을 만들지 않는다. |
| 외부 의존성 | Alamofire 포함 또는 의존성 없음 | 의존성 없음 | `LivithNetworking`은 라이브러리 의존 없는 네트워크 모듈로 확장하는 것이 목표다. |

## 주의 사항
- `LivithNetwork`의 기존 파일은 수정하지 않는다.
- Data 모듈, Feature 모듈, App 모듈의 `LivithNetwork` 의존은 변경하지 않는다.
- `NetworkService`, `NetworkEndpoint`, `HTTPMethod`, `NetworkError` 같은 기능 타입은 이번 작업에서 추가하지 않는다.
- DTO, API endpoint, 토큰, ETag 캐시 관련 코드는 이번 작업에서 추가하지 않는다.
- `LivithNetworking` 프로젝트에 Alamofire 또는 다른 외부 라이브러리 의존성을 추가하지 않는다.
- 테스트는 항상 `xcodebuild`를 사용하고, iPhone 17 시뮬레이터와 OS 26.4.1을 대상으로 실행한다.
- 구현 완료 후 이 계획 문서는 `docs/archives/`로 이동한다.

## 검증 방법
- `tuist generate`
- `xcodebuild test -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1'`
- `git diff --check`
- 환경 제약으로 명령 실행이 실패하면 실패 명령, 오류 요약, 미검증 범위를 최종 보고에 남긴다.
