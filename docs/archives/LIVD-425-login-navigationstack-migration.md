# LIVD-425 LoginFeature NavigationStack 마이그레이션

## 배경
- 현재 프로젝트는 UIKit 기반 Coordinator 패턴(UINavigationController + UIHostingController 래핑)으로 화면 전환을 관리한다.
- SwiftUI 네이티브 NavigationStack/NavigationPath 기반으로 점진적 전환한다.
- 첫 번째 대상은 외부 Feature 의존이 없고 라우트 수가 적은 LoginFeature다.

## 목표
- LoginFeature의 화면 전환을 SwiftUI NavigationStack + Router 패턴으로 교체한다.
- Coordinator class, UIViewControllerRepresentable, EnvironmentKey Coordinator 의존성을 제거한다.
- 외부 인터페이스(onLoginCompleted, onSignupCompleted)는 변경하지 않는다.
- 이후 Feature 마이그레이션을 위한 참조 패턴을 확립한다.

## 작업 항목

### 1. Core/Coordinator 모듈에 Router 기반 클래스 추가
- [x] `Projects/Core/Coordinator/Sources/Router.swift` 신규 생성
  - `@MainActor open class Router<R: Hashable>: ObservableObject`
  - `@Published public private(set) var path = NavigationPath()`
  - 기본 메서드: `push(_ route: R)`, `pop()`, `popToRoot()`
- 기존 `Coordinator` 프로토콜과 `Route` 프로토콜은 수정하지 않고 유지 (다른 Feature 마이그레이션까지 공존)

### 2. LoginFeature에 LoginRouter 구현
- [x] `Projects/LoginFeature/Sources/Coordinator/LoginRouter.swift` 신규 생성
  - `final class LoginRouter: Router<LoginRoute>`
  - `onLoginCompleted: () -> Void`, `onSignupCompleted: (String) -> Void`를 private 프로퍼티로 보유
  - `completeLogin()`, `completeSignup(with:)` 메서드 노출

### 3. LoginContentView를 NavigationStack 기반으로 재작성
- [x] `Projects/LoginFeature/Sources/Coordinator/LoginContentView.swift` 전체 재작성
  - `@StateObject private var router: LoginRouter` 선언
  - `NavigationStack(path: $router.path)` 내에 `LoginView()` 배치
  - `.navigationDestination(for: LoginRoute.self)`로 5개 Route → View 매핑
  - `.environmentObject(router)` 주입
  - `UIViewControllerRepresentable`(LoginNavigationHost) 제거

### 4. 하위 View에서 Coordinator 접근부를 Router로 교체
- [x] `LoginView.swift`: `@Environment(\.loginCoordinator)` → `@EnvironmentObject var router: LoginRouter`
  - `coordinator?.push(to: .terms(user))` → `router.push(.terms(user))`
  - `coordinator?.completeLogin()` → `router.completeLogin()`
- [x] `TermsView.swift`: 동일 변환
- [x] `NicknameSettingView.swift`: 동일 변환
- [x] `PreferredGenreSettingView.swift`: 동일 변환
- [x] `PreferredArtistSettingView.swift`: 동일 변환
  - `coordinator?.completeSignup(with: nickname)` → `router.completeSignup(with: nickname)`

### 5. 불필요 파일 삭제
- [x] `LoginCoordinator.swift` 삭제
- [x] `EnvironmentValues+LoginCoordinator.swift` 삭제

### 6. LoginFeature 모듈 의존성 정리
- [x] `Projects/LoginFeature/Project.swift`에서 Coordinator 모듈 의존성 확인 및 유지/제거 판단
  - LoginFeature → Coordinator 의존성은 `Router`를 사용하므로 유지

### 7. 프로젝트 빌드 검증
- [x] `tuist generate --no-open` 정상 완료
- [x] `XcodeBuildMCP_discover_projs` workspace 인식 확인
- [x] `XcodeBuildMCP_build_sim` 빌드 성공 확인 (LoginFeature 스킴 + Livith-iOS 스킴)

### 8. Login 화면 전환 수동 테스트
- [x] 회원가입 flow 전체: Login → Terms → Nickname → PreferredGenre → PreferredArtist → 회원가입 완료
- [x] pop 동작: Terms에서 뒤로 가기, 중간 단계에서 pop
- [x] popToRoot: 콘텐츠 내에서 한 번에 루트로 복귀 (필요 시)
- [x] 로그인 성공: 로그인 버튼 → 메인 화면으로 전환

