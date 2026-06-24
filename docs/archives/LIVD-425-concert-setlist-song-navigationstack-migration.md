# LIVD-425 Concert/Setlist/Song NavigationStack 마이그레이션

## 배경
- LIVD-425에서 LoginFeature와 UserFeature를 SwiftUI `Router<R>` + `NavigationStack` 패턴으로 전환 완료.
- ConcertFeature는 Home/Search의 자식 `ConcertCoordinator`로 동작하며, 6개의 view가 `concertCoordinator` environment에 의존하고 있다.
- SetlistFeature/SongFeature는 자체 Coordinator가 없으며 `ConcertCoordinator`의 route로 push된다.
- ADR-001에 따라 cross-feature 자식(Concert)은 view-only `CoordinatorView`로 전환한다. Router 없이 선언형 `NavigationLink(value:)` + view 내부 `.sheet`로 navigation/modal을 처리한다.

## 목표
- `ConcertRoute`는 push 케이스만 유지 (`.safari`, `.ticketSafari` 제거).
- `ConcertCoordinatorView` 신설 (NavigationStack/Router 미보유, view-only).
- ConcertFeature 6개 view에서 `concertCoordinator` 의존 제거.
- `SetlistDetailView`/`SongLyricsView`는 callback 인터페이스를 유지하되, `onPlaySong`/`onReportTapped`를 wrapper view로 navigation 연결.
- `ConcertView`의 `coordinator.onTicketSiteReturn` 메커니즘을 자식 view의 `onTicketSiteReturn: () -> Void` 클로저로 전달.
- `ConcertCoordinator`, `EnvironmentValues+ConcertCoordinator` 삭제.

## 작업 항목

### 1. `ConcertRoute` 재작성
- [x] `Projects/ConcertFeature/Sources/Coordinator/ConcertRoute.swift` 수정
  - 기존 6 case에서 `.safari(URL)`, `.ticketSafari(URL)` 제거
  - 4 case 유지: `.detail(concertID:initialTab:initialSection:)`, `.setlistDetail(concertID:setlistID:)`, `.songLyrics(songID:setlistID:songTitle:)`, `.merchandiseDetail([ConcertMerchandise]:ticketingOfficeURL:)`
  - `Route` 프로토콜 채택 제거, `Hashable` 직접 채택 (LoginRoute/UserRoute와 동일)
  - `import Coordinator` 제거

### 2. `ConcertCoordinatorView` 신설
- [x] `Projects/ConcertFeature/Sources/Coordinator/ConcertCoordinatorView.swift` 신규 생성
  - `public struct ConcertCoordinatorView: View`
  - `@State`로 `concertID: Int`, `initialTab: SegmentedTabBarType.DetailTab`, `initialSection: ConcertInfoSection?` 보유
  - body는 `ConcertView(concertID:, initialTab:, initialSection:)`를 root로 렌더링하고 `.navigationDestination(for: ConcertRoute.self)` 등록
  - 4 case 매핑:
    - `.detail` → root (이 route는 실제로 push되지 않음, root가 항상 detail이므로 navigationDestination에 .detail case 불필요)
    - `.setlistDetail` → `SetlistDetailContainer`
    - `.songLyrics` → `SongLyricsView`
    - `.merchandiseDetail` → `MerchandiseDetailView`
  - **NavigationStack 미포함**, **Router 미보유** (view-only)

### 3. `SetlistDetailContainerView` wrapper 신설
- [x] `Projects/ConcertFeature/Sources/Coordinator/SetlistDetailContainerView.swift` 신규 생성
  - `struct SetlistDetailContainerView: View`
  - `@State private var pendingSong: SetlistSong?` 보유
  - body: `SetlistDetailView(concertID:, setlistID:, onPlaySong: { song in pendingSong = song })` + `.navigationDestination(item: $pendingSong)` → `SongLyricsView(songID:, setlistID:, songTitle:)`
  - `SetlistSong`이 `Hashable`인지 확인 후 `.navigationDestination(item:)` 사용 (iOS 17+)
  - `onReportTapped`는 `SetlistDetailView` 내부 `.sheet`로 처리되므로 wrapper는 신경쓰지 않음
  - **이름 변경:** 초기 `SetlistDetailContainer`로 작성 후 `View` 접미사 컨벤션(`CoordinatorView`, `LoginCoordinatorView`, `UserCoordinatorView` 등)에 맞춰 `SetlistDetailContainerView`로 리네임

