# LIVD-425 UserFeature NavigationStack 마이그레이션

## 배경
- LoginFeature(LIVD-425)에서 SwiftUI 네이티브 NavigationStack + Router 패턴으로의 마이그레이션을 완료했다.
- UserFeature는 현재 UIKit 기반 Coordinator 패턴(UINavigationController + UIHostingController)으로 화면 전환을 관리한다.
- LoginFeature에서 확립된 패턴을 UserFeature에 적용하여 일관성을 맞춘다.
- UserFeature는 외부 Feature 의존이 거의 없고(onNavigateToHome 클로저 하나), 라우트 수가 7개로 적절해 두 번째 마이그레이션 대상으로 적합하다.

## 목표
- UserFeature의 화면 전환을 SwiftUI NavigationStack + Router 패턴으로 교체한다.
- `UserCoordinator` class, `UIViewControllerRepresentable`, `EnvironmentValues+UserCoordinator`를 제거한다.
- 외부 인터페이스(UserContentView의 `isTabBarHidden`, `onNavigateToHome`)는 변경하지 않는다.
- LoginFeature 패턴과 동일한 구조로 통일한다.

## 작업 항목

### 1. UserRoute를 Hashable로 변경
- [x] `Projects/UserFeature/Sources/Coordinator/UserRoute.swift` 수정
  - `enum UserRoute: Route` → `enum UserRoute: Hashable`
  - `import Coordinator` 제거 (Hashable은 Swift 표준)
  - associated value 타입(`PreferredGenre`, `PreferredArtist`)은 이미 Hashable이므로 추가 작업 불필요

### 2. UserRouter 신규 생성
- [x] `Projects/UserFeature/Sources/Coordinator/UserRouter.swift` 신규 생성
  - `final class UserRouter: Router<UserRoute>`
  - `onNavigateToHome: () -> Void` private 프로퍼티로 보유, `navigateToHome()` 메서드 노출
  - `onGenreUpdateSuccess: () -> Void` private 프로퍼티로 보유, `genreUpdateSuccess()` 메서드 노출
  - `onArtistUpdateSuccess: () -> Void` private 프로퍼티로 보유, `artistUpdateSuccess()` 메서드 노출
  - LoginFeature의 LoginRouter와 동일한 패턴
  - TODO: 스낵바 콜백은 향후 Store 상태 변경으로 이전 예정

### 3. UserContentView를 NavigationStack 기반으로 재작성
- [x] `Projects/UserFeature/Sources/Coordinator/UserContentView.swift` 재작성
  - `@StateObject private var router: UserRouter` 선언
  - `NavigationStack(path: $router.path)` 내에 `UserView()` 배치
  - `.navigationDestination(for: UserRoute.self)`로 7개 Route → View 매핑
  - `.environmentObject(router)` 주입
  - push되는 모든 destination View에 `.toolbar(.hidden, for: .tabBar)` 추가
  - `UIViewControllerRepresentable`(UserNavigationHost) 제거
  - NoticeSettingView는 `NoticeSettingView(onBack: { router.pop() })`로 생성
  - UserContentView에서 `.environmentObject(router)` 주입

### 4. 하위 View에서 Coordinator 접근부를 Router로 교체
- [x] `Projects/UserFeature/Sources/View/UserView.swift`
  - `@Environment(\.userCoordinator) private var coordinator` → `@EnvironmentObject private var router: UserRouter`
  - `coordinator?.push(to: .xxx)` → `router.push(.xxx)`
  - `coordinator?.pop()` → `router.pop()`
  - `coordinator?.onGenreUpdateSuccess = { ... }` → `router.onGenreUpdateSuccess = { ... }` (TODO: 향후 Store 상태 변경으로 이전)

- [x] `Projects/UserFeature/Sources/View/SettingView.swift`
  - 동일 변환

- [x] `Projects/UserFeature/Sources/View/NicknameUpdateView.swift`
  - 동일 변환

- [x] `Projects/UserFeature/Sources/View/DeleteUserView.swift`
  - 동일 변환

- [x] `Projects/UserFeature/Sources/View/UserGenreUpdateView.swift`
  - 동일 변환
  - 성공 후 `router.genreUpdateSuccess()` / `router.pop()` (TODO: 향후 Store 상태 변경으로 이전)

- [x] `Projects/UserFeature/Sources/View/UserArtistUpdateView.swift`
  - 동일 변환

- [x] `Projects/UserFeature/Sources/View/NoticeSettingView.swift`
  - `onBack` 클로저 유지 (HomeFeature와 공유)
  - `navigationDestination`에서 `NoticeSettingView(onBack: { router.pop() })` 생성

### 5. 불필요 파일 삭제
- [x] `Projects/UserFeature/Sources/Coordinator/UserCoordinator.swift` 삭제
- [x] `Projects/UserFeature/Sources/Coordinator/EnvironmentValues+UserCoordinator.swift` 삭제

### 6. 프로젝트 빌드 검증
- [x] `tuist generate --no-open` 정상 완료
- [x] Xcode 빌드 성공 확인 (UserFeature 스킴 + Livith-iOS 스킴)

