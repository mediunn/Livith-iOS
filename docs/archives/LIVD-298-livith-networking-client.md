# LIVD-298 LivithNetworking 클라이언트 구현

## 배경
- `LivithNetworking`에는 요청 생성 책임의 `RequestBuilder`와 응답 처리 책임의 `ResponseHandler`가 분리되어 있다.
- 실제 네트워크 요청 흐름을 만들기 위해 두 타입과 `URLSession` 전송을 연결하는 최소 클라이언트가 필요하다.
- 1차 작업은 인증, refresh, retry, logging, cache 같은 확장 기능을 제외하고 request build, transport, response handling 경계만 고정한다.

## 목표
- `NetworkClient`를 추가해 `NetworkEndpoint` 기반 요청을 실행한다.
- 값이 있는 응답은 `request(_:)` generic 반환 타입으로 제공한다.
- 값이 없는 응답은 void `request(_:)` 오버로드로 제공한다.
- 요청 생성, 전송, 응답 처리 실패를 `NetworkError`로 통합한다.
- 실제 네트워크 없이 테스트할 수 있도록 internal transport 경계를 둔다.

## 작업 항목
- [x] 설계 문서 기준 확인
  - `docs/designs/LIVD-298-livith-networking-client.md`의 결정 사항을 구현 범위로 고정한다.
- [x] request build 실패 red/green
  - 실패 테스트: `NetworkClient`가 request build 실패를 `NetworkError.requestBuildFailed`로 감싸는지 검증한다.
  - 최소 구현: 테스트 컴파일에 필요한 `NetworkError`, `NetworkTransport`, `NetworkClient` 선언과 request build 실패 매핑만 추가한다.
- [x] transport 실패 red/green
  - 실패 테스트: transport 실패를 `NetworkError.transportFailed`로 감싸는지 검증한다.
  - 최소 구현: transport 호출과 transport error mapping만 추가한다.
- [x] invalid response red/green
  - 실패 테스트: HTTP 응답이 아닌 response를 `NetworkError.invalidResponse`로 처리하는지 검증한다.
  - 최소 구현: `HTTPURLResponse` cast 실패 처리를 추가한다.
- [x] 값 응답 성공 red/green
  - 실패 테스트: 값 응답 성공 시 decoded value를 반환하는지 검증한다.
  - 최소 구현: `ResponseHandler`를 통해 값 응답을 반환한다.
- [x] 값 응답 실패 red/green
  - 실패 테스트: 값 응답 실패 status를 `NetworkError.responseFailed`로 처리하고 server message를 보존하는지 검증한다.
  - 최소 구현: `ResponseError` mapping을 추가한다.
- [x] void 응답 성공 red/green
  - 실패 테스트: void 응답 성공 시 HTTP 2xx만으로 성공 처리하는지 검증한다.
  - 최소 구현: void overload와 2xx 성공 처리를 추가한다.
- [x] void 응답 실패 red/green
  - 실패 테스트: void 응답 실패 status에서 `NetworkError.responseFailed(.invalidStatusCode(_, message: _))`로 server message 추출을 시도하는지 검증한다.
  - 실패 body가 비어 있거나 decoding에 실패하면 message는 `nil`로 유지한다.
  - 최소 구현: 실패 status에서만 `ResponseHandler<EmptyResponse>` 경로를 재사용한다.
- [x] 기본 transport 구현 추가
  - `NetworkError`를 추가한다.
  - internal `NetworkTransport` protocol을 추가한다.
  - `URLSessionTransport`를 추가한다.
  - `NetworkClient`를 추가한다.
- [x] green 검증
  - 새 테스트와 기존 `LivithNetworking` 테스트를 실행해 통과를 확인한다.
- [x] 정리
  - 필요한 경우 파일 위치와 접근 제어를 정리한다.
  - 새 Swift 파일 헤더가 기존 형식을 따르는지 확인한다.
- [x] 최종 검증
  - `tuist generate` 필요 여부를 확인하고 필요한 경우 실행한다.
  - `xcodebuild test -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1'`를 실행한다.
  - `git diff --check`를 실행한다.

