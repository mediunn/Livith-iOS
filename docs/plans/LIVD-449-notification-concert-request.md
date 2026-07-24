# LIVD-449 알림 API 연동 보완 + FR-06 결과 시트 실데이터 + 콘서트 정보 요청 기능

## 배경
- 7차 API 명세서 기준, 담당 항목 중 iOS 미연동/스테일 항목이 확인됐다.
  - **55 알림 목록 조회** (`GET /api/v7/notifications`): iOS 연동은 완료돼 있으나, 스펙에 알림 타입이 추가·수정됨(ADD_TICKETING_10MIN/30MIN/1D, PRE/GENERAL_TICKETING_10MIN, USER_INTEREST_CONCERT). 현재 `NotificationMapper`가 `NotificationType(rawValue:)!` 강제 언래핑이라 **신규 타입 수신 시 크래시**한다.
  - **60 전체 읽기** (`PATCH /api/v7/notifications/read-all`): iOS 코드 전무. UI 액션도 없음.
  - **64 관심 콘서트 결과 알림 목록** (`POST /api/v7/notifications/entry-alerts`): FR-06 결과 시트 UI는 LIVD-438에서 stub으로 구현 완료. 실데이터 연동·네비게이션이 후속으로 남음. 백엔드 확인 결과 **POST 1회가 조회 + 노출 완료 처리를 겸한다**(클라이언트는 요청만 보내면 됨) → 기존 toast 게이트(GET/PATCH `/users/interest-concerts/toast`)를 대체한다.
  - **63 콘서트 정보 요청** (`POST /api/v7/concerts/requests`): FR-06 정보 요청 화면 UI는 LIVD-429에서 UI-only로 구현 완료(`ShareFeature.ConcertRequestView`). API 연결·성공/실패 플로우·앱 진입점이 미구현.
- FR-06 결과 시트의 "확인하기 → 콘서트 상세", "재요청 → 콘서트 요청 페이지" 네비게이션이 no-op 상태라, 63·64는 하나의 사용자 플로우로 묶인다.

## 목표
- 알림 목록이 신규 알림 타입을 받아도 크래시 없이 표시된다.
- 알림 화면에서 전체 읽기가 동작한다.
- FR-06 결과 시트가 entry-alerts 실데이터로 표시되고, 확인하기/재요청 네비게이션이 동작한다.
- 콘서트 정보 요청 화면이 실제 API로 요청을 보내고, 성공 시 홈 복귀 + 성공 토스트, 실패 시 시트 유지 + 실패 토스트가 동작한다.
- 홈에서 콘서트 요청 화면으로 진입할 수 있다(시트 재요청 경로).

## 작업 항목

### 1. [55] 알림 타입 확장 + 매퍼 크래시 수정 (TDD)
- [x] `NotificationType`에 신규 케이스 추가: `PRE_TICKETING_10MIN`, `GENERAL_TICKETING_10MIN`, `ADD_TICKETING_10MIN`, `ADD_TICKETING_30MIN`, `ADD_TICKETING_1D`, `USER_INTEREST_CONCERT`, `unknown`(폴백)
  - 기존 `PRE_TICKETING_OPEN`/`GENERAL_TICKETING_OPEN`은 구서버 호환 위해 유지
- [x] 재현 테스트(red): 미지의 rawValue 디코딩 시 크래시 없이 `.unknown` 매핑
- [x] `NotificationMapper.toDomain` 강제 언래핑 제거 → `NotificationType(rawValue:) ?? .unknown`
- [x] `NoticeView`의 exhaustive switch(트래킹·탭 라우팅)에 신규 케이스 반영
  - `USER_INTEREST_CONCERT`는 `INTEREST_CONCERT`와 동일하게 관심 탭 이동 처리
  - `isTicketType`에 신규 티케팅 타입 포함

### 2. [60] 전체 읽기 end-to-end (TDD)
- [x] `NotificationAPI.markAllAsRead()` — `PATCH /notifications/read-all`, `.plain`, `.required`
- [x] `NotificationRepository`에 `markAllNotificationsAsRead()` 추가 (Void, `markNotificationAsRead` 패턴 복제), Impl + Mock 2곳 stub
- [x] `NoticeStore`에 `.markAllAsRead` intent: 성공 시 `state.notifications` 전체 `isRead = true` 갱신 (테스트 먼저)
- [x] `NoticeView`에 전체 읽기 액션 UI 추가 (네비게이션 우측 영역, 기존 "알림 설정"과 병치)

