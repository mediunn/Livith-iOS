# 관심 콘서트 설정 화면 UI 초안 정리

## 목적
- 유저가 관심 콘서트를 설정하기 위한 새 UI 초안을 정리한다.
- 현재 구현과 별개로 Draft UI를 빠르게 확인할 수 있는 임시 구현 방향을 합의한다.
- 비즈니스 로직과 UI 구현 범위를 분리해 이후 연동 비용을 낮춘다.

## 배경
- 현재 브랜치에서 구현하려는 대상은 관심 콘서트를 설정하는 그리드 뷰 화면이다.
- 기존 구현은 `InterestConcertSearchView` 중심으로 구성되어 있으며, 검색/추천 검색어/단일 선택/제출/완료 화면 이동이 하나의 흐름으로 묶여 있다.
- 변경된 디자인 명세는 기존 화면보다 단순한 구조를 가지며, 추천 검색어 UI가 보이지 않는다.
- 기획 의도는 장기적으로 무제한 관심 콘서트 저장이지만, 현재 작업 범위는 실제 저장 로직이 아니라 UI 초안 구현에 한정한다.

## 현재 구현 구조

### 기존 화면
- `Projects/HomeFeature/Sources/Interest/View/InterestConcertSearchView.swift`
  - 상단 내비게이션
  - 검색창
  - 상태별 콘텐츠 전환
    - `.initial` -> `ConcertGridView`
    - `.recommendingKeywords` -> `RecommendedKeywordListView`
    - `.showingSearchResults` -> `SearchResultGridView`
  - 하단 `설정하기` 버튼
- `Projects/HomeFeature/Sources/Interest/Store/InterestConcertSearchStore.swift`
  - 콘서트 목록/검색 결과/추천 검색어 fetch
  - 단일 선택 상태 관리
  - 제출 및 완료 화면 이동 연계

### 현재 제약
- 도메인/서버/홈 화면은 모두 단일 관심 콘서트 모델을 전제로 동작한다.
- 예시:
  - `UserRepository.updateInterestedConcert(_ concertID: Int)`
  - `UserRepository.fetchInterestedConcert() -> Concert?`
  - `HomeStore`와 `ConcertStore`도 단일 관심 콘서트 기준

## 디자인 시안 해석
시안 확인 파일:
- `tmp/01_basic.png`
- `tmp/02_search.png`
- `tmp/03_search.png`
- `tmp/04_select.png`
- `tmp/05_hideKeyboard.png`

### 화면 구조
- 상단 타이틀은 mode에 따라 달라진다.
  - `initialSetup` -> `공연 설정`
  - `update` -> `공연 변경`
- 검색창 아래에 안내 문구가 노출된다.
  - `소식을 받을 콘서트를 선택해 주세요`
- 우측에는 현재 선택 개수가 표시된다.
  - 예: `1개 선택`, `2개 선택`
- 본문은 3열 포스터 그리드다.
- 하단에는 선택된 콘서트 요약 칩과 CTA 버튼이 배치된다.
  - `initialSetup` -> `설정하기`
  - `update` -> `변경하기`

### 검색 동작
- 검색은 별도 추천 검색어 화면 없이 같은 그리드 영역 안에서 동작한다.
- 검색창이 포커스되면 상단 안내 문구를 노출하지 않는다.
- 검색어를 입력하면 그리드 내용물만 바뀐다.
- 검색 필터링 대상은 `title`만 사용한다.
- 검색어는 입력마다 양 끝 공백을 trim해서 반영한다.
- 검색 결과 상태는 유지되며, `searchText`가 비었을 때만 전체 목록 그리드로 복귀한다.
- 검색어 클리어 시에는 검색어를 비우고 전체 목록을 복구하며 포커스는 유지한다.
- empty state 문구는 `검색 결과가 없어요`로 통일한다.
- 기존 `검색 결과 n건` 헤더는 새 시안에 없다.

### 선택 상태
- 카드 선택 시 포스터 테두리가 노란색으로 바뀐다.
- `D-day` 칩도 노란색 선택 상태를 사용한다.
- 키보드가 내려간 상태에서는 하단 선택 칩과 버튼을 확인할 수 있다.
- 선택 칩은 선택 순서대로 노출한다.

