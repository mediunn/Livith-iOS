# LIVD-447 관심 콘서트 결과 알림 API 반영

## 배경
- LIVD-438에서 FR-06 관심 콘서트 결과 **시트 UI**를 추가했지만, 본문은 stub이고 게이트/mark만 기존 toast API(`GET/PATCH /users/interest-concerts/toast`)를 사용한다.
- 서버 스펙이 `POST /api/v7/notifications/entry-alerts`로 변경되었다. 응답 `items`에 카드 `kind`·`title`·`content`·(선택)`concertId`가 포함된다.
- 스펙 출처: Notion「관심 콘서트 결과 알림(토스트) 목록」(category: 홈, iOS: In progress).
- 브랜치: `feat/LIVD-447-interest-concert-cleanup-api`

## 목표
- 기존 toast GET/PATCH·`InterestConcertCleanupPolicy` 경로를 제거하고, entry-alerts API로 시트 노출·본문을 연결한다.
- 홈 섹션 로드 **성공 후 1회** POST하고, `items`가 비어 있지 않으면 시트를 띄운다.
- 시트 문구는 서버 `title`/`content`를 그대로 표시한다.
- dismiss 시 별도 mark 호출은 하지 않는다(POST 소비 잠정 가정).
- 단위 테스트 + 디버그 스킴 목 데이터로 시뮬에서 시트를 확인한다.

## 작업 항목

### 1. Networking — entry-alerts 계약
- [ ] `HomeAPI`에 `POST /notifications/entry-alerts` 엔드포인트 추가 (auth: required, task: plain)
  - 경로가 `/notifications/...`이지만 스펙 category 홈 → **HomeAPI 배치 (의도적)**
- [ ] `DTO.Response`에 entry-alerts 응답 정의 (`ServerResponse` envelope의 `data.items` 형태를 기존 Home DTO 관례에 맞춤)
- [ ] `AlertItem`: kind/title/content/concertId?
- [ ] kind raw value: `AUTO_REMOVED_COMPLETED` / `AUTO_REMOVED_CANCELED` / `REQUEST_REGISTERED` / `REQUEST_FAILED`
- [ ] 기존 `fetchInterestConcertToast` / `markInterestConcertToastShown` 및 `InterestConcertToast` DTO 제거

### 2. Domain / UserData — Repository·Mapper
- [ ] Domain에 flat entry-alert 모델 정의 (API `items`와 1:1)
  - `InterestConcertEntryAlertKind`: `autoRemovedCompleted` / `autoRemovedCanceled` / `requestRegistered` / `requestFailed`
  - `InterestConcertEntryAlert`: `kind`, `title`, `content`, `concertId: Int?`
  - `Identifiable`이 필요하면 **응답 배열 index** 기반 id (서버 id 없음). 합성키·UUID 미사용
- [ ] `UserRepository.fetchInterestConcertEntryAlerts() -> [InterestConcertEntryAlert]`로 toast policy/mark 교체
- [ ] `InterestConcertCleanupPolicy` 및 관련 mapper/테스트 제거
- [ ] DTO → Domain 매핑 + `UserMapperTests` (TDD)
  - 알 수 없는 `kind`는 해당 item drop
  - drop 후 알려진 kind가 0개면 empty와 동일 → 시트 미표시
- [ ] `UserRepositoryImpl` / `MockUserRepository`(Data·HomeFeature·NicknameEditFeature 등) 시그니처 갱신
- [ ] **디버그 스킴 목 (entry-alerts만)**  
  - `UserRepositoryImpl`(또는 동등 Data 계층) `#if DEBUG`에서 entry-alerts만 Notion 샘플에 가까운 고정 `[InterestConcertEntryAlert]` 반환  
  - 나머지 User API는 실서버 유지. Assembler 전체 Mock 전환 없음  
  - Release/비DEBUG는 실 API만
### 3. HomeFeature — 시트·Store
- [ ] Store가 Domain `[InterestConcertEntryAlert]`를 직접 보유·전달 (이중 표시 모델 축소)
  - 기존 `InterestConcertResultSheetContent`의 클라이언트 카피 생성·`FailureReason` 문구 enum 제거
  - 뷰에서 `kind`로 자동 정리 / 요청 결과 섹션 그룹
  - **필드 매핑 (Notion 샘플 고정)**
    - `AUTO_REMOVED_*`: `title`→카드 제목, `content`→설명. 배지·액션 row 없음
    - `REQUEST_*`: `title`→공연명 줄, `content`→설명. 배지·액션 라벨은 kind helper (`추가 완료`/`추가 실패`, `확인하기`/`재요청`)
    - 섹션 헤더(`자동 정리된 공연` / `요청한 공연`)는 클라이언트 고정
  - `concertId`는 보관 가능, 네비게이션은 no-op 유지
