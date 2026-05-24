# [LIVD-415] SongFeature 네트워크 모듈 LivithNetworking 마이그레이션

## 배경
- 기존 `LivithNetwork` 모듈은 Alamofire 기반의 레거시 네트워크 계층이다.
- `LivithNetworking` 모듈은 URLSession 기반의 새 네트워크 계층으로, 토큰 갱신, ETag 캐싱, 인터셉터 등이 내장되어 있다.
- `SongData` 모듈은 아직 `LivithNetwork`에 의존하고 있어, 새 네트워크 계층으로의 마이그레이션이 필요하다.

## 목표
- `SongData` 모듈이 `LivithNetwork` 대신 `LivithNetworking`을 사용하도록 변경한다.
- `LivithNetworking` 모듈에 SongFeature용 DTO, Service를 새로 선언한다.
- `NetworkingFactory`에서 `SongService`를 생성·제공하도록 한다.
- `SongDataAssembler`가 Factory를 통해 `SongService`를 주입받도록 변경한다.
- 기존 `SongDataTests`가 새 `NetworkError` 기반으로도 통과한다.

## 작업 항목
- [x] LivithNetworking에 SongLyrics DTO 선언
  - `DTO/SongLyrics/FetchSongLyrics.swift` 추가
  - `DTO/SongLyrics/FetchSongFanchant.swift` 추가
  - DTO struct 및 프로퍼티는 `public` 접근 제어 필수 (SongData 모듈에서 접근 필요)
- [x] LivithNetworking에 SongService 선언
  - `Service/SongService.swift` 추가 (프로토콜과 구현체를 동일 파일에, 파일명은 프로토콜명 `SongService`로 작성)
  - `SongService` 프로토콜: `public protocol SongService: Sendable`로 선언, 메서드는 `async throws(NetworkError)`
  - `SongServiceImpl` 구조체: `NetworkClient`를 주입받아 `Sendable` 준수
  - 각 메서드 내부에서 `NetworkEndpoint` 구조체를 직접 생성
    - `path`: `/songs/\(songID)` 또는 `/setlists/\(setlistID)/songs/\(songID)/fanchant`
    - `method: .get`
    - `task: .plain`
    - `requiresAuthentication: false` (Song API는 인증 불필요)
- [x] NetworkingFactory에서 SongService 제공
  - `NetworkingFactory` 프로토콜에 `func makeSongService() -> any SongService` 추가
  - `NetworkingFactoryImpl`에 `makeSongService()` 구현 추가 (내부 `private let networkClient` 사용)
  - `NetworkingFactory.swift` 단일 파일 내에 MARK 주석으로 Service 생성 메서드 구역 구분 (파일 분리하지 않음)
- [x] NetworkingFactoryTests 수정
  - `makeSongService()` 생성 검증 테스트 추가
- [x] SongData 모듈 의존성 변경
  - `Projects/Data/Project.swift`: `songData` 타겟의 `.core(.livithNetwork)` → `.livithNetworking(.livithNetworking)`
- [x] SongDataAssembler 마이그레이션
  - `import LivithNetworking`으로 변경
  - `NetworkingFactory` resolve → `makeSongService()` → `SongService` 등록
- [x] SongRepositoryImpl 마이그레이션
  - `import LivithNetworking`으로 변경
  - DTO 참조는 `import LivithNetworking` 후 `DTO.Response.FetchSongLyrics` / `DTO.Response.FetchSongFanchant`로 사용
  - `private let songService: SongService` → `private let songService: any SongService` 변경 (프로토콜 타입)
  - 호출 패턴을 `songService.fetchSongLyrics(...)` / `songService.fetchSongFanchant(...)`로 변경
  - `HTTPHeaders` → `[String: String]` 변경은 해당 API가 headers를 사용하지 않으므로 영향 없음
- [x] SongMapper 마이그레이션
  - `import LivithNetworking`으로 변경
- [x] SongErrorMapper 마이그레이션
  - `import LivithNetworking`으로 변경
  - 새 `NetworkError` 케이스 매핑 추가
    - `.timeout` → `.noConnection`
    - `.cancelled` → `.cancelled`
    - `.encodingFailed` → `.invalidResponse`
    - `.serverError(statusCode:message:)` → `.serverError` (SongError는 statusCode를 보관하지 않으므로 기존 매핑 유지)
- [x] SongDataTests 마이그레이션
  - `SongErrorMapperTests.swift`: `import LivithNetworking`, 새 `NetworkError` 케이스 테스트 추가/수정
  - `.serverError(message: nil)` → `.serverError(statusCode: 500, message: nil)` 등 구체적 변경 예시 반영
- [x] 빌드 및 테스트 검증
  - `tuist generate` 성공
  - `SongDataTests` 전체 통과
  - `NetworkingFactoryTests` 전체 통과
- [x] 구현 내용을 계획 문서를 바탕으로 서브에이전트에게 리뷰를 받고 통과할 때까지 수정한다

