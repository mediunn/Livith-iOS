# [LIVD-418] SetlistData 네트워크 모듈 LivithNetworking 마이그레이션

## 배경
- 기존 `LivithNetwork` 모듈은 Alamofire 기반의 레거시 네트워크 계층이다.
- `LivithNetworking` 모듈은 URLSession 기반의 새 네트워크 계층으로, 토큰 갱신, 인터셉터, 플러그인 등이 내장되어 있다.
- `SetlistData` 모듈은 아직 `LivithNetwork`에 의존하고 있어, 새 네트워크 계층으로의 마이그레이션이 필요하다.
- `SongData`의 마이그레이션(LIVD-415)과 동일한 패턴으로 진행한다.

## 목표
- `SetlistData` 모듈이 `LivithNetwork` 대신 `LivithNetworking`을 사용하도록 변경한다.
- `LivithNetworking` 모듈에 SetlistFeature용 DTO, Service를 신규 선언한다.
- `NetworkingFactory`에서 `SetlistService`를 생성·제공하도록 한다.
- `SetlistDataAssembler`가 Factory를 통해 `SetlistService`를 주입받도록 변경한다.
- 기존 `SetlistMapperTests`가 새 `NetworkError` 기반으로도 통과한다.

## 작업 항목
- [x] LivithNetworking에 Setlist DTO 선언
  - `DTO/Setlist/FetchConcertSetlist.swift` 추가 — 기존 `LivithNetwork`의 `DTO.Response.FetchConcertSetlist` 포팅
  - `DTO/Setlist/FetchSetlistSongList.swift` 추가 — 기존 `DTO.Response.FetchSetlistSongList` + `SetlistSong` 포팅
  - DTO struct 및 프로퍼티는 `public` 접근 제어 필수 (SetlistData 모듈에서 접근 필요)
- [x] LivithNetworking에 SetlistService 선언
  - `Service/SetlistService.swift` 추가 (프로토콜 + 구현체 동일 파일, 파일명은 프로토콜명 `SetlistService`)
  - `SetlistService` 프로토콜: `public protocol SetlistService: Sendable`, 메서드는 `async throws(NetworkError)`
  - `SetlistServiceImpl` 구조체: `NetworkClient`를 주입받아 `Sendable` 준수
  - 메서드:
    - `fetchSetlistDetail(concertID: Int, setlistID: Int)` → `DTO.Response.FetchConcertSetlist`
    - `fetchSetlistSongList(setlistID: Int)` → `DTO.Response.FetchSetlistSongList`
  - 각 메서드 내부에서 `NetworkEndpoint` struct 직접 생성 (인라인)
    - `path`: `/concerts/\(concertID)/setlists/\(setlistID)`, `/setlists/\(setlistID)/songs`
    - `method: .get`, `task: .plain`, `authentication: .none`
- [x] NetworkingFactory에서 SetlistService 제공
  - `NetworkingFactory` 프로토콜에 `func makeSetlistService() -> any SetlistService` 추가
  - `NetworkingFactoryImpl`에 `makeSetlistService()` 구현 추가
  - `NetworkingFactory.swift` 단일 파일 내 MARK 주석으로 구분
- [x] NetworkingFactoryTests 수정
  - `NetworkingFactoryTests`에 `makeSetlistService()` 생성 검증 테스트 추가 (LIVD-415의 `makeSongService()` 테스트와 동일 패턴)
- [x] SetlistData 모듈 의존성 변경
  - `Projects/Data/Project.swift`: `setlistData` 타겟의 `.core(.livithNetwork)` → `.livithNetworking(.livithNetworking)`
- [x] SetlistDataAssembler 마이그레이션
  - `import LivithNetwork` → `import LivithNetworking`
  - `NetworkingFactory` resolve → `makeSetlistService()` → `SetlistService` 등록
  - 기존 `SetlistService()` 직접 생성 방식 제거
- [x] SetlistRepositoryImpl 마이그레이션
  - `import LivithNetwork` → `import LivithNetworking`
  - `private let setlistService: SetlistService` → `private let setlistService: any SetlistService` (프로토콜 타입)
  - 호출 패턴 변경: `setlistService.request(.fetchSetlistDetail(...))` → `setlistService.fetchSetlistDetail(...)`
- [x] SetlistMapper 마이그레이션
  - `import LivithNetwork` → `import LivithNetworking`
  - DTO 참조 경로 동일 (`DTO.Response.FetchConcertSetlist`) → import만 변경
- [x] SetlistErrorMapper 마이그레이션
  - `import LivithNetwork` → `import LivithNetworking`
  - 새 `NetworkError` 케이스 매핑 추가
    - `.timeout` → `.noConnection`
    - `.cancelled` → `.cancelled`
    - `.encodingFailed` → `.invalidResponse`
    - `.serverError(statusCode:message:)` → `.serverError` (파라미터 시그니처 변경 대응)
  - `extractMessage` 함수의 `.serverError(let msg)` → `.serverError(_, let msg)` 패턴 변경 (새 `NetworkError`의 `serverError`는 `(statusCode: Int, message: String?)`)
  - `checkForCancellation` 내 `.noConnection` 케이스에서 `wrappedError` 접근 패턴 반영 (새 `NetworkError`는 `.noConnection(Error)` 연관값 있음)