### 7. User 화면 전환 수동 테스트
- [x] 기존 동작 회귀 테스트: Store/MVI 변경 없으므로 기존 동작 그대로 유지
- [x] 마이 메인 → 설정 → 각 메뉴 이동/뒤로가기
- [x] 닉네임 수정 완료 후 pop 및 메인 반영
- [x] 선호 장르 변경 완료 후 pop
- [x] 선호 아티스트 변경 완료 후 pop
- [x] 변경사항 있는 상태에서 뒤로가기 → DangerModal → pop
- [x] 회원탈퇴 플로우
- [x] 로그아웃 → 재로그인
- [x] 탭바 전환 시 탭바 상태 정상 복원 확인

## 영향 범위

| 모듈 | 파일 | 변경 유형 |
|------|------|-----------|
| UserFeature | `Sources/Coordinator/UserRouter.swift` | 신규 |
| UserFeature | `Sources/Coordinator/UserRoute.swift` | 수정 (Route → Hashable) |
| UserFeature | `Sources/Coordinator/UserContentView.swift` | 재작성 |
| UserFeature | `Sources/Coordinator/UserCoordinator.swift` | 삭제 |
| UserFeature | `Sources/Coordinator/EnvironmentValues+UserCoordinator.swift` | 삭제 |
| UserFeature | `Sources/View/UserView.swift` | 수정 (coordinator 참조부) |
| UserFeature | `Sources/View/SettingView.swift` | 수정 (coordinator 참조부) |
| UserFeature | `Sources/View/NicknameUpdateView.swift` | 수정 (coordinator 참조부) |
| UserFeature | `Sources/View/DeleteUserView.swift` | 수정 (coordinator 참조부) |
| UserFeature | `Sources/View/UserGenreUpdateView.swift` | 수정 (coordinator 참조부) |
| UserFeature | `Sources/View/UserArtistUpdateView.swift` | 수정 (coordinator 참조부) |
| UserFeature | `Sources/View/NoticeSettingView.swift` | 수정 (coordinator 참조부) |
| App | `Sources/View/LivithMainTabView.swift` | 변경 없음 (인터페이스 유지) |

**영향 없는 모듈:** HomeFeature, SearchFeature, ConcertFeature, LoginFeature, Domain, Data

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 탭바 숨김 방식 | path.count 관찰 / 각 destination View에 .toolbar | 각 destination View에 .toolbar(.hidden, for: .tabBar) | LoginFeature가 navigationBar를 destination에서 가린 것과 동일한 방식. SwiftUI preference 시스템이 pop 시 자동 복원 |
| 동적 콜백 처리 | Router에 콜백 유지 / Store 상태 변경으로 전환 | Router에 콜백 유지 (TODO: 향후 Store로 이전) | 네비게이션 마이그레이션이 우선. 스낵바 리팩토링은 별도 작업으로 분리 |
| NoticeSettingView | onBack 클로저 유지 / Router로 교체 | onBack 클로저 유지 (HomeFeature에서 공유 사용) | `public` 인터페이스. HomeFeature도 동일하게 사용 중. Router 주입 불필요 |
| Route 소유 | Core / 각 Feature | 각 Feature | LoginFeature와 동일한 결정. Feature 응집도 우선 |
| Router 외부 콜백 | Router에 클로저 / EnvironmentKey 분리 | Router에 클로저 | LoginFeature와 동일. 필요 이상의 추상화 방지 |

## 주의 사항
- `UserRoute`의 모든 associated value(`PreferredGenre`, `PreferredArtist`)가 `Hashable`인지 확인 — Domain 모델에서 Hashable 준수 확인 완료 (Conformances: Hashable)
- `AppRootView`에서 `UserContentView(isTabBarHidden:onNavigateToHome:)` 시그니처 불변 — 변경 없음
- `NavigationStack`은 iOS 16+ 요구사항 — 프로젝트 배포 타겟 iOS 17이므로 충족
- `@EnvironmentObject`는 `.environmentObject()` 미주입 시 runtime fatalError 발생. UserContentView에서 주입하므로 정상 경로에서는 문제 없으나, 추후 해당 View를 다른 컨텍스트에서 재사용 시 주의
- Steps 3-4는 중간 컴파일 실패가 예상됨 (하위 View가 아직 이전 `@Environment` 참조). Step 7에서 일괄 빌드 검증
- `SettingView`의 로그아웃과 `DeleteUserView`의 회원탈퇴는 `NotificationCenter.post(name: "reloginRequired")`를 사용 — Router와 무관하므로 변경 없음
- NoticeSettingView는 `onBack` 클로저를 유지 (HomeFeature와 공유). `navigationDestination`에서 `NoticeSettingView(onBack: { router.pop() })`로 주입
- UserRoute의 모든 associated value(`PreferredGenre`, `PreferredArtist`)는 Domain 모델에서 이미 `Hashable` 채택 확인됨

## 검증 방법
1. `tuist generate --no-open` 정상 완료
2. Xcode 빌드 성공 확인 (UserFeature 스킴)
