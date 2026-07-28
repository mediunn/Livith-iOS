# LIVD-425 HomeFeature NavigationStack 마이그레이션

## 배경
- LIVD-425 Concert/Setlist/Song 마이그레이션(Plan 1)을 완료했다. `ConcertCoordinatorView`(view-only)가 신설되어 Home/Search가 `ConcertRoute`로 진입할 수 있는 기반이 마련됐다.
- HomeFeature는 여전히 UIKit 기반 Coordinator 패턴(`HomeCoordinator: Coordinator` + `UIViewControllerRepresentable`로 `UINavigationController` 임베드)을 사용 중이다.
- LoginFeature/UserFeature와 동일한 Router + NavigationStack 패턴으로 통일하여 일관성을 확보한다.
- HomeRoute에 `.concertDetail` case를 추가하여 Plan 1에서 신설한 `ConcertCoordinatorView`를 navigation destination으로 연결한다.

## 목표
- `HomeRoute`에 `.concertDetail(concertID:initialTab:initialSection:)` case 추가, `Route` → `Hashable` 직접 채택
- `HomeRouter`는 typealias로 표현 (별도 클래스 신설 없음, `Router<HomeRoute>` 직접 사용)
- `HomeCoordinatorView` 신설 — `NavigationStack(path: $router.path)` + `navigationDestination(for: HomeRoute.self)`
- HomeFeature의 view들이 `@EnvironmentObject var homeRouter: HomeRouter`로 router에 접근 (Login/User 패턴)
- 예외: `NoticeSettingView`는 `UserFeature` 모듈에 있고 `UserRoute.noticeSetting`에서도 재사용되므로 closure 인터페이스 유지
- Tab bar 숨김: destination view에 `.toolbar(.hidden, for: .tabBar)` 적용, `isTabBarHidden` binding 제거
- Deep link: `LivithMainTabView`의 binding을 `HomeCoordinatorView`가 받아서 `.onChange`에서 `homeRouter.popToRoot()` + `homeRouter.push(.concertDetail(...))` 처리
- `HomeCoordinator`, `HomeContentView`, `EnvironmentValues+HomeCoordinator` 삭제
- `LivithMainTabView`에서 `HomeContentView`를 `HomeCoordinatorView`로 교체

## 작업 항목

### 1. `HomeRoute` 확장
- [x] `Projects/HomeFeature/Sources/Coordinator/HomeRoute.swift` 수정
  - `.concertDetail(concertID: Int, initialTab: SegmentedTabBarType.DetailTab, initialSection: ConcertInfoSection?)` case 추가
  - `Route` 프로토콜 채택 제거, `Hashable` 직접 채택 (LoginRoute/UserRoute/ConcertRoute와 동일)
  - `import Coordinator` 제거
  - `import LivithDesignSystem` 추가 (SegmentedTabBarType 사용)
  - **모듈 의존성:** `ConcertFeature`는 이미 HomeFeature/Project.swift에 dependencies로 포함되어 있어 별도 추가 불필요

### 2. `HomeRouter` typealias 선언
- [x] `Projects/HomeFeature/Sources/Coordinator/HomeCoordinatorView.swift` 상단에 typealias 선언
  - `typealias HomeRouter = Router<HomeRoute>` (별도 파일 미생성, HomeCoordinatorView 파일 내 top-level)
  - **결정 변경:** 사용자 피드백으로 nested `HomeCoordinatorView.HomeRouter` → top-level `HomeRouter`로 변경. views에서 `HomeRouter` 직접 사용 가능

### 3. `HomeCoordinatorView` 신설
- [x] `Projects/HomeFeature/Sources/Coordinator/HomeCoordinatorView.swift` 신규 생성
  - `public struct HomeCoordinatorView: View`
  - `@StateObject private var router: HomeRouter`
  - body: `NavigationStack(path: $router.path) { HomeView().navigationDestination(for: HomeRoute.self) { route in destinationView(for: route).toolbar(.hidden, for: .tabBar, .navigationBar) } }`
  - 9개 case 매핑 완료
  - `.environmentObject(router)` 주입
  - `.ignoresSafeArea()`
  - **Tab bar + navigation bar 숨김:** `.toolbar(.hidden, for: .tabBar, .navigationBar)` — 시스템 NavigationStack의 nav bar는 숨기고 `LivithNavigationView`만 표시