## 영향 범위

| 모듈 | 파일 | 변경 유형 |
|------|------|-----------|
| Core/Coordinator | `Sources/Router.swift` | 신규 |
| LoginFeature | `Sources/Coordinator/LoginRouter.swift` | 신규 |
| LoginFeature | `Sources/Coordinator/LoginCoordinatorView.swift` | 재작성 |
| LoginFeature | `Sources/Coordinator/LoginCoordinator.swift` | 삭제 |
| LoginFeature | `Sources/Coordinator/EnvironmentValues+LoginCoordinator.swift` | 삭제 |
| LoginFeature | `Sources/Login/View/LoginView.swift` | 수정 (coordinator 참조부) |
| LoginFeature | `Sources/Onboarding/View/TermsView.swift` | 수정 (coordinator 참조부) |
| LoginFeature | `Sources/Onboarding/View/NicknameSettingView.swift` | 수정 (coordinator 참조부) |
| LoginFeature | `Sources/Onboarding/View/PreferredGenreSettingView.swift` | 수정 (coordinator 참조부) |
| LoginFeature | `Sources/Onboarding/View/PreferredArtistSettingView.swift` | 수정 (coordinator 참조부) |
| App | `Sources/View/AppRootView.swift` | 변경 없음 (인터페이스 유지) |

**영향 없는 모듈:** HomeFeature, SearchFeature, ConcertFeature, UserFeature, Domain, Data

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| Core Router 타입 | Protocol + associatedtype / Generic class | Generic class | `private(set) path` 요구사항 충족, View에서 구체 타입 사용 가능 |
| 외부 콜백 위치 | Router / EnvironmentKey 분리 | Router | LoginFeature 5 depth라 FlowAction 분리는 과추상화. 간단히 Router에 보유 |
| Route 소유 | Core / 각 Feature | 각 Feature | Core가 모든 Feature 타입을 알게 됨. Feature 응집도 우선 |
| LoginRoute 변경 | 유지 / 단순화 | 유지 | 이미 Hashable, associated value도 모두 Hashable |
| sub-feature (Concert) | ViewFactory / Protocol / 별도 Router | ViewFactory (이후 HomeFeature 마이그레이션 시 적용) | 의존성 최소, 패턴 일관성 |

## 주의 사항
- `LoginRoute`의 모든 associated value(`TempUser`, `SignupBuilder`, `PreferredGenre` 등)가 `Hashable`인지 사전 확인 — 확인 완료
- `AppRootView`에서 `LoginContentView(onLoginCompleted:onSignupCompleted:)` 시그니처 불변 — 변경 없음
- `NavigationStack`은 iOS 16+ 요구사항 — 프로젝트 배포 타겟 iOS 17이므로 충족
- Coordinator 모듈 의존성은 `Router` 참조를 위해 유지
- Store/ViewModel(`LoginStore`, `TermsStore`, `SignupStore`)은 변경 없음 — MVI 패턴 유지
- Steps 3-4는 중간 컴파일 실패가 예상됨 (하위 View가 아직 이전 `@Environment` 참조). Step 7에서 일괄 빌드 검증
- `@EnvironmentObject`는 `.environmentObject()` 미주입 시 runtime fatalError 발생. LoginContentView에서 주입하므로 정상 경로에서는 문제 없으나, 추후 해당 View를 다른 컨텍스트에서 재사용 시 주의

## 검증 방법
1. `tuist generate --no-open` 정상 완료
2. `XcodeBuildMCP_build_sim` 빌드 성공 확인 (LoginFeature 스킴)
3. `XcodeBuildMCP_build_run_sim` 시뮬레이터에서 앱 실행
4. 수동 검증
   - 회원가입 flow: Login → Terms → Nickname → PreferredGenre → PreferredArtist → 완료까지 정상 이동
   - 뒤로 가기: 각 단계에서 pop 정상 동작
   - 로그인: Apple/Kakao 로그인 후 메인 진입 정상
5. 기존 Store/ViewModel 동작 이상 없음 확인
