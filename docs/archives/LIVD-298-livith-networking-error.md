# LIVD-298 LivithNetworking 에러 구체화

## 배경
- `LivithNetworking`의 현재 `NetworkError`는 `requestBuildFailed`, `transportFailed`, `responseFailed`처럼 실패 단계 중심으로 구성되어 있다.
- 호출부가 `unauthorized`, `serverError`, `timeout`, `decodingFailed` 같은 의미 기반 분기를 하기 어렵다.
- 기존 `LivithNetwork`의 에러 모델은 참고하되 그대로 복제하지 않고, 신규 모듈의 현재 범위에 맞게 네트워크 레벨 에러만 구체화한다.

## 목표
- `NetworkError`를 호출부가 분기하기 쉬운 의미 기반 에러로 재정의한다.
- HTTP status code는 주요 케이스를 named case로 분리하고 서버 `message`를 보존한다.
- `NetworkError`는 `LocalizedError`를 채택하고 기본 한글 설명을 제공한다.
- `RequestBuildError`, `ResponseError`도 필요한 범위에서 원본 원인을 보존하도록 조정한다.
- 도메인 에러 매핑, 인증 token refresh/retry, logging 기능은 이번 범위에서 제외한다.

## 작업 항목
- [x] 설계 기준 확인
  - 기존 `LivithNetwork.NetworkError`, `ErrorMapper`, `ResponseHandler`의 분류 방식은 참고만 한다.
  - 신규 `LivithNetworking`의 public error API는 의미 기반으로 정리한다.
- [x] `NetworkError` 케이스 red/green
  - 실패 테스트: 기존 단계 기반 wrapper 케이스 대신 의미 기반 케이스로 분기할 수 있어야 한다.
  - 새 enum case를 테스트에서 참조하기 전, 컴파일을 위한 최소 case 선언만 먼저 추가하고 런타임 실패를 확인한다.
  - 최소 구현: `invalidURL`, `invalidRequest`, `encodingFailed`, `noConnection`, `timeout`, `cancelled`, `invalidResponse`, `noData`, `decodingFailed`, HTTP 에러, `unknown` 케이스를 추가한다.
- [x] request build 에러 매핑 red/green
  - 실패 테스트: invalid URL은 `NetworkError.invalidURL`로 매핑되어야 한다.
  - 실패 테스트: encoding 실패는 `NetworkError.encodingFailed(Error)`로 원본 에러를 보존해야 한다.
  - 테스트 방식: `RequestBuildError`는 `Error` 연관값 때문에 `Equatable` 자동 합성이 불가능하므로 pattern matching과 원본 error 타입 확인으로 검증한다.
  - 최소 구현: `RequestBuildError.encodingFailed(Error)`로 원인을 보존하고 `NetworkClient`에서 의미 기반 에러로 매핑한다.
- [x] transport 에러 매핑 red/green
  - 실패 테스트: `CancellationError`는 `NetworkError.cancelled`로 매핑되어야 한다.
  - 실패 테스트: `URLError.cancelled`도 `NetworkError.cancelled`로 매핑되어야 한다.
  - 실패 테스트: `URLError.timedOut`은 `NetworkError.timeout(Error)`로 매핑되어야 한다.
  - 실패 테스트: `URLError.notConnectedToInternet`, `networkConnectionLost`, `cannotConnectToHost`, `cannotFindHost`, `dnsLookupFailed`는 `NetworkError.noConnection(Error)`로 매핑되어야 한다.
  - 실패 테스트: 그 외 transport error는 `NetworkError.unknown(Error)`으로 매핑되어야 한다.
- [x] HTTP status 에러 매핑 red/green
  - 실패 테스트: 400은 `badRequest(message:)`로 매핑되어야 한다.
  - 실패 테스트: 401은 `unauthorized(message:)`로 매핑되어야 한다.
  - 실패 테스트: 403은 `forbidden(message:)`으로 매핑되어야 한다.
  - 실패 테스트: 404는 `notFound(message:)`로 매핑되어야 한다.
  - 실패 테스트: 기타 4xx는 `clientError(statusCode:message:)`로 매핑되어야 한다.
  - 실패 테스트: 5xx는 `serverError(statusCode:message:)`로 매핑되어야 한다.
  - 실패 테스트: 값 응답 실패와 void 응답 실패 모두에서 status code와 서버 message가 보존되어야 한다.
  - 최소 구현: status code mapper를 한 곳에 둔다.
- [x] response 처리 에러 매핑 red/green
  - 실패 테스트: non-HTTP response는 `NetworkError.invalidResponse`로 매핑되어야 한다.
  - 실패 테스트: 값 응답 성공 status에서 wrapper `data`가 없으면 `NetworkError.noData`로 매핑되어야 한다.
  - 실패 테스트: 값 응답 성공 status에서 decoding 실패는 `NetworkError.decodingFailed(Error)`로 매핑되어야 한다.
  - 유지 조건: void 응답 성공은 기존 설계대로 body decoding 없이 2xx만으로 성공해야 한다.
  - 최소 구현: `ResponseError`를 `NetworkError` 의미 기반 케이스로 변환한다.
