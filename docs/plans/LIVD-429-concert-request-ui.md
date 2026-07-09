# LIVD-429 공연 요청(FR-06) UI 구현

## 배경
- Figma `라이빗 디자인 사본` > `7차 기획 + 디자인 명세` > `FR-06_정보 요청`에 공연 요청 화면이 정의되어 있다.
- 이 화면은 Share Extension 플로우(FR-04 매칭 성공 → FR-05 매칭 실패 → FR-06 공연 요청)의 일부이며, 탭 Feature(Home/Search/User) 소속이 아니다.
- FR-04/05도 같은 플로우에서 구현할 예정이므로, 이번 이슈에서 `ShareFeature` 모듈을 신설하고 FR-06 UI만 먼저 구현한다.
- 현재 코드베이스에는 Share Extension 타깃·공연 요청 관련 구현이 없다.

## 목표
- `ShareFeature` 모듈을 신설하고, FR-06 공연 요청 **단일 화면**의 UI 상태(빈 폼 / 입력 / 바텀시트 / 취소 모달 / 실패 토스트)를 SwiftUI로 구현한다.
- `#Preview`로 상태별 UI를 확인할 수 있다.
- API·Store·Repository·성공 후 홈 토스트(`1:1910`)·앱/익스텐션 진입점 연결은 이번 이슈 범위 밖이다.

## 작업 항목

### 1. `ShareFeature` 모듈 신설
- [ ] Tuist 모듈 등록 (Workspace는 `Projects/**`라 별도 변경 불필요)
  - `ProjectID.share = "ShareFeature"` (`Module+ProjectID.swift`)
  - `ShareModule.shareFeature = "ShareFeature"` (`Module+Constant.swift`)
  - `TargetDependency.share(_:)` (`TargetDependency+Extension.swift`)
  - `TargetID`에 `case share(ShareModule)` 추가, `name` / `sourcesPath`(`["Sources/**"]`) / `bundleID` switch 분기 (`Module+TargetID.swift`)
- [ ] `Projects/ShareFeature/Project.swift` 생성
  - product: `.framework`
  - 의존성(이번 이슈): `LivithDesignSystem`만 (UI-only)
  - Domain / DI / Coordinator는 FR-04/05·API 연동 시점에 추가
- [ ] 폴더 골격 생성
  ```
  Projects/ShareFeature/
    Project.swift
    Sources/
      ConcertRequest/
        ConcertRequestView.swift
        Components/
          InterestConcertBottomSheet.swift
  ```
- [ ] `tuist generate` 실행

### 2. `ConcertRequestView` 구현 (단일 화면 + 상태)
- [ ] `ConcertRequestView` 신설
  - 헤더: `LivithNavigationView(.back(...))` + 타이틀 `공연 요청`
  - 안내 문구: `필요한 공연 정보를 요청하면 / 빠르게 등록까지 도와드려요`
  - 서브 문구: `지난 공연은 관심 콘서트에 추가할 수 없어요`
  - 필드
    - 공연 명(필수, max 50자, `n/50` 카운터) — `LivithTextField` `.text(maxLength: 50)`, placeholder `공연 명을 입력해주세요`
    - URL(선택, **글자수 제한 없음**, 카운터 없음) — `LivithTextField`는 `maxLength` 필수라 **커스텀 단일라인 필드** (ShareFeature 내부). placeholder `공연 정보를 확인할 수 있는 URL을 추가해주세요`
    - 추가 작성(선택, 멀티라인, **글자수 제한 없음**, 카운터 없음) — **커스텀 멀티라인 필드**. placeholder `아티스트 명이나 공연 일자 적어주면 더 빠르게 등록되어요!`
  - 하단 고정 `요청하기` 버튼 — `LivithButton`
    - 활성 조건: `concertName.trimmingCharacters(in: .whitespacesAndNewlines)`가 비어 있지 않을 때
- [ ] `@State`로 UI 상태 관리 (Store 없음)
  - `concertName`, `url`, `additionalNote`
  - `isBottomSheetPresented`
  - `isCancelModalPresented`
  - `showFailureToast`
