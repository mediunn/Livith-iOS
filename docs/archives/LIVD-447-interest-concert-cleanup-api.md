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
- dismiss 시 별도 mark 호출은 하지 않는다(POST 소비).
- 단위 테스트로 노출·매핑을 검증하고, 수동 확인은 실서버 entry-alerts 데이터가 있을 때 진행한다.

## 작업 항목

### 1. Networking — entry-alerts 계약
- [x] `HomeAPI`에 `POST /notifications/entry-alerts` 엔드포인트 추가 (auth: required, task: plain)
  - 경로가 `/notifications/...`이지만 스펙 category 홈 → **HomeAPI 배치 (의도적)**
- [x] `DTO.Response`에 entry-alerts 응답 정의 (`ServerResponse` envelope의 `data.items` 형태를 기존 Home DTO 관례에 맞춤)
- [x] `AlertItem`: kind/title/content/concertId?
- [x] kind raw value: `AUTO_REMOVED_COMPLETED` / `AUTO_REMOVED_CANCELED` / `REQUEST_REGISTERED` / `REQUEST_FAILED`
- [x] 기존 `fetchInterestConcertToast` / `markInterestConcertToastShown` 및 `InterestConcertToast` DTO 제거

### 2. Domain / UserData — Repository·Mapper
- [x] Domain에 flat entry-alert 모델 정의 (API `items`와 1:1)
  - `InterestConcertEntryAlertKind`: `autoRemovedCompleted` / `autoRemovedCanceled` / `requestRegistered` / `requestFailed`
  - `InterestConcertEntryAlert`: `kind`, `title`, `content`, `concertId: Int?`
  - `Identifiable`이 필요하면 **응답 배열 index** 기반 id (서버 id 없음). 합성키·UUID 미사용
- [x] `UserRepository.fetchInterestConcertEntryAlerts() -> [InterestConcertEntryAlert]`로 toast policy/mark 교체
- [x] `InterestConcertCleanupPolicy` 및 관련 mapper/테스트 제거
- [x] DTO → Domain 매핑 + `UserMapperTests` (TDD)
  - 알 수 없는 `kind`는 해당 item drop
  - drop 후 알려진 kind가 0개면 empty와 동일 → 시트 미표시
- [x] `UserRepositoryImpl` / `MockUserRepository`(Data·HomeFeature·NicknameEditFeature 등) 시그니처 갱신
- [x] ~~**디버그 스킴 목 (entry-alerts만)**~~ → **철회**: 실 API만 사용 (유저 피드백)

### 3. HomeFeature — 시트·Store
- [x] Store가 Domain `[InterestConcertEntryAlert]`를 직접 보유·전달 (이중 표시 모델 축소)
  - 기존 `InterestConcertResultSheetContent`의 클라이언트 카피 생성·`FailureReason` 문구 enum 제거
  - 뷰에서 `kind`로 자동 정리 / 요청 결과 섹션 그룹
  - **필드 매핑 (Notion 샘플 고정)**
    - `AUTO_REMOVED_*`: `title`→카드 제목, `content`→설명. 배지·액션 row 없음
    - `REQUEST_*`: `title`→공연명 줄, `content`→설명. 배지·액션 라벨은 kind helper (`추가 완료`/`추가 실패`, `확인하기`/`재요청`)
    - 섹션 헤더(`자동 정리된 공연` / `요청한 공연`)는 클라이언트 고정
  - `concertId`는 보관 가능, 네비게이션은 no-op 유지 (TODO 주석)
- [x] stub/카피 테스트 → Domain 매핑·섹션 그룹핑·presentation helper 테스트로 교체
- [x] `HomeStore`: 섹션 성공(초기 로드) 후 entry-alerts 1회 호출
  - `items` non-empty → 시트 present
  - empty → 미표시
  - fetch 실패 → 흡수, 홈 에러 미전파
  - 섹션 실패 / `errorMessage` 존재 → 기존과 같이 시트 discard·미조회
  - dismiss → 시트만 닫기 (**mark 호출 없음**)
- [x] `forceInterestResultSheet` 잔존 여부 확인 후 정리(이미 없으면 no-op)
- [x] TDD: `HomeStoreTests` 갱신 (노출/미노출/실패 흡수/dismiss/미호출 타이밍). mark 실패·멱등 테스트는 삭제·교체
- [x] Intent/상태 네이밍을 policy/toast → entryAlerts 기준으로 정리