- [ ] stub/카피 테스트 → Domain 매핑·섹션 그룹핑·presentation helper 테스트로 교체
- [ ] `HomeStore`: 섹션 성공(초기 로드) 후 entry-alerts 1회 호출
  - `items` non-empty → 시트 present
  - empty → 미표시
  - fetch 실패 → 흡수, 홈 에러 미전파
  - 섹션 실패 / `errorMessage` 존재 → 기존과 같이 시트 discard·미조회
  - dismiss → 시트만 닫기 (**mark 호출 없음**)
- [ ] `forceInterestResultSheet` 잔존 여부 확인 후 정리(이미 없으면 no-op)
- [ ] TDD: `HomeStoreTests` 갱신 (노출/미노출/실패 흡수/dismiss/미호출 타이밍). mark 실패·멱등 테스트는 삭제·교체
- [ ] Intent/상태 네이밍을 policy/toast → entryAlerts 기준으로 정리 (`_interestResultPolicyResult`, `pendingInterestResultPolicyFetch`, `_markInterestToastResult` 등)
### 4. Home UI
- [ ] `InterestConcertResultSheetView`가 `[InterestConcertEntryAlert]`(+ kind 그룹)로 그리도록 맞춤
- [ ] 「확인하기」「재요청」탭은 UI만, 이동 no-op 유지
- [ ] 「확인」/스와이프 dismiss → store dismiss Intent (mark 없음)

### 5. 검증
- [ ] `tuist generate --no-open` (Swift 파일 추가/삭제 후)
- [ ] XcodeBuildMCP `test_sim`으로 Domain / UserData / HomeFeature 관련 테스트 통과 (시뮬레이터: **iPhone 17**)
- [ ] 디버그 스킴 + Mock items로 시뮬에서 시트 노출·dismiss 확인 (필요 시 XcodeBuildMCP `build_run_sim`)

## 영향 범위
- `Projects/LivithNetworking` — `HomeAPI`, DTO (`InterestConcertToast` 제거, entry-alerts + `ServerResponse`/`data.items` envelope)
- `Projects/Domain` — `UserRepository`, `InterestConcertCleanupPolicy` 제거, entry-alerts 엔티티
- `Projects/Domain/Tests/ConcertDomainModelTests.swift` — policy 테스트 제거·교체
- `Projects/Data/UserData` — RepositoryImpl(DEBUG entry-alerts stub 포함), Mapper, Mock, Tests
- `Projects/HomeFeature` — `HomeStore`, `HomeView`, `InterestConcertResultSheetView`, `InterestConcertResultSheetContent`(축소·제거), Tests, MockUserRepository
- `Projects/HomeFeature/Tests/InterestConcertResultSheetContentTests.swift` — 카피 테스트 교체
- `Projects/Shared/NicknameEditFeature/Tests` — Mock `UserRepository` 시그니처
- 기타 `UserRepository` mock 구현체 (UserData / HomeFeature / NicknameEditFeature 3곳)
## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 스펙 기준 | Notion export | Notion `POST /notifications/entry-alerts` | grill Q1 |
| 기존 toast | 병행 vs 완전 교체 | **완전 교체** | grill Q2 A |
| 알림 소비 | dismiss mark vs POST 소비 | **POST 소비, mark 없음** | grill Q3 A. LIVD-438 “미닫고 종료 시 재노출”은 **폐기** (리뷰 must-fix, 유저 A) |
| 확인하기/재요청 | 실네비 vs no-op | **no-op** | grill Q4 A |
| 완료 기준 | 테스트만 vs +시뮬 | **단위 테스트 + 디버그 Mock 시뮬** | grill Q5 B → 유저: 디버그 목 |
| API 위치 | Notification vs Home | **HomeAPI + UserRepository** | 스펙 category 홈, grill Q6 B |
| fetch 실패 | 홈 에러 vs 흡수 | **흡수** | grill Q7 A |
| 시트 문구 | 서버 vs 클라이언트 조합 | **서버 title/content 그대로** | grill Q9 A |
| 호출 시점 | 병렬 vs 섹션 성공 후 | **섹션 성공 후 1회** | grill Q10′ A (소비 가정과 안전) |
| 구 policy 모델 | 잔존 vs 제거 | **제거** | grill Q11 A |
| Domain 형태 | flat items vs 섹션 분리 vs DTO 직결 | **flat `InterestConcertEntryAlert` + Feature에서 kind 그룹** | grill 도메인 A (시트 이중 모델 축소) |
| 카드 필드 매핑 | title/content 배치 | **AUTO=title/content, REQUEST=title→공연명·content→설명, 배지·액션=kind, 섹션헤더=클라 고정** | 리뷰 must-fix, Notion 샘플, 유저 A |
| ForEach id | index vs 합성키 vs UUID | **응답 배열 index** | 리뷰 must-fix, 유저 A |
| 디버그 목 | 전체 Mock DI vs entry-alerts만 vs Store 강제 | **DEBUG에서 entry-alerts만 샘플 반환 (실서버 나머지 유지)** | 리뷰 must-fix, 유저 B |
| 검증 도구 | xcodebuild shell vs XcodeBuildMCP | **XcodeBuildMCP 우선** (`project-operations`의 xcodebuild 우선에 대한 **본 티켓 예외**) | 유저 지정 |
| 브랜치 | 신규 | **`feat/LIVD-447-interest-concert-cleanup-api`** | 현재 브랜치 |

