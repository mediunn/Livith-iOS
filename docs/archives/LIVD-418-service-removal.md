# LIVD-418 Networking Service 계층 제거

## 배경
- 기존 `LivithNetwork`(Alamofire 기반)에서 `LivithNetworking`(URLSession 기반)으로 마이그레이션 완료.
- 현재 `LivithNetworking`의 `*Service`는 `NetworkEndpoint`를 인라인 조립하여 `NetworkClient.request`에 전달하는 thin wrapper.
- 모든 `*ServiceImpl`은 Factory 내 동일한 `networkClient` 인스턴스를 주입받으며, 추가 로직 없음.
- `*Service`와 `*Endpoint`가 1:1 대응하는 상황에서 Service 계층은 불필요한 간접 참조.

## 목표
- `*Service` 프로토콜/구현체 10종 제거.
- `*API` 네임스페이스 enum에 static func 형태로 `NetworkEndpoint` 생성기 도입.
- Data 모듈의 Repository가 `NetworkClient`를 직접 주입받아 호출.
- `NetworkingFactory` 프로토콜/구현체 제거, `NetworkClientBuilder`로 대체.
- App은 `NetworkClient` + `TokenStore`만 등록.
- `NetworkTransport` 및 `NetworkClient(transport:)` 생성자를 `public`으로 열어 테스트 가능하게.

## 작업 항목

### 1. LivithNetworking — 인프라 변경
- [x] `NetworkTransport` 프로토콜 접근 제어 `internal` → `public`
  - 테스트 모듈에서 Mock 구현 가능하도록
- [x] `NetworkClient`에 `public init(config:transport:interceptor:plugins:)` 추가
  - 기존 `internal init(... transport: ...)`은 제거, production용 `public init(config:interceptor:plugins:)`는 유지
- [x] `AuthInterceptor.init(config:tokenStore:)` 편의 생성자 제거
  - 내부에서 `TokenRefreshServiceImpl`을 직접 생성 중 → `NetworkClientBuilder.build()`에서만 생성하도록 일원화
  - `AuthInterceptorTests`는 주 생성자 `init(tokenManager:)`만 사용하므로 영향 없음
- [x] `NetworkClientBuilder` enum 추가
  - 기존 `NetworkingFactoryImpl.init`의 조립 로직(`refreshClient` → `TokenRefreshService` → `TokenManager` → `AuthInterceptor` → `NetworkClient`)을 `static func build(config:onAuthenticationExpired:tokenStore:) -> (client: NetworkClient, tokenStore: any TokenStore)`로 제공
- [x] `Sources/Testing/MockNetworkTransport.swift` 추가 (`public`)
  - 기존 `Tests/Support/TestNetworkTransport.swift`의 Output 패턴 기반으로 이관
  - `public`으로 노출하여 각 Data 모듈 테스트에서 import 가능하도록
  - 요청 기록(`request()`, `requests()`) 기능 포함
  - 기존 `Tests/Support/TestNetworkTransport.swift`는 제거하고 `MockNetworkTransport`로 대체

### 2. LivithNetworking — *API 네임스페이스 추가, *Service 제거
- [x] 각 도메인별 `*API` enum 및 `NetworkEndpoint` static func 추가 (10개)
  - `SongAPI`, `SetlistAPI`, `CommentAPI`, `SearchAPI`, `PreferenceAPI`, `NotificationAPI`, `UserAPI`, `OnboardingAPI`, `HomeAPI`, `ConcertAPI`
  - 각 static func는 기존 `*ServiceImpl` 메서드의 `NetworkEndpoint` 인라인 생성 로직을 그대로 이관
- [x] `*Service` 프로토콜 10종 제거
- [x] `*ServiceImpl` struct 10종 제거
- [x] `NetworkingFactory` 프로토콜 + `NetworkingFactoryImpl` struct 제거
- [x] `TokenRefreshService` / `TokenRefreshServiceImpl` 유지 확인 (`NetworkClientBuilder` 내부에서만 사용)

### 3. Data 모듈 — Repository / Assembler 변경 (9개 모듈)
- [x] 각 `*RepositoryImpl`에서 `*Service` 의존을 `NetworkClient`로 교체
  - `init(*Service: ...)` → `init(networkClient: NetworkClient)`
  - 메서드 내부 호출을 `*Service.method()` → `networkClient.request(*API.method(...))`로 변경
  - `ConcertRepositoryImpl`은 4개 Service를 `NetworkClient` 하나로 통합
- [x] 각 `*DataAssembler`에서 `NetworkingFactory.resolve()` → `factory.make*Service()` 패턴 제거
  - `NetworkClient`를 DI에서 직접 resolve하여 RepositoryImpl 생성
  - AuthDataAssembler: `TokenStore` 별도 resolve