- [x] `LocalizedError` red/green
  - 실패 테스트: `NetworkError.errorDescription`은 기본 한글 설명을 제공해야 한다.
  - 실패 테스트: HTTP 에러 설명은 서버 `message`를 포함해야 한다.
  - 실패 테스트: HTTP 에러의 서버 `message`가 `nil`이어도 기본 한글 설명은 비어 있지 않아야 한다.
  - 최소 구현: 사용자에게 바로 노출해도 크게 어색하지 않은 일반 문구를 제공한다.
- [x] 기존 `NetworkClient` 테스트 갱신
  - `requestBuildFailed`, `transportFailed`, `responseFailed` 기대값을 새 의미 기반 에러로 변경한다.
  - 값 응답, void 응답 성공 동작은 유지한다.
- [x] 문서 업데이트
  - `docs/designs/LIVD-298-livith-networking-client.md`에 새 에러 정책을 반영한다.
  - `Projects/LivithNetworking/README.md`의 에러 다이어그램, catch 예시, `LocalizedError` 설명 정책을 새 모델로 갱신한다.
- [x] 최종 검증
  - `xcodebuild test -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1'`를 실행한다.
  - `git diff --check`를 실행한다.

## 영향 범위
- `Projects/LivithNetworking/Sources/Client/NetworkError.swift`
- `Projects/LivithNetworking/Sources/Client/NetworkClient.swift`
- `Projects/LivithNetworking/Sources/Request/RequestBuilder.swift`
- `Projects/LivithNetworking/Sources/Response/ResponseError.swift`
- `Projects/LivithNetworking/Sources/Response/ResponseHandler.swift`
- `Projects/LivithNetworking/Tests/Client/NetworkClientTests.swift`
- `Projects/LivithNetworking/Tests/Request/RequestBuilderTests.swift`
- `Projects/LivithNetworking/Tests/Response/ResponseHandlerTests.swift`
- `Projects/LivithNetworking/README.md`
- `docs/designs/LIVD-298-livith-networking-client.md`

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 에러 노출 기준 | 실패 단계 또는 의미 기반 | 의미 기반 | 호출부가 대응 방식을 명확하게 분기할 수 있어야 한다. |
| 단계 기반 wrapper | 유지 또는 제거 | 제거 | `requestBuildFailed`, `transportFailed`, `responseFailed`는 호출부 분기 기준으로는 추상도가 맞지 않는다. |
| HTTP 400/401/403/404 | 전용 케이스 또는 status fallback | 전용 케이스 | 호출부에서 자주 분기할 가능성이 높은 status다. |
| 기타 4xx/5xx | 통합 status error 또는 fallback 분리 | `clientError`, `serverError` | status code와 message를 보존하면서 케이스 수를 과도하게 늘리지 않는다. |
| 서버 message | 버림, 연관값만 보존, description 포함 | 연관값 보존 및 description 포함 | 서버가 제공한 실패 이유를 호출부와 기본 설명에서 활용할 수 있다. |
| 도메인 에러 매핑 | 포함 또는 제외 | 제외 | repository/domain 전환 단계의 책임이며 네트워크 모듈이 도메인을 알면 안 된다. |
| 원본 에러 보존 | 버림 또는 연관값 보존 | 연관값 보존 | debugging과 후속 logging 설계에 필요한 원인을 잃지 않는다. |
| `LocalizedError` | 채택 또는 미채택 | 채택 | 기존 모듈과 Domain error 흐름과 맞추고 기본 설명을 제공한다. |
| `RequestBuildError` 동등성 | `Equatable` 유지 또는 제거 | 제거 | `encodingFailed(Error)`가 원본 에러를 보존하면 자동 동등성 비교가 불가능하다. |

## 주의 사항
- 기존 `LivithNetwork` 파일은 수정하지 않는다.
- 기존 `LivithNetwork.NetworkError`를 그대로 복제하지 않는다.
- `LivithNetworking`에서 Domain error를 import하거나 매핑하지 않는다.
- 인증 토큰 삽입, 401 refresh/retry, interceptor 구조는 구현하지 않는다.
- response body 원문을 logging하거나 `errorDescription`에 포함하지 않는다.
- 서버 `message`만 HTTP 에러 연관값과 `errorDescription`에 포함한다.
- `RequestBuildError`와 `NetworkError`의 `Error` 연관값은 동등성 비교 대신 case와 원본 타입 보존을 검증한다.
- 테스트는 `Testing` 기반으로 작성하고 `#require`는 중첩하지 않는다.

## 검증 방법
- 생산 코드 변경 전에 실패 테스트를 먼저 작성하고 실패 원인을 확인한다.
- `xcodebuild test -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1'`
- `git diff --check`
