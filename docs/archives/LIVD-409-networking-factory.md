# [LIVD-409] NetworkingFactory 구현

## 배경
- LivithNetworking 모듈은 네트워크 클라이언트, 토큰 관리, 인증 인터셉터 등 여러 컴포넌트로 구성되어 있음
- 현재는 각 컴포넌트를 개별적으로 생성하여 사용하고 있어 설정 주입과 공유자원 관리가 분산되어 있음
- DI 컨테이너에서 네트워킹 모듈의 단일 진입점 역할을 할 팩토리가 필요함
- 리프레시 토큰 만료 시 앱으로 이벤트를 전파할 메커니즘이 필요함

## 목표
- `NetworkingFactory` 프로토콜 및 구현체(`NetworkingFactoryImpl`) 구현
- 앱 설정(`NetworkConfig`, 리프레시 토큰 만료 핸들러)을 팩토리가 소유하고 공유자원으로 관리
- 팩토리를 통해 도메인별 네트워크 서비스를 반환받을 수 있는 구조 구축
- 남용 방지를 위해 납부 구현은 `internal`로 숨기고 필요한 인터페이스만 `public`으로 노출

## 작업 항목
- [x] `TokenRefreshServiceImpl` 테스트 작성
  - 리프레시 토큰 만료(401) 시 `onRefreshTokenExpired` 클로저 호출 검증 → `TokenManager`로 이관
  - `NetworkError` 전파 검증
- [x] `TokenRefreshServiceImpl`에 `onRefreshTokenExpired` 클로저 파라미터 추가 → **`TokenManagerImpl`로 이관**
  - 리프레시 토큰 만료(401) 감지 시 클로저 호출 (최종: `TokenManager`가 담당)
  - 접근 제어 제거 (암시적 internal)
  - 기존 생성자 제거 (새 생성자만 사용)
- [x] `NetworkingFactoryImpl` 테스트 작성
  - 생성자에서 공유자원 초기화 검증
  - 순환 의존성 없이 `TokenRefreshService`가 별도 `NetworkClient` 사용 검증
- [x] `NetworkingFactory` 프로토콜 정의
  - `config: NetworkConfig`
  - `onAuthenticationExpired: @Sendable () -> Void`
  - (추후) 도메인 서비스 팩토리 메서드
  - 프로토콜과 구현체 단일 파일(`NetworkingFactory.swift`)로 통합
- [x] `NetworkingFactoryImpl` 구현
  - `struct`로 구현 (불변 상태로 인해 actor 불필요)
  - 생성자에서 `NetworkConfig`, `@Sendable () -> Void`, `TokenStore` 주입받음
  - 남부에서 `TokenRefreshService`, `TokenManager`, `NetworkClient` 초기화 및 소유
  - 순환 의존성 방지를 위해 `TokenRefreshService`는 별도의 `NetworkClient` 인스턴스 사용 (AuthInterceptor 없음)
  - 만료 이벤트 핸들러는 `TokenManager`로 전달 (책임 분리)
- [x] 남부 구현체 접근 제어 변경
  - `TokenManager` 프로토콜: `public` 접근 제어 제거
  - `TokenManagerImpl`: `public` 접근 제어 제거
  - `TokenRefreshService` 프로토콜: `public` 접근 제어 제거
  - `AuthInterceptor`: `public` 접근 제어 제거
- [x] `Sources/Factory/` 디렉토리 생성 및 파일 배치
- [x] `NetworkConfig.swift` 위치 이동: `Sources/Request/` → `Sources/Client/`
- [x] 서브에이전트 최종 리뷰 (`통과` 판정)

## 영향 범위
- `Projects/LivithNetworking/Sources/Factory/` (신규)
- `Projects/LivithNetworking/Sources/Service/TokenRefreshService.swift`
- `Projects/LivithNetworking/Sources/Token/TokenManager.swift`
- `Projects/LivithNetworking/Sources/Token/TokenManager.swift` (프로토콜 접근 제어)
- `Projects/LivithNetworking/Sources/Interceptor/AuthInterceptor.swift`

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| Factory 구현체 타입 | Struct vs Actor | Struct | 불변 상태(`let`)만 보유하므로 Sendable 준수. 호출부에서 `await` 불필요 |
| 공유자원 관리 | 외부 주입 vs 남부 초기화 | 혼합 | `config`, `onAuthenticationExpired`, `tokenStore`는 주입. 나머지는 남부 초기화 |
| 순환 의존성 해결 | 동일 클라이언트 vs 별도 클라이언트 | 별도 클라이언트 | `TokenRefreshService`는 AuthInterceptor 없는 별도 `NetworkClient` 사용. 그렇지 않으면 리프레시 API 호출 시 무한 루프 발생 |
| 접근 제어 | Public vs 암시적 internal | 구분 적용 | 팩토리 인터페이스와 설정만 Public. 남부 구현(TokenManager, TokenRefreshService, AuthInterceptor 등)은 접근 제어 미명시 (암시적 internal) |
| 하위호환성 | 기존 생성자 유지 vs 삭제 | 기존 생성자 제거 | `TokenRefreshServiceImpl`의 기존 생성자는 불필요하므로 제거하고 새 생성자만 사용 |
| 이벤트 전파 방식 | Delegate vs Closure | Closure | Sendable 준수 용이, 구현 간단, DI 주입 직관적 |

## 주의 사항
- **순환 의존성**: `TokenRefreshService`는 인증이 필요 없는 별도의 `NetworkClient` 인스턴스를 사용해야 함
  - 그렇지 않으면 리프레시 API 호출 → 인터셉터 동작 → 토큰 리프레시 시도 → 리프레시 API 호출... 무한 루프
- **Sendable 준수**: `onAuthenticationExpired` 클로저는 `@Sendable`이어야 함
- **테스트 고려**: `NetworkingFactory` 프로토콜을 두어 테스트에서 Mock 구현체 주입 가능

## 테스트 전략
- **`TokenRefreshServiceImpl` 테스트**: `NetworkTransport` 프로토콜을 준수하는 `MockNetworkTransport`를 구현하여 주입
  - `NetworkClient`는 `NetworkTransport`를 주입받는 구조이므로, transport 레벨에서 401 응답을 시뮬레이션하여 `onRefreshTokenExpired` 클로저 호출 검증
- **`NetworkingFactoryImpl` 테스트**: 
  - 생성자 호출 시 남부 의존성들이 정상 초기화되는지 검증
  - `TokenRefreshService`와 도메인 서비스용 `NetworkClient`가 별도 인스턴스인지 확인 (interceptor 유무로 간접 검증)

## 검증 방법
- [x] 프로젝트 컴파일 성공 확인 (`tuist generate` 및 빌드)
- [x] `NetworkingFactoryImpl`이 `Sendable` 준수 확인
- [x] 접근 제어 변경 후 외부 모듈에서 필요한 인터페이스만 접근 가능한지 확인
- [x] 테스트 통과 확인 (125개)
- [x] 서브에이전트 최종 리뷰
  - 모든 구현 내용을 계획 문서를 바탕으로 리뷰
  - 계획 충실도, 과도 구현 여부, 누락 항목 점검
  - `통과` 판정
