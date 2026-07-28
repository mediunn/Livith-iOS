# LIVD-425 SearchFeature NavigationStack 마이그레이션

## 배경
- LIVD-425 Plan 1(Concert/Setlist/Song), Plan 2(Home) 마이그레이션을 완료했다. Login/User + Home + Concert/Setlist/Song은 모두 SwiftUI Router + NavigationStack 패턴을 사용한다.
- SearchFeature는 UIKit 기반 Coordinator 패턴(`SearchCoordinator: Coordinator` + `UIViewControllerRepresentable`로 `UINavigationController` 임베드)을 사용 중인 마지막 Feature다.
- `SearchRoute`에 `.concertDetail` case를 추가하여 Plan 1의 `ConcertCoordinatorView`로 진입할 수 있게 한다.
- Plan 2에서 도입한 `HomeCoordinatorView` 패턴과 동일하게 적용하여 일관성을 완성한다.

## 목표
- `SearchRoute`에 `.concertDetail(concertID:)` case 추가, `Hashable` 직접 채택
- `SearchRouter`는 typealias로 표현 (`Router<SearchRoute>`)
- `SearchCoordinatorView` 신설 — `NavigationStack(path: $router.path)` + `navigationDestination(for: SearchRoute.self)`
- SearchFeature의 view들이 `@EnvironmentObject var searchRouter: SearchRouter`로 router에 접근
- Tab bar + navigation bar 숨김: destination view에 `.toolbar(.hidden, for: .tabBar, .navigationBar)` 적용
- `SearchCoordinator`, `SearchContentView`, `EnvironmentValues+SearchCoordinator` 삭제
- `LivithMainTabView` 최종 업데이트 — `SearchContentView`를 `SearchCoordinatorView`로 교체, `isTabBarHidden` state 완전 제거

## 작업 항목

### 1. `SearchRoute` 확장
- [x] `Projects/SearchFeature/Sources/Coordinator/SearchRoute.swift` 수정
  - `.concertDetail(concertID: Int)` case 추가
  - `Route` 프로토콜 채택 제거, `Hashable` 직접 채택
  - `import Coordinator` 제거
  - `import ConcertFeature` 불필요 (Int만 사용)

### 2. `SearchRouter` typealias 선언
- [x] `Projects/SearchFeature/Sources/Coordinator/SearchCoordinatorView.swift` 상단에 typealias 선언
  - `typealias SearchRouter = Router<SearchRoute>`
  - Home과 동일 패턴, top-level 선언

### 3. `SearchCoordinatorView` 신설
- [x] `Projects/SearchFeature/Sources/Coordinator/SearchCoordinatorView.swift` 신규 생성
  - `public struct SearchCoordinatorView: View`
  - `@StateObject private var router: SearchRouter`
  - body: `NavigationStack(path: $router.path) { ExploreView().navigationDestination(for: SearchRoute.self) { route in destinationView(for: route).toolbar(.hidden, for: .tabBar, .navigationBar) } }`
  - 3개 case 매핑 완료
  - `.environmentObject(router)` 주입
  - `.ignoresSafeArea()`

### 4. 하위 View에서 Router로 전환
- [x] `Projects/SearchFeature/Sources/Explore/View/ExploreView.swift` 수정
  - `@EnvironmentObject private var searchRouter: SearchRouter`
  - `coordinator?.push(to: .search)` → `searchRouter.push(.search)`
  - `coordinator?.showConcertDetail(concertID:)` → `searchRouter.push(.concertDetail(concertID:))`

- [x] `Projects/SearchFeature/Sources/Search/View/SearchView.swift` 수정
  - `@EnvironmentObject private var searchRouter: SearchRouter`
  - `coordinator?.pop()` → `searchRouter.pop()` (back 액션)
  - `coordinator?.showConcertDetail(concertID:)` → `searchRouter.push(.concertDetail(concertID:))`

### 5. `LivithMainTabView` 최종 업데이트
- [x] `Projects/App/Sources/View/LivithMainTabView.swift` 수정
  - `isTabBarHidden` state **완전 제거** (Home + Search 모두 자체 관리)
  - Search tab: `SearchContentView(isTabBarHidden: ...)` → `SearchCoordinatorView()`로 교체
  - Search tab의 `.toolbar(isTabBarHidden ? .hidden : .visible, for: .tabBar)` 제거
  - deep link notification 처리는 Home/탭 전환 로직만 유지

### 6. 불필요 파일 삭제
- [x] `Projects/SearchFeature/Sources/Coordinator/SearchCoordinator.swift` 삭제
- [x] `Projects/SearchFeature/Sources/Coordinator/SearchContentView.swift` 삭제
- [x] `Projects/SearchFeature/Sources/Coordinator/EnvironmentValues+SearchCoordinator.swift` 삭제

### 7. 빌드 검증
- [x] `tuist generate --no-open` 정상 완료
- [x] SearchFeature, HomeFeature, ConcertFeature, UserFeature, Livith-iOS 스킴 빌드 성공
  - **빌드 환경:** xcodebuildmcp `XcodeBuildMCP_build_sim` 사용
  - **시뮬레이터 실행은 사용하지 않음** (빌드만 수행)
  - SearchFeature: 빌드 성공 (경고 0, 에러 0)
  - HomeFeature: 빌드 성공
  - ConcertFeature: 빌드 성공
  - UserFeature: 빌드 성공
  - Livith-iOS: 빌드 성공

