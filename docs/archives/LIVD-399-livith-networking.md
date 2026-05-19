# LIVD-399 LivithNetworking 확장 및 ETag 캐시

## 배경
- `LivithNetworking`은 `RequestBuilder`, `NetworkClient`, `NetworkTransport`, `ResponseHandler`, `RequestInterceptor` 중심으로 요청 흐름을 구성하는 신규 네트워킹 모듈이다.
- 인증 헤더 삽입과 401 refresh/retry는 `RequestInterceptor`가 담당하지만, 로깅·metrics·activity tracking 같은 범용 네트워크 생명주기 확장을 위해 별도 plugin 구조가 필요했다.
- 일부 조회성 GET API에서는 서버가 제공하는 `ETag`를 활용해 `304 Not Modified` 응답 시 기존 응답 body를 재사용할 수 있어, endpoint별 opt-in ETag 캐시가 필요했다.
- ETag 캐시 추가 후 `NetworkClient`가 plugin, 인증 retry, ETag 캐시, 304 fallback을 함께 다루며 복잡해졌으므로, 추가 기능을 붙이기 전에 내부 책임을 정리했다.

## 목표
- `RequestInterceptor`의 인증/재시도 책임은 유지하고, 요청/응답 생명주기 확장을 위한 `NetworkPlugin`을 추가한다.
- 안전한 요약 로그만 출력하는 `DebugNetworkPlugin`을 제공한다.
- `NetworkEndpoint.etagCacheEnabled`로 특정 GET endpoint만 ETag 캐시에 opt-in할 수 있게 한다.
- ETag 캐시는 `NetworkClient` 인스턴스 단위 메모리 저장소만 사용하고, `URLCache`와 디스크 저장소는 사용하지 않는다.
- 304 cache hit 시 저장된 body와 2xx response metadata를 반환해 기존 decoding 경로를 유지한다.
- 304 cache miss 시 `If-None-Match` 없이 1회 fallback 요청을 수행한다.
- 로그아웃 또는 사용자 전환 시 `NetworkClient.removeAllETagCache()`로 현재 클라이언트의 ETag 캐시를 전체 삭제할 수 있게 한다.
- `NetworkClient`는 요청 흐름 조율에 집중하고, ETag 세부 정책과 retry/fallback 상태는 별도 내부 타입으로 분리한다.

## 작업 항목

### 1. NetworkPlugin 구조
- [x] 실패 테스트 작성 및 red 확인
  - `NetworkPlugin` 테스트 컴파일에 필요한 최소 선언만 먼저 추가한다.
  - `Projects/LivithNetworking/Tests/Plugin/NetworkPluginTests.swift`를 추가한다.
  - `Projects/LivithNetworking/Tests/Plugin/DebugNetworkPluginTests.swift`를 추가한다.
  - `NetworkClient` 통합 동작은 `Projects/LivithNetworking/Tests/Client/NetworkClientTests.swift`에 추가한다.
  - 신규 테스트가 생산 코드 구현 전 기대한 이유로 실패하는지 확인한다.
- [x] 플러그인 API 최소 구현
  - `Projects/LivithNetworking/Sources/Plugin/NetworkPlugin.swift`를 추가한다.
  - `NetworkPlugin`과 `NetworkPluginResponse`를 정의한다.
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
  - `ResponseHandler`의 status mapping 또는 decoding 실패는 plugin hook 범위에 포함하지 않는다.
  - 401 retry로 재전송할 때도 동일한 플러그인 흐름을 다시 적용한다.
- [x] `DebugNetworkPlugin` 구현
  - 요청 method, query를 제거한 URL의 scheme/host/path, 응답 status code, 전송 실패의 요약 정보만 출력한다.
  - 기본 출력은 `print`로 두되, `@Sendable (String) -> Void` 클로저 주입으로 출력 방식을 교체할 수 있게 한다.
  - 기본 구현에서는 request/response header, query string, 요청/응답 body 원문을 출력하지 않는다.