- [x] SetlistMapperTests 마이그레이션
  - `import LivithNetwork` → `import LivithNetworking`
  - `SetlistErrorMapperTests`의 `NetworkError` 케이스 수정
    - `.serverError(message: nil)` → `.serverError(statusCode: 500, message: nil)`
    - `.noConnection` wrapped 에러 생성 패턴 확인
    - `.cancelled` 케이스 테스트 추가 (`.encodingFailed` / `.timeout` 등)
- [x] 빌드 및 테스트 검증
  - `tuist generate` 성공
  - `SetlistMapperTests` 전체 통과 (10 tests passed)
  - `NetworkingFactoryTests` 확인 (5 tests passed, 기존 테스트 깨지지 않음)
- [x] 구현 내용을 계획 문서를 바탕으로 서브에이전트에게 리뷰를 받고 통과할 때까지 수정한다

## 영향 범위
| 모듈 | 파일 | 상태 |
|------|------|------|
| LivithNetworking | `Sources/DTO/Setlist/FetchConcertSetlist.swift` | 신규 |
| LivithNetworking | `Sources/DTO/Setlist/FetchSetlistSongList.swift` | 신규 |
| LivithNetworking | `Sources/Service/SetlistService.swift` | 신규 |
| LivithNetworking | `Sources/Service/NetworkingFactory.swift` | 수정 |
| LivithNetworking | `Tests/Factory/NetworkingFactoryTests.swift` | 수정 |
| Data | `Projects/Data/Project.swift` | 수정 |
| SetlistData | `Sources/Assembler/SetlistDataAssembler.swift` | 수정 |
| SetlistData | `Sources/Repository/SetlistRepositoryImpl.swift` | 수정 |
| SetlistData | `Sources/Mapper/SetlistMapper.swift` | 수정 |
| SetlistData | `Sources/Mapper/SetlistErrorMapper.swift` | 수정 |
| SetlistData | `Tests/SetlistMapperTests.swift` | 수정 |

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| DTO 폴더명 | `SetlistFeature` / `Setlist` | **`Setlist`** | `SongLyrics`와 동일한 네이밍 컨벤션. 주제명으로 폴더명 사용 |
| Endpoint 선언 방식 | A: 별도 enum/파일 (`SetlistEndpoint.swift`)<br>B: `SetlistService` 메서드 내 `NetworkEndpoint` 직접 생성 | **B** | LIVD-415와 동일. 불필요한 파일 분리를 피하고 엔드포인트 정의를 사용처에 응집 |
| SetlistService 설계 방식 | A: `NetworkClient` 직접 노출<br>B: 프로토콜 래퍼를 Factory가 생성 제공 | **B** | LIVD-415와 동일. DI 및 테스트 용이성, 구현 은닉 |
| SetlistService 타입 구분 | A: 단일 구조체<br>B: 프로토콜 + 구현체 | **B** | LIVD-415와 동일. `any SetlistService`로 주입 |
| SetlistService 인터페이스 | A: 엔드포인트 enum 노출<br>B: 메서드별 API (`fetchSetlistDetail(...)`, `fetchSetlistSongList(...)`) | **B** | 엔드포인트 enum을 별도로 두지 않으므로 메서드 기반 API가 자연스럽다 |
| SetlistService throws | A: `async throws`<br>B: `async throws(NetworkError)` | **B** | LivithNetworking의 기존 Service와 동일 패턴 |
| 새 `NetworkError` 매핑 (`.timeout`) | `.noConnection` / `.unknown` | **`.noConnection`** | 사용자 관점에서 네트워크 연결 문제로 인식 |
| 새 `NetworkError` 매핑 (`.encodingFailed`) | `.invalidResponse` / `.invalidRequest` | **`.invalidResponse`** | 기존 매핑 그룹(`decodingFailed`, `invalidURL` 등)과 동일 처리 |
| `.serverError` 파라미터 변경 | old: `.serverError(message:)` → new: `.serverError(statusCode:message:)` | **매핑 로직에서 `_`로 statusCode 무시** | `SetlistError`에 statusCode가 없으므로 동일하게 `.serverError`로 매핑 |

## 주의 사항
- `LivithNetworking.NetworkError`와 `LivithNetwork.NetworkError`는 enum 케이스가 다르다. `SetlistErrorMapper`의 `switch`에 `.timeout`, `.cancelled`, `.encodingFailed` 케이스를 반드시 추가해야 컴파일 에러가 발생하지 않는다.
- `SetlistData` 모듈이 `LivithNetworking`을 의존하게 되면, `NetworkClient`가 `Sendable`이므로 `SetlistService`도 `Sendable`을 준수해야 한다.
- `Projects/Data/Project.swift` 변경 시 `tuist generate`가 필수이며, 다른 Data 모듈에는 영향을 주지 않도록 주의한다.
- `SetlistEndpoint`의 `fetchConcertMainSetlist`, `fetchConcertSetlist`는 현재 `SetlistData`에서 사용하지 않으므로 새 `SetlistService`에 포함하지 않는다.

## 검증 방법
1. `tuist generate` 실행 — 모든 타겟이 성공적으로 생성되는지 확인
2. `xcodebuild test`로 `SetlistMapperTests` 실행 — 전체 통과 확인
3. `grep -r "import LivithNetwork" Projects/Data/SetlistData/` 실행 — 결과가 없음을 확인 (`LivithNetwork` 의존 완전 제거)
4. `NetworkingFactoryTests` 실행 — `makeSetlistService()` 생성 검증 및 기존 테스트 통과 확인
