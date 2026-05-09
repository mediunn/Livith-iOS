# LIVD-298 LivithNetworking 클라이언트 설계

## 배경
- `LivithNetworking`에는 요청을 `URLRequest`로 만드는 `RequestBuilder`와 응답을 값으로 변환하는 `ResponseHandler`가 이미 분리되어 있다.
- 다음 단계에서는 두 타입을 실제 `URLSession` 전송 흐름과 연결하는 최소 실행 단위가 필요하다.
- 1차 `NetworkClient`는 인증, refresh, retry, cache, logging 같은 확장 기능보다 요청 생성, 전송, 응답 처리의 경계를 먼저 고정한다.
- 실제 전송은 테스트에서 대체 가능해야 하므로 `URLSession`을 직접 고정하지 않고 작은 transport 경계를 둔다.

## 목표
- `LivithNetworking`에 `NetworkClient` 타입을 둔다.
- `NetworkClient`는 `NetworkEndpoint`를 받아 HTTP 요청을 수행한다.
- 값이 있는 응답은 generic 반환 타입으로 decode해 반환한다.
- 값이 없는 응답은 void 오버로드로 처리한다.
- request build, transport, response 처리 실패를 `NetworkError` 하나로 노출한다.
- 전송 책임은 internal transport protocol과 `URLSessionTransport`로 분리한다.

## 범위
- `NetworkClient`의 public initializer는 `NetworkConfig`, `RequestBuilder`, `ResponseHandler`를 받고 기본 transport는 내부에서 `URLSessionTransport`로 구성한다.
- `NetworkClient`의 internal initializer는 테스트를 위해 transport를 주입받는다.
- `NetworkConfig`는 `NetworkClient`가 보관한다.
- `RequestBuilder`는 `NetworkEndpoint`와 `NetworkConfig`를 조합해 `URLRequest`를 만든다.
- transport는 이미 만들어진 `URLRequest`를 실행해 `(Data, URLResponse)`를 반환한다.
- `URLSessionTransport`는 `URLSession`을 감싸는 concrete transport로 둔다.
- transport protocol은 internal로 둔다.
- 값 응답 API는 `request(_:) async throws(NetworkError) -> T` 형태로 둔다.
- void 응답 API는 `request(_:) async throws(NetworkError)` 형태로 둔다.
- 값 응답은 `ResponseHandler`를 통해 `ServerResponse<T>` decoding 규칙을 따른다.
- void 응답은 HTTP status code가 `200..<300`이면 성공으로 처리하고 body decoding은 생략한다.
- void 응답의 실패 status에서는 `ResponseHandler<EmptyResponse>` 경로를 사용해 서버 message 추출을 시도한다.
- void 응답의 실패 body가 비어 있거나 decoding에 실패하면 message는 `nil`로 둔다.
- `URLResponse`가 `HTTPURLResponse`가 아니면 `NetworkError.invalidResponse`로 처리한다.
- transport에서 발생한 에러는 `NetworkError.transportFailed`로 감싼다.

## 비목표
- 이번 설계에서 인증 토큰 삽입을 구현하지 않는다.
- 이번 설계에서 401 refresh와 retry를 다루지 않는다.
- 이번 설계에서 request/response logging을 다루지 않는다.
- 이번 설계에서 ETag cache를 다루지 않는다.
- 이번 설계에서 interceptor 구조를 만들지 않는다.
- 이번 설계에서 status code별 도메인 에러 매핑을 다루지 않는다.
- 이번 설계에서 외부 모듈이 custom transport를 주입하는 public 확장 지점을 열지 않는다.
- 이번 설계에서 transport가 endpoint, base URL, response decoding 책임을 갖지 않는다.
- 이번 설계에서 기존 `LivithNetwork`를 수정하지 않는다.