## 현재까지 확정된 결정사항

### 1. 작업 범위
- 이번 단계는 실제 서비스 화면 연결이 아닌 Draft UI 구현을 우선한다.
- 기존 `InterestConcertSearchView`와 `InterestConcertSearchStore`는 바로 수정하지 않는다.
- 새 UI는 임시 화면으로 별도 구현한다.

### 2. 비즈니스 로직 분리
- 장기적으로는 무제한 선택/저장이 기획 의도다.
- 하지만 현재 도메인과 서버는 단일 관심 콘서트 구조다.
- 따라서 이번 단계에서는 복수 선택 UI만 만든다.
- 실제 저장 로직, submit 연동, 완료 화면 이동은 연결하지 않는다.

### 3. 설정 버튼 동작
- CTA 버튼은 mode에 따라 문구가 달라진다.
  - `initialSetup` -> `설정하기`
  - `update` -> `변경하기`
- 현재 단계에서는 UI 확인용이며, 활성/비활성만 바뀌고 탭해도 아무 동작을 하지 않는다.

### 4. 추천 검색어
- 이번 디자인에서는 추천 검색어 UI를 노출하지 않는다.
- 다만 기능 자체는 추후 다시 생길 여지가 있으므로, 현재 논의에서는 기존 구현을 즉시 제거하지 않는다.

### 5. 그리드 구조
- 상태마다 그리드 뷰를 교체하기보다, 하나의 공통 그리드 뷰에 표시 데이터만 바꾸는 방향이 적합하다.
- 이유:
  - 기본 목록과 검색 결과가 같은 시각 구조를 가진다.
  - 검색 결과 헤더가 사라졌다.
  - 선택 상태 표현을 한 곳에서 관리하기 쉽다.

### 6. 선택 칩 정책
- 하단 선택 칩은 한 줄 가로 스크롤이다.
- 칩에 표시되는 콘서트명은 최대 20자까지 노출한다.
- 20자를 초과하면 뒤를 `...`으로 생략한다.

### 7. Draft MVI Store
- UI 상태 변화를 확인하기 위한 정말 최소한의 Draft용 MVI store를 둔다.
- 이 store는 실제 비즈니스 로직이나 네트워크 연동을 담당하지 않는다.
- 역할은 Draft UI 상태 전이 확인에 한정한다.
- Draft store는 iOS 17 Observation 프레임워크 기반의 `@Observable`을 사용한다.
- 따라서 `ObservableObject`와 `@Published` 기반으로 구현하지 않는다.
- 선택 가능한 전체 콘서트 목록은 store 내부의 mock 데이터로만 관리한다.
- `update` 모드에서 비교 기준이 되는 유저의 기존 관심 콘서트 목록은 외부에서 주입받는다.
- 파생 프로퍼티는 store가 아니라 state와 mode가 제공하는 방향을 사용한다.
- 권장 이름:
  - `InterestConcertSettingDraftStore`
  - `InterestConcertSettingDraftState`
  - `InterestConcertSettingDraftIntent`

## 네이밍 정리

### 화면 목적 기준 네이밍
- 이 화면의 본질은 `검색`이 아니라 `관심 콘서트 설정`이다.
- 따라서 최상위 화면 이름은 `Search`보다 `Setting`이 더 적절하다.

### 임시 UI 네이밍 방향
- 실제 화면과 아직 연결하지 않으므로 Draft 성격이 드러나는 이름을 사용한다.
- 권장 이름:
  - `InterestConcertSettingDraftView`
  - `InterestConcertSettingDraftStore`
  - `InterestConcertSelectionGridView`
  - `InterestConcertSelectionBottomBarView`
  - 필요 시 Draft 상태용 래퍼: `InterestConcertSettingDraftContainer`

### 컬렉션 네이밍 규칙
- 복수형을 단순히 `s`로 끝내지 않고 `List`를 사용한다.
- 예시:
  - `concertList`
  - `filteredConcertList`
  - `selectedConcertIDList`
  - `selectedConcertList`

## 파일 배치 방향

### 문서
- 현재 문서는 다음 경로에 둔다.
  - `docs/plans/interest-concert-setting-ui-draft.md`

