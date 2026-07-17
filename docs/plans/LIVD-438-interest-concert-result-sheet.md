# LIVD-438 관심 콘서트 결과 알림 시트 (FR-06)

## 배경
- 기존에는 관심 콘서트 자동 정리 결과를 **토스트**로 안내했다 (`interestToastMessage` + `fetchInterestConcertCleanupPolicy`).
- 변경된 기획(FR-06)은 홈 최초 진입 시 정리·요청 결과를 **시스템 시트**로 보여 준다.
- Figma: [FR-06 섹션](https://www.figma.com/design/G53QwXoxT96gB68dO7vRZi/?node-id=15-1954), [시트 화면 예](https://www.figma.com/design/G53QwXoxT96gB68dO7vRZi/?node-id=15-4474)
- 세그먼트·View 분리·동시성 작업은 `docs/plans/LIVD-438-home-segment-concurrency.md`에서 진행 중/완료. **본 문서는 그와 별도**이며, 브랜치 `feat/LIVD-438-home-ui`를 유지한다.

## 목표
- 홈 섹션 로드 성공 후, 기존 interest toast 대신 **FR-06 관심 콘서트 소식 시트**를 띄운다.
- 시트 UI는 Figma 기준 **자동 정리 + 요청한 공연(추가 완료/실패)** 전체를 포함한다.
- 표시 여부는 기존 toast API(`needsToShow` / policy ≠ none)로 판단하고, **시트 본문 데이터는 stub**이다.
- dismiss(확인 또는 스와이프) 시 `markInterestConcertToastShown`을 호출한다.
- 기존 interest toast UI·상태를 제거(또는 시트로 대체)하고, Store 테스트로 노출/닫기/mark 타이밍을 검증한다.

## 작업 항목

### 1. 도메인/표시 모델 (stub)
- [x] 시트에 필요한 표시용 모델 정의 (자동 정리 카드, 요청 결과 카드, 실패 사유 카피 등)
- [x] stub 팩토리/샘플 데이터로 Figma의 자동 정리·요청 완료·요청 실패 섹션을 채울 수 있게 한다
- [x] API/Repository 계약 확장은 **범위 밖** (기존 GET/PATCH toast 엔드포인트만 게이트·mark에 사용)

### 2. HomeStore — toast → 시트 전환
- [x] `interestToastMessage` 기반 토스트 흐름을 시트 표시 상태(`shouldShowInterestResultSheet` 등)로 교체
- [x] 섹션 로드 성공 후 기존처럼 cleanup policy를 fetch
  - `needsToShow` / policy ≠ `.none` → 시트 present + stub 콘텐츠 세팅
  - 불필요하면 present 안 함
- [x] dismiss Intent에서 시트 닫기 + `markInterestConcertToastShown` 호출
- [x] 기존 에러 토스트와 충돌 시 시트 결과 discard 정책은 현 toast와 동일하게 유지(에러 있으면 관심 안내 미노출)
- [x] TDD: 노출 조건, 섹션 실패 시 미조회, dismiss 시 mark, fetch 실패 흡수 등 `HomeStoreTests` 갱신

### 3. Home UI — 시스템 시트
- [x] DesignSystem `livithSheet`(또는 동등 `.sheet` + detents)로 시트 프레젠테이션
- [x] `InterestConcertResultSheetView`(가칭) — 타이틀, 자동 정리 섹션, 요청한 공연 섹션, 확인 버튼
- [x] 「확인하기」「재요청」은 탭 가능 UI만, 네비게이션은 no-op
- [x] 「확인」및 시트 dismiss → store dismiss Intent
- [x] `HomeView`의 interest success toast UI 제거

### 4. 검증
- [x] XcodeBuildMCP로 `HomeStoreTests` 통과
- [ ] (선택) 시뮬에서 needsToShow 상황에서 시트·dismiss 확인

## 영향 범위
- `Projects/HomeFeature/Sources/Home/Store/HomeStore.swift` — toast → 시트 상태/Intent
- `Projects/HomeFeature/Sources/Home/View/HomeView.swift` — sheet 프레젠테이션, toast 제거
- `Projects/HomeFeature/Sources/Home/View/...` — 시트 콘텐츠 View (Interest 하위 또는 공통)
- `Projects/HomeFeature/Tests/HomeStoreTests.swift`
- Domain / Networking / UserRepository — **계약 변경 없음** (기존 toast API 재사용)
- DesignSystem — 기존 `livithSheet` 재사용 (필요 시 detent만 조정)

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 제품 범위 | 자동 정리만 vs Figma 전체 | **자동 정리 + 요청 완료/실패** | deep-interview A |
| 데이터 | 실API vs stub | **내용은 stub, 게이트/mark만 기존 toast API** | deep-interview B → A |
| 프레젠테이션 | 커스텀 오버레이 vs 시스템 sheet | **SwiftUI `.sheet` + detents (`livithSheet`)** | deep-interview A |
| 노출 시점 | homeAppear vs 섹션 성공 후 | **섹션 로드 성공 후** (기존 toast와 동일) | deep-interview A |
| 노출 게이트 | 로컬 플래그 vs 기존 API | **기존 `needsToShow` / policy ≠ none** | deep-interview A |
| mark 시점 | present 직후 vs dismiss | **dismiss 시 mark** | deep-interview A |
| 액션 | 실네비 vs UI only | **확인 dismiss만, 확인하기/재요청 no-op** | deep-interview A |
| 완료 기준 | UI+테스트 vs 수동 포함 | **UI + 타이밍 + toast 제거 + Store 테스트** | deep-interview A |
| 계획 문서 | 기존 concurrency 계획에 합침 vs 신규 | **신규 계획 문서** (이슈 번호 LIVD-438 공유) | 유저 지정 |
| 브랜치 | 신규 vs 유지 | **`feat/LIVD-438-home-ui` 유지** | 유저 지정 |

## 주의 사항
- 기존 toast 카피/상태(`interestToastMessage`)와 시트 상태를 이중으로 두지 않는다. 한 경로로 대체한다.
- stub 본문은 Figma 레이아웃 검증용이다. policy 종류별로 섹션을 다르게 줄지 여부는 구현 시 단순하게: **needsToShow면 전체 stub 샘플**을 기본으로 한다 (세분화는 실API 후속).
- Figma 스펙의 “미닫고 종료 시 재노출”은 **mark를 dismiss에만 호출**함으로써 기존 PATCH 의미와 맞춘다.
- 확인하기/재요청의 실제 라우팅·API 확장은 후속 티켓.
- TDD: Store 상태/Intent 변경은 실패 테스트 먼저 (`docs/rules/tdd.md`).
- 빌드·테스트는 **XcodeBuildMCP 우선**.
- 세그먼트/동시성 계획과 충돌 시: 본 계획이 toast→시트 부분을 **우선**한다. concurrency 계획의 “토스트(섹션 성공 후)”는 본 시트 흐름으로 해석한다.

## 검증 방법
- 단위 테스트 (`HomeStoreTests`)
  - 섹션 성공 + needsToShow → 시트 present, toast 메시지 미사용
  - needsToShow 아님 → 시트 미표시, mark 미호출
  - 섹션 실패 → policy fetch 미수행
  - dismiss → 시트 닫힘 + mark 1회
  - policy fetch 실패 → 초기 홈 실패로 전파하지 않음
  - errorMessage 존재 시 시트 결과 discard (기존 toast 정책 유지)
- 명령: XcodeBuildMCP `test_sim` (HomeFeature / HomeStoreTests)
- 수동(선택): needsToShow stub으로 시트 UI·dismiss 확인

## 비범위
- toast/결과 API 응답 확장 및 실데이터 매핑
- 확인하기 → 콘서트 상세, 재요청 → 콘서트 요청 페이지 실네비게이션
- 캘린더 날짜 상세 UI
- pull-to-refresh와의 시트 상호작용 개편
