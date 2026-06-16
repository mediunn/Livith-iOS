# ADR-001: SwiftUI NavigationStack 기반 네비게이션 마이그레이션

## 상태
Accepted (2026-06-16)

## 컨텍스트
- 프로젝트는 UIKit 기반 Coordinator 패턴(`UINavigationController` + `UIHostingController` 래핑)으로 화면 전환을 관리해 왔다.
- LIVD-425에서 LoginFeature와 UserFeature를 SwiftUI `Router<R>` + `NavigationStack` + `NavigationPath` 패턴으로 마이그레이션 완료.
- HomeFeature, SearchFeature, ConcertFeature는 아직 UIKit Coordinator 패턴을 사용 중이며, 다음 두 가지 한계가 있다.
  1. `UIViewControllerRepresentable`로 SwiftUI 안에 `UINavigationController`를 임베드하므로 SwiftUI 네이티브 navigation API(`NavigationLink`, `.toolbar`, `.sheet` 등)와 자연스럽게 연동되지 않는다.
  2. Login/User와 패턴이 달라 코드 가독성과 신규 개발자 온보딩 비용이 분기되어 발생한다.
- `ConcertFeature`는 Home/Search의 자식 Coordinator로 동작해 `UINavigationController`를 공유하는데, SwiftUI `NavigationStack`은 중첩이 시각적으로 부자연스럽다 (네비게이션 바 중복).

## 결정
LoginFeature/UserFeature와 동일한 SwiftUI 네이티브 패턴으로 나머지 Feature를 마이그레이션한다. 단, `NavigationStack` 중첩을 회피하기 위해 cross-feature 진입은 부모 `NavigationStack`에 push하고 자식 Feature는 view-only 형태로 노출한다.

### 1. Feature별 navigation 구조
- **Home / Search / User**: 각 Feature는 자체 `*Router: Router<*Route>` + `*CoordinatorView` 보유. `*CoordinatorView`는 `NavigationStack(path: $router.path)` + `.navigationDestination(for: *Route.self)`. 각 탭당 1개의 `NavigationStack` (탭별 navigation history 독립).
- **Concert (cross-feature 자식)**: `ConcertRoute`와 `ConcertCoordinatorView`만 보유. `NavigationStack`/`Router` 없음 (view-only). 부모(Home/Search) `NavigationStack`의 `navigationDestination(for: HomeRoute.concertDetail)`가 `ConcertCoordinatorView`를 렌더링하고, `ConcertCoordinatorView`는 `navigationDestination(for: ConcertRoute.self)`을 등록해 부모 스택에 push한다.

### 2. View ↔ Router 인터페이스
- Home/Search/User의 view는 `@EnvironmentObject var *Router: *Router`로 router에 접근, `*Router.push(.xxx)`로 navigation 트리거 (Login/User 패턴과 동일).
- 예외: 다른 모듈과 공유되는 view(예: `UserFeature`의 `NoticeSettingView`는 `HomeFeature`의 `HomeRoute.noticeSetting`과 `UserRoute.noticeSetting`에서 모두 사용)는 closure 인터페이스를 유지해 router 타입에 결합되지 않도록 한다.
- `ConcertFeature`의 view는 router가 없으므로 `NavigationLink(value:)` 선언형 navigation과 view 내부 `.sheet`로 modal을 처리한다.
- `SetlistDetailView`/`SongLyricsView`는 자체 router가 없으므로 closure 인터페이스를 유지하고, `ConcertCoordinatorView`의 destination switch가 wrapper view(`SetlistDetailContainer`)로 navigation을 연결한다.

### 3. Modal 처리
- Router가 있는 Feature: `present(to:)` 호출 제거, view 내부 `.sheet(item:)` 또는 `.sheet(isPresented:)`로 처리.
- Router가 없는 Feature(Concert): 모든 modal을 view 내부 `.sheet`로 처리. `ConcertRoute`에서 `.safari`/`.ticketSafari` case 제거.

### 4. Tab bar 숨김
- 기존 `isTabBarHidden` binding + `UINavigationControllerDelegate` 패턴 제거.
- 각 Feature의 `*CoordinatorView`의 `.navigationDestination(for: *Route.self)` closure 안에서 모든 destination view에 `.toolbar(.hidden, for: .tabBar)` modifier를 적용한다. SwiftUI preference 시스템이 pop 시 자동 복원.

