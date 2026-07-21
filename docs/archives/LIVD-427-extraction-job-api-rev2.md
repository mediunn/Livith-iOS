# [LIVD-427] 인스타 추출 및 콘서트 매칭 API 명세 개정 반영 (rev2)

## 배경
- 1차 연동(아카이브: `LIVD-427-extraction-job-api.md`)은 "잡 생성 + long-poll 결과 조회" 2개 API 기준이었다.
- 서버가 명세를 개정했다 (명세 문서 2026-07-20 22:09 수정, 구현 여부 Done / iOS 연결 In progress):
  - **단일 동기 API로 통합**: `POST /api/v7/extraction-jobs` — body `{instagramUrl}`, 200 응답 `data: { result, concerts }`.
  - `result`: `MATCHED`(매칭 성공) / `NO_MATCH`(매칭 실패) 2종. `PENDING`/`EXTRACTING`/폴링/`jobId` 폐기.
  - `concerts`: 최대 3개. 필수 필드는 `id`/`status`/`artist`/`introduction`뿐이고 `code`/`title`/`startDate`/`endDate`/`poster`/`daysLeft`/`ticketSite`/`ticketUrl`/`venue`/`label`은 null 가능 (Output 예시에서 `daysLeft: null`, `label: null` 확인).
  - Exception: 400 "유효한 인스타그램 게시글 URL이 아닙니다.", 401 — 기존과 동일.
- develop에 DEBUG 스킴 v7 전환(LIVD-349)이 반영되어 있어 머지로 수용한다.

## 목표
- 단일 POST 호출로 매칭 결과를 수신한다: `MATCHED`→콘서트 목록(최대 3개) 반환, `NO_MATCH`→빈 배열 반환(FR-05 폴백).
- null 가능 필드가 포함된 콘서트도 목록에서 제외되지 않고 도메인 `Concert`(optional 허용)로 변환된다.
- 폐기된 폴링 경로(`GET /extraction-jobs/{jobId}`, `FetchExtractionJob` DTO, 폴링 로직)를 제거한다.

## 작업 항목
- [x] origin/develop 머지 (DEBUG v7 포함) 및 충돌 없음 확인
- [x] 테스트 개정 (red 선행)
  - `ConcertMatchingMapperTests`: 새 응답 JSON(`{result, concerts}` + null 필드 포함) 기준으로 재작성. null 필드 원소 유지, invalid status 원소 제외 단언
  - `ConcertMatchingRepositoryImplTests`: 단일 POST(MATCHED→목록, NO_MATCH→빈 배열, 미지 result→matchFailed, 400→matchFailed, 연결없음→noConnection), 요청 1회 단언. 폴링 시나리오 테스트 제거
  - `InstagramAPITests`: `fetchExtractionJob` 테스트 제거 (엔드포인트 폐기)
- [x] DTO 개정: `DTO.Response.CreateExtractionJob` → `{ result: String, concerts: [MatchedConcert] }`, `MatchedConcert`는 null 허용 필드 반영 신규 정의 (`RecommendedConcert` 재사용 불가 — 필수/optional 구성이 다름)
- [x] `ConcertMatchingMapper`: `MatchedConcert` → `Concert` 변환. 제외 조건은 invalid `status`만 유지, 나머지 optional은 nil 그대로 전달
- [x] `ConcertMatchingRepositoryImpl`: 폴링 제거, 단일 요청 + `result` 분기
- [x] 폐기 코드 제거: `InstagramAPI.fetchExtractionJob`, `DTO/Instagram/FetchExtractionJob.swift`
- [x] 검증: `tuist generate` → `xcodebuild test`(LivithNetworking/UserData/HomeFeature) → `tuist build Livith-iOS-Dev`
- [x] 서브 에이전트 명세 준수 재검증 루프 (98% 이상까지)
- [x] sim-use 실기동 검증: 시뮬레이터에서 딥링크 진입 → 실서버(v7) 응답 기반 화면 확인
  - FR-04 로딩(dots)·FR-05 매칭실패·FR-05 직접찾기 실화면 확보, 접근성 프레임+3x 스크린샷 픽셀 실측으로 Figma 대조
  - 실측 불일치 7건 발견·수정: 그리드 행간 24, 카드 사이드 16 고정(열 정렬), 검색필드 상단 32, 필드→그리드 29, 툴팁 오프셋 7, 정보요청 버튼(.info) 텍스트 black50+보더 black90 1px+높이 24
  - 수정 후 재실측: 전 항목 디자인과 ≤1pt 정합. FR-04 매칭 성공(카드) 상태는 실서버가 테스트 게시물들을 전부 NO_MATCH 처리해 실기동 미확인 — 코드-디자인 대조(100%)와 Store 테스트로 갈음

## 영향 범위
- `Projects/LivithNetworking/Sources/API/InstagramAPI.swift`, `Sources/DTO/Instagram/*`, `Tests/Request/InstagramAPITests.swift`
- `Projects/Data/UserData/Sources/{Repository,Mapper}/ConcertMatching*`, `Tests/ConcertMatching*Tests.swift`
- Domain·HomeFeature·App 무변경 (Store 폴백 로직 그대로 유효)

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| concerts DTO | `RecommendedConcert` 재사용 / 전용 DTO | 전용 `MatchedConcert` | 개정 명세는 title·startDate·poster·venue·daysLeft 등이 null 가능. 기존 DTO는 non-optional이라 디코딩 실패 위험 |
| null 필드 원소 처리 | 제외(compactMap) / 유지 | 유지 | 명세가 명시적으로 optional 선언. 도메인 `Concert`도 해당 필드 optional. 제외하면 매칭 결과 유실 |
| invalid status 원소 | 제외 / 기본값 대체 | 제외 | `status`는 필수(O)이고 enum 매핑 불가 시 표시 불가. 기존 Mapper 관례 |
| 폐기 API 코드 | 유지 / 제거 | 제거 | 명세에서 폴링 API 폐기. 미사용 코드 잔존은 혼란 유발 |

## 주의 사항
- 동기 API지만 서버 처리(파싱·매칭)가 길 수 있음 — URLSession 기본 요청 타임아웃(60초) 내 응답을 전제. 타임아웃 시 `noConnection` 매핑(기존 ErrorMapper 규칙).
- 요청 취소는 URLSession 취소 전파(`cancelled` 매핑)로 처리 — 폴링 루프가 없어 별도 체크 불필요.
- POST 비멱등 — 재시도 금지 유지.
- Output 예시의 poster는 `http://`(kopis) — 기존 콘서트 포스터와 동일 출처로 신규 이슈 아님.

## 검증 방법
- `xcodebuild test` 3개 scheme + `tuist build Livith-iOS-Dev`
- 서브 에이전트 명세 준수 검증 98% 이상
- sim-use: 로그인 후 `xcrun simctl openurl booted "livith://instagram?url=<인스타 URL>"` → FR-04(매칭 시)/FR-05(실패 시) 실화면 확인