### 4. Deep link 처리
- [x] `HomeCoordinatorView.init`에 deep link binding 파라미터 추가
  - `@Binding deepLinkConcertID: Int?`
  - `@Binding deepLinkInitialTab: SegmentedTabBarType.DetailTab`
  - `@Binding deepLinkInitialSection: ConcertInfoSection?`
  - `@Binding deepLinkShowInterest: Bool`
  - `.onChange(of: deepLinkConcertID)` + `.onChange(of: deepLinkShowInterest)`로 router 호출
  - **구현 참고:** iOS 17 `onChange(of:)`는 1-arg (deprecated) 또는 0/2-arg closure 지원. 빌드 호환을 위해 1-arg deprecated form 사용 (warning만 발생, 동작 동일). 향후 2-arg form으로 전환 가능

### 5. 하위 View에서 Router로 전환
- [x] `Projects/HomeFeature/Sources/Home/View/HomeView.swift` 수정
  - `@EnvironmentObject private var homeRouter: HomeRouter`
  - 모든 `coordinator?.push(to:)` → `homeRouter.push()`로 변경
  - `coordinator?.showConcertDetail(concertID:)` → `homeRouter.push(.concertDetail(...))` (initialTab: .artistDetail, initialSection: nil)

- [x] `Projects/HomeFeature/Sources/Notice/View/NoticeView.swift` 변경 없음
  - closure 인터페이스 유지, HomeCoordinatorView에서 router 메서드로 wire

- [x] `Projects/HomeFeature/Sources/Interest/View/InterestConcertListView.swift` 수정
- [x] `Projects/HomeFeature/Sources/Interest/View/InterestConcertSettingView.swift` 수정
- [x] `Projects/HomeFeature/Sources/PreferenceUpdate/View/GenreUpdateView.swift` 수정
- [x] `Projects/HomeFeature/Sources/PreferenceUpdate/View/ArtistUpdateView.swift` 수정
- [x] `Projects/HomeFeature/Sources/Home/View/Subview/ConcertContentSection/RecommendedConcertGridView.swift` 수정

### 6. Tab bar + navigation bar 숨김 처리
- [x] `HomeCoordinatorView`의 `navigationDestination(for: HomeRoute.self)` closure에서 모든 destination view에 `.toolbar(.hidden, for: .tabBar, .navigationBar)` modifier 적용

### 7. `LivithMainTabView` 업데이트
- [x] `Projects/App/Sources/View/LivithMainTabView.swift` 수정
  - `isTabBarHidden` state는 Search tab이 여전히 UIKit 기반이므로 **유지** (Search는 Plan 3에서 제거 예정)
  - Home tab: `HomeContentView(isTabBarHidden: ...)` → `HomeCoordinatorView(deepLinkConcertID: ...)`로 교체
  - Home tab의 `.toolbar(isTabBarHidden ? .hidden : .visible, for: .tabBar)` 제거 (HomeCoordinatorView가 자체 관리)
  - Search tab은 UIKit Coordinator가 아직 사용 중이므로 `isTabBarHidden` binding 유지

### 8. 불필요 파일 삭제
- [x] `Projects/HomeFeature/Sources/Coordinator/HomeCoordinator.swift` 삭제
- [x] `Projects/HomeFeature/Sources/Coordinator/HomeContentView.swift` 삭제
- [x] `Projects/HomeFeature/Sources/Coordinator/EnvironmentValues+HomeCoordinator.swift` 삭제

### 9. 모듈 의존성
- [x] `Projects/HomeFeature/Project.swift` — ConcertFeature dependencies 이미 포함 (변경 불필요)

### 10. 빌드 검증
- [x] `tuist generate --no-open` 정상 완료
- [x] HomeFeature, ConcertFeature, UserFeature, Livith-iOS 스킴 빌드 성공
  - **빌드 환경:** xcodebuildmcp `XcodeBuildMCP_build_sim` 사용
  - **시뮬레이터 실행은 사용하지 않음** (빌드만 수행)
  - HomeFeature: 빌드 성공 (deprecation warning 2건 — onChange(of:perform:) deprecated in iOS 17.0, 1-arg form 사용 중)
  - ConcertFeature: 빌드 성공
  - UserFeature: 빌드 성공
  - Livith-iOS: 빌드 성공
  - Search는 Plan 3 전이므로 UIKit Coordinator 상태로 빌드 통과 (임시 어댑터)

