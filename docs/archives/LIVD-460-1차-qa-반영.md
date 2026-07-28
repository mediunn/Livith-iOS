# LIVD-460 [Fix] 1차 QA 반영 (담당자 Youjin)

## 배경
- 7차 스프린트 iOS 1차 QA 시트에서 담당자가 Youjin으로 지정된 2건을 반영한다.
- 항목 2(P2): 인스타그램 추출 후 매칭 결과 화면의 콘서트 칩 D-day가 `daysLeft: 68`인데 `D-6868`로 표기됨(숫자 이중 표기).
- 항목 1(P4): 정보 요청(검색) 화면 UI가 FR-06 디자인 가이드와 일부 어긋남. 제보 메모: "UI 수정한 걸 몇 군데에 반영을 못해놓았다. 디자인 가이드 참고하여 수정 요청".

## 목표
- 인스타 매칭 콘서트 칩의 D-day가 `D-68`처럼 정상 표기된다.
- 정보 요청(검색) 화면(`InstagramManualSearchView`)이 FR-06 디자인 가이드 및 이미 반영된 참조 화면(`InterestConcertSettingView`)과 시각적으로 정합된다.

## 작업 항목
- [x] 항목 2 · 콘서트 칩 D-day 이중 표기 수정
  - 원인: `InstagramMatchConfirmView.matchedConcertCards`가 `.status(text:)`에 이미 포맷된 문자열(`ConcertDisplayHelper.statusBadge` → `"D-68"`)을 넘기면서 동시에 `remainDays: concert.daysLeft`(68)를 넘김. `LivithCard.badgeView`가 `remainDays != nil` 분기로 `LivithChip.dDay("D-68", remainDays: 68)`를 호출 → `"D-68" + "68" = "D-6868"`.
  - 다른 7개 호출부는 모두 `remainDays: nil` pass-through 분기를 사용해 정상.
  - 수정: `InstagramMatchConfirmView.swift`의 badge를 `remainDays: nil`로 변경(다른 호출부와 동일, `statusBadge`가 공연중/종료/D-day 상태를 모두 커버).
  - 재현 테스트: 뷰 배선 수정이라 순수 UI에 해당하나, 회귀 방지를 위해 `ConcertDisplayHelperTests`에 배지 문자열 계약(중복 없음) 가드 테스트를 검토한다. (아래 기술 결정 참고)
- [x] 항목 1 · 정보 요청 화면 툴팁 패딩 FR-06 정합 (스코프 확정: 툴팁 패딩만)
  - 대상: `InstagramManualSearchView`의 `reportTooltip` (매칭 실패 케이스 = context `.matchFailed`).
  - 사용자 확정: 화면 문구/버튼/그리드 등은 손대지 않고 **툴팁 버블 세로 여백만** FR-06 기준으로 맞춘다.
  - FR-06 툴팁 좌표(frame 135×37): 버블 `top-0`/`bottom-16.22%` → 높이 31pt. 현재 코드 `tooltipBubbleHeight = 21` → 세로 여백 협소.
  - 수정: `tooltipBubbleHeight` 21 → 31.
  - 화살표(현재 13×8 ≈ 디자인 14×8)와 버블 수평 패딩(15)은 이미 근접/동일하므로 미변경.

## 영향 범위
- `Projects/HomeFeature/Sources/InstagramMatch/View/InstagramMatchConfirmView.swift` (항목 2)
- `Projects/HomeFeature/Sources/InstagramMatch/View/InstagramManualSearchView.swift` (항목 1)
- `Projects/HomeFeature/Sources/InstagramMatch/Store/InstagramManualSearchStore.swift` (항목 1, guideTitle/context 관련 시 조정)
- `Projects/Shared/DisplaySupport/Tests/ConcertDisplayHelperTests.swift` (항목 2 회귀 테스트 검토)
- 디자인 시스템 컴포넌트(`LivithChip`, `LivithCard`)는 정상 동작하므로 미변경.

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 항목 2 수정 위치 | A: 호출부 `remainDays: nil` / B: `LivithChip.dDay` 시그니처 변경 | A | 버그는 호출부의 잘못된 인자 조합. B는 정상 동작하는 공유 컴포넌트를 건드려 회귀 위험 큼. A는 다른 7개 호출부와 동일 패턴. |
| 항목 2 TDD 적용 | A: 뷰 배선 수정=순수 UI 예외 / B: 배지 문자열 계약 테스트 추가 | A | 버그가 뷰 조합 텍스트에만 존재해 red-first 유닛 seam 없음(스냅샷/뷰 인스펙션 인프라 없음). `statusBadge`는 이미 정상 반환. `tdd.md` 순수 UI 예외 적용, 빌드+화면 확인으로 검증. |
| 항목 1 스코프 | A: 화면 전체 FR-06 정합 / B: 툴팁 패딩만 | B | 사용자 확정. 문구/버튼/그리드는 별개 인스타 플로우 semantics라 미변경, 툴팁 세로 여백만 조정. |

## 주의 사항
- `InstagramManualSearchView`와 `InterestConcertSettingView`는 유사하지만 별개 플로우(등록 vs 설정)로, 버튼/문구 의미가 다르다. 시각 정합만 맞추고 동작 semantics는 보존한다.
- 커밋 문서(본 계획서)에는 Figma/MCP 링크를 넣지 않고 FR 번호로만 참조한다.
- 작업 브랜치는 `develop`에서 분기한 `fix/LIVD-460-...`로 생성한다(현재 브랜치는 `feat/LIVD-459-cicd-pipeline`).

## 검증 방법
- 항목 2: 프로젝트 빌드 성공 + 인스타 매칭 결과 화면에서 칩이 `D-68`(정상)로 표기되는지 확인. 회귀 테스트 추가 시 해당 테스트 통과.
- 항목 1: 빌드 성공 + `InstagramManualSearchView` 프리뷰/실행 화면을 FR-06 및 `InterestConcertSettingView`와 대조해 정합 확인.
