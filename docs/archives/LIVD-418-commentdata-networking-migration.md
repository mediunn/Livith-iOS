# [LIVD-418] CommentData 네트워크 모듈 LivithNetworking 마이그레이션

## 배경
- 기존 `LivithNetwork` 모듈은 Alamofire 기반의 레거시 네트워크 계층이다.
- `LivithNetworking` 모듈은 URLSession 기반의 새 네트워크 계층이다.
- `CommentData` 모듈은 아직 `LivithNetwork`에 의존하고 있어, 새 네트워크 계층으로의 마이그레이션이 필요하다.
- `SongData`(LIVD-415), `SetlistData`(LIVD-418)와 동일한 패턴으로 진행한다.
- Comment API는 **모든 엔드포인트가 인증을 필요로 하며**, GET·POST·DELETE 메서드와 쿼리·바디 파라미터를 모두 사용한다는 점에서 Song/Setlist보다 복잡도가 높다.

## 목표
- `CommentData` 모듈이 `LivithNetwork` 대신 `LivithNetworking`을 사용하도록 변경한다.
- `LivithNetworking` 모듈에 Comment DTO(Request·Response), Service를 신규 선언한다.
- `NetworkingFactory`에서 `CommentService`를 생성·제공하도록 한다.
- `CommentDataAssembler`가 Factory를 통해 `CommentService`를 주입받도록 변경한다.
- 기존 `CommentMapperTests`가 새 `NetworkError` 기반으로도 통과한다.

## 작업 항목
- [x] LivithNetworking에 Comment DTO 선언
  - `DTO/Comment/CreateConcertComment.swift` — `DTO.Request.CreateConcertComment` + `DTO.Response.CreateConcertComment` (Request DTO도 함께 포팅)
  - `DTO/Comment/CreateCommentReport.swift` — `DTO.Request.CreateCommentReport` + `DTO.Response.CreateCommentReport`
  - `DTO/Comment/FetchConcertCommentList.swift` — `DTO.Response.FetchConcertCommentList` + `Comment` + `Cursor` nested struct
  - DTO struct 및 프로퍼티는 `public` 접근 제어 필수 (CommentData 모듈에서 접근 필요)
  - Request DTO는 기존 LivithNetwork와 동일하게 `DTO.Request` 네임스페이스 아래 선언
- [x] LivithNetworking에 CommentService 선언
  - `Service/CommentService.swift` 추가 (프로토콜 + 구현체 동일 파일)
  - `CommentService` 프로토콜: `public protocol CommentService: Sendable`, 메서드는 `async throws(NetworkError)`
  - `CommentServiceImpl` 구조체: `NetworkClient`를 주입받아 `Sendable` 준수
  - 메서드:
    - `fetchConcertComments(concertID: Int, cursor: (createdAt: String, id: Int)?, size: Int?)` → `DTO.Response.FetchConcertCommentList`
    - `createComment(concertID: Int, content: String)` → `DTO.Response.CreateConcertComment`
    - `deleteComment(commentID: Int)` → `DTO.Response.EmptyResponse`
    - `reportComment(commentID: Int, content: String?)` → `DTO.Response.CreateCommentReport`
  - 각 메서드 내부에서 `NetworkEndpoint` struct 직접 생성
    - `fetchConcertComments`: `path: "/concerts/\(concertID)/comments"`, `method: .get`, `task: .query(...)`로 cursor+size 전달, `authentication: .required`
    - `createComment`: `path: "/concerts/\(concertID)/comments"`, `method: .post`, `task: .body(DTO.Request.CreateConcertComment(...))`, `authentication: .required`
    - `deleteComment`: `path: "/comments/\(commentID)"`, `method: .delete`, `task: .plain`, `authentication: .required`
    - `reportComment`: `path: "/comments/\(commentID)/report"`, `method: .post`, `task: .body(DTO.Request.CreateCommentReport(...))`, `authentication: .required`