### 4. App — DI 등록 변경
- [x] `LivithApp+InjectDependency.swift`의 `registerNetworkingFactory()` → `registerNetworkingClient()`로 변경
- [x] `NetworkClientBuilder.build(...)` 호출 → `NetworkClient`, `TokenStore` 등록

### 5. 규칙 문서
- [x] `docs/rules/architecture.md` 수정 (4개 라인)
  - L34: "Repository 구현체는 Service(네트워크), Cache, Mapper를 조합" → "NetworkClient, Cache, Mapper를 조합"
  - L60: "`NetworkService<EndPoint>` 제네릭 클래스를 사용한다" → 제거
  - L61: "각 Feature별로 Service 타입 별칭을 정의한다" → "각 도메인별 API 네임스페이스를 정의한다"
  - L62: "API 요청 정의는 `NetworkEndpoint` 프로토콜을 채택한 enum으로 작성한다" → "`*API` 네임스페이스의 static func로 `NetworkEndpoint`를 생성한다"

### 6. 정리
- [ ] `Projects/Core/LivithNetwork` 디렉토리 제거 — UserFeature에서 여전히 참조 중이므로 별도 이슈로 분리
- [x] `LivithNetworking/Tests`의 `TestNetworkTransport`를 `Sources/Testing/`로 이관 및 `MockNetworkTransport`로 대체

## 영향 범위

| 모듈 | 변경 유형 |
|------|----------|
| `LivithNetworking` | 대규모: *Service 제거, *API 추가, NetworkClientBuilder 추가, NetworkTransport public |
| `AuthData` | Assembler, RepositoryImpl |
| `CommentData` | Assembler, RepositoryImpl |
| `ConcertData` | Assembler, RepositoryImpl |
| `NotificationData` | Assembler, RepositoryImpl |
| `PreferenceData` | Assembler, RepositoryImpl |
| `SearchData` | Assembler, RepositoryImpl |
| `SetlistData` | Assembler, RepositoryImpl |
| `SongData` | Assembler, RepositoryImpl |
| `UserData` | Assembler, RepositoryImpl |
| `App` | DI 등록 코드 |
| `docs/rules/architecture.md` | 네트워크 계층 규칙 수정 |
| `Projects/Core/LivithNetwork` | 제거 (별도 이슈) |

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| API 정의 방식 | 1. `*Endpoint` enum (case + associated value) 2. `*API` 네임스페이스 enum (static func만) 3. `NetworkEndpoint` extension에 직접 static func | 2 | 1은 불필요한 enum case 타입 추가, 3은 이름 충돌 위험. 2가 타입 최소화 + 도메인 네임스페이스 분리를 모두 만족 |
| NetworkClient 생성 책임 | 1. App에서 직접 조립 2. `NetworkClientBuilder` static 메서드로 위임 | 2 | 조립 로직(`TokenManager`, `AuthInterceptor` 등)이 복잡하므로 App에서 분리 |
| Factory 제거 범위 | 1. `NetworkingFactory` 완전 제거 2. `NetworkClientProvider`로 축소 | 1 | 모든 Service가 제거되면 Factory의 유일한 역할은 `NetworkClient` 생성뿐. Builder로 충분 |
| NetworkTransport 노출 | 1. `internal` 유지, `@testable import`로만 접근 2. `public`으로 전환 | 2 | Data 모듈의 테스트는 별도 타겟이므로 `@testable import` 불가. public 필수 |
| TokenStore 제공 방식 | 1. Factory/Build의 반환값에 포함 2. 별도 등록 | 1 | `build()` 튜플 반환으로 `NetworkClient`와 함께 전달. DI 등록 코드 간결 |

## 주의 사항
- `*API` static func 이름 충돌 방지 — 같은 도메인 내에서 파라미터 시그니처로 오버로딩 관리
- `NetworkClient`는 struct이며 `Sendable`. DI Container에서 value로 등록 시 복사되지만 내부 `URLSession`은 동일 인스턴스 공유 (문제 없음)
- `ConcertDataAssembler`는 여러 Service(`homeService`, `searchService`, `concertService`, `setlistService`)를 주입받으므로, RepositoryImpl 생성자가 `NetworkClient` 하나만 받도록 통합
- `AuthDataAssembler`는 `TokenStore`를 별도로 resolve해야 함
- 기존 `LivithNetwork` 제거는 별도 작업으로 분리 (UserFeature가 아직 참조 중)

## 검증 방법
1. `tuist generate` 성공 여부 확인 ✅
2. 전체 프로젝트 빌드 성공 (`xcodebuild`) ✅
3. `LivithNetworking` 테스트 통과 (별도 실행)
4. 각 Data 모듈 테스트 통과 (MockNetworkTransport로 Repository 격리 테스트 — 별도)