- [ ] dirty / 작성 있음 판정 (공백만은 작성 없음)
  ```
  hasInput =
    !concertName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    || !url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    || !additionalNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  ```
- [ ] 인터랙션
  - 공연명(trim 후 non-empty) → 요청하기 활성화
  - 요청하기 탭 → 관심 콘서트 바텀시트 표시
  - 뒤로가기(`!hasInput`) → `onDismiss()`
  - 뒤로가기(`hasInput`) → 취소 확인 모달
  - 바텀시트 `괜찮아요` / `등록할래요` → **동일 동작**: 시트 dismiss + **실패 토스트(08) 표시** (UI-only 스텁)
- [ ] 진입 인터페이스는 closure 기반 (`NicknameEditView`의 **closure 인터페이스만** 참고, Store 패턴은 따르지 않음)
  - `onDismiss: () -> Void`
  - (선택) `onRequest: (concertName:url:note:registerInterest:) -> Void` — 후속 API용 스텁. 이번엔 바텀시트 버튼이 토스트를 띄우는 것이 완료 조건

### 3. 관심 콘서트 등록 바텀시트
- [ ] `InterestConcertBottomSheet` 컴포넌트
  - Figma `1:1729` 기준
  - 타이틀: `콘서트가 등록되면 / 관심 콘서트로 자동 등록할까요?`
  - 설명: `관심 콘서트로 등록하면 예매 알림, / 콘서트 정보 업데이트 소식을 빠르게 받아볼 수 있어요!`
  - 버튼: `괜찮아요`(secondary) / `등록할래요`(primary)
  - 제시는 `.livithSheet(isPresented:detents:)` 사용 (커스텀 dim overlay 직접 구현하지 않음)
  - detent는 Figma `1:1729` 기준으로 맞추고, 구현 시 측정 후 고정

### 4. 취소 확인 모달 · 실패 토스트
- [ ] 취소 모달 — `.crossDissolve` + `LivithDangerModal` 재사용
  - 메시지: `공연 요청을 그만 두시나요?\n언제든 다시 지정할 수 있어요.`
  - confirm: `지금은 그만할래요` → `onDismiss`
  - cancel: `잘못 눌렀어요` → 모달 닫기
- [ ] 실패 토스트 — `.livithToast` / `LivithToast` 재사용
  - 메시지: `요청 중 오류가 발생했어요\n다시 시도해주세요`
  - 바텀시트 버튼 탭 시 `showFailureToast = true`로 연결
  - Preview에서 `.livithToast`가 `UIWindowScene` 부재로 실패하면 **완료를 막지 않고**, 사용자에게 알린 뒤 해당 Preview 검증만 스킵

### 5. Preview
- [ ] `#Preview`로 주요 상태 확인
  - 빈 폼 (요청하기 비활성)
  - 공연명 입력 (요청하기 활성)
  - 바텀시트 표시
  - 취소 모달 표시
  - 실패 토스트 표시 (안 되면 스킵 + 사용자 알림)

### 6. 검증
- [ ] `tuist generate`
- [ ] XcodeBuildMCP로 `ShareFeature` 빌드 (시뮬레이터: **iPhone 17**)
  - `session_show_defaults`로 scheme/시뮬레이터 확인 후, 필요 시 scheme=`ShareFeature`, simulator=`iPhone 17`로 설정
  - `build_sim`으로 컴파일 검증

## 영향 범위
- **신규**
  - `Projects/ShareFeature/` (모듈 전체)
  - Tuist: `Module+ProjectID`, `Module+Constant`, `Module+TargetID`(`TargetID.case share` 포함), `TargetDependency+Extension`
- **재사용 (변경 최소화)**
  - `LivithDesignSystem`: `LivithButton`, `LivithTextField`(공연명만), `LivithNavigationView`, `LivithDangerModal`, `LivithToast`, `.livithSheet`, `.crossDissolve`
- **미포함**
  - `App` 의존성 연결 / Share Extension 타깃
  - FR-04 / FR-05 화면
  - Domain / Data / Store / API
  - 성공 후 홈 + 토스트 (`1:1910`)
  - 앱 네비게이션 진입점
  - DesignSystem `LivithTextField` API 확장 (제한 없음 타입 추가)