## 결정
| 결정 사항 | 결정 | 근거 |
|-----------|------|------|
| 클라이언트 타입 | `NetworkClient` | 요청 생성, 전송, 응답 처리를 연결하는 진입점임이 드러난다. |
| 메서드 이름 | `request` | HTTP 요청 수행 의미가 `send`보다 명확하고 `fetch`보다 범용적이다. |
| 값 응답 API | `request(_:) async throws(NetworkError) -> T` | 호출부 타입 문맥으로 응답 타입을 결정할 수 있고 불필요한 `as` 인자를 줄인다. |
| void 응답 API | `request(_:) async throws(NetworkError)` | 값이 없는 성공 요청을 호출부에서 `EmptyResponse` 없이 표현할 수 있다. |
| 설정 소유 | `NetworkClient` | `baseURL`은 request build에 필요한 클라이언트 단위 설정이고 transport 실행 책임과 분리된다. |
| 전송 경계 | internal transport protocol | 테스트 대체는 가능하게 하되 외부 API 표면과 확장 계약은 작게 유지한다. |
| 기본 전송 구현 | `URLSessionTransport` | `URLSession`을 감싸되 client가 세션 구체 타입에 직접 묶이지 않게 한다. |
| transport 책임 | `URLRequest` 실행만 담당 | endpoint, base URL, response decoding 책임이 transport로 새지 않게 한다. |
| 에러 노출 | `NetworkError` | 호출부가 네트워크 요청 실패를 한 타입으로 처리하면서 원인 에러를 보존할 수 있다. |
| build 실패 | `.requestBuildFailed(RequestBuildError)` | request 생성 실패를 transport/response 실패와 구분한다. |
| 전송 실패 | `.transportFailed(Error)` | URL loading 단계의 원본 에러를 보존한다. |
| HTTP 응답 아님 | `.invalidResponse` | `URLResponse`가 HTTP 응답이 아닌 경우를 명확히 분리한다. |
| 응답 처리 실패 | `.responseFailed(ResponseError)` | status code와 decoding 실패는 기존 응답 처리 계약을 재사용한다. |
| void 성공 기준 | HTTP `200..<300` | body가 없거나 wrapper가 없는 성공 응답도 최소 클라이언트 단계에서 처리할 수 있다. |
| void 실패 처리 | `ResponseHandler<EmptyResponse>` 실패 경로 재사용 | 실패 status에서는 서버 message를 가능한 한 보존한다. |

## 에러 경계
```swift
public enum NetworkError: Error {
    case requestBuildFailed(RequestBuildError)
    case transportFailed(Error)
    case invalidResponse
    case responseFailed(ResponseError)
}
```

- `RequestBuilder.make(endpoint:config:)`에서 던진 에러는 `.requestBuildFailed`로 감싼다.
- transport의 `data(for:)`에서 던진 에러는 `.transportFailed`로 감싼다.
- transport가 반환한 response가 `HTTPURLResponse`가 아니면 `.invalidResponse`를 던진다.
- `ResponseHandler`에서 던진 에러는 `.responseFailed`로 감싼다.

## API 형태
```swift
public struct NetworkClient {
    public init(
        config: NetworkConfig,
        requestBuilder: RequestBuilder = RequestBuilder(),
        responseHandler: ResponseHandler = ResponseHandler()
    )

    init(
        config: NetworkConfig,
        requestBuilder: RequestBuilder = RequestBuilder(),
        responseHandler: ResponseHandler = ResponseHandler(),
        transport: any NetworkTransport
    )

    public func request<T: Decodable>(
        _ endpoint: any NetworkEndpoint
    ) async throws(NetworkError) -> T

    public func request(
        _ endpoint: any NetworkEndpoint
    ) async throws(NetworkError)
}
```

## Transport 형태
```swift
protocol NetworkTransport {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

struct URLSessionTransport: NetworkTransport {
    init(session: URLSession = .shared)

    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}
```

- `NetworkTransport`는 internal로 둔다.
- `URLSessionTransport`는 `URLSession.data(for:)`를 위임한다.
- `NetworkConfig`는 transport가 아니라 `NetworkClient`가 가진다.
- transport가 가질 수 있는 설정은 이후 필요해지면 `URLSessionConfiguration`, timeout, cache policy 같은 전송 실행 정책으로 제한한다.
- `NetworkTransport.data(for:)`는 `URLSession.data(for:)`와 fake transport의 원본 에러를 보존하기 위해 untyped `throws`를 사용한다.
- `URLSessionTransport` 자체는 얇은 시스템 API 위임이므로 1차 작업에서는 실제 네트워크 단위 테스트를 추가하지 않고, `NetworkClient`는 fake transport로 검증한다.

## 후속 작업
- 인증 설계에서 `requiresAuthentication`이 `true`인 endpoint에 토큰 삽입을 적용한다.
- refresh 설계에서 401 응답과 retry 정책을 정의한다.
- logging 설계가 필요해지면 민감한 request/response body 원문을 남기지 않는 정책을 먼저 정의한다.
- void 응답도 서버 wrapper 규칙을 반드시 따라야 하는 요구가 생기면 `ResponseHandler<EmptyResponse>` 성공 경로를 재사용하도록 바꾼다.
