# [LIVD-427] 인스타그램 추출 잡 API 연동 — ConcertMatchingRepository 실구현

## 배경
- LIVD-427에서 인스타그램 공유 → 관심 콘서트 등록 화면(FR-04/FR-05)을 구현하며, 매칭 결과 공급부를 `ConcertMatchingRepository` 프로토콜 + 스텁(`ConcertMatchingRepositoryImpl`, 무조건 `.matchFailed` throw)으로 분리해 두었다.
- 서버 API 명세(인스타그램 카테고리 2종)가 확정되었다.
  - 추출 잡 생성: `POST /extraction-jobs` — body `{instagramUrl: String}`, 201 응답 `{jobId: String}`. 400(유효하지 않은 URL), 401.
  - 추출 잡 결과 조회: `GET /extraction-jobs/{jobId}?wait={0~25}` — long-poll(최대 25초 보류), 응답 `{jobId, status, concerts}`. `status`: `PENDING`/`EXTRACTING`(진행 중), `MATCHED`(성공, concerts 1~N), `NO_MATCH`(실패 또는 부분성공, concerts []). 404(존재하지 않거나 정리된 jobId), 401.
  - `concerts` 원소 스키마는 기존 `DTO.Response.RecommendedConcert`와 동일(id, code, title, startDate("yyyy.MM.dd"), endDate, status, poster, artist, daysLeft, ticketSite, ticketUrl, venue, introduction).
- 스텁을 실제 API 기반 구현으로 교체하면 Feature 레이어(`InstagramMatchConfirmStore`) 무수정으로 기능이 완성된다.

## 목표
- FR-04 진입 시 실제 서버 매칭 결과가 노출된다: 잡 생성 → long-poll → `MATCHED`면 콘서트 목록 반환, `NO_MATCH`면 빈 배열 반환(Store가 FR-05 검색 화면으로 폴백).
- 네트워크 오류·타임아웃·취소가 `ConcertMatchingError`로 일관되게 매핑된다.
- Endpoint·DTO·Mapper·ErrorMapper·Repository 폴링 로직을 TDD(red→green)로 구현한다.

## 작업 항목
- [x] LivithNetworking: `InstagramAPI` 네임스페이스 추가 — **TDD**
  - `createExtractionJob(instagramURL:)` → `NetworkEndpoint(path: "/extraction-jobs", method: .post, task: .body(DTO.Request.CreateExtractionJob), authentication: .required)`
  - `fetchExtractionJob(jobID:wait:)` → `NetworkEndpoint(path: "/extraction-jobs/{jobId}", method: .get, task: .query([wait]), authentication: .required)`
  - `Tests/Request/InstagramAPITests.swift` (Testing, 한글 제목)로 path/method/task/auth 단언
- [x] LivithNetworking: DTO 추가
  - `DTO.Request.CreateExtractionJob { instagramUrl }`, `DTO.Response.CreateExtractionJob { jobId }`
  - `DTO.Response.FetchExtractionJob { jobId, status, concerts: [RecommendedConcert] }` (`RecommendedConcert` 재사용)
- [x] UserData: `ConcertMatchingMapper` — **TDD**
  - `FetchExtractionJob` → `[Concert]` 변환 (기존 `ConcertMapper`의 `RecommendedConcert` 매핑과 동일 규칙: status/date/poster 파싱 실패 원소는 `compactMap` 제외, `.dotDate` 포맷)
  - `Tests/ConcertMatchingMapperTests.swift` — 실서버 응답 JSON 인라인 디코드 후 매핑 단언
- [x] UserData: `ConcertMatchingErrorMapper` — **TDD**
  - `NetworkError`·`CancellationError` → `ConcertMatchingError` (연결 없음→`noConnection`, 취소→`cancelled`, 디코딩 실패→`invalidResponse`, 4xx 서버 메시지("유효한 인스타그램 게시글 URL이 아닙니다." 등)→`matchFailed`, 5xx→`serverError`, 그 외→`unknown`)
- [x] UserData: `ConcertMatchingRepositoryImpl` 실구현 — **TDD**
  - `NetworkClient` 주입(기존 `UserRepositoryImpl` 패턴), `init()` → `init(networkClient:)` 변경 및 `UserDataAssembler` 갱신
  - 흐름: `createExtractionJob` → 최대 4회 `fetchExtractionJob(wait: 25)` long-poll → `MATCHED`→매핑 결과 반환, `NO_MATCH`→`[]` 반환, `PENDING`/`EXTRACTING`→재시도, 미지 status·시도 소진→`matchFailed`
  - 각 이터레이션 전 `Task.checkCancellation()` → `cancelled`
  - `Tests/ConcertMatchingRepositoryImplTests.swift` — `MockNetworkTransport` 순차 응답(`outputList`)으로 잡 생성→PENDING→MATCHED 시나리오, NO_MATCH, 시도 소진, 에러 매핑 단언
