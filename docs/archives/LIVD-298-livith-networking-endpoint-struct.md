# LIVD-298 LivithNetworking Endpoint 구조체 전환

## 배경
- 현재 `LivithNetworking.NetworkEndpoint`는 protocol이며 테스트와 호출부가 이를 채택하는 별도 타입을 만들어야 한다.
- 신규 네트워킹 방향에서는 endpoint를 값 타입 명세로 다루고, 이후 서비스가 endpoint 명세를 직접 제공하도록 보일러플레이트를 줄이고자 한다.
- 이번 작업은 서비스 추상화나 repository migration 전 단계로, endpoint 표현만 struct로 고정한다.

## 목표
- `NetworkEndpoint` 이름을 유지하면서 protocol을 struct 값 타입으로 전환한다.
- `path`, `method`, `task`, `headers`, `requiresAuthentication`을 저장 프로퍼티로 제공한다.
- initializer 기본값으로 `task = .plain`, `headers = [:]`, `requiresAuthentication = true`를 제공한다.
- `any NetworkEndpoint` existential 사용을 제거한다.

## 작업 항목
- [x] 설계 기준 확인
  - static factory method는 이번 범위에서 제외한다.
  - 서비스 추상화, 구체 서비스 은닉, Data repository migration은 제외한다.
- [x] `NetworkEndpoint` struct red/green
  - 실패 테스트: 기본 initializer로 `path`와 `method`를 저장해야 한다.
  - 실패 테스트: `task`, `headers`, `requiresAuthentication` 기본값을 제공해야 한다.
  - 실패 테스트: `task`, `headers`, `requiresAuthentication`을 명시값으로 재정의할 수 있어야 한다.
  - 최소 구현: `NetworkEndpoint`를 struct로 전환하고 기본값 있는 public initializer를 추가한다.
- [x] `RequestBuilder` 적용 red/green
  - 실패 테스트: 테스트 helper endpoint type 없이 `NetworkEndpoint` 값으로 request를 생성해야 한다.
  - 최소 구현: `RequestBuilder.make`와 private helper 파라미터에서 `any NetworkEndpoint`를 제거한다.
- [x] `NetworkClient` 적용 red/green
  - 실패 테스트: 테스트 helper endpoint type 없이 `NetworkEndpoint` 값으로 request를 실행해야 한다.
  - 최소 구현: 값 응답, void 응답, load 파라미터에서 `any NetworkEndpoint`를 제거한다.
- [x] 문서 업데이트
  - `Projects/LivithNetworking/README.md`에서 `NetworkEndpoint` protocol 표기와 `any NetworkEndpoint` 표기를 제거한다.
  - `docs/designs/LIVD-298-livith-networking-basic-request.md`에서 endpoint를 struct 값 타입 명세로 설명한다.
  - `docs/designs/LIVD-298-livith-networking-client.md`의 API 예시에서 `any NetworkEndpoint`를 제거한다.
- [x] 최종 검증
  - `xcodebuild test -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1'`를 실행한다.
  - `git diff --check`를 실행한다.

## 영향 범위
- `Projects/LivithNetworking/Sources/Request/NetworkEndpoint.swift`
- `Projects/LivithNetworking/Sources/Request/RequestBuilder.swift`
- `Projects/LivithNetworking/Sources/Client/NetworkClient.swift`
- `Projects/LivithNetworking/Tests/Request/NetworkEndpointTests.swift`
- `Projects/LivithNetworking/Tests/Request/RequestBuilderTests.swift`
- `Projects/LivithNetworking/Tests/Client/NetworkClientTests.swift`
- `Projects/LivithNetworking/README.md`
- `docs/designs/LIVD-298-livith-networking-basic-request.md`
- `docs/designs/LIVD-298-livith-networking-client.md`

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| endpoint 표현 | protocol 또는 struct | struct | endpoint를 값 타입 요청 명세로 직접 전달해 별도 채택 타입 보일러플레이트를 줄인다. |
| 타입 이름 | `NetworkEndpoint` 또는 `Endpoint` | `NetworkEndpoint` | 기존 의미와 파일명을 유지하고 변경 범위를 줄인다. |
| 생성 방식 | initializer, factory, 둘 다 | initializer | factory method는 후속으로 보류하고 이번에는 기본값 있는 생성자로 충분히 단순화한다. |
| 인증 기본값 | `true`, `false`, 명시 강제 | `true` | 기존 protocol extension 기본값과 현재 인증 필요 요청 중심 설계를 유지한다. |
| `Sendable` 채택 | 채택 또는 보류 | 보류 | `RequestTask`가 `any Encodable` body를 보관해 현재 단계에서 안전한 `Sendable` 합성이 어렵다. |

## 주의 사항
- 기존 `Projects/Core/LivithNetwork`의 `NetworkEndpoint` protocol은 수정하지 않는다.
- 기존 Data repository와 service typealias는 수정하지 않는다.
- `docs/rules/architecture.md`의 기존 네트워크 규칙은 `LivithNetwork` 기준이므로, 이번 신규 모듈 변경은 `LivithNetworking` 설계 문서에 한정해 반영한다.
- static factory method는 이번 작업에서 추가하지 않는다.
- 토큰, interceptor, auth 적용은 이번 작업에서 다루지 않는다.

## 검증 방법
- 생산 코드 변경 전에 실패 테스트를 먼저 작성하고 실패 원인을 확인한다.
- `xcodebuild test -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1'`
- `git diff --check`
