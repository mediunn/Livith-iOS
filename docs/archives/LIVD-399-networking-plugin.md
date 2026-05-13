# LIVD-399 LivithNetworking Plugin

## 배경
- `LivithNetworking`은 현재 `RequestBuilder`, `NetworkClient`, `NetworkTransport`, `ResponseHandler`, `RequestInterceptor` 중심으로 요청 흐름을 구성한다.
- 현재 확장 지점인 `RequestInterceptor`는 인증 헤더 삽입과 401 refresh/retry에 초점이 맞춰져 있어, 로깅·공통 헤더·activity tracking·metrics 같은 범용 네트워크 생명주기 확장을 담기에는 책임이 넓어진다.
- `NetworkClient` 내부를 반복 수정하지 않고 요청/응답 흐름에 부수효과 또는 가벼운 요청 수정을 추가할 수 있는 단순한 플러그인 구조가 필요하다.

## 목표
- `RequestInterceptor`의 인증/재시도 책임은 유지하고, 별도의 `NetworkPlugin` 확장 지점을 추가한다.
- 플러그인은 요청 생성 이후, 실제 전송 직전, 응답/전송 실패 직후의 생명주기를 관찰하거나 요청을 수정할 수 있어야 한다.
- 실제 사용 가능한 디버깅용 구체 타입 `DebugNetworkPlugin`을 제공한다.
- 디버깅 플러그인은 기본적으로 안전한 로그만 출력하고, 출력 방식은 클로저로 교체 가능해야 한다.
- 변경 사항은 테스트로 검증하고 `README.md`의 구조/사용 예시를 갱신한다.

## 작업 항목
- [x] 실패 테스트 작성 및 red 확인
  - `NetworkPlugin` 테스트 컴파일에 필요한 최소 선언만 먼저 추가한다.
  - `Projects/LivithNetworking/Tests/Plugin/NetworkPluginTests.swift`를 추가한다.
  - `Projects/LivithNetworking/Tests/Plugin/DebugNetworkPluginTests.swift`를 추가한다.
  - `NetworkClient` 통합 동작은 `Projects/LivithNetworking/Tests/Client/NetworkClientTests.swift`에 추가한다.
  - 신규 테스트가 생산 코드 구현 전 기대한 이유로 실패하는지 확인한다.
- [x] 플러그인 API 최소 구현
  - `Projects/LivithNetworking/Sources/Plugin/NetworkPlugin.swift`를 추가한다.
  - 같은 파일 안에 `NetworkPlugin`과 `NetworkPluginResponse`를 정의한다.
  - 한 파일 안의 타입 구분을 위해 `// MARK: - NetworkPlugin`, `// MARK: - Default Implementation`, `// MARK: - NetworkPluginResponse`를 사용한다.
  - 첫 구현의 `NetworkPluginResponse`는 `data`, `response`만 가진다.
- [x] `NetworkClient`에 플러그인 생명주기 통합
  - `NetworkClient` 생성자에 `plugins: [any NetworkPlugin] = []` 파라미터를 추가한다.
  - 요청 생성 후 `prepare`를 플러그인 배열 순서대로 적용한다.
  - 인증 endpoint에서는 `prepare` 이후 기존 `RequestInterceptor.adapt`를 적용한다.
  - 실제 transport 호출 직전에 `willSend`를 호출한다.
  - `didReceive`는 transport 경계에서 호출한다.
  - HTTPURLResponse 수신 시 status code와 무관하게 `.success(NetworkPluginResponse)`로 호출한다.
  - transport throw 또는 non-HTTP response는 `.failure(NetworkError)`로 호출한다.
  - `prepare` 실패와 `RequestInterceptor.adapt` 실패는 실제 전송 전 실패이므로 `didReceive`를 호출하지 않는다.
  - `ResponseHandler`의 status mapping 또는 decoding 실패는 이번 plugin hook 범위에 포함하지 않는다.
  - 401 retry로 재전송할 때도 동일한 플러그인 흐름을 다시 적용한다.
- [x] `DebugNetworkPlugin` 구체 타입 구현
  - `Projects/LivithNetworking/Sources/Plugin/DebugNetworkPlugin.swift`를 추가한다.
  - 요청 method, query를 제거한 URL의 scheme/host/path, 응답 status code, 전송 실패의 요약 정보만 출력한다.
  - 기본 출력은 `print`로 두되, `@Sendable (String) -> Void` 클로저 주입으로 출력 방식을 교체할 수 있게 한다.
  - 기본 구현에서는 request/response header를 출력하지 않는다.
  - 향후 header 출력 옵션을 추가할 경우 `Authorization`, `Cookie`, `Set-Cookie`, `X-API-Key`, `API-Key` 등 민감 헤더는 항상 `[REDACTED]`로 마스킹한다.
  - query string과 요청/응답 body 원문 출력은 이번 범위에서 제외한다.
- [x] green 확인 및 보호 테스트 보강
  - `prepare`가 수정한 요청이 실제 transport로 전달되는지 검증한다.
  - 여러 플러그인의 `prepare`가 배열 순서대로 적용되는지 검증한다.
  - `willSend`와 `didReceive`가 성공 응답에서 호출되는지 검증한다.
  - transport 실패가 `didReceive(.failure)`로 전달되는지 검증한다.
  - non-HTTP response가 `didReceive(.failure(.invalidResponse))`로 전달되는지 검증한다.
  - `prepare` 실패 시 transport를 호출하지 않고 `NetworkError`를 던지는지 검증한다.
  - 401 retry 시 첫 요청과 재시도 요청 각각에 `prepare`, `willSend`, `didReceive`가 호출되는지 검증한다.
  - 첫 401 응답은 retry 판단 전 `didReceive(.success)`로 관찰 가능해야 함을 검증한다.
  - `DebugNetworkPlugin`의 output 클로저로 출력이 수집되는지 검증한다.
  - `DebugNetworkPlugin`이 query string, body, 민감 헤더 값을 원문으로 출력하지 않는지 검증한다.
