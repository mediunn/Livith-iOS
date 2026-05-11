# LIVD-298 LivithNetworking 모듈 경계 설계

## 배경
- 현재 `LivithNetwork`는 네트워크 코어, DTO, API endpoint, 토큰 처리, Alamofire 기반 구현이 한 모듈에 함께 있다.
- Alamofire 타입이 public API에 노출되어 있어 기존 모듈을 직접 수정하면 Data 모듈과 Feature 모듈까지 한 번에 영향을 받을 수 있다.
- 새 네트워크 모듈은 기존 앱 동작을 흔들지 않고, 라이브러리 의존 없는 구조로 점진 확장할 수 있어야 한다.

## 목표
- 신규 독립 프로젝트 이름을 `LivithNetworking`으로 고정한다.
- `LivithNetworking`은 네트워크 인프라 책임만 갖도록 경계를 고정한다.
- 기존 `LivithNetwork`는 당장 수정하거나 삭제하지 않고 병렬 유지한다.
- 첫 구현 단위는 기능 없는 빈 모듈 생성으로 제한한다.
- 기초 통신, 응답 처리, 토큰, ETag 캐시, DTO/API endpoint 이전은 후속 설계와 계획에서 작게 나누어 진행한다.

## 비목표
- 이번 설계에서 `NetworkService`의 상세 API를 확정하지 않는다.
- 이번 설계에서 실제 HTTP 통신 구현을 다루지 않는다.
- 이번 설계에서 토큰 저장, 토큰 삽입, refresh, 401 retry 세부 정책을 다루지 않는다.
- 이번 설계에서 ETag 캐시 저장 구조와 재검증 알고리즘을 다루지 않는다.
- 이번 설계에서 기존 DTO와 API endpoint를 `LivithNetworking`으로 이전하지 않는다.
- 이번 설계에서 기존 `LivithNetwork`나 Alamofire 의존 제거를 계획하지 않는다.

## 모듈명과 위치
- 신규 프로젝트명과 모듈명은 `LivithNetworking`으로 한다.
- 테스트 타깃명은 `LivithNetworkingTests`로 한다.
- 프로젝트 위치는 `Projects/LivithNetworking`으로 한다.
- Tuist helper에는 `ProjectID.livithNetworking`과 `LivithNetworkingModule`을 추가한다.

## 기존 모듈과의 관계
- `LivithNetwork`는 레거시 네트워크 모듈로 유지한다.
- `LivithNetworking`은 Core 하위 타깃이 아니라 독립 Tuist Project로 둔다.
- `LivithNetworking`은 `LivithNetwork`를 import하지 않는다.
- `LivithNetwork`도 현재 단계에서는 `LivithNetworking`을 import하지 않는다.
- 앱과 Data 모듈의 기존 `LivithNetwork` 의존은 이번 단계에서 변경하지 않는다.
- 후속 브랜치에서 기능 단위로 `LivithNetworking` 사용처를 늘린다.

## 신규 모듈 책임
- `LivithNetworking`은 장기적으로 HTTP 요청 생성, 요청 전송, 응답 처리, 네트워크 에러 매핑을 담당한다.
- 인증 토큰 삽입과 refresh retry는 네트워크 요청 흐름에 결합되는 인프라 기능으로 보고, 후속 설계에서 경계를 확정한다.
- ETag 기반 응답 캐시는 HTTP 요청/응답 처리에 결합되는 인프라 기능으로 보고, 후속 설계에서 경계를 확정한다.
- 서버 공통 응답 형식은 feature DTO가 아니라 네트워크 계약으로 볼 수 있으나, 구체 타입 이름과 디코딩 정책은 후속 응답 처리 설계에서 결정한다.

## 제외 범위
- `HomeEndpoint`, `SearchEndpoint`, `UserEndpoint` 같은 구체 API endpoint는 `LivithNetworking`의 초기 범위에 포함하지 않는다.
- `DTO.Request.*`, `DTO.Response.*` 같은 feature DTO는 `LivithNetworking`의 초기 범위에 포함하지 않는다.
- Data 모듈의 Repository, Mapper, Assembler는 초기 범위에서 수정하지 않는다.
- Alamofire 패키지 제거는 마이그레이션 완료 후 별도 작업으로 다룬다.

## 작업 단위 원칙
- 설계 문서는 하나의 결정 주제나 밀접하게 연결된 결정 묶음만 다룬다.
- 계획 문서는 하나의 작은 구현 단위만 다룬다.
- 설계 문서에는 구현 체크박스를 두지 않는다.
- 구현 체크리스트와 검증 명령은 `docs/plans/`의 계획 문서에만 작성한다.
- 각 구현 단계는 다음 단계가 없어도 빌드 가능한 상태를 목표로 한다.
- 모호한 결정은 임의로 확정하지 않고 질문한 뒤 문서에 반영한다.

## 네이밍 원칙
- 이름은 간결하고 역할이 바로 드러나게 작성한다.
- 기존 `LivithNetwork`에서 의미가 명확한 이름은 가능하면 유지한다.
- `Manager`, `Impl`, `Protocol`, `Envelope`처럼 의미가 모호하거나 길어지는 접미사는 피한다.
- 모듈 외부에서 자주 쓰는 네트워크 계약 타입은 충돌을 줄이기 위해 `Network` 접두사를 사용할 수 있다.

## 후속 설계 문서
- `LIVD-298-livith-networking-basic-request.md`: 기초 요청 계약과 `URLRequest` 생성 경계
- `LIVD-298-livith-networking-response.md`: 공통 응답, 빈 응답, 에러 처리 경계
- `LIVD-298-livith-networking-token.md`: 토큰 삽입, refresh, 401 retry 경계
- `LIVD-298-livith-networking-etag-cache.md`: ETag 메모리 캐시 정책
- `LIVD-298-livith-networking-migration.md`: DTO, API endpoint, Data 모듈 이전 전략

## 단계적 확장 방향
- 1단계: `LivithNetworking` 빈 독립 프로젝트와 테스트 타깃을 추가한다.
- 2단계: 기초 HTTP 통신을 추가한다.
- 3단계: 공통 응답 처리와 에러 매핑을 추가한다.
- 4단계: 인증 토큰 삽입을 추가한다.
- 5단계: 토큰 refresh와 401 retry를 추가한다.
- 6단계: ETag 메모리 캐시를 추가한다.
- 7단계: DTO와 API endpoint를 기능 단위로 이전한다.
- 8단계: 기존 `LivithNetwork`와 Alamofire 의존을 제거한다.

## 설계 문서 운영
- 설계 문서는 `docs/designs/`에 유지한다.
- 설계 문서는 구현 완료 후에도 `docs/archives/`로 이동하지 않는다.
- 후속 브랜치에서 설계 변경이 필요하면 관련 설계 문서를 먼저 갱신한다.
- 구현 계획과 완료 체크는 별도 `docs/plans/` 문서에서 관리한다.

## 열린 질문
- 첫 빈 모듈 구현 시 빌드 안정성을 위해 최소 placeholder Swift 파일을 둘지 구현 계획에서 확정한다.