## 영향 범위
- `Projects/LivithNetworking/Sources/Client/`
- `Projects/LivithNetworking/Tests/Client/`
- `docs/designs/LIVD-298-livith-networking-client.md`
- `docs/plans/LIVD-298-livith-networking-client.md`

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 클라이언트 책임 | 최소 연결 또는 인증 포함 | 최소 연결 | 현재 단계는 `RequestBuilder`, transport, `ResponseHandler` 조합 경계를 고정하는 것이 목적이다. |
| 메서드 이름 | `send`, `request`, `execute` | `request` | HTTP 요청 수행 의도가 명확하고 GET에 치우치지 않는다. |
| 값 응답 API | `request(_:as:)` 또는 `request(_:) -> T` | `request(_:) -> T` | 호출부 타입 문맥으로 응답 타입을 결정하고 불필요한 인자를 줄인다. |
| void 응답 API | `EmptyResponse` 반환 또는 void 오버로드 | void 오버로드 | 호출부에서 빈 응답 타입을 직접 다루지 않아도 된다. |
| 설정 소유 | client 또는 transport | client | `NetworkConfig.baseURL`은 request build 단계의 설정이고 transport 책임과 분리된다. |
| 전송 경계 | protocol, `URLSession` 직접 주입, `URLProtocol` | internal protocol | 테스트 대체는 가능하게 하되 외부 API 표면과 확장 계약은 작게 유지한다. |
| 기본 transport | `URLSessionTransport` 또는 client 직접 호출 | `URLSessionTransport` | `URLSession` wrapping 책임을 분리한다. |
| 에러 노출 | 단계별 에러 또는 통합 에러 | `NetworkError` | 호출부는 한 타입으로 처리하면서 원인 에러를 보존할 수 있다. |
| void 성공 기준 | wrapper decode 또는 2xx 확인 | 2xx 확인 | body가 없거나 wrapper가 없는 성공 응답도 최소 단계에서 처리할 수 있다. |
| void 실패 처리 | message 없음 또는 `ResponseHandler<EmptyResponse>` 재사용 | 실패 경로 재사용 | 실패 status에서 서버 message를 가능한 한 보존한다. |

## 주의 사항
- 기존 `LivithNetwork`는 수정하지 않는다.
- 인증 토큰 삽입, 401 refresh/retry, logging, cache, interceptor 구조는 구현하지 않는다.
- response body 원문을 로그로 남기지 않는다.
- transport protocol은 internal로 두고 endpoint, base URL, response decoding 책임을 갖지 않게 한다.
- `NetworkClient` public initializer는 기본 `RequestBuilder`, `ResponseHandler`를 제공하고 내부에서 `URLSessionTransport`를 구성한다.
- `NetworkClient` internal initializer는 테스트를 위해 transport를 주입받는다.
- `NetworkClient.request`의 endpoint 파라미터는 Swift 6 existential 표기인 `any NetworkEndpoint`를 사용한다.
- `ResponseHandler`는 타입 인스턴스를 보관하고 generic `handle(_:data:response:)` 메서드를 호출한다.
- `NetworkTransport.data(for:)`는 `URLSession.data(for:)`와 fake transport의 원본 에러를 보존하기 위해 untyped `throws`를 사용한다.
- `URLSessionTransport` 자체는 얇은 시스템 API 위임으로 보고 1차 작업에서는 실제 네트워크 단위 테스트를 추가하지 않는다.
- void 응답 성공은 값 응답과 달리 body decoding을 생략하므로 설계 문서의 후속 작업 단서를 유지한다.
- 계획 문서는 후속 조정 가능성을 남기기 위해 작업 완료 후에도 이번에는 `docs/plans/`에 유지하고 아카이브하지 않는다.

## 검증 방법
- 생산 코드 변경 전에 실패 테스트를 먼저 작성하고 실패 원인을 확인한다.
- `xcodebuild test -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1'`
- `git diff --check`