- [x] 문서 갱신
  - `Projects/LivithNetworking/README.md`의 타입 관계, 요청 흐름, 사용 예시, 보안 정책, 검증 명령을 갱신한다.
  - 플러그인과 인터셉터의 책임 분리를 표 또는 별도 섹션으로 명시한다.
  - `DebugNetworkPlugin` 사용 예시는 `#if DEBUG` 조건부 등록만 제공한다.
  - 디버그 로그가 query string, body, 민감 헤더 값을 출력하지 않는다는 제한을 명시한다.
- [x] 검증 및 정리
  - `tuist generate`를 실행한다.
  - `xcodebuild test -workspace Livith-iOS.xcworkspace -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17'`를 실행한다.
  - `git diff --check`를 실행한다.

## 영향 범위
- `Projects/LivithNetworking/Sources/Plugin/NetworkPlugin.swift`
- `Projects/LivithNetworking/Sources/Plugin/DebugNetworkPlugin.swift`
- `Projects/LivithNetworking/Sources/Client/NetworkClient.swift`
- `Projects/LivithNetworking/Tests/Client/NetworkClientTests.swift`
- `Projects/LivithNetworking/Tests/Plugin/*`
- `Projects/LivithNetworking/README.md`

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 인증 확장과 범용 플러그인 관계 | `RequestInterceptor`에 hook 추가 / 별도 `NetworkPlugin` 추가 | 별도 `NetworkPlugin` 추가 | 인증/401 retry 책임과 로깅·metrics 같은 범용 생명주기 책임을 분리해 기존 인증 흐름의 의미를 유지한다. |
| 플러그인 hook 범위 | `prepare`, `willSend`, `didReceive` / `process`까지 포함 | `prepare`, `willSend`, `didReceive`만 포함 | 첫 구현에서는 요청 수정과 관찰만 지원해 단순성을 유지한다. 결과 변환, cache, retry policy는 후속 확장으로 남긴다. |
| hook 실행 순서 | interceptor 전 `prepare` / interceptor 후 `prepare` | `prepare` 후 `RequestInterceptor.adapt` | 공통 요청 수정 이후 인증 헤더를 최종 적용해 인증 관련 헤더가 플러그인에 의해 덮이는 위험을 줄인다. |
| 응답 모델 | tuple 공개 / `NetworkPluginResponse` struct | `NetworkPluginResponse` struct | public API에서 의미 있는 이름을 제공한다. 첫 구현은 `data`, `response`만 포함하고 duration, requestID 등은 후속 요구가 생길 때 추가한다. |
| 디버그 출력 추상화 | 직접 `print` / Logger 프로토콜 / output 클로저 | output 클로저 | 기본 사용은 단순하게 유지하면서 테스트 수집, `os.Logger`, 외부 로거 연결 등 출력 방식 교체가 가능하다. |
| 디버그 URL 출력 | full URL / query 제거 URL / 허용 목록 기반 query 출력 | query 제거 URL | query parameter에 토큰, code, 사용자 식별값, 검색어 등이 포함될 수 있으므로 기본 로그에서는 제외한다. |
| 디버그 header 출력 | 기본 출력 / 마스킹 후 출력 / 기본 미출력 | 기본 미출력 | 첫 구현을 요약 로그로 제한하고 민감 헤더 노출 위험을 줄인다. |
| 디버그 body 로깅 | 기본 지원 / 옵션 지원 / 제외 | 제외 | 민감 정보 노출 위험을 줄이고 첫 구현 범위를 요청/응답 요약으로 제한한다. |

## 주의 사항
- 이 계획 문서는 구현 전 사용자 확인을 받아야 한다.
- `RequestInterceptor`는 인증 헤더 삽입과 401 refresh/retry 책임을 계속 담당한다.
- `NetworkPlugin`은 기본적으로 요청/응답 생명주기 확장 지점이며, retry 정책이나 response decoding 정책을 변경하지 않는다.
- `DebugNetworkPlugin`은 토큰, Authorization 헤더 전체 값, Cookie, Set-Cookie, API key, query string, 요청/응답 body 원문을 로그에 남기지 않는다.
- `DebugNetworkPlugin` 자체는 public으로 제공하되, README 사용 예시는 `#if DEBUG` 조건부 등록만 제공한다.
- `NetworkClient` public initializer에 기본값이 있는 `plugins` 파라미터를 추가해 기존 호출부 변경을 최소화한다.
- `NetworkClient`의 internal test initializer도 동일한 plugin 주입이 가능해야 한다.
- 플러그인 hook에서 발생한 `NetworkError`는 기존 `NetworkClient.request`의 typed throws 경계를 유지해 전달한다.
- Swift 6 strict concurrency 기준에서 `NetworkPlugin`, `DebugNetworkPlugin`, `NetworkPluginResponse`의 `Sendable` 경고/오류가 없는지 테스트 빌드로 확인한다.
- `NetworkEndpoint`는 `RequestTask.body(any Encodable)`을 포함하므로, 별도 검토 없이 `Sendable` 채택을 추가하지 않는다.

## 검증 방법
- 신규 테스트가 먼저 실패하는지 확인한 뒤 구현한다.
- 구현 후 `LivithNetworking` 테스트가 통과하는지 확인한다.

```bash
tuist generate
xcodebuild test -workspace Livith-iOS.xcworkspace -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17'
git diff --check
```