## 영향 범위

| 모듈 | 파일 | 변경 유형 |
|------|------|-----------|
| SearchFeature | `Sources/Coordinator/SearchRoute.swift` | 수정 (case 추가, Hashable) |
| SearchFeature | `Sources/Coordinator/SearchCoordinatorView.swift` | 신규 (typealias SearchRouter 포함) |
| SearchFeature | `Sources/Coordinator/SearchCoordinator.swift` | 삭제 |
| SearchFeature | `Sources/Coordinator/SearchContentView.swift` | 삭제 |
| SearchFeature | `Sources/Coordinator/EnvironmentValues+SearchCoordinator.swift` | 삭제 |
| SearchFeature | `Sources/Explore/View/ExploreView.swift` | 수정 (coordinator → router) |
| SearchFeature | `Sources/Search/View/SearchView.swift` | 수정 (coordinator → router) |
| App | `Sources/View/LivithMainTabView.swift` | 수정 (SearchContentView → SearchCoordinatorView, isTabBarHidden 완전 제거) |

**영향 없는 모듈:** LoginFeature, UserFeature, ConcertFeature, SetlistFeature, SongFeature, HomeFeature, Domain, Data

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| SearchView Router 인터페이스 | @EnvironmentObject / closure | @EnvironmentObject | Login/User/Home 패턴과 일관. closure는 view를 router 타입에 결합 |
| SearchCoordinator 임시 어댑터 처리 | 제거 / 유지 | 제거 | Plan 3에서 정식 Router로 전환. Plan 1 임시 어댑터 코드 모두 제거 |
| SearchRouter 표현 방식 | 별도 class / typealias | **typealias `SearchRouter = Router<SearchRoute>`** | 추가 콜백/메서드 없음. Home과 동일 패턴. top-level typealias로 views에서 직접 사용 |
| Tab bar + navigation bar 숨김 | isTabBarHidden binding / .toolbar modifier | .toolbar(.hidden, for: .tabBar, .navigationBar) | HomeCoordinatorView 패턴과 일관. SearchContentView의 UIViewControllerRepresentable wrapper 제거 |
| LivithMainTabView의 isTabBarHidden | 유지 / 제거 | **완전 제거** | Plan 3에서 Home + Search 모두 자체 관리하므로 binding 불필요. App에서 tab bar hidden 관리 책임 제거 |

## 주의 사항
- `SearchRoute`의 모든 associated value가 `Hashable`인지 확인 (`Int` — Hashable, 확인 완료)
- `SearchContentView`의 `SearchNavigationHost: UIViewControllerRepresentable` 구조와 `UINavigationControllerDelegate` 기반 tab bar hidden 관리가 SwiftUI NavigationStack으로 전환되며 자동 처리됨
- `SearchView`는 `init(store: SearchStore)`로 `SearchStore`를 외부에서 받음. `SearchCoordinatorView.destinationView(for: .search)`에서 `SearchView(store: .init())`로 새 store 생성
- `ExploreView`의 `@Environment(\.openURL) private var openURL`은 Coordinator와 무관하므로 유지
- `SearchCoordinator`의 미사용 메서드 (`showConcertDetail`)는 Plan 1에서 이미 사용되지 않음. Plan 3에서 파일 자체 삭제
- Steps 4는 2개 view 리팩터 (ExploreView, SearchView). Step 5에서 `LivithMainTabView` 최종 업데이트. Step 7에서 일괄 빌드 검증
- Plan 3 종료 후 모든 plan 완료 → 단일 commit/PR로 최종 정리 (또는 plan별 commit 분리)

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
3. `XcodeBuildMCP_session_set_defaults`로 scheme 지정 (Plan 3는 SearchFeature, HomeFeature, ConcertFeature, UserFeature, Livith-iOS 빌드)
4. `XcodeBuildMCP_build_sim` 빌드 성공 확인 — 5개 스킴 모두 컴파일 가능

### 런타임 검증 (수동 테스트, 사용자 디바이스/시뮬레이터 환경)
- 빌드 검증은 xcodebuildmcp로만 수행. 시뮬레이터는 사용자 환경에서 별도 실행.
- 검증 시나리오:
  1. Search (탐색) → 콘서트 카드 탭 → Concert 진입 → back 시 Search로 복귀
  2. Search (탐색) → 검색 탭 → 검색 결과 → 콘서트 탭 → Concert 진입
  3. Search → Concert 진입 시 tab bar 숨김, back 시 복원
  4. 탭 전환: Home ↔ Search ↔ User 시 navigation history 독립 유지
  5. Deep link 알림 → Home → Concert 진입, Search history에 영향 없음
  6. Home/Search/Concert 마이그레이션 회귀 테스트

## 빌드 상태
Plan 3 종료 시점에서 모든 Feature가 SwiftUI Router + NavigationStack 패턴으로 통일됨. 단일 NavigationStack 정책 완성. 빌드는 전체 통과. Plan 1, 2, 3 완료 후 단일 PR로 일괄 커밋 가능.