- [x] NetworkingFactory에서 CommentService 제공
  - `NetworkingFactory` 프로토콜에 `func makeCommentService() -> any CommentService` 추가
  - `NetworkingFactoryImpl`에 `makeCommentService()` 구현 추가
- [x] NetworkingFactoryTests 수정
  - `NetworkingFactoryTests`에 `makeCommentService()` 생성 검증 테스트 추가
- [x] CommentData 모듈 의존성 변경
  - `Projects/Data/Project.swift`: `commentData` 타겟의 `.core(.livithNetwork)` → `.livithNetworking(.livithNetworking)`
- [x] CommentDataAssembler 마이그레이션
  - `import LivithNetwork` → `import LivithNetworking`
  - `NetworkingFactory` resolve → `makeCommentService()` → `CommentService` 등록
  - 기존 `CommentService()` 직접 생성 방식 제거
- [x] CommentRepositoryImpl 마이그레이션
  - `import LivithNetwork` → `import LivithNetworking`
  - `private let commentService: CommentService` → `private let commentService: any CommentService`
  - 호출 패턴: `commentService.request(.fetchConcertCommentList(...))` → `commentService.fetchConcertComments(...)`
  - `deleteComment`의 `EmptyResponse` 타입은 `import LivithNetworking` 후 `DTO.Response.EmptyResponse`로 참조 (LivithNetworking에도 동일 타입 존재)
- [x] CommentMapper 마이그레이션
  - `import LivithNetwork` → `import LivithNetworking`
  - DTO 참조 경로 동일 (`DTO.Response.FetchConcertCommentList`) → import만 변경
- [x] CommentErrorMapper 마이그레이션
  - `import LivithNetwork` → `import LivithNetworking`
  - 새 `NetworkError` 케이스 매핑 추가
    - `.timeout` → `.noConnection`
    - `.cancelled` → `.cancelled`
    - `.encodingFailed` → `.invalidResponse`
    - `.serverError(statusCode:message:)` → `.serverError` (파라미터 시그니처 변경 대응)
  - `extractMessage`의 `.serverError(let msg)` → `.serverError(_, let msg)` 패턴 변경
  - 주의: CommentErrorMapper는 `.unauthorized`/`.forbidden`을 `.forbidden`으로 매핑하며, `.noData`를 `.invalidResponse`로, `.notFound`를 `.unknown`으로 매핑한다. 이 기존 매핑 논리는 유지.
- [x] CommentMapperTests 마이그레이션
  - `import LivithNetwork` → `import LivithNetworking`
  - `CommentErrorMapperTests`의 `NetworkError` 케이스 수정
    - `.serverError(message: nil)` → `.serverError(statusCode: 500, message: nil)`
    - `.noConnection` wrapped 에러 생성 패턴 확인
    - 새 케이스 테스트 추가 (`.timeout` → `.noConnection`, `.encodingFailed` → `.invalidResponse`)
- [x] 빌드 및 테스트 검증
  - `tuist generate` 성공
  - `CommentMapperTests` 전체 통과
  - `NetworkingFactoryTests` 확인 (기존 테스트 깨지지 않음)
- [x] 구현 내용을 계획 문서를 바탕으로 서브에이전트에게 리뷰를 받고 통과할 때까지 수정한다