## 영향 범위

| 모듈 | 파일 | 변경 유형 |
|------|------|-----------|
| HomeFeature | `Sources/Coordinator/HomeRoute.swift` | 수정 (case 추가, Hashable) |
| HomeFeature | `Sources/Coordinator/HomeCoordinatorView.swift` | 신규 (typealias HomeRouter 포함) |
| HomeFeature | `Sources/Coordinator/HomeCoordinator.swift` | 삭제 |
| HomeFeature | `Sources/Coordinator/HomeContentView.swift` | 삭제 |
| HomeFeature | `Sources/Coordinator/EnvironmentValues+HomeCoordinator.swift` | 삭제 |
| HomeFeature | `Sources/Home/View/HomeView.swift` | 수정 (coordinator → router) |
| HomeFeature | `Sources/Interest/View/InterestConcertListView.swift` | 수정 (coordinator → router) |
| HomeFeature | `Sources/Interest/View/InterestConcertSettingView.swift` | 수정 (coordinator → router) |
| HomeFeature | `Sources/PreferenceUpdate/View/GenreUpdateView.swift` | 수정 (coordinator → router) |
| HomeFeature | `Sources/PreferenceUpdate/View/ArtistUpdateView.swift` | 수정 (coordinator → router) |
| HomeFeature | `Sources/Home/View/Subview/ConcertContentSection/RecommendedConcertGridView.swift` | 수정 (coordinator → router) |
| HomeFeature | `Sources/Notice/View/NoticeView.swift` | 변경 없음 (closure 인터페이스 유지, HomeCoordinatorView에서 wire) |
| HomeFeature | `Project.swift` | 수정 (dependencies에 ConcertFeature 추가) |
| App | `Sources/View/LivithMainTabView.swift` | 수정 (HomeContentView → HomeCoordinatorView, isTabBarHidden 제거) |

**영향 없는 모듈:** LoginFeature, UserFeature, ConcertFeature, SetlistFeature, SongFeature, SearchFeature (Plan 3 대상), Domain, Data

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| HomeView Router 인터페이스 | @EnvironmentObject / closure | @EnvironmentObject | Login/User 패턴과 일관. closure는 view를 router 타입에 결합 |
| NoticeSettingView 인터페이스 | closure / @EnvironmentObject | closure 유지 | UserFeature와 공유. HomeRoute/ UserRoute 두 곳에서 사용. router 타입 결합 회피 |
| Tab bar 숨김 | isTabBarHidden binding / .toolbar modifier | .toolbar modifier | UserCoordinatorView 패턴과 일관. SwiftUI preference가 pop 시 자동 복원 |
| Deep link 처리 위치 | LivithMainTabView / HomeCoordinatorView | HomeCoordinatorView | HomeFeature 내부 관심사. binding만 받아서 router로 위임 |
| HomeRoute.concertDetail case | 새로 추가 / 기존 route 활용 | 새로 추가 (concertID, initialTab, initialSection) | Plan 1의 ConcertCoordinatorView init 시그니처와 일치. deep link 시 initialTab/initialSection 필요 |
| HomeCoordinator 임시 어댑터 처리 | 제거 / 유지 | 제거 | Plan 2에서 정식 Router로 전환. Plan 1 임시 어댑터 코드 모두 제거 |
| HomeRouter 표현 방식 | 별도 class / typealias | **typealias `HomeRouter = Router<HomeRoute>`** | 추가 콜백/메서드 없음. LoginRouter/UserRouter와 달리 subclass 불필요. HomeCoordinatorView 파일 상단에 MARK와 함께 선언. 필요 시 향후 확장 가능 (별도 파일로 분리) |

