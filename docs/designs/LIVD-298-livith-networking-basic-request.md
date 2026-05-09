# LIVD-298 LivithNetworking 기초 요청 설계

## 배경
- `LivithNetworking`은 외부 라이브러리 의존 없이 HTTP 요청을 구성해야 한다.
- 기존 `LivithNetwork`의 `HTTPMethod`는 Alamofire 타입 별칭이므로 신규 모듈에서는 자체 타입이 필요하다.
- 요청을 만들 때 기준이 되는 base URL은 환경 설정에서 직접 읽지 않고 외부에서 주입받아야 한다.
- API 요청 하나를 표현하는 endpoint 명세는 base URL과 분리되어 API path와 요청 속성만 표현해야 한다.
- query와 body를 각각 optional property로 두면 조합이 모호해질 수 있으므로 요청 payload 형태를 별도 값으로 명확히 표현해야 한다.
- 요청 계약을 실제 전송 전 단계의 `URLRequest`로 변환하는 책임은 별도 타입으로 분리해야 한다.
- 요청 생성 실패는 전송 실패나 응답 실패와 구분되는 build 단계의 에러로 표현해야 한다.

## 목표
- `LivithNetworking`에 자체 `HTTPMethod` 타입을 둔다.
- `NetworkConfig`는 요청 생성에 필요한 base URL을 보관한다.
- `RequestTask`는 요청 payload 형태만 표현한다.
- `NetworkEndpoint`는 요청 명세를 담는 struct 값 타입으로 `path`, `method`, `task`, `headers`, `requiresAuthentication`을 표현한다.
- `RequestBuilder`는 `NetworkConfig`와 `NetworkEndpoint`를 조합해 `URLRequest`를 만든다.
- `RequestBuildError`는 request build 단계에서 발생하는 실패만 표현한다.
- 자주 쓰는 값에는 기본값을 제공해 endpoint 선언을 단순하게 유지한다.
- 실제 네트워크 전송, 응답 처리, 인증 토큰 삽입은 후속 설계로 미룬다.

## 범위
- `HTTPMethod`는 `GET`, `POST`, `PUT`, `PATCH`, `DELETE`를 지원한다.
- `HTTPMethod` raw value는 `URLRequest.httpMethod`에 그대로 사용할 수 있는 대문자 문자열로 한다.
- `NetworkConfig`는 `baseURL: URL`을 생성자 주입으로 받는 값 타입으로 둔다.
- `NetworkConfig`는 Bundle, plist, xcconfig를 직접 읽지 않는다.
- `RequestTask`는 `plain`, `query`, `body`, `queryAndBody` case를 지원한다.
- query 값은 `[URLQueryItem]`로 표현한다.
- body 값은 `any Encodable`로 표현한다.
- `NetworkEndpoint.path`는 API path 문자열로 표현한다.
- `NetworkEndpoint.method`는 `HTTPMethod`로 표현한다.
- `NetworkEndpoint.task`는 `RequestTask`로 표현한다.
- `NetworkEndpoint.headers`는 `[String: String]`으로 표현한다.
- `NetworkEndpoint.requiresAuthentication`은 `Bool`로 표현한다.
- `RequestBuilder.make(endpoint:config:)`는 `URLRequest`를 반환한다.
- `RequestBuilder`는 생성 시 주입받은 `JSONEncoder`를 body encoding에 사용한다.
- `NetworkConfig.baseURL`과 `NetworkEndpoint.path`를 결합해 최종 URL을 만든다.
- base URL path와 endpoint path의 slash는 builder가 정규화한다.
- `RequestTask.query`와 `RequestTask.queryAndBody`의 query item은 URL query에 반영한다.
- `RequestTask.body`와 `RequestTask.queryAndBody`의 body는 JSON `Data`로 encode해 `httpBody`에 반영한다.
- body가 있는 요청에는 `Content-Type: application/json` 기본값을 적용한다.
- endpoint가 같은 header를 제공하면 endpoint header를 우선한다.
- `HTTPMethod.rawValue`를 `URLRequest.httpMethod`에 반영한다.
- `NetworkEndpoint.headers`를 `URLRequest` header에 반영한다.
- `RequestBuildError.invalidURL`은 URL 조합 결과가 HTTP 요청 URL로 유효하지 않을 때 사용한다.
- `RequestBuildError.encodingFailed`는 body JSON encoding에 실패했을 때 사용한다.

## 비목표
- 이번 설계에서 `NetworkService`를 정의하지 않는다.
- 이번 설계에서 실제 네트워크 전송을 다루지 않는다.
- 이번 설계에서 응답 decoding을 다루지 않는다.
- 이번 설계에서 공통 응답 wrapper를 다루지 않는다.
- 이번 설계에서 status code 기반 에러 매핑을 다루지 않는다.
- 이번 설계에서 인증 토큰 삽입을 구현하지 않는다.
- 이번 설계에서 refresh와 401 retry를 다루지 않는다.
- 이번 설계에서 ETag cache를 다루지 않는다.
- 이번 설계에서 HTTP method와 task 조합 검증 정책을 정의하지 않는다.
- 이번 설계에서 multipart, form-urlencoded, raw data 요청을 다루지 않는다.

## HTTPMethod 결정
| 결정 사항 | 결정 | 근거 |
|-----------|------|------|
| 타입 이름 | `HTTPMethod` | 기존 네트워크 코드와 의미가 같고 간결하다. |
| 값 표현 | `String` raw value | `URLRequest.httpMethod`에 그대로 전달하기 쉽다. |
| raw value 표기 | 대문자 | HTTP method 표준 표기와 일치한다. |
| 지원 method | `get`, `post`, `put`, `patch`, `delete` | 현재 앱 API에서 사용하는 기본 method만 우선 지원한다. |
| 외부 의존성 | 없음 | `LivithNetworking`은 라이브러리 의존 없는 모듈이어야 한다. |