- [x] plugin 보호 테스트 보강
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

### 2. ETag 캐시 기능
- [x] 실패 테스트 작성 및 red 확인
  - `NetworkEndpoint` 기본값이 ETag 캐시 비활성화인지 검증한다.
  - ETag 캐시가 비활성화된 요청은 `If-None-Match`를 추가하지 않는지 검증한다.
  - ETag 캐시가 활성화된 GET 요청의 200 + `ETag` 응답이 캐시에 저장되는지 검증한다.
  - 두 번째 같은 GET 요청에서 `If-None-Match` 헤더가 추가되는지 검증한다.
  - 304 응답 시 캐시된 body를 사용해 decoded value를 반환하는지 검증한다.
  - 304 응답인데 캐시가 없으면 `If-None-Match` 없이 1회 fallback 요청하는지 검증한다.
  - fallback 요청 성공 시 body와 새 `ETag`를 저장하고 decoded value를 반환하는지 검증한다.
  - fallback 요청이 실패하거나 다시 304를 반환하면 기존 에러 흐름으로 실패하는지 검증한다.
  - 200 응답에 `ETag`가 없으면 기존 캐시를 삭제하는지 검증한다.
  - `removeAllETagCache()` 호출 후 다음 요청에 `If-None-Match`가 추가되지 않는지 검증한다.
  - `etagCacheEnabled == true`여도 GET이 아닌 요청은 ETag 캐시를 적용하지 않는지 검증한다.
  - query가 다른 같은 path는 서로 다른 캐시 키로 분리되는지 검증한다.
- [x] Cache 폴더와 메모리 캐시 구현 추가
  - `Projects/LivithNetworking/Sources/Cache/` 폴더를 추가한다.
  - `ETagCacheEntry`를 추가해 `etag`, `data`, 원 성공 응답의 `statusCode`를 보관한다.
  - `ETagCacheStore` 프로토콜을 추가해 조회, 저장, 단건 삭제, 전체 삭제 API를 정의한다.
  - `MemoryETagCacheStore`를 actor로 구현해 비동기 요청 흐름에서 안전하게 사용한다.
  - `ETagCacheEntry`, `ETagCacheStore`, `MemoryETagCacheStore`는 internal로 둔다.
  - 캐시 키는 adapted request 기준의 `HTTP method + absolute URL`로 만든다.
- [x] `NetworkEndpoint` opt-in 옵션 추가
  - `NetworkEndpoint`에 `etagCacheEnabled: Bool = false`를 추가한다.
  - 기존 생성자 호출부가 깨지지 않도록 기본값을 유지한다.
- [x] `NetworkClient`에 ETag 캐시 흐름 통합
  - public initializer에는 cache store 파라미터를 노출하지 않고 내부에서 새 `MemoryETagCacheStore()` 인스턴스를 생성한다.
  - internal test initializer에서만 store를 주입할 수 있게 한다.
  - shared store 또는 전역 singleton은 만들지 않는다.
  - `etagCacheEnabled == true`이고 GET 요청이며 캐시 entry가 있을 때만 `If-None-Match`를 추가한다.
  - transport 응답이 200이고 `ETag`가 있으면 body와 응답 metadata를 저장한다.
  - transport 응답이 200이고 `ETag`가 없으면 해당 캐시 키를 삭제한다.
  - transport 응답이 304이고 캐시 entry가 있으면 캐시된 body와 성공 status metadata를 반환한다.
  - transport 응답이 304이고 캐시 entry가 없으면 ETag 헤더 없이 한 번만 fallback 요청한다.
  - `NetworkPlugin.didReceive`는 실제 transport 응답을 관찰하므로 304 cache hit 시에도 네트워크에서 받은 304 응답을 전달한다.
  - 네트워크 실패 시 기존 캐시를 반환하는 offline fallback은 구현하지 않는다.
- [x] 전체 삭제 API 추가
  - `NetworkClient.removeAllETagCache()`를 public async API로 추가한다.
  - 로그아웃 또는 사용자 전환 흐름에서 이 API를 호출할 수 있음을 README에 문서화한다.

