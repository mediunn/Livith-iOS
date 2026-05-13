# LIVD-395 Token Refresh Service

## 배경
- 현재 `LivithNetworking` 모듈에는 토큰 저장소(`TokenStore`)와 인증 헤더 삽입(`AuthInterceptor`)은 있지만, refresh token으로 새 토큰을 발급받는 전용 서비스가 없다.
- 기존 네트워크 모듈의 리프레셔 역할은 단순 API 통신 객체에 가까우므로, 새 네트워킹 모듈에서는 `NetworkClient`를 내부적으로 사용하는 서비스로 분리한다.
- 동시에 여러 요청이 토큰 리프레시를 시도할 때 중복 네트워크 요청이 발생하지 않도록 single-flight 처리가 필요하다.

## 목표
- `LivithNetworking` 모듈에 refresh token으로 토큰 재발급 API를 호출하는 `TokenRefreshService`를 추가한다.
- 구현체 `TokenRefreshServiceImpl`은 내부적으로 `NetworkClient`를 사용한다.
- 동일 시점의 중복 refresh 호출은 하나의 네트워크 요청으로 합쳐 처리한다.
- 이번 작업에서는 토큰 저장, 401 감지, 원요청 재시도 연결은 포함하지 않는다.

## 작업 항목
- [x] refresh API 요청/응답 모델 정의
  - refresh token 요청 body와 access/refresh token 응답 data 모델을 `LivithNetworking` 내부 타입으로 정의한다.
- [x] `TokenRefreshService` 프로토콜 추가
  - refresh token을 입력받아 새 `Token`을 반환하는 비동기 API를 정의한다.
- [x] `TokenRefreshServiceImpl` 구현
  - `NetworkClient`를 통해 인증이 필요 없는 refresh endpoint를 호출한다.
  - 응답의 access/refresh token과 현재 시각을 이용해 `Token`을 생성한다.
- [x] single-flight 처리 추가
  - 진행 중인 refresh 작업이 있으면 새 네트워크 요청을 만들지 않고 기존 작업 결과를 await한다.
  - 성공/실패 후 진행 중인 작업 참조를 정리한다.
- [x] 테스트 추가
  - 성공 응답 변환, 요청 구성, 에러 전달, single-flight 동작을 검증한다.
- [x] 검증 실행
  - `LivithNetworking` 테스트를 실행해 신규/기존 테스트 통과를 확인한다.

## 영향 범위
- `Projects/LivithNetworking/Sources/Service/TokenRefreshService.swift`
  - `TokenRefreshService` 프로토콜, `TokenRefreshServiceImpl` 구현체 추가
- `Projects/LivithNetworking/Sources/DTO/`
  - `DTO` 네임스페이스와 `DTO.Request.Token`, `DTO.Response.Token` 추가
- `Projects/LivithNetworking/Tests/Token/`
  - `TokenRefreshService` 테스트 추가
- 제외 범위
  - `AuthInterceptor`의 retry 동작 연결
  - `NetworkClient`의 retry 실행 흐름 변경
  - `TokenStore` 저장 정책 변경
  - 앱/데이터 레이어 DI 등록

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 서비스 이름 | `TokenRefresher`, `TokenRefreshService` | `TokenRefreshService` | 객체의 책임이 리프레시 API 통신 서비스임을 명확히 표현한다. |
| 구현체 이름 | `DefaultTokenRefreshService`, `TokenRefreshServiceImpl` | `TokenRefreshServiceImpl` | 프로젝트 내 Data 구현체의 `Impl` 접미사 관례와 사용자의 명시 요청을 따른다. |
| 내부 통신 방식 | `URLSession` 직접 사용, `NetworkClient` 사용 | `NetworkClient` 사용 | 요청 구성, 응답 wrapper 처리, 에러 매핑을 기존 네트워킹 모듈 규칙과 일치시킨다. |
| 동시성 제어 위치 | 호출자, `AuthInterceptor`, `TokenRefreshServiceImpl` | `TokenRefreshServiceImpl` | refresh API 호출 중복 방지는 서비스 자체의 책임으로 두는 것이 재사용성과 안정성에 유리하다. |
| 구현 타입 | `struct`, `final class`, `actor` | `actor` | single-flight 상태를 안전하게 보호하고 Swift Concurrency와 자연스럽게 맞춘다. |
| 토큰 저장 여부 | 서비스에서 저장, 호출자가 저장 | 호출자가 저장 | 이번 범위는 API 호출 전용 객체이며, 저장 책임은 `TokenStore` 또는 상위 orchestration 객체에 남긴다. |
| refresh token 발급 시각 | 서버 응답 사용, 클라이언트 현재 시각 사용 | 클라이언트 현재 시각 사용 | 현재 예상 응답에는 발급 시각이 없고 기존 `Token` 모델에는 `refreshTokenIssuedAt`이 필요하다. |

## 주의 사항
- refresh API는 인증 헤더를 요구하지 않아야 하므로 endpoint의 `requiresAuthentication`은 `false`로 설정한다.
- 토큰 원문, refresh token, 인증 응답 원문을 로그로 출력하지 않는다.
- `UserDefaults` 계열 저장소에 토큰을 저장하지 않는다.
- single-flight 작업 참조는 성공과 실패 모두에서 반드시 정리한다.
- 이번 작업에서 `NetworkClient`의 retry 흐름을 변경하지 않는다.
- 실제 refresh API 계약(path, query, body, 응답 필드)이 다르면 구현 전 계획을 수정하고 확인받는다.

## 검증 방법
- 신규 `TokenRefreshService` 테스트를 먼저 작성하고 실패를 확인한다.
- 구현 후 `LivithNetworking` 테스트를 실행해 신규 테스트와 기존 테스트가 통과하는지 확인한다.
- 주요 검증 항목:
  - refresh 성공 응답이 `Token`으로 변환되는가
  - 요청 method/path/query/body가 refresh API 계약과 일치하는가
  - refresh endpoint가 인증 없이 호출되는가
  - 네트워크/응답 실패가 `NetworkError`로 전달되는가
  - 동시 refresh 호출이 하나의 네트워크 요청으로 합쳐지는가