### 3. [64] entry-alerts 연동 — FR-06 시트 실데이터 (TDD)
- [x] DTO: `DTO.Response.FetchEntryAlerts { items: [AlertItem] }`, `AlertItem { kind, title, content, concertId? }`
- [x] `NotificationAPI.fetchEntryAlerts()` — `POST /notifications/entry-alerts`, `.plain`, `.required`
- [x] Domain 엔티티 `InterestEntryAlert` — `kind`(AUTO_REMOVED_COMPLETED / AUTO_REMOVED_CANCELED / REQUEST_REGISTERED / REQUEST_FAILED + unknown 폴백), `title`, `content`, `concertID?`
- [x] `NotificationRepository.fetchEntryAlerts() -> [InterestEntryAlert]` + mapper (테스트 먼저)
- [x] `InterestConcertResultSheetContent`를 서버 카피 기반으로 재구성
  - 클라 카피 조합 로직(`Kind.description` 등) 제거, 서버 `title`/`content` 그대로 표시
  - kind 기준 섹션 분류: `AUTO_REMOVED_*` → 자동 정리 섹션, `REQUEST_*` → 요청한 공연 섹션
  - `RequestResultItem`에 `concertID?` 추가 (확인하기 이동용)
- [x] `HomeStore` 게이트 교체: toast policy(GET) + mark(PATCH) 흐름 제거 → 홈 섹션 초기 로드 성공 후 `fetchEntryAlerts()` 1회 호출, `items` 비어있지 않으면 시트 표시
  - dismiss 시 별도 mark 호출 없음 (서버가 POST 시점에 노출 완료 처리)
  - 기존 `HomeStoreTests` FR-06 관련 12개 테스트를 새 흐름 기준으로 재작성
- [x] `InterestConcertResultSheetContentTests` stub 카피 테스트를 새 모델 기준으로 갱신

### 4. [63] 콘서트 정보 요청 API 연결 (TDD)
- [x] DTO: `DTO.Request.RequestConcert { title, url?, autoRegister, requestContent? }` (응답 모델은 프론트 미사용 확인 → Void 처리)
- [x] `ConcertAPI.requestConcert(...)` — `POST /concerts/requests`, `.body(...)`, `.required`
- [x] `ConcertRepository.requestConcert(title:url:autoRegister:requestContent:)` (Void, typed throws `ConcertError`) + Impl + Mock (테스트 먼저)
- [x] `ShareFeature`에 `ConcertRequestStore` 신설 (MVI, `@Injected ConcertRepository`, 테스트 먼저)
  - intent: `.submit(autoRegister: Bool)` — 바텀시트 `등록할래요`=true / `괜찮아요`=false
  - 성공 → `onRequestSuccess` 위임(홈 복귀 + 성공 토스트), 실패 → 시트 유지 + 실패 토스트
  - 중복 제출 방지(isSubmitting)
- [x] `ConcertRequestView` 배선 교체: `handleBottomSheetAction` 스텁 제거 → store 제출 호출
  - public init에 `onRequestSuccess: () -> Void` 추가
- [x] `ShareFeature/Project.swift` 의존성 추가: `Domain`, `DIContainer`