### 3. NetworkClient 구조 개선
- [x] 리팩터링 전 보호 테스트 확인
  - 현재 `LivithNetworking` 테스트가 통과하는지 확인한다.
  - ETag 관련 테스트가 리팩터링 대상 동작을 보호하는지 확인한다.
- [x] 요청 시도 상태 값 타입 추가
  - `RequestAttempt` internal struct를 추가한다.
  - `retryCount`, `fallbackCount`, `skipsETag`를 묶는다.
  - 401 retry 증가와 ETag fallback 증가를 명확한 메서드 또는 계산 프로퍼티로 표현한다.
- [x] ETag 캐시 정책 타입 분리
  - `ETagCacheHandler` internal 타입을 `Sources/Cache/`에 추가한다.
  - ETag cache key 생성, `If-None-Match` 적용/제거, 200 응답 저장/삭제, 304 cache hit 변환을 담당한다.
  - `MemoryETagCacheStore`는 저장소 역할만 유지한다.
  - `NetworkClient.removeAllETagCache()`는 기존처럼 store 전체 삭제를 호출한다.
- [x] `NetworkClient` 흐름 단순화
  - `load`는 build → prepare → adapt → ETag 적용 → send → retry/fallback 판단 흐름만 조율한다.
  - ETag 세부 정책은 `ETagCacheHandler`에 위임한다.
  - plugin `didReceive`가 실제 transport 응답을 관찰하는 기존 계약을 유지한다.
  - 401 retry는 기존처럼 원 요청을 다시 prepare/adapt한다.
  - 304 cache miss fallback은 기존처럼 `If-None-Match` 없이 1회만 수행한다.
- [x] 테스트 유지 및 문서 갱신
  - 기존 테스트가 모두 통과하도록 리팩터링한다.
  - README의 타입 관계, 파일 구조, 요청 흐름, 사용 예시, 보안 정책, 검증 명령을 갱신한다.

### 4. 검증 및 정리
- [x] `tuist generate`를 실행한다.
- [x] `xcodebuild test -workspace Livith-iOS.xcworkspace -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17'`를 실행한다.
- [x] `git diff --check`를 실행한다.
- [x] 서브에이전트 리뷰를 통해 ETag 구현과 리팩터링이 계획대로 수행됐는지 확인하고 `통과` 판정을 받는다.

## 영향 범위
- `Projects/LivithNetworking/Sources/Plugin/NetworkPlugin.swift`
- `Projects/LivithNetworking/Sources/Plugin/DebugNetworkPlugin.swift`
- `Projects/LivithNetworking/Sources/Request/NetworkEndpoint.swift`
- `Projects/LivithNetworking/Sources/Client/NetworkClient.swift`
- `Projects/LivithNetworking/Sources/Client/RequestAttempt.swift`
- `Projects/LivithNetworking/Sources/Cache/ETagCacheEntry.swift`
- `Projects/LivithNetworking/Sources/Cache/ETagCacheStore.swift`
- `Projects/LivithNetworking/Sources/Cache/MemoryETagCacheStore.swift`
- `Projects/LivithNetworking/Sources/Cache/ETagCacheHandler.swift`
- `Projects/LivithNetworking/Tests/Client/NetworkClientTests.swift`
- `Projects/LivithNetworking/Tests/Plugin/*`
- `Projects/LivithNetworking/Tests/Cache/ETagCacheStoreTests.swift`
- `Projects/LivithNetworking/Tests/Request/NetworkEndpointTests.swift`
- `Projects/LivithNetworking/Tests/Support/HTTPTestResponseFactory.swift`
- `Projects/LivithNetworking/README.md`