### Swift UI 초안
- 임시 UI는 `Interest` 기능 내부의 draft 영역으로 둔다.
- 권장 경로:

```text
Projects/HomeFeature/Sources/Interest/Store/Draft/
  InterestConcertSettingDraftStore.swift

Projects/HomeFeature/Sources/Interest/View/Draft/
  InterestConcertSettingDraftView.swift
  Subview/
    InterestConcertSelectionGridView.swift
    InterestConcertSelectionBottomBarView.swift
```

### 배치 이유
- `Interest` 기능과 관련된 임시 UI이므로 같은 feature 아래에 두는 것이 자연스럽다.
- 별도 최상위 feature 디렉터리를 만들 정도의 독립 기능은 아니다.
- 나중에 실제 화면으로 승격할 때 이동 범위를 줄일 수 있다.

## Draft 우선 구현 원칙
- Draft 상태를 바로 확인할 수 있는 최소 MVI store를 우선한다.
- 검색어, 선택 개수, 키보드 포커스 상태는 Draft store를 통해 조작할 수 있도록 만든다.
- 화면은 외부 데이터 대신 입력값 기반으로 렌더링되도록 설계한다.
- store는 순수 상태 전이만 담당하고, repository 의존성은 두지 않는다.
- store 구현 방식은 `@Observable` 단일 store를 기준으로 한다.
- View는 이 Draft store를 관찰해 UI 상태 변화를 확인한다.
- 이 화면은 추후 `초기 설정`과 `기존 설정 변경`을 모두 수용할 수 있게 설계한다.
- 따라서 store는 화면 목적별로 분리하기보다, 공통 선택 UI store 하나를 두고 진입 맥락만 mode로 주입하는 방향을 우선한다.
- 현재 Draft 단계에서는 실제 조회 대신 store 내부 mock 데이터로만 화면을 구성한다.
- 외부에서 주입받는 값은 mode와 유저의 기존 관심 콘서트 목록으로 한정한다.
- store는 `state` 하나를 소유하고 `send(intent)`를 통해서만 상태를 변경한다.
- `mode`는 state가 소유하는 고정 문맥 값이며 `let`으로 둔다.

### Draft store가 다룰 상태
- `mode: InterestConcertSettingDraftMode`
- `concertList: [Concert]`
- `searchText: String`
- `isSearchFocused: Bool`
- `filteredConcertList: [Concert]`
- `initialUserInterestConcertIDList: [Int]`
- `selectedConcertIDList: [Int]`

### Draft store가 다룰 intent
- 검색어 변경
- 검색어 클리어
- 검색 포커스 변경
- 카드 선택 토글
- 선택 칩 제거

### Draft MVI 최소 스펙
- `InterestConcertSettingDraftStore`
  - `@Observable` 기반 단일 store
  - `state`를 보유하고 `send(_ intent: InterestConcertSettingDraftIntent)` 형태로 상태를 갱신
- `InterestConcertSettingDraftState`
  - `let mode: InterestConcertSettingDraftMode`
  - `concertList: [Concert]`
  - `filteredConcertList: [Concert]`
  - `searchText: String`
  - `isSearchFocused: Bool`
  - `initialUserInterestConcertIDList: [Int]`
  - `selectedConcertIDList: [Int]`
  - state가 제공하는 파생 프로퍼티
    - `selectedConcertCount`
    - `selectedConcertList`
    - `isCTAEnabled`
    - 필요 시 `isShowingEmptyState`
- `InterestConcertSettingDraftMode`
  - `case initialSetup`
  - `case update`
  - mode가 제공하는 파생 프로퍼티
    - `navigationTitle`
    - `ctaTitle`
  - navigation title
    - `initialSetup` -> `공연 설정`
    - `update` -> `공연 변경`
  - CTA title
    - `initialSetup` -> `설정하기`
    - `update` -> `변경하기`
- `InterestConcertSettingDraftIntent`
  - `case updateSearchText(String)`
  - `case clearSearchText`
  - `case setSearchFocused(Bool)`
  - `case toggleConcertSelection(Int)`
  - `case removeSelectedConcert(Int)`