- [x] 검증: `tuist generate` → `tuist build` → `xcodebuild test` (LivithNetworking, UserData, HomeFeature)
- [x] 서브 에이전트 검증 루프: API 명세·Figma 디자인(FR-04/FR-05) 대비 구현 유사도 측정 → 98% 이상까지 불일치 수정 반복
  - 1회차: API 명세 100%, FR-04 100%, FR-05 88.9%(툴팁 미구현) → 툴팁 구현
  - 2회차: FR-05 100% — 세 축 모두 98% 초과로 수렴

## 영향 범위
- `Projects/LivithNetworking/Sources/API/InstagramAPI.swift` (신규), `Sources/DTO/Instagram/*` (신규), `Tests/Request/InstagramAPITests.swift` (신규)
- `Projects/Data/UserData/Sources/Repository/ConcertMatchingRepositoryImpl.swift` (교체)
- `Projects/Data/UserData/Sources/Mapper/ConcertMatchingMapper.swift`, `Sources/Mapper/ConcertMatchingErrorMapper.swift` (신규)
- `Projects/Data/UserData/Sources/Assembler/UserDataAssembler.swift` (주입 변경)
- `Projects/Data/UserData/Tests/*` (신규 테스트 3파일)
- `Projects/HomeFeature/Sources/InstagramMatch/View/InstagramMatchSearchView.swift` (검증 루프에서 FR-05 툴팁 추가)
- `Projects/HomeFeature/Tests/InstagramMatchConfirmStoreTests.swift` (3개 절단 보호 테스트 추가)

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| API 버전 | 전역 v7 전환 / 상대 경로 유지(v6) | 상대 경로 유지 | `NetworkConfig`가 apiVersion을 전역 하드코딩. v7 일괄 전환은 전 엔드포인트 영향이라 별도 이슈. 서버 배포 시 버전만 올리면 됨 |
| NO_MATCH 처리 | `matchFailed` throw / `[]` 반환 | `[]` 반환 | 명세상 NO_MATCH는 정상 응답(200). Store가 빈 배열이면 FR-05로 폴백하는 로직 기구현 |
| 폴링 방식 | 클라 sleep 폴링 / 서버 long-poll(`wait=25`) | long-poll 4회 | 명세 제공 파라미터. 클라 타이머 불필요, 요청 수 최소화. 총 ~100초 데드라인으로 서버 잡 유실 시 무한 대기 방지 |
| concerts DTO | 신규 정의 / `RecommendedConcert` 재사용 | 재사용 | 필드 완전 일치. 중복 정의는 과설계 |
| Mapper 위치 | ConcertData의 `ConcertMapper` 재사용 / UserData 신규 | UserData 신규 | Data 모듈 간 의존 금지(architecture.md). Repository 전담 Mapper 규칙 |
| Repository 테스트 | Mapper 테스트만 / `MockNetworkTransport` 기반 Repository 테스트 추가 | Repository 테스트 추가 | 폴링·상태 분기·데드라인은 상태 변경 로직이라 TDD 대상. `NetworkTransport` protocol 추상화가 이미 있어 tdd.md 요건 충족 |
| FR-05 툴팁 노출 | 후속 이슈 유지 / 노출 포함 | 노출 포함 | 검증 루프에서 디자인 불일치로 판정. 정적 노출 요소는 화면 범위. 탭 액션(FR-06)은 후속 유지 |

## 주의 사항
- `POST /extraction-jobs`는 비멱등 — 클라이언트에서 재시도하지 않는다(응답 유실 시 잡 중복 생성 방지).
- `wait=25`는 URLSession 기본 타임아웃(60초) 이내로 안전.
- 폴링 도중 404(잡 정리됨) → `matchFailed`로 매핑해 FR-05 폴백.
- `DTO.Response.FetchExtractionJob.concerts`의 개별 원소 파싱 실패는 전체 실패가 아니라 해당 원소만 제외(`compactMap`, 기존 Mapper 관례).
- 프로덕션 init에 테스트 전용 파라미터 금지 — 폴링 횟수·wait 값은 내부 상수로 고정한다.
- Swift 파일 추가 후 `tuist generate` 필수, Tuist 명령 순차 실행.

## 검증 방법
- `xcodebuild test -only-testing:LivithNetworkingTests` (InstagramAPI/DTO), `-only-testing:UserDataTests` (Mapper·ErrorMapper·RepositoryImpl), `-only-testing:HomeFeatureTests` (기존 Store 보호 테스트 회귀), destination `iPhone 17`
- `tuist build`로 App 컴파일 검증
- 서브 에이전트 유사도 검증 루프 결과 98% 이상 — 최종: API 100% / FR-04 100% / FR-05 100%
