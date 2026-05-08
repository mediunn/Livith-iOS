# LIVD-298 LivithNetworking HTTPMethod 설계

## 배경
- `LivithNetworking`은 외부 라이브러리 의존 없이 HTTP 요청을 구성해야 한다.
- 기존 `LivithNetwork`의 `HTTPMethod`는 Alamofire 타입 별칭이므로 신규 모듈에서는 자체 타입이 필요하다.

## 목표
- `LivithNetworking`에 자체 `HTTPMethod` 타입을 둔다.
- `HTTPMethod`는 `URLRequest.httpMethod`에 그대로 사용할 수 있는 대문자 문자열 값을 제공한다.
- 현재 필요한 기본 method만 지원한다.

## 범위
- 포함 method는 `GET`, `POST`, `PUT`, `PATCH`, `DELETE`로 제한한다.
- 타입 이름은 간결하게 `HTTPMethod`로 한다.
- raw value는 HTTP 표준 표기와 동일한 대문자 문자열로 한다.

## 비목표
- 이번 설계에서 `NetworkEndpoint`를 정의하지 않는다.
- 이번 설계에서 `NetworkService`나 request builder를 정의하지 않는다.
- 이번 설계에서 header, query, body, response, token, ETag 정책을 다루지 않는다.

## 결정
| 결정 사항 | 결정 | 근거 |
|-----------|------|------|
| 타입 이름 | `HTTPMethod` | 기존 네트워크 코드와 의미가 같고 간결하다. |
| 값 표현 | `String` raw value | `URLRequest.httpMethod`에 그대로 전달하기 쉽다. |
| raw value 표기 | 대문자 | HTTP method 표준 표기와 일치한다. |
| 지원 method | `get`, `post`, `put`, `patch`, `delete` | 현재 앱 API에서 사용하는 기본 method만 우선 지원한다. |
| 외부 의존성 | 없음 | `LivithNetworking`은 라이브러리 의존 없는 모듈이어야 한다. |

## 후속 작업
- 다음 작은 단위에서 `NetworkConfig` 또는 `NetworkEndpoint` 설계를 진행한다.