## 기능 명세 (FR-06)

Figma Description (`1:1431`, `1:1457`) 기준. UI-only 범위에서 **구현 / 스텁 / 제외**를 고정한다.

| # | 명세 | 이번 이슈 | UI 동작 |
|---|------|-----------|---------|
| 1 | **뒤로가기 (`<`)** — 작성 사항이 없으면 이전 화면으로 이동. 진입 경로별 분기: 매칭 (부분)성공>`직접 찾아볼게요` → 매칭 확인 페이지 / 매칭 실패 or 검색 엠티뷰 → 홈. 작성 사항이 1개라도 있으면 취소 확인 팝업(02) 등장 | **스텁** | `!hasInput` → `onDismiss()`. `hasInput` → 취소 모달. **공백만은 작성 없음**. 진입 경로별 실제 네비게이션 분기는 후속 |
| 2 | **취소 확인 팝업** — `지금은 그만할래요` → 홈 이동 / `잘못 눌렀어요` → 팝업 닫기 | **구현** | `.crossDissolve` + `LivithDangerModal`. confirm → `onDismiss()`, cancel → 모달 닫기 |
| 3 | **공연 명** — 필수, 제한 50자. 입력 필드 클릭 시 키보드, 작성 시 우측 글자 수 카운트 (`n/50`) | **구현** | `LivithTextField(.text(maxLength: 50))` + `n/50`. (명세 `n/20`과 화면 `50/50` 혼재 → **화면 기준 50자**) |
| 4 | **URL** — 선택, 글자수 제한 없음. 입력 필드 클릭 시 키보드 | **구현** | 커스텀 단일라인. 제한·카운터 없음 |
| 5 | **추가 작성** — 선택, 글자수 제한 없음. 입력 필드 클릭 시 키보드 | **구현** | 커스텀 멀티라인. 제한·카운터 없음 |
| 6 | **요청하기 버튼** — 필수(공연 명) 입력 시 활성화. 클릭 시 관심 콘서트 등록 선택 바텀시트(07) 등장 | **구현** | 공연명 trim 후 non-empty일 때 enabled. 탭 → 바텀시트 |
| 7 | **관심 콘서트 등록 바텀시트** — `등록할래요` 선택 시 추후 관심 콘서트 자동 추가. `괜찮아요` / `등록할래요` 클릭 시 동작 동일. 실패 → 현 페이지 유지 + 실패 토스트(08). 성공 → 홈 + 성공 토스트(09) + 디스코드 | **부분 구현** | `.livithSheet` + UI. 두 버튼 동일: dismiss + **실패 토스트(08)**. 성공·디스코드 **제외** |
| 8 | **공연 요청 실패 토스트** — `요청 중 오류가 발생했어요 / 다시 시도해주세요` | **구현** | 바텀시트 버튼에서 트리거. Preview 실패 시 스킵 + 사용자 알림 |
| 9 | **공연 요청 성공 토스트** — 홈 이동 후 `정보가 요청되었어요` (`1:1910`) | **제외** | 홈 화면 연출·성공 플로우는 이번 이슈 밖 |

### Figma 화면 매핑