### 상태 전이 기준
- `updateSearchText`는 입력값의 양 끝 공백을 trim한 뒤 `searchText`에 저장한다.
- `updateSearchText`는 `concertList`를 기준으로 `title`만 사용해 `filteredConcertList`를 로컬 필터링한다.
- `updateSearchText` 결과 `searchText`가 비면 `filteredConcertList`는 전체 `concertList`로 복구된다.
- `clearSearchText`는 `searchText`를 비우고 `filteredConcertList`를 전체 `concertList`로 복구하며, `isSearchFocused = true`를 유지한다.
- `setSearchFocused`는 상단 안내 문구 노출 여부를 제어하기 위한 UI 상태로 사용한다.
- `toggleConcertSelection`은 선택된 ID가 이미 있으면 제거하고, 없으면 `selectedConcertIDList` 마지막에 추가한다.
- `removeSelectedConcert`는 하단 선택 칩 제거 동작과 동일한 의미를 가진다.
- store 초기화 시 `concertList`와 `filteredConcertList`는 내부 mock 데이터로 세팅한다.
- store 초기화 시 `userInterestConcertList`를 받아 `initialUserInterestConcertIDList`로 변환한다.
- `selectedConcertIDList`의 초기값은 `initialUserInterestConcertIDList`와 동일하게 시작한다.

### CTA 활성화 기준
- `initialSetup` 모드에서는 `selectedConcertIDList`가 비어 있지 않으면 CTA를 활성화한다.
- `update` 모드에서는 `selectedConcertIDList`가 `initialUserInterestConcertIDList`와 다를 때만 CTA를 활성화한다.
- `update` 모드의 비교는 선택 순서가 아니라 선택된 콘서트 ID 구성 기준으로 판단한다.
- 따라서 항목이 없던 상태, 추가된 상태, 제거된 상태, 일부만 달라진 상태는 모두 활성화 조건에 해당한다.

### 초기 설정 / 변경 대응 기준
- `초기 설정`과 `기존 설정 변경`은 별도 store 두 개로 나누지 않는다.
- 두 흐름 모두 같은 선택 UI와 같은 상태 전이를 공유하기 때문이다.
- 차이는 진입 맥락, 외부에서 주입되는 기존 관심 콘서트 목록, 추후 submit 의미에 가깝다.
- 따라서 공통 selection store를 유지하고, `mode`와 `userInterestConcertList`를 외부에서 주입하는 구조가 적합하다.
- 실제 비즈니스 로직이 붙는 시점에는 Draft store와 별개로 상위 container/store를 두는 방향을 우선 검토한다.

### 외부 주입값
- `mode: InterestConcertSettingDraftMode`
- `userInterestConcertList: [Concert]`

## 이번 단계에서 구현하지 않는 것
- 실제 route 연결
- 기존 `InterestConcertSearchView` 교체
- 기존 `InterestConcertSearchStore` 수정
- 추천 검색어 제거 작업
- 실제 저장 API 호출
- 실제 API 조회
- 완료 화면 이동 연동
- 홈/상세/위젯과의 연결
- repository 의존 Draft store 추가

## 이후 연동 시 고려사항
- UI가 확정되면 그 다음 단계에서 연동 방식을 결정한다.
- 후보:
  - 기존 Store를 개편해서 연결
  - 새 Store를 만들어 UI에 주입
  - 어댑터 뷰를 통해 Draft UI와 실제 상태를 연결
- 복수 저장이 실제 기능으로 확정되면 도메인, 서버, 홈 화면, 상세 화면, 위젯까지 설계 범위가 확장된다.

## 다음 구현 단계 제안
1. `InterestConcertSettingDraftView`를 만든다.
2. `InterestConcertSettingDraftStore`를 만든다.
3. 기본 화면 레이아웃을 시안에 맞춘다.
4. 공통 그리드 뷰를 만든다.
5. 복수 선택 UI를 Draft store에 붙인다.
6. 하단 칩 한 줄 스크롤과 20자 말줄임 규칙을 구현한다.
7. Draft 상태를 여러 가지로 확인할 수 있게 시나리오를 추가한다.
   - 기본 상태
   - 검색 중
   - 검색 결과 1건
   - 선택 상태
   - 키보드 내린 후 하단 칩 표시 상태
