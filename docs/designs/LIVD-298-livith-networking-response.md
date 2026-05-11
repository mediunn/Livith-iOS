# LIVD-298 LivithNetworking 응답 처리 설계

## 배경
- 기존 `LivithNetwork`는 `ResponseHandler`에서 HTTP status code 검사, 서버 공통 wrapper decoding, 빈 응답 처리를 함께 수행한다.
- 신규 `LivithNetworking`은 Alamofire `validate()` 없이 `URLSession` 기반으로 확장될 예정이므로 응답 본문과 status code를 같은 계층에서 직접 판단할 수 있다.
- 서버 응답은 기존 모듈의 `BaseResponse<T>`와 같은 공통 wrapper 구조를 전제로 한다.
- 응답 원문 로그는 민감 정보 노출 가능성이 있으므로 신규 모듈의 응답 처리 책임에 포함하지 않는다.

## 목표
- `LivithNetworking`에 `ResponseHandler` 타입을 둔다.
- `ResponseHandler`는 `HTTPURLResponse`와 `Data`를 받아 호출부가 기대하는 `Decodable` 값으로 변환한다.
- 서버 공통 wrapper는 `ServerResponse<T>`로 표현한다.
- 빈 성공 응답은 `EmptyResponse`로 표현한다.
- 응답 처리 단계의 실패는 `ResponseError`로 표현한다.
- status code 검사와 JSON decoding은 우선 `ResponseHandler` 하나에서 처리한다.

## 범위
- `ResponseHandler.handle(_:data:response:)`는 `T: Decodable` 값을 반환한다.
- `ResponseHandler`는 생성 시 주입받은 `JSONDecoder`를 사용한다.
- 성공 status code 범위는 `200..<300`으로 한다.
- 성공 status에서는 `ServerResponse<T>`를 decode한다.
- `ServerResponse.data`가 있으면 해당 값을 반환한다.
- `T == EmptyResponse.self`이면 `ServerResponse.data == nil`이어도 성공으로 처리한다.
- `T != EmptyResponse.self`이고 `ServerResponse.data == nil`이면 `ResponseError.noData`를 던진다.
- 실패 status에서는 `ServerResponse<EmptyResponse>` decode를 시도해 `message`를 추출한다.
- 실패 status body decode에 실패하면 message는 `nil`로 둔다.
- 성공 status body decode에 실패하면 `ResponseError.decodingFailed`를 던진다.
- `ServerResponse`는 `statusCode`, `error`, `message`, `data`를 표현한다.

## 비목표
- 이번 설계에서 실제 네트워크 전송을 다루지 않는다.
- 이번 설계에서 `NetworkClient`를 정의하지 않는다.
- 이번 설계에서 request build error와 response error를 하나로 합치지 않는다.
- 이번 설계에서 인증 토큰 삽입을 구현하지 않는다.
- 이번 설계에서 refresh와 401 retry를 다루지 않는다.
- 이번 설계에서 ETag cache를 다루지 않는다.
- 이번 설계에서 에러 body 상세 모델링을 다루지 않는다.
- 이번 설계에서 status code별 세부 error case를 정의하지 않는다.
- 이번 설계에서 응답 원문 logging을 다루지 않는다.

## 결정
| 결정 사항 | 결정 | 근거 |
|-----------|------|------|
| 응답 처리 타입 | `ResponseHandler` | status code와 body decoding을 함께 판단하는 책임이 드러난다. |
| handle 메서드 | `handle(_:data:response:)` | 기대 타입, 응답 body, HTTP 응답을 명시적으로 받는다. |
| 공통 wrapper 이름 | `ServerResponse` | 서버 공통 응답 구조임이 `BaseResponse`보다 구체적으로 드러난다. |
| 빈 응답 타입 | `EmptyResponse` | `data`가 없는 성공 응답을 타입으로 명시한다. |
| 에러 이름 | `ResponseError` | 응답 처리 단계의 실패임이 드러난다. |
| 성공 status | `200..<300` | HTTP 성공 범위와 기존 모듈의 처리 방식에 맞춘다. |
| 실패 status | `invalidStatusCode(Int, message: String?)` | status code와 서버 message를 보존하되 초기에 과도하게 세분화하지 않는다. |
| data 없음 | `noData` | 성공 wrapper에 필요한 `data`가 없음을 명확히 표현한다. |
| decoding 실패 | `decodingFailed(Error)` | 원래 decoding error를 보존해 디버깅 가능성을 유지한다. |
| decoder 설정 | 생성자 주입 | 날짜, key decoding strategy 같은 설정을 호출부에서 제어할 수 있다. |
| 응답 로그 | 하지 않음 | 응답 원문에는 민감 정보가 포함될 수 있다. |

## 후속 작업
- `NetworkClient` 설계에서 `RequestBuilder`, `URLSession`, `ResponseHandler`를 조합한다.
- 인증 설계에서 401 응답과 refresh retry 경계를 정의한다.
- 필요해지면 status code별 세부 error case와 error body 모델을 추가한다.