### 4. `ConcertView` 리팩터
- [x] `Projects/ConcertFeature/Sources/View/ConcertView.swift` 수정
  - `@Environment(\.concertCoordinator)` 제거
  - `init`에서 `onDismiss: @escaping () -> Void` 제거 (시스템 back 사용, navigationDestination이 back을 자동 처리)
  - 단, `LivithNavigationView(type: .back(title:, onBack:))`에서 custom back이 필요한 경우를 위해 `onBack: nil` 또는 시스템 처리 검토 — `LivithNavigationView`의 back 타입이 onBack 클로저를 받으므로 빈 클로저 `{}`로 두거나, custom back이 없으면 시스템 back으로 변경
  - `onAppear`의 `coordinator?.onTicketSiteReturn = { ... }` 제거
  - `onDisappear`의 `coordinator?.onTicketSiteReturn = nil` 제거
  - 대신 ticket return 배너를 트리거하기 위해 `@State private var showTicketReturnBanner`로 자체 관리하고, 자식 view(`ConcertInfoTabView`, `ConcertInfoCarousel`, `MerchandiseDetailView`)에 `onTicketSiteReturn: { showTicketReturnBanner = true }` 클로저 전달
  - `tabContentView`의 `ConcertInfoTabView(...)` 생성 시 `onTicketSiteReturn` 클로저 추가
  - `ConcertInfoCarousel` 사용처 (`ConcertInfoTabView` 내부)에도 동일 클로저 전달 (ConcertInfoTabView가 받은 클로저를 그대로 전달)
  - `MerchandiseDetailView` 사용처 (`ConcertCoordinatorView`의 navigationDestination)에도 동일 클로저 전달
  - `store.state.showTicketReturnBanner` 직접 참조 부분 (line 113, 232-247) 확인 후 `@State` 변수로 변경

### 5. `SetlistTabView` 리팩터
- [x] `Projects/ConcertFeature/Sources/View/TabContent/SetlistTabView.swift` 수정
  - `@Environment(\.concertCoordinator)` 제거
  - `@State private var isReportSheetPresented: Bool = false` (방안 b - bool flag)
  - `coordinator?.present(to: .safari(...))` → `isReportSheetPresented = true` (SectionHeaderView의 onReport 액션)
  - `coordinator?.push(to: .setlistDetail(...))` → `NavigationLink(value: ConcertRoute.setlistDetail(...))` (setlistCard)
  - `.sheet(isPresented: $isReportSheetPresented) { SafariView(url: ConcertConstant.reportFormURL) }`

### 6. `ConcertInfoTabView` 리팩터
- [x] `Projects/ConcertFeature/Sources/View/TabContent/ConcertInfoTabView.swift` 수정
  - `@Environment(\.concertCoordinator)` 제거
  - `@State private var isReportSheetPresented: Bool` + `@State private var isTicketSheetPresented: Bool`
  - `coordinator?.present(to: .safari(...))` 2곳 → `isReportSheetPresented = true`
  - `coordinator?.present(to: .ticketSafari(...))` → `isTicketSheetPresented = true`
  - `coordinator?.push(to: .merchandiseDetail(...))` → `NavigationLink(value: ConcertRoute.merchandiseDetail(...))`
  - `.sheet(isPresented:)` 2개 + ticket sheet에는 `onDismiss: { onTicketSiteReturn() }`
  - `onTicketSiteReturn: () -> Void` 클로저를 init에서 받음
  - `ConcertInfoCarousel`에 `onTicketSiteReturn` 전달