## 영향 범위
| 모듈 | 파일 | 상태 |
|------|------|------|
| LivithNetworking | `Sources/DTO/SongLyrics/FetchSongLyrics.swift` | 신규 |
| LivithNetworking | `Sources/DTO/SongLyrics/FetchSongFanchant.swift` | 신규 |
| LivithNetworking | `Sources/Service/SongService.swift` | 신규 |
| LivithNetworking | `Sources/Factory/NetworkingFactory.swift` | 수정 |
| LivithNetworking | `Tests/Factory/NetworkingFactoryTests.swift` | 수정 |
| Data | `Projects/Data/Project.swift` | 수정 |
| SongData | `Sources/Assembler/SongDataAssembler.swift` | 수정 |
| SongData | `Sources/Repository/SongRepositoryImpl.swift` | 수정 |
| SongData | `Sources/Mapper/SongMapper.swift` | 수정 |
| SongData | `Sources/Mapper/SongErrorMapper.swift` | 수정 |
| SongData | `Tests/SongErrorMapperTests.swift` | 수정 |

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| DTO 폴더명 | `SongFeature` / `SongLyrics` | **`SongLyrics`** | 주제가 "가사 보기"이며, 응원법도 해당 화면 내에서 함께 노출되는 데이터이다. 서버 명세 기반으로 주제를 담은 폴더명을 선택한다. |
| Endpoint 선언 방식 | A: 별도 enum/파일 (`SongEndpoint.swift`)<br>B: `SongService` 메서드 내부에서 `NetworkEndpoint` 직접 생성 | **B** | LivithNetworking의 `NetworkEndpoint`는 struct이므로 별도 타입 선언 없이 인라인으로 생성 가능하다. 불필요한 파일을 줄이고, 엔드포인트 정의가 사용처에 응집되도록 한다. |
| SongService 설계 방식 | A: `NetworkClient`를 직접 외부에 노출<br>B: `SongService` 래퍼를 Factory가 생성 제공 | **B** | `SongRepositoryImpl`이 `SongService` 타입에 의존하도록 기존 패턴을 유지하고, `NetworkClient` 세부 구현을 숨긴다. |
| SongService 타입 구분 | A: 단일 구조체<br>B: 프로토콜 + 구현체 | **B** | `SongService`는 **프로토콜**(`public protocol SongService: Sendable`)로 외부에 공개하고, `SongServiceImpl`은 **구조체**로 구현한다. DI와 테스트 시 모의 객체 주입이 용이하다. 사용처에서는 `any SongService`로 선언한다. |
| SongService 인터페이스 | A: 엔드포인트 enum 노출 (`request(_ endpoint: SongEndpoint)`)<br>B: 메서드별 API (`fetchSongLyrics(...)`, `fetchSongFanchant(...)`) | **B** | 엔드포인트를 별도 타입으로 두지 않으므로, 메서드 기반 API가 자연스럽다. `SongRepositoryImpl`의 호출 패턴도 직관적으로 변경된다. |
| SongService throws 타입 | A: `async throws`<br>B: `async throws(NetworkError)` | **B** | LivithNetworking의 기존 Service(`TokenRefreshService`)가 `throws(NetworkError)`를 사용하므로 동일 패턴을 따른다. |
| 새 `NetworkError` 매핑 | `.timeout` → `noConnection` 또는 `unknown` | **`.noConnection`** | 사용자 관점에서 네트워크 연결 문제로 인식하는 것이 자연스럽다. |
| 새 `NetworkError` 매핑 | `.encodingFailed` → `invalidResponse` 또는 `invalidRequest` | **`.invalidResponse`** | 기존 매핑 그룹(`decodingFailed`, `invalidURL` 등)과 동일하게 처리한다. |
| `.serverError` 매핑 | 기존 `.serverError(message:)` vs 신규 `.serverError(statusCode:message:)` | **`.serverError`로 동일 매핑** | `SongError`에는 statusCode가 없으므로 기존과 동일하게 `.serverError`로 매핑한다. |

## 주의 사항
- `LivithNetworking.NetworkError`와 `LivithNetwork.NetworkError`는 enum 케이스가 다르다. `SongErrorMapper`의 `switch`가 exhaustive하지 않으면 컴파일 에러가 발생하므로, 새 케이스(`.timeout`, `.cancelled`, `.encodingFailed`)를 반드시 추가해야 한다.
- `SongData` 모듈이 `LivithNetworking`을 의존하게 되면, `NetworkClient`가 `Sendable`이므로 `SongService`도 `Sendable`을 준수하도록 선언해야 한다.
- `Projects/Data/Project.swift` 변경 시 `tuist generate`가 필수이며, 다른 Data 모듈에는 영향을 주지 않도록 주의한다.

## 검증 방법
1. `tuist generate` 실행 — 모든 타겟이 성공적으로 생성되는지 확인
2. `xcodebuild test` 또는 `tuist test`로 `SongDataTests` 실행 — `SongErrorMapperTests` 전체 통과 확인
3. `LivithNetworkingTests` 실행 — `NetworkingFactoryTests` 통과 확인
4. `grep -r "import LivithNetwork" Projects/Data/SongData/` 실행 — 결과가 없음을 확인 (`LivithNetwork` 의존 완전 제거)
