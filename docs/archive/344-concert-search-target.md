# [#344] 세 화면의 공연 검색 로직 공통화

## 결과·범위

`Projects/Shared`에 `ConcertSearch` 프레임워크 타깃을 추가해 관심 콘서트 설정·변경, 인스타그램 수동 공연 검색, 일반 검색에 연결했다. `HomeFeature`와 `SearchFeature`가 각자 타깃에 의존하고, 일반 검색 화면은 `SearchStore`에서 `@MainActor @Observable` ViewModel로 전환했다. 일반 탐색, 인스타그램 매칭 후보 확인, 관심 콘서트 목록 전용 화면은 범위에서 제외했다. 기존 Domain Repository 계약과 API를 사용한다.

## 남긴 결정

- 각 화면 모델이 독립적인 검색 모델을 생성한다. 공통 모델은 확정된 조건과 커서를 함께 관리하고, 첫 페이지는 결과를 교체하며 다음 페이지는 같은 조건으로 이어 붙인다. 진행 중인 추가 페이지는 한 번만 요청한다. 이전 요청은 `Task`로 취소하고, 완료한 작업이 현재 작업일 때만 요청 상태를 정리한다. [상태 소유권 ADR 0002](../adr/0002-viewmodel-ownership.md)
- 두 Home 화면은 검색어 변경 즉시 이전 페이지를 무효화한다. 검색어를 지우면 기본 카탈로그와 커서를 복원하고 기존 선택은 유지한다. 기본 카탈로그, 공연 선택과 저장·등록, 화면 이동은 각 화면이 담당한다. 일반 검색은 새 입력이 조회되기 전까지 이전에 확정한 조건으로 페이지를 이어갈 수 있고, 입력을 지우면 현재 필터·정렬로 새 조회를 시작한다. 입력 후 300ms 대기와 일반 검색의 추가 페이지 500ms 대기는 화면에서 결정한다.
- 일반 검색은 검색 실패 시 표시 중인 결과를, 추가 페이지 실패 시 기존 커서도 유지한다. 두 Home 화면은 검색 실패 시 검색 결과와 검색 커서를 비우고 토스트를 띄운다. 기본 카탈로그 추가 페이지 실패 시에는 기존 카탈로그를 유지한다.

## 검증 결과

| 방법·명령 | 기대 신호 | 실제 결과 |
|---|---|---|
| 변경 전 `xcodebuild test` · iPhone 17, iOS 26.5 | Home 두 ViewModel 스위트와 기존 `SearchStoreTests` 동작 확인 | `4d302ccd`에서 Home 37건, Search 3건 통과. 매개변수 조합 포함 |
| 변경 후 `xcodebuild test` · `ConcertSearch`, `HomeFeature`, `SearchFeature` | 이전 응답 무시, 화면별 상태 격리, 페이지 중복 방지, 검색어 삭제와 실패 후 재시도 확인 | 공통 검색 4건, Home 37건, 일반 검색 4건으로 총 45건 통과. 매개변수 조합 포함 |
| `tuist generate --no-open`, `xcodebuild build -scheme Livith-iOS-Dev`, 시뮬레이터 실행 | 두 소비 모듈을 포함한 Dev 앱 조립·실행 | 프로젝트 생성과 Dev 빌드 성공. 시뮬레이터에서 로그인 화면 진입 확인 |
| 2026-11-29 사용자 실기기 조작 | 일반 검색, 관심 콘서트 설정·변경, 인스타그램 수동 공연 검색 확인 | 사용자가 세 화면 모두 문제없이 동작했다고 확인 |

## 교훈·규칙 반영

같은 검색어로 다시 요청할 때도 이전 요청이 새 로딩을 끄지 않도록, 완료한 `Task`와 현재 `Task`를 비교한다. 공유 범위는 조회·페이지네이션으로 제한하고, 각 화면의 시작 시점과 오류 정책을 유지한다. 상태와 작업의 소유권은 기존 ADR 기준을 적용했다.

## 추가 기록

**2026-11-29 · 검색 반환값과 Repository 주입 정리**

- `search`와 `loadNextPage`는 `Result<[Concert], SearchError>?`를 직접 반환한다. 취소되거나 교체된 요청과 실행할 페이지가 없는 호출은 `nil`을 반환한다. 일반 실패는 각 화면의 기존 오류 경로로 전달한다.
- `AppRootView`는 필수 Repository를 타입 기반 Environment로 주입한다. 홈과 일반 검색이 같은 `SearchDependencies.repository`를 사용하고, `HomeDependencies`는 카탈로그·관심 콘서트·공연 요청 Repository를 전달한다. 테스트는 Repository 대역을 ViewModel 생성자에 직접 전달한다. Environment 객체의 주입 누락은 런타임 오류다.
- iPhone 17, iOS 26.5에서 `ConcertSearch` 6건, `HomeFeature` 50건, `SearchFeature` 4건, `ShareFeature` 5건으로 총 65건 통과했다. `tuist generate --no-open`과 `xcodebuild build -scheme Livith-iOS-Dev`도 성공했다. 기존 실기기 확인은 최초 PR 변경 기준이며 이번 후속 변경은 실기기에서 다시 확인하지 않았다.

**2026-11-29 · 탐색 화면 이름과 중복 요청 테스트 정리**

- 탐색 탭의 진입은 `ExploreCoordinatorView`, 첫 화면은 `ExploreHomeView`, 검색창에서 진입하는 화면과 모델은 `ExploreSearchView`와 `ExploreSearchViewModel`로 명명했다. 공통 공연 조회·페이지네이션 모델은 `ConcertSearchViewModel`이다.
- 중복 페이지 요청 테스트에서 예상 밖의 Repository 호출은 즉시 실패를 기록한다. iPhone 17, iOS 26.5에서 `SearchFeature` 4건과 `ConcertSearch` 6건이 통과했고, Tuist 프로젝트 생성과 Dev 앱 빌드도 성공했다.

## 참조

- [GitHub 이슈 #344](https://github.com/mediunn/Livith-iOS/issues/344)
- 통합한 계획 `docs/plans/344-concert-search-target.md`
