# 아키텍처

## Purpose
- 레이어 간 책임과 의존 방향을 고정하여 변경의 영향 범위를 제한한다.
- 모듈 간 결합을 줄여 기능 단위의 독립적인 개발과 테스트를 가능하게 한다.

## Scope
- 프로젝트의 모든 모듈에 적용한다.
- typed throws와 Store 상태(`@Published private(set)`)·`send` 단일 진입점의 정본은 이 문서다. `docs/rules/code-convention.md`는 이를 재정의하지 않고 따른다.

## Do

### 레이어 구조
- Presentation과 Data는 Domain에 의존한다 (Presentation → Domain ← Data).
- Domain 레이어는 Swift 표준 라이브러리와 Foundation을 사용할 수 있다. `Date`, `URL` 같은 값 타입은 도메인 모델에서 사용할 수 있다.
- Data 레이어는 Domain 레이어의 프로토콜을 구현한다.
- Presentation 레이어는 Domain 레이어의 프로토콜에만 의존한다.

### 모듈 구조
- 화면 기능과 여러 화면에서 공유하는 사용자 기능은 `Projects/Feature/` 하위의 독립 타깃으로 둔다. 각 타깃의 소스와 테스트는 기능별 디렉터리에 두고 `Projects/Feature/Project.swift`에서 함께 정의한다.
- Core는 앱의 공통 인프라를 맡는다. 네트워크 전송, 의존성 주입, 화면 전환, 로컬 저장소, 인증 SDK 연동, 분석 이벤트 전송이 여기에 해당한다.
- Shared는 여러 기능이 재사용하는 보조 코드를 맡는다. `DisplaySupport`처럼 도메인 값을 표시 문구로 변환하는 코드나 범용 유틸리티를 여기에 둔다. 특정 화면에서만 쓰는 표시 로직은 해당 Feature에 둔다.
- 공용 UI 컴포넌트와 디자인 리소스는 Shared의 `LivithDesignSystem` 타깃에서 관리한다.
- Data 모듈은 도메인 단위로 `Projects/Data/` 하위에 분리한다 (예: `UserData`, `ConcertData`).
- Core와 Shared의 역할은 타깃이 맡는 책임을 기준으로 구분한다. Xcode 프로젝트로 묶는 단위는 별도로 결정한다.

### MVI 패턴 (Store-Intent-State)
- View의 사용자 액션은 Intent enum으로 정의한다.
- Store는 `ObservableObject`를 채택하고, `send(_ intent:)` 메서드를 단일 진입점으로 사용한다.
- State는 struct로 정의하고, `@Published private(set)`으로 외부 직접 변경을 차단한다.
- 비동기 작업은 Store 내부의 `perform*()` 메서드에서 수행한다.
- 비동기 작업의 결과는 내부 Intent(언더스코어 prefix: `._fetchResult`)로 다시 `send`한다.

### ViewModel 전환 시 상태 소유

ViewModel로 전환하기로 한 기능에는 다음 기준을 적용한다. 기존 Store는 위 MVI 규칙을 따른다. [ADR 0002](../adr/0002-viewmodel-ownership.md)