## 제외 범위
- `Projects/Core/LivithNetwork` 수정
- 실제 API에 `etagCacheEnabled: true` 적용
- 앱/DI 레이어 연결
- 앱/DI 레이어에서 로그아웃 또는 사용자 전환 이벤트와 자동 연결
- refresh 실패 시 로그아웃/토큰 삭제 정책
- 디스크 캐시, `URLCache`, 앱 재실행 후 캐시 유지
- 네트워크 실패 시 stale cache 반환 또는 offline fallback
- TTL, `Cache-Control`, `Expires`, `Vary` 기반 HTTP 캐시 정책 처리
- 새로운 cache policy enum 도입
- endpoint별 캐시 만료 시간 설정
- body가 있는 non-GET 요청 캐시
- retry 정책 일반화, backoff, queue, retry policy 객체
- plugin hook 추가 또는 계약 변경
- 인증 refresh 정책 변경
- 서버 ETag 발급 정책 변경

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
| 캐시 적용 방식 | 전체 API 자동 적용 / endpoint opt-in | endpoint opt-in | 서버가 ETag를 지원하는 특정 조회 API에만 안전하게 적용하기 위함이다. |
| endpoint API | `cachePolicy` enum / `etagCacheEnabled` Bool | `etagCacheEnabled` Bool | 현재 요구는 ETag on/off뿐이므로 가장 단순한 API를 사용한다. |
| 저장소 | `URLCache` / 별도 메모리 store / 디스크 store | 별도 메모리 store | opt-in 동작, 304 body 대체, 전체 삭제, 테스트를 명확히 제어한다. |
| 저장 기간 | 앱 실행 중 메모리 / 앱 재실행 후 유지 | 앱 실행 중 메모리 | 사용자가 앱 재실행 후 유지가 필요 없다고 결정했다. |
| store 소유 | shared singleton / `NetworkClient` 인스턴스 단위 | `NetworkClient` 인스턴스 단위 | shared 전역 상태를 피하고 테스트와 클라이언트별 격리를 단순화한다. |
| 전체 삭제 API 위치 | store public 노출 / `NetworkClient` 메서드 | `NetworkClient.removeAllETagCache()` | internal store 구현을 숨기고 호출부는 클라이언트 API만 사용하게 한다. |
| 캐시 키 | path만 / method + absolute URL / header 포함 | method + absolute URL | query가 다른 요청을 분리하면서 인증/동적 헤더로 인한 캐시 파편화를 피한다. |
| 캐시 키 계산 시점 | build 직후 / prepare 이후 / adapt 이후 | adapt 이후 | 실제 transport 전송 URL 기준으로 캐시 키를 만들기 위함이다. |
| 적용 HTTP method | 모든 method / GET만 | GET만 | 안전한 조회 요청 재검증으로 범위를 제한한다. |
| 304 cache hit 처리 | 304를 그대로 response handler에 전달 / cached representation 반환 | cached representation 반환 | `ResponseHandler`는 2xx만 성공 처리하므로 저장된 body와 원 성공 응답의 2xx status metadata를 반환해야 한다. |
| 304 cache miss 처리 | `invalidResponse` / ETag 없는 1회 fallback 요청 | ETag 없는 1회 fallback 요청 | 메모리 캐시 삭제 또는 외부 ETag 헤더로 인한 불일치를 한 번 복구할 수 있다. |
| fallback 횟수 | 무제한 / 설정값 / 1회 고정 | 1회 고정 | 무한 재시도와 불필요한 트래픽 증가를 방지한다. |
| 200 + ETag 없음 처리 | 기존 캐시 유지 / 기존 캐시 삭제 | 기존 캐시 삭제 | 서버가 더 이상 ETag 캐시 대상으로 보지 않는 상황에서 오래된 캐시 재사용을 막는다. |
| 304 + 네트워크 실패 fallback | 캐시 반환 / 실패 전달 | 실패 전달 | 이번 목표는 재검증 캐시이며 offline fallback은 제외 범위다. |
| 캐시 store 구현 타입 | class + lock / actor | actor | 비동기 요청 환경에서 메모리 상태를 안전하게 직렬화한다. |
| 전체 삭제 API 동기성 | sync / async | async | actor store와 자연스럽게 연결하고 concurrency 경고를 줄인다. |
| 리팩터링 방식 | 동작 변경 포함 / 동작 유지 리팩터링 | 동작 유지 리팩터링 | 기능 통과 상태에서 구조만 개선해 회귀 위험을 줄인다. |
| ETag 책임 위치 | `NetworkClient` 유지 / 별도 내부 타입 분리 | 별도 내부 타입 분리 | `NetworkClient`의 분기와 private helper를 줄이고 캐시 정책을 한 곳에 모은다. |
| 저장소 책임 | 정책까지 포함 / 순수 저장소 유지 | 순수 저장소 유지 | `MemoryETagCacheStore`는 actor storage로 단순하게 유지한다. |
| retry/fallback 상태 | 개별 파라미터 유지 / 값 타입으로 묶기 | 값 타입으로 묶기 | `load` 시그니처를 줄이고 상태 전이를 명확히 한다. |
| public API | 변경 / 유지 | 유지 | 호출부 영향이 없는 구조 개선이 목적이다. |
| 테스트 전략 | 테스트 재작성 / 기존 보호 테스트 유지 + 필요한 보강 | 기존 보호 테스트 유지 + 필요한 보강 | 리팩터링 안정성을 높이고 불필요한 테스트 중복을 피한다. |
| 네이밍 | 설명형 장문 / 간결한 책임 중심 이름 | 간결한 책임 중심 이름 | 구현체, 프로퍼티, 메서드 이름은 짧고 명료하게 유지한다. |

