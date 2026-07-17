# LIVD-438 홈 세그먼트 분리 + 초기 진입 네트워크 동시성 정리

## 배경
- 홈이 **관심 콘서트 / 캘린더** 두 모드로 분리된다. ([참고 Figma](https://www.figma.com/design/G53QwXoxT96gB68dO7vRZi/?node-id=10-17969))
- 세그먼트·단일 `HomeStore`·초기 로드 동시성 1차는 반영됨. 이어서 **View를 탭 맥락으로 분리**하고, **로드 트리거를 셸/관심 콘텐츠로 나눈다**.
- `HomeView.onAppear`에 관심 파이프라인까지 두면 캘린더가 보이는 상태에서도 관심 API가 돌 수 있어, 책임이 어긋난다.
- **관심 콘서트 결과 안내(toast → FR-06 시트)** 는 별도 계획: `docs/plans/LIVD-438-interest-concert-result-sheet.md`

## 목표
- 홈 루트에 세그먼트(관심 콘서트 / 캘린더)를 둔다. (**완료**)
- **기존 홈 콘텐츠 전부**를 관심 콘서트 탭 아래에 유지한다. (관심 탭 콘텐츠 재디자인 없음)
- 캘린더 탭은 `준비 중` 플레이스홀더. (실제 캘린더 콘텐츠는 범위 밖)
- **단일 `HomeStore`**를 유지하되, **View는 탭별로 분리·폴더링**한다.
- 네트워크 책임 분리:
  - `homeAppear`(셸): 유저 + 미읽음 알림
  - `interestAppear`(관심 콘텐츠): 관심 목록 ∥ 섹션, 추천(user 후), 토스트(섹션 성공 후)
- 세그먼트 전환 + 관심 탭 동작 유지 + 동시성/분리를 테스트로 검증한다.

## 작업 항목

### 1. 세그먼트 타입 / DesignSystem 정리
- [x] `SegmentedTabBarType.HomeTab`을 `interestConcert` / `calendar`로 **교체**
- [x] 홈 `.home` 세그먼트 배경을 clear로 두어 빈 상태 `black90`과 단차 제거

### 2. Home UI — 세그먼트 + 단일 Store (1차)
- [x] `HomeView`에 세그먼트 추가, 관심=기존 홈 / 캘린더=`준비 중`
- [x] `selectedHomeTab` + `homeTabSelected`를 **단일 `HomeStore`**에서 관리
- [x] 자식 Store / Reducer 미도입

### 3. 초기 진입 네트워크 동시성 (1차 — 이후 4항에서 트리거·파이프라인 재분리)
- [x] 의존 없는 호출 동시 실행, 추천·토스트 후행, 유저 실패 시 섹션 미반영/cancel
- [x] `onRefresh`는 범위 밖(회귀만)
- [x] HomeStoreTests로 세그먼트·동시성·재시도 검증

### 4. Home View 분리 + 폴더링 + 로드 트리거 재분리 (그릴 2차)
- [x] `HomeView`를 셸만 남기고 탭 콘텐츠 View 분리
  - `InterestHomeContentView` — 기존 관심 스크롤 + `refreshable`
  - `CalendarHomeContentView` — `준비 중` 플레이스홀더
- [x] 폴더 구조

```text
Home/View/
  HomeView.swift
  Interest/
    InterestHomeContentView.swift
    Subview/   # 기존 Interest·Empty·ConcertContent 이동
  Calendar/
    CalendarHomeContentView.swift
```

- [x] 자식 View는 `@ObservedObject var store: HomeStore` 생성자 주입 (`@StateObject`는 `HomeView`만)
- [x] 셸 책임: 네비·세그먼트·토스트·배경, `homeAppear` 호출
- [x] 관심 콘텐츠: `interestAppear` 호출 (캘린더 보일 때는 관심 파이프라인 미실행)
- [x] Intent 분리
  - `homeAppear` → 유저 ∥ 미읽음 알림
  - `interestAppear` → 관심 목록 ∥ 섹션, 추천은 `user` 준비 후, 토스트는 섹션 성공 후
  - 기존 단일 `onAppear` 초기 로드는 위 둘로 대체
- [x] 기본 탭이 관심이면 두 `onAppear`가 거의 동시 → 파이프라인은 병렬 유지, 추천만 user 후행
- [x] TDD: `homeAppear` / `interestAppear` 각각의 호출·순서·실패 흡수 테스트 갱신
- [x] Swift 파일 이동 후 `tuist generate` + XcodeBuildMCP로 테스트

### 5. 검증
- [x] 1차: XcodeBuildMCP `HomeStoreTests` 통과
- [x] 2차: View 분리·Intent 분리 후 `HomeStoreTests` (+ 필요 시 회귀) 통과
- [ ] 시뮬레이터에서 세그먼트 전환·관심 탭·캘린더 `준비 중`·캘린더만 볼 때 관심 API 미호출 확인

## 영향 범위
- `Projects/HomeFeature/Sources/Home/View/HomeView.swift` — 셸만 유지
- `Projects/HomeFeature/Sources/Home/View/Interest/**` — 콘텐츠 + 기존 Subview 이동
- `Projects/HomeFeature/Sources/Home/View/Calendar/**` — 플레이스홀더
- `Projects/HomeFeature/Sources/Home/Store/HomeStore.swift` — `homeAppear` / `interestAppear` 파이프라인 분리
- `Projects/HomeFeature/Tests/HomeStoreTests.swift`
- DesignSystem `SegmentedTabBar` — (1차 완료, 추가 변경 최소)
- Domain / Networking / Repository 계약 변경 **없음**

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 관심 탭 콘텐츠 | Figma 재디자인 vs 기존 홈 유지 | **기존 홈 전부 유지** | deep-interview |
| 캘린더 탭 | 콘텐츠 vs 플레이스홀더 | **`준비 중` 플레이스홀더** | deep-interview + 그릴 |
| Store 분리 | 단일 vs 부모+자식 | **단일 `HomeStore`** | 그릴 1차 |
| View 분리 | 단일 HomeView vs 탭별 | **탭별 분리 + 폴더링** | 그릴 2차 |
| Store 주입 | ObservedObject vs EnvironmentObject | **`@ObservedObject` 생성자 주입** | 그릴 2차 |
| 관심 로드 트리거 | HomeView.onAppear vs Interest content | **`InterestHomeContentView.onAppear`** | 캘린더 표시 중 관심 API 방지 |
| 셸 로드 | 유저만 vs 유저+알림 vs 없음 | **유저 ∥ 미읽음 알림** | 뱃지가 셸 소속 |
| Intent | 단일 onAppear vs 분리 | **`homeAppear` / `interestAppear`** | 그릴 2차 |
| 동시성 (2차) | 직렬 vs 분리 병렬 | **home∥interest 동시, 목록∥섹션, 추천=user 후, 토스트=섹션 후** | 그릴 2차 |
| refresh | 셸 vs 관심 콘텐츠 | **관심 콘텐츠 `refreshable`** | 그릴 2차 |
| Reducer | 도입 vs 미도입 | **미도입** | LIVD-438 |

## Home 구조 (2차 목표)

```text
HomeView (@StateObject HomeStore)
  ├─ homeAppear → 유저 ∥ 미읽음 알림
  ├─ 네비 / 세그먼트 / 토스트
  └─ tabContent
       ├─ InterestHomeContentView (@ObservedObject store)
       │    └─ interestAppear → 목록 ∥ 섹션 → 추천(user 후) → 토스트(섹션 후)
       │         + refreshable
       └─ CalendarHomeContentView (@ObservedObject store)
            └─ "준비 중" (로드 없음)
```

- **비범위:** 캘린더 실콘텐츠, 관심 탭 Figma 재디자인, 자식 Store, Reducer, refresh 동시성 개편, 탭 선택 영속화

## 주의 사항
- 파일 이동 후 반드시 `tuist generate`.
- 추천은 `user` 의존 — `interestAppear`가 `homeAppear`보다 먼저여도 섹션은 진행 가능, 추천만 user 대기.
- 유저 실패 시 섹션 성공 결과 미반영·관련 Task cancel 정책 유지.
- 상태 변경은 `send`에서, `perform*`는 부수효과만 (`docs/rules/architecture.md`).
- TDD: Intent 분리·트리거 변경은 실패 테스트 먼저 (`docs/rules/tdd.md`).
- 빌드·테스트는 **XcodeBuildMCP 우선**.

## 검증 방법
- 단위 테스트
  - `homeAppear`: 유저·알림 호출, 관심 목록/섹션 미호출(또는 관심 Intent와 분리됨을 검증)
  - `interestAppear`: 목록∥섹션, 추천 user 후행, 토스트 섹션 후행, 실패 흡수
  - 세그먼트 전환은 로드 재실행 없음
- 명령: `tuist generate` → XcodeBuildMCP `test_sim` (HomeFeatureTests)
- 수동: 관심 기본 진입, 캘린더만 선택 후 재진입 시 관심 API 과도 호출 없음, `준비 중` 표시

## 요구사항 고정 (deep-interview + 그릴 1·2차)
- Store: **단일 HomeStore**
- View: **탭별 분리 + Interest/Calendar 폴더링**
- 로드: **`homeAppear`(유저+알림)** / **`interestAppear`(관심 파이프라인)**
- 공유 이해: 그릴 2차 Q1–Q8 확정 (계획 반영 후 구현)