## 주의 사항
- POST는 호출 시점에 서버가 소비한다. dismiss 시 mark 없음. LIVD-438의 “미닫고 종료 시 재노출”은 이번 스펙에서 **의도적으로 폐기**한다 (시트 present 전에 이미 소비될 수 있음).
- 섹션과 entry-alerts를 병렬로 치지 않는다. 소비 가정 하에 섹션 실패 시 알림만 사라지는 낭비를 막기 위함이다.
- 홈 에러(`errorMessage`)가 있으면 관심 결과 시트를 띄우지 않는 LIVD-438 정책을 유지한다.
- Domain은 API flat 구조를 유지하고, 자동 정리/요청 결과 **섹션 분리는 HomeFeature 책임**이다. Domain에 UI 섹션 모델을 두지 않는다.
- `concertId` 네비게이션·재요청 실플로우는 **범위 밖**(후속).
- Domain/Mapper/Store 변경은 TDD (`docs/rules/tdd.md`): red → verify red → green.
- Swift 파일 추가/삭제 후 `tuist generate --no-open` 필수 (`docs/rules/project-operations.md`).
- 빌드·테스트는 **XcodeBuildMCP 우선** (`test_sim` / 필요 시 `build_sim`). MCP 불가 시에만 `xcodebuild test` fallback (`docs/rules/project-operations.md`).
- 실패·피드백·가정 변경 시 `docs/troubleshooting/LIVD-447-interest-concert-cleanup-api.md`에 즉시 기록.

## 검증 방법
- 단위 테스트
  - Mapper: DTO items → Domain, kind 매핑, 선택 concertId
  - HomeStore: 섹션 성공 + non-empty items → 시트 present, 서버 문구 반영
  - empty items → 미표시
  - unknown kind만 있어 drop 후 empty → 미표시
  - 섹션 실패 → entry-alerts 미호출
  - entry-alerts 실패 → 홈 에러 미전파, 시트 미표시
  - dismiss → 시트 닫힘, mark API 미호출
  - errorMessage 존재 시 시트 discard
- 명령
  - `tuist generate --no-open`
  - XcodeBuildMCP: `session_set_defaults`(workspace / scheme / simulator **iPhone 17**) → `test_sim`
    - 예: HomeFeature(`HomeStoreTests` 등), UserData(`UserMapperTests`), Domain(관련 모델 테스트)
  - MCP 실패 시에만 `xcodebuild test` fallback
- 수동: 디버그 스킴에서 entry-alerts DEBUG 샘플로 홈 진입 → 시트 문구·섹션 구성·dismiss 확인
  - 필요 시 XcodeBuildMCP `build_run_sim`(Livith-iOS 디버그 스킴)

## 비범위
- 확인하기 → 콘서트 상세, 재요청 → 요청 플로우 실연결
- entry-alerts를 NotificationAPI/NotificationRepository로 이전
- 섹션과 entry-alerts 구조적 병렬 호출
- 시나리오별(4 kind) 실서버 수동 QA 전부
- pull-to-refresh와 시트 상호작용 개편