## 주의 사항
- `RequestInterceptor`는 인증 헤더 삽입과 401 refresh/retry 책임을 계속 담당한다.
- `NetworkPlugin`은 요청/응답 생명주기 확장 지점이며, retry 정책이나 response decoding 정책을 변경하지 않는다.
- `NetworkPlugin.didReceive`는 계속 실제 transport 응답을 관찰해야 한다.
- `DebugNetworkPlugin`은 토큰, Authorization 헤더 전체 값, Cookie, Set-Cookie, API key, query string, 요청/응답 body 원문을 로그에 남기지 않는다.
- `NetworkEndpoint` 기본값은 기존 호출부를 깨지 않도록 유지한다.
- cache key는 계속 adapted request의 `HTTP method + absolute URL` 기준이어야 한다.
- 캐시 대상은 `etagCacheEnabled == true`인 GET 요청으로 제한한다.
- `ETag` 헤더 값은 weak validator(`W/`)를 포함해 서버가 준 값을 그대로 사용한다.
- HTTP header 이름은 대소문자를 구분하지 않고 처리한다.
- 304 cache hit에서만 cached body와 cached 2xx response metadata를 `ResponseHandler`로 전달한다.
- 304 cache miss fallback은 `If-None-Match` 없이 1회만 수행한다.
- 네트워크 실패 시 stale cache를 반환하지 않는다.
- `ETag`와 `If-None-Match` 원문 값을 디버그 로그나 테스트 failure message에 불필요하게 노출하지 않는다.
- 응답 body 원문을 로그로 남기지 않는다.
- 사용자별 응답이 섞이지 않도록 로그아웃 또는 사용자 전환 시 `removeAllETagCache()` 호출이 필요함을 문서화한다.
- 기존 `Projects/Core/LivithNetwork`는 수정하지 않는다.
- 새 내부 API 이름은 간결하고 책임이 드러나게 작성한다.
- 과도한 protocol 추상화나 설정 객체를 추가하지 않는다.

## 검증 방법
- 신규 실패 테스트를 먼저 작성하고 기대한 이유로 실패하는지 확인한다.
- 리팩터링 전후로 전체 `LivithNetworking` 테스트가 통과하는지 확인한다.

```bash
tuist generate
xcodebuild test -workspace Livith-iOS.xcworkspace -scheme LivithNetworking -destination 'platform=iOS Simulator,name=iPhone 17'
git diff --check
```
