# LIVD-438 홈 세그먼트 분리 + 초기 진입 네트워크 동시성 정리

## 배경
- 홈이 **관심 콘서트 / 캘린더** 두 모드로 분리된다. ([참고 Figma](https://www.figma.com/design/G53QwXoxT96gB68dO7vRZi/?node-id=10-17969))
- 현재 `HomeView`에는 세그먼트가 없고, 기존 홈 콘텐츠가 단일 스크롤로 구성되어 있다.
- 초기 진입 네트워크는 Phase 1(유저·관심·알림 동시) → Phase 2(섹션·추천) → Phase 3(토스트)로 **단계 직렬**이다. 의존성이 없는 호출까지 대기하는 구조라 진입 지연이 커질 수 있다.
- `DesignSystem.SegmentedTabBarType.HomeTab`은 현재 `콘서트 일정` / `셋리스트`로 정의되어 있어, 이번 홈 세그먼트 라벨과 맞지 않는다.

## 목표
- 홈 루트에 세그먼트(관심 콘서트 / 캘린더)를 추가한다.
- **기존 홈 콘텐츠 전부**를 관심 콘서트 탭 아래에 그대로 둔다. (관심 탭 콘텐츠 재디자인 없음)
- 캘린더 탭은 `준비 중` 문구 플레이스홀더만 제공한다. (실제 캘린더 콘텐츠는 범위 밖)
- 초기 진입 네트워크에서 의존성 없는 호출은 최대한 동시 실행하고, 필수 순서만 유지한다.
- 기존과 동일한 데이터 결과·에러 흡수·토스트 타이밍(콘텐츠 로드 후)을 유지한다.
- 세그먼트 전환 + 관심 탭 기존 동작 유지 + 동시성 정리를 테스트로 검증한다.

## 작업 항목

### 1. 세그먼트 타입 / DesignSystem 정리
- [ ] `SegmentedTabBarType.HomeTab`을 `interestConcert` / `calendar`로 **교체**
  - 표시명: `관심 콘서트` / `캘린더`
  - 기존 `schedule` / `setlist` 사용처 검색 후 Preview 등 동기화
  - (실사용처가 홈 외 없으면 교체로 단순화 — 그릴 확정)

### 2. Home UI — 세그먼트 + 탭 콘텐츠 분기
- [ ] `HomeView`에 `SegmentedTabBar(type: .home(...))` 추가
  - 기본 선택: 관심 콘서트
  - 관심 콘서트: 기존 `scrollView` 및 관련 UI 전부 이동 (헤더/알림/토스트/리프레시 등 기존 홈 동작 유지)
  - 캘린더: `준비 중` 문구 플레이스홀더
- [ ] 세그먼트 선택 상태를 **단일 `HomeStore`**에서 관리 (`selectedHomeTab` + `homeTabSelected` Intent)
  - 관심/캘린더 전용 자식 Store **분리하지 않음** (추후 캘린더 실구현 시 재검토)
  - 바닐라 Reducer/Effect 패턴 **이번 티켓에서 도입하지 않음** (기존 `send` + `perform*` 유지)
  - 선택 상태 영속화 없음 (재진입 시 관심 콘서트 기본)
  - 탭과 무관하게 관심 콘서트용 초기 로드 수행 (탭별 로드 분기 없음)

### 3. 초기 진입 네트워크 동시성 정리 (`HomeStore`)
- [ ] Phase 1 → 2 → 3 직렬 파이프라인을 재구성 (그릴 확정 모델)
  - **동시 시작:** 유저, 관심 목록, 알림 수, **홈 섹션**
  - **유저 성공 후:** 추천 (`user.hasPreferences`일 때만)
  - **섹션 성공 후(기존 타이밍):** 관심 콘서트 토스트 조회·표시
  - **유저 실패 시:** 관련 Task **cancel** + 섹션 성공 결과 **미반영** + 기존처럼 초기 실패 처리
  - **로딩 UX:** `onAppear`에서 `isConcertSectionLoading = true`, 유저·섹션 준비 후 해제
- [ ] 에러 흡수 규칙 유지
  - 관심 목록 / 알림 실패 → 홈 초기 실패로 전파하지 않음
  - 유저 실패만 초기 데이터 실패로 전파
- [ ] `onRefresh`는 **범위 밖** — 기존 동작 회귀 확인만

### 4. TDD — 실패 테스트 선행
- [ ] 세그먼트 선택 Intent/State 테스트 (기본값 = 관심 콘서트, 전환)
- [ ] 초기 로드 동시성/순서 회귀 테스트
  - 유저 실패 시 섹션 결과 미반영·Task cancel 동작
  - 관심/알림 실패 흡수
  - 토스트는 섹션 로드 성공 후에만 조회
  - 섹션이 유저와 직렬 대기하지 않음 (delay stub로 검증 가능하면)
- [ ] 기존 `HomeStoreTests`의 onAppear 시나리오가 새 파이프라인에서도 통과하도록 갱신

### 5. 검증
- [ ] Swift 파일 추가/이동 시 `tuist generate` (셸)
- [ ] **빌드·테스트·시뮬레이터 확인은 XcodeBuildMCP 우선** (`session_show_defaults` → `build_sim` / `test_sim` / `build_run_sim`)
  - MCP 세션 기본값(project/scheme/simulator) 확인 후 실행
  - `xcodebuild` 직접 호출은 MCP로 불가하거나 실패할 때만 fallback (`docs/rules/project-operations.md`)
- [ ] 시뮬레이터에서 세그먼트 전환·관심 탭 기존 콘텐츠·캘린더 `준비 중` 확인

## 영향 범위
- `Projects/DesignSystem/Sources/Components/Navigation/SegmentedTabBar.swift` — `HomeTab` 케이스/라벨 교체
- `Projects/HomeFeature/Sources/Home/View/HomeView.swift` — 세그먼트 UI, 탭 분기, 캘린더 플레이스홀더
- `Projects/HomeFeature/Sources/Home/Store/HomeStore.swift` — `selectedHomeTab`, 초기 로드 동시성
- `Projects/HomeFeature/Tests/HomeStoreTests.swift`
- `SegmentedTabBarType.HomeTab` 기존 사용처 (DesignSystem preview 등)
- Domain / Networking / Repository 계약 변경 **없음**

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 관심 탭 콘텐츠 | Figma 재디자인 vs 기존 홈 유지 | **기존 홈 전부 유지** | deep-interview |
| 캘린더 탭 | 콘텐츠 vs 플레이스홀더 | **`준비 중` 플레이스홀더** | deep-interview + 그릴 |
| 초기 네트워크 | 3단계 유지 vs 최대 동시 | **섹션∥유저 등 최대 동시** | deep-interview + 그릴 |
| 섹션 vs 유저 | 유저 후 섹션 vs 병렬 | **병렬 + 유저 실패 시 미반영/cancel** | 그릴 |
| 추천 | 병렬 vs 유저 후행 | **유저 후행** | `hasPreferences` 의존 |
| 토스트 | 병렬 vs 섹션 후 | **섹션 성공 후** | 기존 UX 유지 |
| 로딩 플래그 | 기존 타이밍 vs onAppear | **onAppear부터 전체 로딩** | 그릴 |
| refresh | 동시성 포함 vs 제외 | **제외 (회귀만)** | 그릴 |
| 세그먼트 컴포넌트 | 신규 vs `SegmentedTabBar` | **`SegmentedTabBar` 재사용** | 기존 DS |
| `HomeTab` | 유지+신규 vs 교체 | **`interestConcert`/`calendar`로 교체** | 그릴 |
| 세그먼트 상태 | View vs Store | **`HomeStore`** | 그릴 |
| Store 분리 | 단일 vs 부모+자식 | **단일 `HomeStore`** | 캘린더는 플레이스홀더, MVI 기본형은 화면 단위 단일 Store. 분리·Reducer는 추후 재검토 |
| Reducer | 도입 vs 미도입 | **미도입** (`send`/`perform*` 유지) | LIVD-438 범위·회귀 최소화. 레포에 Reducer 컨벤션 없음 |
| 탭별 초기 로드 | 분기 vs 무관 | **탭 무관 (관심용 로드)** | 그릴 — 이번 범위에 분기로 이득 없음 |

## HomeStore 구조 (단일 Store, 확정)

```text
HomeView
  └─ HomeStore.send(HomeIntent)     // 단일 진입점
       ├─ state 갱신 (HomeState)
       └─ perform*() 부수효과 → ._fetch… Result Intent로 재진입
```

- **State:** 기존 홈 필드 + `selectedHomeTab` (기본 `.interestConcert`). 캘린더 전용 필드는 이번엔 없음.
- **Intent:** 기존 + `homeTabSelected(HomeTab)`. 탭 전환은 state만 변경, 초기 로드 재실행 없음.
- **동시성:** `performFetchInitialHomeData()` 한 파이프라인 (섹션∥유저, 추천·토스트 후행, 유저 실패 시 cancel).
- **View:** `selectedHomeTab`으로 관심(기존 scrollView) / 캘린더(`준비 중`) 분기.
- **비범위:** 관심·캘린더 자식 Store 분리, 바닐라 Reducer/Effect 도입.

## 주의 사항
- `HomeTab` 교체 전 `schedule`/`setlist` 사용처를 검색한다.
- 추천 API는 유저 의존 — 섹션과 같은 “완전 병렬”로 묶지 않는다.
- 토스트 API를 초기 동시 묶음에 넣지 않는다.
- 관심 콘서트 탭 콘텐츠 재디자인은 범위 밖이다.
- 캘린더 실콘텐츠·탭 선택 영속화·refresh 동시성 개편·홈 외 API 변경은 범위 밖이다.
- TDD: Store/동시성·세그먼트 state는 실패 테스트 먼저 (`docs/rules/tdd.md`).
- 빌드·테스트·시뮬레이터 검증은 **XcodeBuildMCP를 우선** 사용한다.

## 검증 방법
- 단위 테스트
  - 세그먼트 기본값 = 관심 콘서트, 전환 시 state 반영
  - onAppear: 유저 실패(cancel·미반영) / 관심·알림 흡수 / 토스트 후행 / 섹션∥유저 / 추천 조건
- 명령
  - Swift 파일 추가·이동 후: `tuist generate` (셸)
  - 빌드/테스트/실행: **XcodeBuildMCP** (`session_show_defaults`로 project·scheme·simulator 확인 후 `build_sim` / `test_sim` / `build_run_sim`)
  - MCP 불가 시에만 `xcodebuild test` fallback (`docs/rules/project-operations.md`, destination은 환경에 맞게)
- 수동
  - 홈 진입 → 세그먼트 표시, 기본 탭 = 관심 콘서트
  - 관심 콘서트: 기존과 동일한 콘텐츠·토스트·리프레시
  - 캘린더: `준비 중`
  - 탭 전환 반복 시 크래시/이상 로드 없음

## 요구사항 고정 (deep-interview + 그릴)
- 목표: 세그먼트 + 기존 홈→관심 탭 + 초기 네트워크 동시성
- 포함: 세그먼트 UI, 캘린더 `준비 중`, HomeStore 탭 state, 초기 로드 동시성, 테스트
- 제외: 캘린더 콘텐츠, 관심 탭 재디자인, 토스트/에러 UX 의도적 변경, refresh 동시성 개편, 탭별 로드 분기, 자식 Store 분리, Reducer 도입
- 완료: 세그먼트 전환 + 관심 탭 동작 유지 + 동시성 테스트 검증
- Store: **단일 HomeStore** (`selectedHomeTab` + 기존 send/perform*)
- 공유 이해: 그릴 Q1–Q9 확정 + Store는 **단일 HomeStore** (자식 분리·Reducer 미도입)
- 구현 착수: 계획 확인 후 가능