### 7. `ArtistDetailTabView` 리팩터
- [x] `Projects/ConcertFeature/Sources/View/TabContent/ArtistDetailTabView.swift` 수정
  - `@Environment(\.concertCoordinator)` 제거
  - `@State` bool 3개: `isReportSheetPresented`, `isInstagramSheetPresented`, `isTwitterSheetPresented`
  - `coordinator?.present(to: .safari(...))` 4곳 → 각 bool true
  - `.sheet(isPresented:)` 3개

### 8. `ConcertInfoCarousel` 리팩터
- [x] `Projects/ConcertFeature/Sources/View/Subview/ConcertInfoCarousel.swift` 수정
  - `@Environment(\.concertCoordinator)` 제거
  - `@State private var isTicketSheetPresented: Bool`
  - `coordinator?.present(to: .ticketSafari(...))` (탭) → `isTicketSheetPresented = true`
  - `.sheet(isPresented:onDismiss:)` ticket
  - `onTicketSiteReturn: () -> Void` 클로저를 init에서 받음

### 9. `MerchandiseDetailView` 리팩터
- [x] `Projects/ConcertFeature/Sources/View/MerchandiseDetailView.swift` 수정
  - `@Environment(\.concertCoordinator)` 제거
  - `init`에서 `onDismiss: @escaping () -> Void` 제거 (시스템 back), `onTicketSiteReturn: @escaping () -> Void` 추가
  - `@Environment(\.dismiss)`로 back 처리
  - `@State private var isTicketSheetPresented: Bool`
  - `coordinator?.present(to: .ticketSafari(...))` → `isTicketSheetPresented = true`
  - `.sheet(isPresented:onDismiss:)` ticket
  - Preview 업데이트

### 10. `SetlistDetailView` 리팩터
- [x] `Projects/SetlistFeature/Sources/View/SetlistDetailView.swift` 수정
  - `onReportTapped: (() -> Void)?` → `reportURL: URL?` 제거
  - `static let reportFormURL` (타입 프로퍼티) + 자체 `.sheet(isPresented:)`
  - `init`에서 `reportURL` 파라미터 제거
  - **결정 변경:** plan 작성 시점의 방안 A(`onReportTapped` 유지, nil이면 자체 처리)에서 사용자 피드백으로 `static let reportFormURL` 타입 프로퍼티 방식으로 변경. URL 자체가 고정이므로 인자로 받을 필요 없음.

### 11. `SongLyricsView` 리팩터
- [x] `Projects/SongFeature/Sources/View/SongLyricsView.swift` 수정
  - `onReportTapped: @escaping () -> Void` → `reportURL: URL?` 제거
  - `static let reportFormURL` (타입 프로퍼티) + 자체 `.sheet(isPresented:)`
  - **결정 변경:** 10번과 동일

### 12. `ConcertConstant` 공유 검토
- [x] 방안 3 폐기, 타입 프로퍼티 방식으로 변경
  - `SetlistDetailView`, `SongLyricsView`의 `static let reportFormURL`로 자체 보유
  - `ConcertConstant.reportFormURL`은 ConcertFeature 내부에서만 사용 (TabContent view들의 .sheet)
  - 모듈 간 의존성 없음

### 13. 불필요 파일 삭제
- [x] `Projects/ConcertFeature/Sources/Coordinator/ConcertCoordinator.swift` 삭제
- [x] `Projects/ConcertFeature/Sources/Coordinator/EnvironmentValues+ConcertCoordinator.swift` 삭제

### 14. Home/Search 임시 처리 (Plan 2/3에서 정식 처리)
- [x] `Projects/HomeFeature/Sources/Coordinator/HomeCoordinator.swift` 임시 수정
  - `ConcertCoordinator` 참조 제거
  - `showConcertDetail(concertID:initialTab:initialSection:)` → `ConcertCoordinatorView`를 `UIHostingController`로 push
  - 미사용 메서드 (`showSongDetail`, `showSetlistDetail`) 제거