## NetworkConfig 결정
| 결정 사항 | 결정 | 근거 |
|-----------|------|------|
| 타입 이름 | `NetworkConfig` | 간결하고 네트워크 설정 역할이 드러난다. |
| 타입 형태 | `struct` | 설정 값 묶음이며 참조 공유가 필요하지 않다. |
| base URL 타입 | `URL` | 문자열보다 요청 생성 시 안정적이고 변환 실패를 호출부에서 먼저 처리할 수 있다. |
| base URL 공급 방식 | 생성자 주입 | 테스트와 환경 분리가 쉽고 모듈이 앱 설정 파일에 의존하지 않는다. |
| 설정 파일 접근 | 하지 않음 | `LivithNetworking`을 독립적인 네트워크 인프라 모듈로 유지한다. |
| 동시성 | `Sendable` 채택 | 설정 값은 비동기 요청 흐름에서 전달될 수 있다. |

## RequestTask 결정
| 결정 사항 | 결정 | 근거 |
|-----------|------|------|
| 타입 이름 | `RequestTask` | 요청 payload 형태를 표현하는 역할이 드러난다. |
| plain 요청 | `plain` | query와 body가 없는 요청을 명확히 표현한다. |
| query 요청 | `query([URLQueryItem])` | URL query item을 Foundation 표준 타입으로 전달한다. |
| body 요청 | `body(any Encodable)` | 기존 DTO를 body로 전달할 수 있고 encoding 책임은 `RequestBuilder`로 분리한다. |
| query와 body 요청 | `queryAndBody(queryItems: [URLQueryItem], body: any Encodable)` | query와 body를 동시에 갖는 요청을 optional 조합 없이 명시한다. |
| encoding 책임 | `RequestBuilder` | `RequestTask`는 payload 형태만 표현하고 변환 책임을 갖지 않는다. |

## NetworkEndpoint 결정
| 결정 사항 | 결정 | 근거 |
|-----------|------|------|
| 타입 이름 | `NetworkEndpoint` | 네트워크 endpoint 명세임이 명확하고 기존 코드와 의미가 이어진다. |
| 타입 형태 | `struct` | endpoint를 값 타입 요청 명세로 직접 전달해 별도 채택 타입 보일러플레이트를 줄인다. |
| path 책임 | endpoint가 API path만 제공 | base URL은 `NetworkConfig` 책임으로 유지해 환경 설정과 endpoint 선언을 분리한다. |
| method 표현 | `HTTPMethod` | 외부 라이브러리 의존 없는 자체 method 타입을 재사용한다. |
| payload 표현 | `RequestTask` | query/body optional 조합 대신 요청 payload 형태를 하나의 값으로 표현한다. |
| header 표현 | `[String: String]` | Foundation 표준 타입만으로 표현 가능하고 추가 타입 없이 단순하다. |
| 인증 필요 여부 | `requiresAuthentication: Bool` | 토큰 삽입 구현 전에도 endpoint 명세에서 인증 필요 여부를 표현할 수 있다. |
| task 기본값 | `.plain` | query/body 없는 요청 선언을 간단하게 만든다. |
| headers 기본값 | `[:]` | 커스텀 header가 없는 endpoint 선언을 간단하게 만든다. |
| 인증 기본값 | `true` | 기존 `LivithNetwork`의 기본 인증 필요 정책과 맞춘다. |
| factory method | 이번 단계에서 보류 | 기본값 있는 initializer만으로 현재 보일러플레이트를 줄일 수 있고 service 명세 설계와 함께 후속 결정한다. |

## RequestBuilder 결정
| 결정 사항 | 결정 | 근거 |
|-----------|------|------|
| builder 이름 | `RequestBuilder` | 모듈명이 이미 네트워크 문맥을 제공하므로 `Network` 접두사를 반복하지 않는다. |
| build 메서드 | `make(endpoint:config:)` | 호출부에서 결과가 `URLRequest`임이 타입으로 드러나고 이름이 짧다. |
| build 에러 이름 | `RequestBuildError` | 전송, 응답, decoding 에러와 구분되는 request 생성 실패임이 드러난다. |
| URL 실패 | `invalidURL` | base URL, path, query 조합 결과가 요청 URL로 부적합한 상황을 포괄한다. |
| encoding 실패 | `encodingFailed` | body encoding 실패를 간결하게 표현한다. |
| slash 정책 | builder가 정규화 | endpoint 선언부가 base URL의 trailing slash에 의존하지 않게 한다. |
| body encoding | 주입된 `JSONEncoder` 사용 | 날짜, key encoding strategy 같은 설정을 호출부에서 제어할 수 있다. |
| `Content-Type` 기본값 | body가 있을 때 `application/json` | JSON body 요청의 기본 header를 builder가 제공한다. |
| header 우선순위 | endpoint header 우선 | endpoint별 예외 설정이 공통 기본값을 덮어쓸 수 있어야 한다. |

## 후속 작업
- 인증 설계에서 `requiresAuthentication`이 `true`인 요청에만 토큰 삽입을 적용한다.
- 응답 처리 설계에서 status code, decoding, 공통 response wrapper 에러를 정의한다.
- 필요해지면 multipart, form-urlencoded, raw data task를 `RequestTask`에 별도 case로 추가한다.