### 4. Home UI
- [x] `InterestConcertResultSheetView`가 `[InterestConcertEntryAlert]`(+ kind 그룹)로 그리도록 맞춤
- [x] 「확인하기」「재요청」탭은 UI만, 이동 no-op 유지 (TODO)
- [x] 「확인」/스와이프 dismiss → store dismiss Intent (mark 없음)

### 5. 검증
- [x] `tuist generate --no-open` (Swift 파일 추가/삭제 후)
- [x] XcodeBuildMCP `test_sim`으로 Domain / UserData / HomeFeature 관련 테스트 통과 (시뮬레이터: **iPhone 17**)
- [x] 실서버 entry-alerts 데이터로 시뮬 시트 노출 확인 (유저 확인)

## 영향 범위
- `Projects/LivithNetworking` — `HomeAPI`, DTO (`InterestConcertToast` 제거, entry-alerts)
- `Projects/Domain` — `UserRepository`, `InterestConcertCleanupPolicy` 제거, entry-alerts 엔티티
- `Projects/Domain/Tests/ConcertDomainModelTests.swift`
- `Projects/Data/UserData` — RepositoryImpl, Mapper, Mock, Tests
- `Projects/HomeFeature` — HomeStore, HomeView, SheetView, Presentation, Tests, MockUserRepository
- `Projects/Shared/NicknameEditFeature/Tests` — Mock `UserRepository` 시그니처

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 스펙 기준 | Notion export | Notion `POST /notifications/entry-alerts` | grill Q1 |
| 기존 toast | 병행 vs 완전 교체 | **완전 교체** | grill Q2 A |
| 알림 소비 | dismiss mark vs POST 소비 | **POST 소비, mark 없음** | grill Q3 A. LIVD-438 재노출 **폐기** |
| 확인하기/재요청 | 실네비 vs no-op | **no-op** (+ TODO) | grill Q4 A |
| 완료 기준 | 테스트만 vs +시뮬 | **단위 테스트 (+ 실서버 수동)** | grill Q5 → DEBUG 목 철회 |
| API 위치 | Notification vs Home | **HomeAPI + UserRepository** | 스펙 category 홈 |
| fetch 실패 | 홈 에러 vs 흡수 | **흡수** | grill Q7 A |
| 시트 문구 | 서버 vs 클라이언트 조합 | **서버 title/content 그대로** | grill Q9 A |
| 호출 시점 | 병렬 vs 섹션 성공 후 | **섹션 성공 후 1회** | grill Q10′ A |
| 구 policy 모델 | 잔존 vs 제거 | **제거** | grill Q11 A |
| Domain 형태 | flat vs 섹션 vs DTO 직결 | **flat `InterestConcertEntryAlert` + Feature kind 그룹** | grill 도메인 A |
| 카드 필드 매핑 | title/content 배치 | **AUTO=title/content, REQUEST=title→공연명·content→설명** | Notion 샘플 |
| ForEach id | index vs 합성키 vs UUID | **응답 배열 index** | 리뷰 |
| 디버그 목 | Mock DI vs stub vs Store | **철회 → 실 API만** | 유저 피드백 |
| 검증 도구 | xcodebuild vs XcodeBuildMCP | **XcodeBuildMCP 우선** | 유저 지정 |
| 브랜치 | 신규 | **`feat/LIVD-447-interest-concert-cleanup-api`** | 현재 브랜치 |

## 주의 사항
- POST는 호출 시점에 서버가 소비한다. dismiss 시 mark 없음.
- 섹션과 entry-alerts를 병렬로 치지 않는다.
- 홈 에러가 있으면 관심 결과 시트를 띄우지 않는다.
- Domain은 API flat 구조, 섹션 분리는 HomeFeature 책임.
- `concertId` 네비게이션·재요청 실플로우는 **범위 밖**(TODO).
- Array extension 제거는 보류.

## 검증 방법
- 단위 테스트: Mapper, HomeStore 노출/미노출/실패 흡수/dismiss
- `tuist generate --no-open` → XcodeBuildMCP `test_sim` (HomeFeature / UserData / Domain)
- 수동: 실서버 entry-alerts 데이터가 있을 때 홈 진입 → 시트 확인

## 비범위
- 확인하기 → 콘서트 상세, 재요청 → 콘서트 요청 페이지 실연결
- entry-alerts를 NotificationAPI로 이전
- 섹션과 entry-alerts 구조적 병렬 호출
- pull-to-refresh와 시트 상호작용 개편