- [x] `Projects/SearchFeature/Sources/Coordinator/SearchCoordinator.swift` 임시 수정
  - 동일 처리

### 15. 빌드 검증
- [x] `tuist generate --no-open` 정상 완료
- [x] HomeFeature, SearchFeature, ConcertFeature, SetlistFeature, SongFeature, Livith-iOS 스킴 빌드 성공 확인
  - **빌드 환경:** xcodebuildmcp `XcodeBuildMCP_build_sim` 사용
  - **시뮬레이터 실행은 사용하지 않음** (빌드만 수행)

## 영향 범위

| 모듈 | 파일 | 변경 유형 |
|------|------|-----------|
| ConcertFeature | `Sources/Coordinator/ConcertRoute.swift` | 수정 (case 제거, Hashable) |
| ConcertFeature | `Sources/Coordinator/ConcertCoordinatorView.swift` | 신규 |
| ConcertFeature | `Sources/Coordinator/SetlistDetailContainer.swift` | 신규 |
| ConcertFeature | `Sources/Coordinator/ConcertCoordinator.swift` | 삭제 |
| ConcertFeature | `Sources/Coordinator/EnvironmentValues+ConcertCoordinator.swift` | 삭제 |
| ConcertFeature | `Sources/View/ConcertView.swift` | 수정 (coordinator 제거, onTicketSiteReturn 자체 관리) |
| ConcertFeature | `Sources/View/TabContent/SetlistTabView.swift` | 수정 (NavigationLink, .sheet) |
| ConcertFeature | `Sources/View/TabContent/ConcertInfoTabView.swift` | 수정 (NavigationLink, .sheet, onTicketSiteReturn) |
| ConcertFeature | `Sources/View/TabContent/ArtistDetailTabView.swift` | 수정 (.sheet) |
| ConcertFeature | `Sources/View/Subview/ConcertInfoCarousel.swift` | 수정 (.sheet, onTicketSiteReturn) |
| ConcertFeature | `Sources/View/MerchandiseDetailView.swift` | 수정 (.sheet, onTicketSiteReturn) |
| SetlistFeature | `Sources/View/SetlistDetailView.swift` | 수정 (onReportTapped 자체 처리, reportURL 파라미터) |
| SongFeature | `Sources/View/SongLyricsView.swift` | 수정 (onReportTapped 자체 처리, reportURL 파라미터) |
| HomeFeature | `Sources/Coordinator/HomeCoordinator.swift` | 임시 수정 (ConcertCoordinator → ConcertCoordinatorView) |
| SearchFeature | `Sources/Coordinator/SearchCoordinator.swift` | 임시 수정 (ConcertCoordinator → ConcertCoordinatorView) |

**영향 없는 모듈:** LoginFeature, UserFeature, App (Plan 2/3에서 업데이트), Domain, Data

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| ConcertRouter 유무 | 생성 / 미생성 | 미생성 | ADR-001, 단일 NavigationStack 정책, view-only CoordinatorView |
| modal 처리 | Router.present / view .sheet | view .sheet | Router 없음, view-only 정책. 일관성 |
| cross-feature 자식 navigation | NavigationLink 선언 / imperative push | NavigationLink 선언 | Router 없으므로 선언형 강제 |
| Setlist/Song 콜백 유지 | callback / @EnvironmentObject router | callback 유지 | 자체 router 없음, wrapper로 bridge. 모듈 분리 |
| SetlistDetailContainer 위치 | SetlistFeature / ConcertFeature | ConcertFeature | navigation 연결이 ConcertFeature의 책임 |
| ConcertConstant 공유 | public 노출 / Core 이동 / 파라미터 전달 | 파라미터 전달 (reportURL) | 모듈 의존 최소화 |
| HomeRoute/SearchRoute에 .concertDetail 추가 | Plan 1에서 / Plan 2/3에서 | Plan 1에서 임시 처리 | 빌드 통과를 위해 임시 어댑터. Plan 2/3에서 정식 처리 |
| ticket return banner 트리거 | coordinator callback / @State 자체 관리 | @State 자체 관리 + 자식에 클로저 전달 | Router 없음. ConcertView가 banner 상태 관리, 자식이 알림 |
| onTicketSiteReturn 클로저 위치 | Environment / init 파라미터 | init 파라미터 | 모듈 간 결합 최소화 |