### 5. 네비게이션 연결 + 성공 토스트
- [x] `HomeFeature/Project.swift`에 `.share(.shareFeature)` 의존 추가 (기존 ConcertFeature 선례 준용)
- [x] `HomeRoute`에 `.concertRequest` 추가, `HomeCoordinatorView.destinationView`에서 `ConcertRequestView(onDismiss: pop, onRequestSuccess: 홈 복귀+토스트)` 렌더
- [x] `HomeView` 시트 콜백 배선: `onCheckTap`(concertID 있으면 `.concertDetail` push + 시트 dismiss), `onRetryTap`(`.concertRequest` push + 시트 dismiss)
- [x] 요청 성공 토스트: 홈 복귀 후 `정보가 요청되었어요` 표시 (FR-06 #9) — `HomeCoordinatorView` `@State` + 기존 `livithToast` 재사용 (순수 화면 연출이라 Store 상태 불필요, 구현 시 조정)

### 6. 검증 + 마무리
- [ ] `tuist generate` + 전체 빌드
- [ ] 변경 모듈 테스트: NotificationData·HomeFeature·ShareFeature(신설 테스트 타깃)·ConcertData
- [ ] 노션 API 명세서 iOS 연결 상태 갱신(55·60·63·64 → Done) — 각 변경 전 사용자 확인
- [ ] plan·troubleshooting 문서 `docs/archives/` 이동

## 영향 범위
- `Projects/Domain`: `NotificationType`(케이스 추가), `NotificationRepository`·`ConcertRepository`(메서드 추가), `InterestEntryAlert`(신규)
- `Projects/LivithNetworking`: `NotificationAPI`·`ConcertAPI`(팩토리 추가), DTO 신규 3건
- `Projects/Data/NotificationData`: mapper 크래시 수정, entry-alerts repo/mapper, read-all impl, Mock
- `Projects/Data/ConcertData`: requestConcert impl, Mock
- `Projects/HomeFeature`: `HomeStore`(게이트 교체·성공 토스트), `HomeView`(시트 콜백), `HomeRoute`·`HomeCoordinatorView`(route 추가), `InterestConcertResultSheetContent`(재구성), `NoticeStore`·`NoticeView`(전체 읽기·신규 타입), 테스트 다수 재작성
- `Projects/ShareFeature`: `ConcertRequestStore`(신규), `ConcertRequestView`(배선), `Project.swift`(의존성), 테스트 타깃 신설
- 미변경: 온보딩/검색/댓글 등 다른 Feature, DesignSystem

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 미지 알림 타입 처리 | 디코딩 실패로 항목 드롭 vs `.unknown` 폴백 | **`.unknown` 폴백** | 크래시·항목 소실 없이 표시. 서버 카피(title/content)는 그대로 유효 |
| 구 티케팅 타입 케이스 | 삭제 vs 유지 | **유지** | 구서버/기존 알림 데이터 호환 |
| FR-06 게이트 | 기존 toast GET/PATCH 유지+entry-alerts 병행 vs entry-alerts 단일 | **entry-alerts 단일** | 백엔드 확인: POST가 노출 완료 처리 겸함. 이중 게이트는 상태 불일치 위험 |
| 시트 카피 | 클라 조합 유지 vs 서버 카피 표시 | **서버 카피** | 명세 Response가 완성 문구 제공. 카피 이원화 방지 |
| 63 응답 처리 | 응답 DTO 디코딩 vs Void | **Void** | 명세서 댓글로 프론트 미사용 확인 |
| ConcertRequest 상태 관리 | View `@State` 유지+`@Injected` vs Store 신설 | **Store 신설** | API 호출·성공/실패 분기·중복 제출 방지는 상태 변경 로직 → 프로젝트 MVI·TDD 규칙 대상 |
| Home→ShareFeature 연결 | App 레벨 조립 vs HomeFeature 직접 의존 | **HomeFeature 직접 의존** | ConcertFeature가 HomeRoute에서 직접 참조되는 기존 선례와 일관. `ConcertRequestView`는 closure 인터페이스 유지로 Router 비결합 |
| 성공 토스트 표시 위치 | ShareFeature 내부 vs 홈 복귀 후 홈 소유 | **홈 복귀 후 `HomeCoordinatorView` `@State`** | FR-06 #9 명세(홈 이동 후 토스트). 순수 화면 연출이라 Store 상태 대신 CoordinatorView 로컬 상태로 처리 |

## 주의 사항
- **entry-alerts는 호출 즉시 서버가 소비 처리**한다. 시트를 실제로 띄울 수 있는 시점(홈 섹션 로드 성공 후)에만 호출하고, 실패·에러 토스트 존재 시 기존 정책(관심 안내 미노출)을 유지한다. FR-06 명세의 "닫지 않고 이탈 시 재등장"은 서버 소비 정책에 종속되므로 클라에서 별도 보장하지 않는다(백엔드 합의 사항).
- 기존 toast 게이트 제거 시 `UserRepository.fetchInterestConcertCleanupPolicy`/`markInterestConcertToastShown`과 `HomeAPI` toast 팩토리는 **삭제하지 않고 유지**한다(다른 사용처 여부와 무관하게 이번 범위는 HomeStore 배선 교체까지).
- `NoticeView` switch는 exhaustive라 케이스 추가 시 컴파일 에러로 전파된다. `.unknown` 트래킹은 no-op으로 둔다.
- `ShareFeature` 의존성 추가 후 `tuist generate` 필수.
- 55·60·63·64 모두 커밋 단위를 분리한다(타입 수정 / read-all / entry-alerts / 콘서트 요청 / 네비게이션).
- 작업 중 실패·피드백 발생 시 `docs/troubleshooting/LIVD-449-notification-concert-request.md`에 즉시 기록.

## 검증 방법
1. 단위 테스트
   - NotificationData: 미지 타입 `.unknown` 매핑, entry-alerts 매핑(kind 4종 + concertId 유무), read-all 호출
   - HomeFeature: 섹션 성공 → entry-alerts 호출·시트 표시 / items 빈 배열 → 미표시 / 에러 존재 시 discard / dismiss 시 mark 미호출 / NoticeStore 전체 읽기 반영
   - ShareFeature: submit 성공/실패 분기, autoRegister 전달, 중복 제출 방지
2. `tuist generate` 후 전체 빌드 (XcodeBuildMCP, iPhone 17 시뮬레이터)
3. 시뮬레이터 실기동: 알림 목록(신규 타입 포함) 표시, 전체 읽기, FR-06 시트 표시·확인하기·재요청, 콘서트 요청 성공/실패 플로우