## 주의 사항
- `HomeRoute`의 모든 associated value가 `Hashable`인지 확인 필요: `InterestConcertSettingMode`, `[Concert]`, `[PreferredGenre]` (확인 완료), `Int`, `SegmentedTabBarType.DetailTab`, `ConcertInfoSection?` (모두 Hashable 가정)
- `LivithMainTabView`의 `isTabBarHidden` state와 Home tab의 `.toolbar(.hidden, for: .tabBar)`는 Plan 2에서 제거. Search tab의 동일 코드는 Plan 3까지 유지 (Search의 NavigationStack 마이그레이션이 끝나기 전이므로)
- `HomeRoute`가 `SegmentedTabBarType.DetailTab`, `ConcertInfoSection`을 사용하므로 `import ConcertFeature`가 필요. `HomeFeature/Project.swift`의 dependencies에 `ConcertFeature` 추가
- `HomeFeature`는 이미 `ConcertFeature`를 import해서 `Coordinator.swift`를 통해 접근 중이지만, 이제 `ConcertRoute`/`ConcertCoordinatorView`도 import하므로 명시적 dependencies 필요
- `HomeContentView`의 `HomeNavigationHost: UIViewControllerRepresentable` 구조는 `UINavigationControllerDelegate`를 통해 tab bar hidden을 관리했는데, Plan 2에서는 SwiftUI NavigationStack이 자동 처리하므로 불필요
- Deep link의 `popToRoot()` 후 `push(.concertDetail(...))` 순서는 Plan 1과 동일 (Home의 root → Concert). User의 push가 `popToRoot` 후 즉시 push되므로 stack이 `[home, concertDetail]`이 됨
- `recommendedConcertList`의 `concertList`는 array of `Concert`. `Concert`가 `Hashable`인지 확인 (Domain 모델에서 Hashable 채택 가정)
- `preferredArtistUpdate`의 `selectedGenreList`는 `[PreferredGenre]`. `PreferredGenre`가 `Hashable`인지 확인 (UserRoute plan에서 이미 확인 완료)
- `NoticeSettingView`의 `onBack` closure는 `HomeCoordinatorView.destinationView(for:)`에서 `{ router.pop() }`로 wire. `UserFeature`의 `UserCoordinatorView`는 이미 `{ router.pop() }`로 wire 중
- Steps 5는 다수 view 리팩터. Step 7에서 `LivithMainTabView` 업데이트. Step 10에서 일괄 빌드 검증
- Plan 2 종료 후 다음 Plan 3 시작 전까지 사용자 승인 대기

## 검증 방법

### 빌드 환경
- 빌드 검증 도구: **xcodebuildmcp** (MCP 서버)
- 시뮬레이터 실행은 사용하지 않음 (빌드만 수행, 시뮬레이터 부팅/실행 안 함)
- 사용 도구:
  - `XcodeBuildMCP_discover_projs` — workspace 인식
  - `XcodeBuildMCP_session_set_defaults` — scheme/simulator 지정
  - `XcodeBuildMCP_build_sim` — 빌드 (시뮬레이터 target으로 컴파일만, 실행 안 함)
- 사용하지 않는 도구: `XcodeBuildMCP_build_run_sim` (시뮬레이터 실행)

### 빌드 검증 절차
1. `tuist generate --no-open` 정상 완료
2. `XcodeBuildMCP_discover_projs` workspace 인식 확인
3. `XcodeBuildMCP_session_set_defaults`로 scheme 지정 (Plan 2는 HomeFeature, ConcertFeature, UserFeature, Livith-iOS 빌드)
4. `XcodeBuildMCP_build_sim` 빌드 성공 확인 — HomeFeature 스킴과 의존 모듈 컴파일 가능

### 런타임 검증 (수동 테스트, 사용자 디바이스/시뮬레이터 환경)
- 빌드 검증은 xcodebuildmcp로만 수행. 시뮬레이터는 사용자 환경에서 별도 실행.
- 검증 시나리오:
  1. Home → 알림 → 알림 설정 → 뒤로 가기 (pop)
  2. Home → 관심 콘서트 설정 → 변경 → 저장 → popToRoot
  3. Home → 콘서트 카드 탭 → Concert 진입 → setlist → song → 뒤로 가기 체인
  4. Home → 추천 콘서트 → 그리드 → 콘서트 탭 → Concert 진입
  5. 탭 전환: Home ↔ Search ↔ User 시 navigation history 유지
  6. Tab bar: Home root에서 보이고, push된 화면에서 숨김, pop 시 다시 보임
  7. Deep link: 알림 탭 → Concert 진입, 알림 아이콘 → interest concert 설정 진입
  8. Login/User 마이그레이션 회귀 테스트

## 빌드 상태
Plan 2 종료 시점에서 Home은 정식 Router로 마이그레이션 완료. Search는 Plan 1과 동일한 임시 어댑터 상태 유지. 빌드는 전체 통과. Plan 3에서 Search 마이그레이션 후 일괄 커밋.