## 주의 사항
- `ConcertRoute`의 모든 associated value는 이미 `Hashable` (확인 완료: `Int`, `SegmentedTabBarType.DetailTab`, `ConcertInfoSection?`, `[ConcertMerchandise]`, `URL?`).
- `SetlistSong`이 `Hashable`인지 확인 필요 (`.navigationDestination(item:)` 사용 조건). 미충족 시 래퍼 struct 도입.
- `LivithNavigationView`의 `.back(title:, onBack:)` 타입이 `onBack` 클로저를 받음. `ConcertView`/`MerchandiseDetailView`에서 system back이 아닌 custom back을 원하면 클로저를 제공해야 함. 현재 custom back 로직이 없는지 확인.
- `SectionHeaderView`의 `onReport` 액션 시그니처 확인 필요 (Task-5의 .sheet 처리 패턴 결정에 영향).
- `URL`은 `Identifiable`이 아니므로 `.sheet(item:)` 사용 시 별도 wrapper struct 필요 (`IdentifiableURL` 등) 또는 `.sheet(isPresented:)` + `@State URL?` 사용.
- `@EnvironmentObject`와 달리 `@Environment`는 default value가 가능해서 ConcertFeature view가 `concertCoordinator` 없이도 컴파일 가능했음. Plan 1 이후에는 모든 사용처가 사라지므로 문제 없음.
- Steps 4-12는 ConcertFeature view들의 `concertCoordinator` 사용을 모두 제거. Step 14에서 Home/Search의 `ConcertCoordinator` 사용도 임시로 변경. Step 15에서 일괄 빌드 검증.
- Plan 1 종료 시점에서 Home/Search의 임시 어댑터로 빌드는 통과하지만, 코드 품질은 Plan 2/3에서 정식 처리.
- Plan 1 종료 후 다음 Plan 2를 시작하기 전까지, 코드 변경이 반영된 상태로 작업이 일시 정지될 수 있음 (사용자 승인 대기).

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
3. `XcodeBuildMCP_session_set_defaults`로 scheme 지정 (Plan 1은 LoginFeature, UserFeature, HomeFeature, SearchFeature, ConcertFeature, SetlistFeature, SongFeature, Livith-iOS 모두 빌드)
4. `XcodeBuildMCP_build_sim` 빌드 성공 확인 — 임시 어댑터로 Home/Search가 컴파일 가능해야 함

### 런타임 검증 (수동 테스트, 사용자 디바이스/시뮬레이터 환경)
- 빌드 검증은 xcodebuildmcp로만 수행. 시뮬레이터는 사용자 환경에서 별도 실행.
- 검증 시나리오:
  1. Home → Concert 진입 → setlist → song navigation 동작
  2. Concert에서 safari/report form/ticket safari .sheet 표시 동작
  3. Ticket safari dismiss 후 banner 표시 동작
  4. back 동작: Concert → Home 정상 pop
  5. Search → Concert 진입 동일 시나리오
  6. Login/User 마이그레이션과 무관한지 확인 (Login/User 회귀 테스트)

## 빌드 상태
Plan 1 종료 시점에서 빌드는 임시 어댑터로 통과 가능. 단, Home/Search의 navigation은 UIKit Coordinator 패턴이 일부 남아있어 최종 사용자 동작은 Plan 2/3 완료 후 정상.