### 5. Deep link
- `LivithMainTabView`가 deep link state(`deepLinkConcertID` 등)를 보유하고 `*CoordinatorView`로 binding 전달.
- `*CoordinatorView`는 `.onChange`에서 `*Router.popToRoot()` + `*Router.push(.concertDetail(...))`로 처리.
- 외부 인터페이스(`LivithMainTabView`)는 변경하지 않는다.

### 6. 진행 순서
- **Plan 1 (Concert + Setlist + Song)**: Concert를 view-only CoordinatorView로 전환, Setlist/Song의 callback은 wrapper view로 bridge. Home/Search는 임시로 컴파일 실패 상태가 되지만 커밋하지 않음.
- **Plan 2 (Home)**: HomeFeature를 `HomeRouter` + `HomeCoordinatorView`로 전환. `HomeRoute.concertDetail`이 `ConcertCoordinatorView`를 호출. `LivithMainTabView` 업데이트.
- **Plan 3 (Search)**: SearchFeature를 `SearchRouter` + `SearchCoordinatorView`로 전환. `SearchRoute.concertDetail`이 `ConcertCoordinatorView`를 호출. `LivithMainTabView` 최종 업데이트.
- 모든 plan 완료 후 단일 PR로 머지, PR 내부는 plan별로 commit 분리.

## 검토한 대안

### 대안 A: 모든 Feature에 자체 NavigationStack (중첩 허용)
- 각 Feature가 자체 `NavigationStack` 보유, cross-feature는 자식 `NavigationStack`이 됨.
- 장점: Feature 간 결합도 최소, 각 Feature가 독립적.
- 단점: `NavigationStack` 중첩으로 인한 UX 문제 (네비게이션 바 중복, back 버튼 이중 노출). 사용자 거부감.

### 대안 B: 앱 전역 단일 NavigationStack
- `AppRootView` 또는 `LivithMainTabView` 레벨에서 1개의 `NavigationStack` 보유, 모든 view가 그 안에.
- 장점: 단순한 구조.
- 단점: 탭별로 navigation history를 독립적으로 유지하기 어려움 (탭 전환 시 path 손실). Modal/Sheet와 Push의 routing이 복잡해짐.

### 대안 C (선택): 탭 단위 NavigationStack + cross-feature view-only
- 탭별로 `NavigationStack` 1개, cross-feature 진입은 부모 스택에 push, 자식은 view-only.
- 장점: 탭별 history 독립, 단일 스택 정책으로 back 동작 자연스러움, cross-feature 자식의 복잡도 최소화 (Router 불필요).
- 단점: cross-feature 자식의 modal은 자체 `.sheet` 처리 필요. Plan 1 종료 시점에서 Home/Search가 컴파일 실패하는 중간 상태 발생 (커밋하지 않음으로 우회).

## 결과

### 긍정적
- LoginFeature/UserFeature와 일관된 SwiftUI 네이티브 패턴 확립.
- 단일 `NavigationStack` 정책으로 back 동작이 자연스럽고 일관됨 (Home → Concert → Setlist → Song의 back 체인이 한 스택에서 처리됨).
- 모듈별 응집도 유지: cross-feature 진입은 부모 `NavigationStack`을 사용하므로 Feature 간 직접 의존이 발생하지 않음.
- `UIViewControllerRepresentable` 제거로 SwiftUI 네이티브 API(`NavigationLink`, `.toolbar`, `.sheet`)와 자연스러운 연동.

### 부정적
- Plan 1 종료 시점에서 Home/Search가 컴파일 실패. Plan 2/3에서 복구할 때까지 build 가능한 상태가 아님. 워크플로우로 우회 (Plan 단위로 진행, 최종 build 가능한 시점에서 단일 PR).
- cross-feature 자식(Concert)의 view는 router가 없으므로 modal을 자체 `.sheet`로 처리. 동일 패턴이 view마다 중복될 수 있음 (필요 시 helper modifier로 추출).
- `SetlistDetailView`/`SongLyricsView`에 wrapper view(`SetlistDetailContainer`)가 추가되어 view 트리 depth가 1단계 깊어짐.

### Follow-up
- `docs/rules/architecture.md`의 "Coordinator 패턴" 섹션을 Router + CoordinatorView 패턴으로 갱신.
- 동일 패턴이 view마다 중복될 경우 `.sheet` 헬퍼 modifier로 추출하는 리팩토링.
- `NoticeSettingView`처럼 다중 모듈 공유 view가 늘어나면 별도 Shared 모듈 분리 검토.