| node-id | 의미 | 구현 |
|---------|------|------|
| `1:1676` | 빈 폼, 버튼 비활성 | `ConcertRequestView` 기본 상태 |
| `1:1649` | 공연명 입력·포커스 | 동일 View 입력 상태 |
| `1:1703` | URL·추가작성 상태 | 동일 View 입력 상태 |
| `1:1729` | 바텀시트 오버레이 (#7) | `InterestConcertBottomSheet` + `.livithSheet` |
| `1:3437` | 이탈 확인 모달 (#2) | `LivithDangerModal` |
| `1:1766` | 실패 토스트 (#8) | `LivithToast` |
| `1:1910` | 홈 + 성공 토스트 (#9) | **제외** |
| `1:1431` / `1:1457` | Description (명세 1~7) | 구현 참고용 (UI 아님) |
| `1:1351`, `1:3455`~`1:3471` | 섹션 타이틀·번호 뱃지 | 구현 불필요 |

파일: `https://www.figma.com/design/G53QwXoxT96gB68dO7vRZi` (라이빗 디자인 사본)

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 모듈 위치 | Shared/ConcertRequestFeature vs ShareFeature | **ShareFeature** | FR-04/05/06이 하나의 Share Extension 플로우. 익스텐션 타깃이 모듈 하나만 의존하면 됨 |
| 이번 이슈 범위 | FR-06 UI만 vs FR-04~06 전부 | **FR-06 UI만** | LIVD-429 목표. 모듈 골격만 FR-04/05 자리를 열어 둠 |
| 상태 관리 | Store(MVI) vs View `@State` | **`@State`** | UI-only. Store/API 없음. **TDD 예외**: 상태 변경 도메인 로직 없는 순수 UI 배선. 예외 대상 `ConcertRequestView` 인터랙션 |
| 네비게이션 | ShareRouter 신설 vs closure | **closure** | 진입점 미연결. NicknameEdit의 closure 인터페이스만 참고. Router는 FR-04/05 연결 시 추가 |
| URL·추가작성 필드 | LivithTextField 우회 vs 커스텀 | **커스텀** | 글자수 제한 없음. `LivithTextField`는 `maxLength` 필수·`.text`는 카운터 표시 |
| 작성 있음(dirty) | 원문 empty vs trim | **trim 후 non-empty** | 공백만은 작성 없음·버튼 비활성과 동일 기준 |
| 바텀시트 제시 | 커스텀 overlay vs `.livithSheet` | **`.livithSheet`** | DesignSystem 표준 |
| 바텀시트 버튼 스텁 | dismiss만 vs 실패 토스트 | **dismiss + 실패 토스트(08)** | 사용자 확정. UI-only에서 실패 경로를 Preview로 확인 |
| 성공 홈 토스트 | 포함 vs 제외 | **제외** (`1:1910`, 명세 #9) | 사용자 확정 |
| 실패 토스트 Preview | 필수 vs 실패 시 스킵 | **시도 후 실패 시 스킵 + 사용자 알림** | `.livithToast`는 `UIWindowScene` 의존. Preview 한계 허용 |
| 완료 확인 | Preview vs 앱 임시 진입점 | **`#Preview`** | UI-only + 진입점 미연결 |

## 주의 사항
- Feature 모듈 간 직접 의존 금지. `ShareFeature` → Home/Search 의존을 만들지 않는다.
- DesignSystem 컴포넌트를 우선 재사용한다. URL·추가작성만 제한 없음 요구로 커스텀 필드를 둔다. DesignSystem API 확장은 이번 이슈 밖.
- 공연명 제한은 명세에 `50자`와 `n/20`이 혼재한다. Figma 화면 카운터(`50/50`)를 우선하고 **max 50자**로 구현한다.
- `hasInput` / 요청하기 활성 모두 **trim 후** 판정한다. 공백만 입력은 작성 없음으로 본다.
- 바텀시트 두 버튼은 동일하게 실패 토스트를 띄운다. 성공 플로우는 구현하지 않는다.
- 이번 이슈에서 App에 `ShareFeature`를 연결하지 않는다. Preview로만 검증한다.
- 실패 토스트 Preview가 안 되면 완료를 막지 말고 사용자에게 알린다.
- 작업 중 빌드 실패·피드백·접근 변경 시 `docs/troubleshooting/LIVD-429-concert-request-ui.md`에 즉시 기록한다.

## 검증 방법
1. `tuist generate`
2. XcodeBuildMCP `build_sim` — scheme `ShareFeature`, simulator **iPhone 17**
3. Xcode Preview에서 아래 상태 육안 확인
   - [ ] 빈 폼 + 요청하기 비활성
   - [ ] 공연명 입력 + 요청하기 활성 + 글자 수
   - [ ] 공백만 입력 시 요청하기 비활성 / 뒤로가기 시 모달 없음
   - [ ] 바텀시트 → 괜찮아요/등록할래요 → 실패 토스트
   - [ ] 취소 모달
   - [ ] 실패 토스트 (Preview 실패 시 스킵 + 사용자 알림)