## 영향 범위
| 모듈 | 파일 | 상태 |
|------|------|------|
| LivithNetworking | `Sources/DTO/Comment/CreateConcertComment.swift` | 신규 |
| LivithNetworking | `Sources/DTO/Comment/CreateCommentReport.swift` | 신규 |
| LivithNetworking | `Sources/DTO/Comment/FetchConcertCommentList.swift` | 신규 |
| LivithNetworking | `Sources/Service/CommentService.swift` | 신규 |
| LivithNetworking | `Sources/Service/NetworkingFactory.swift` | 수정 |
| LivithNetworking | `Tests/Factory/NetworkingFactoryTests.swift` | 수정 |
| Data | `Projects/Data/Project.swift` | 수정 |
| CommentData | `Sources/Assembler/CommentDataAssembler.swift` | 수정 |
| CommentData | `Sources/Repository/CommentRepositoryImpl.swift` | 수정 |
| CommentData | `Sources/Mapper/CommentMapper.swift` | 수정 |
| CommentData | `Sources/Mapper/CommentErrorMapper.swift` | 수정 |
| CommentData | `Tests/CommentMapperTests.swift` | 수정 |

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| DTO 폴더명 | `CommentFeature` / `Comment` | **`Comment`** | `SongLyrics`, `Setlist`와 동일한 네이밍 컨벤션 |
| Endpoint 선언 방식 | A: 별도 enum/파일<br>B: `CommentService` 메서드 내 `NetworkEndpoint` 직접 생성 | **B** | 기존 마이그레이션과 동일 패턴 |
| CommentService 타입 구분 | A: 단일 구조체<br>B: 프로토콜 + 구현체 | **B** | `any CommentService`로 주입, DI 및 테스트 용이성 |
| 인증 정책 | `authentication: .none` / `.required` | **`.required`** | 모든 Comment 엔드포인트는 로그인 필요 (`requiresInterceptor: true`) |
| cursor 쿼리 전달 방식 | A: JSON 직렬화 문자열<br>B: `URLQueryItem` 목록 | **B** | 새 `NetworkEndpoint`의 `task: .query([URLQueryItem])` 사용. `NetworkClient`가 URL 인코딩 처리 |
| Request DTO 처리 | A: `DTO.swift`에 통합<br>B: Response DTO와 동일 파일에 선언 | **B** | 기존 LivithNetwork의 DTO 파일 구조를 그대로 유지. `DTO.Request` + `DTO.Response` 동일 파일 |
| 새 `NetworkError` 매핑 | LIVD-418과 동일: `.timeout` → `.noConnection`, `.encodingFailed` → `.invalidResponse`, `.cancelled` → `.cancelled` | **동일 적용** | SongData, SetlistData와 일관성 유지 |
| `EmptyResponse` 참조 | LivithNetworking에도 `EmptyResponse`가 존재하므로 그대로 사용 | **LivithNetworking.EmptyResponse** | `import LivithNetworking`만 변경하면 동일 타입명 사용 가능 |

## 주의 사항
- Comment API는 모든 엔드포인트가 `authentication: .required`다. Song/Setlist와 달리 인증 정책을 `.required`로 설정해야 한다.
- `fetchConcertComments`의 cursor 파라미터는 `(createdAt: String, id: Int)?` 튜플이다. `URLQueryItem`으로 변환 시 커서의 각 필드를 개별 쿼리 아이템으로 전달해야 한다.
- CommentErrorMapper는 다른 모듈과 달리 `.unauthorized`/`.forbidden` → `.forbidden`, `.notFound` → `.unknown`, `.noData` → `.invalidResponse`로 매핑한다. 이 기존 논리를 변경하지 않도록 주의한다.
- `DTO.Request` DTO는 `Encodable`이며, `NetworkEndpoint.task`의 `.body(any Encodable)`로 전달된다.
- `deleteComment`의 반환 타입은 `DTO.Response.EmptyResponse`다. LivithNetworking에도 동일한 `EmptyResponse` 타입이 존재한다 (별도 생성 불필요).

## 검증 방법
1. `tuist generate` 실행 — 모든 타겟이 성공적으로 생성되는지 확인
2. `xcodebuild test`로 `CommentMapperTests` 실행 — 전체 통과 확인
3. `grep -r "import LivithNetwork" Projects/Data/CommentData/` 실행 — 결과 없음 확인
4. `NetworkingFactoryTests` 실행 — `makeCommentService()` 생성 검증 및 기존 테스트 통과 확인