- 여러 View가 함께 바꾸거나 참조하는 상태는 공통 소유자에 둔다. [#341 수동 공연 검색](https://github.com/mediunn/Livith-iOS/issues/341)의 단일 선택은 목록이 관리하고, 카드는 선택 여부와 탭 콜백을 받는다.
- 셀이 항목별로 독립적인 상태나 작업을 관리한다면 셀 단위 ViewModel을 둘 수 있다. 셀이 사라져도 유지해야 하는 작업은 그 수명을 보장하는 상위 소유자에 둔다.

### Repository 패턴
- Domain 레이어에 Repository 프로토콜을 정의한다.
- Data 레이어에 `*RepositoryImpl` struct로 구현한다.
- Repository 구현체는 NetworkClient, Cache(로컬 저장소), Mapper를 조합한다.

### Mapper 패턴
- DTO → Domain Entity 변환은 Mapper struct에서 수행한다.
- 각 Repository마다 전담 Mapper를 둔다.
- 날짜 포맷 변환, URL 생성, nil 처리 등은 Mapper에서 처리한다.

### 에러 처리
- Domain 레이어에 도메인별 Error enum을 정의한다 (예: `UserError`, `ConcertError`).
- Data 레이어에 ErrorMapper를 두어 네트워크/저장소 에러를 도메인 에러로 변환한다.
- Repository 메서드는 Typed Throws를 사용한다 (예: `throws(UserError)`).

### 네비게이션 패턴 (Router + NavigationStack)
- 화면 전환은 SwiftUI 네이티브 `NavigationStack` + `Router<R>`을 사용한다.
- 각 Feature 모듈은 독립적인 `Router<R>` (또는 typealias)와 `Route` enum을 가진다. `Route`는 `Hashable`을 채택하며, `Router`는 `Router<R>: ObservableObject`를 상속받는다.
- Feature의 진입점은 `*CoordinatorView`로, `NavigationStack(path: $router.path)`를 생성하고 `navigationDestination(for:)`에서 Route → View를 매핑한다.
- `NavigationStack`은 **탭 단위로 1개**만 유지하며, 중첩을 금지한다 (자식 Feature는 view-only CoordinatorView로 동작).
- View는 `@EnvironmentObject var *Router: *Router`로 Router에 접근하여 `push()`, `pop()`, `popToRoot()`를 호출한다.
- 자식 Feature(예: Concert)로 진입 시 부모 Feature의 Route case에 추가하고, `navigationDestination`에서 자식의 `*CoordinatorView`(Router 없음)를 렌더링하여 단일 NavigationStack을 유지한다.
- 부모 Feature가 Coordinator에서 자식 Feature의 공개 화면 진입점을 연결할 때는 부모에서 자식으로의 직접 타깃 의존을 허용한다.
- 모달(Sheet, fullScreenCover)은 각 View 내부에서 `.sheet(isPresented:)`, `.fullScreenCover(isPresented:)`로 자체 처리한다.
- 다른 Feature와 공유되는 View(예: `NoticeSettingView`)는 closure 인터페이스를 유지하여 Router 타입에 결합되지 않도록 한다.

### 의존성 주입
- `@Injected` Property Wrapper를 사용하여 의존성을 주입한다.
- 의존성 등록은 `DependencyAssembler` 프로토콜을 구현하여 수행한다.
- 각 Data 모듈마다 전담 Assembler를 둔다 (예: `UserDataAssembler`).
- Assembler 등록은 App 진입점(`LivithApp`)에서 일괄 수행한다.

### 네트워크
- 각 도메인별 API 네임스페이스를 정의한다 (예: `HomeAPI`).
- API 요청 정의는 `*API` 네임스페이스의 static func로 `NetworkEndpoint`를 생성한다.

### 비동기 작업 관리
- Store 내부에서 `CancelID` enum으로 Task를 식별한다.
- 동일 작업 재요청 시 이전 Task를 취소한 뒤 새 Task를 생성한다.

## Don't
- Domain 레이어는 UIKit·SwiftUI 같은 UI 프레임워크, 네트워크 구현, 서드파티 라이브러리에 의존하지 않는다.
- Data 레이어에서 Presentation 레이어를 참조하지 않는다.
- View에서 Repository를 직접 호출하지 않는다 (Store를 거친다).
- View에서 State를 직접 변경하지 않는다 (Intent를 통해서만 변경한다).
- Store 외부에서 `state` 프로퍼티에 직접 값을 할당하지 않는다.
- DTO를 Domain 레이어나 Presentation 레이어에 노출하지 않는다.
- Router 없이 View에서 직접 `NavigationStack`을 생성하지 않는다.
- 화면 Feature 간 직접 의존은 Coordinator의 자식 화면 연결에 한정한다. 화면 간 상태나 로직 공유에는 공용 기능 타깃을 사용한다.

## Exception
- [#330 공연 요청 파일럿](https://github.com/mediunn/Livith-iOS/issues/330)은 App에서 Repository를 조회하고 Home의 Environment를 거쳐 화면 모델에 생성자로 전달한다. 이 화면은 `@MainActor @Observable` ViewModel에 초안과 제출 상태를 두고, 제출은 중복 호출을 차단하는 메서드로 처리한다. View는 입력 바인딩과 표시 상태, 외부 콜백을 맡는다.
- [#337 관심 콘서트 목록](https://github.com/mediunn/Livith-iOS/issues/337)도 같은 DI 경로를 사용한다. 화면이 소유한 Observable ViewModel에서 정렬, 페이지 조회와 요청 취소를 관리한다.
- [#339 관심 콘서트 설정](https://github.com/mediunn/Livith-iOS/issues/339)은 같은 경로로 세 Repository를 주입하고 화면별 Observable ViewModel이 검색·선택·저장을 관리한다.
- DesignSystem 모듈은 레이어 구조와 무관하게 Presentation 레이어에서 자유롭게 사용한다.
- Core 모듈은 모든 레이어에서 참조할 수 있다.
- 단순 데이터 표시만 하는 View는 Store 없이 직접 데이터를 받을 수 있다.

## Checklist
- 새 모듈의 의존 방향이 Presentation → Domain ← Data를 따르는가
- Domain 레이어에 UI 프레임워크, 네트워크 구현, 서드파티 라이브러리 의존이 없는가
- Repository 프로토콜이 Domain에, 구현체가 Data에 위치하는가
- Store가 send → State 변경 흐름을 따르는가
- DTO가 Domain/Presentation에 노출되지 않았는가
- 새 Data 모듈에 전담 Assembler가 있는가
- 화면 전환이 Router + NavigationStack을 통해 이루어지는가
- 자식 Feature 진입 시 단일 NavigationStack 정책을 지키는가 (Router 없이 view-only CoordinatorView 사용)
