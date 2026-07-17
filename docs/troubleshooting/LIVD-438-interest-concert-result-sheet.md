# LIVD-438 관심 콘서트 결과 시트 트러블슈팅

## 2026-07-17 - 유저 피드백: 시트 폰트·글자색 Figma 정합

### 증상
- 타이틀/섹션 헤더 폰트 크기·색이 시안과 불일치

### 시도
- 타이틀: `headSemibold(22)` → `body1Semibold(18)` + white100
- 섹션 헤더: `body2Medium`+black50 → `body3Medium`+black5
- 자동정리 카드 타이틀-설명 간격 8 → 4
- 확인 버튼 하단 패딩 16 → 24
- 카드 본문/칩/액션은 기존 body3Semibold·body4Medium·caption1* 유지 (시안과 일치)

### 결과
- 수정 반영

### 학습
- FR-06 타이틀은 head가 아니라 Body1-sm(18 SemiBold)이다

---

## 2026-07-17 - 유저 피드백: 콘텐츠가 적을 때 시트 높이 적응

### 증상
- `.height(580)` 고정이면 카드가 적을 때 아래 여백이 과도함. Figma는 최대 580.

### 시도
- 스크롤 콘텐츠 높이를 PreferenceKey로 측정
- detent = `min(max(콘텐츠+버튼, 200), 580)`
- 스크롤 뷰포트는 max 시트의 남는 높이로 제한해 넘칠 때만 스크롤

### 결과
- 수정 반영. 앱에서 소수 케이스·전체 stub로 확인 필요

### 학습
- FR-06 580은 고정이 아니라 상한이다

---

## 2026-07-17 - 유저 피드백: Figma 전체 케이스를 데이터로 · 스크롤바 숨김

### 증상
- stub이 일부 케이스만 포함해 실패 사유·1건/다건 카피가 모델에 없음
- 시트 ScrollView 스크롤바가 보임

### 시도
- `AutoCleanupItem`(completed/canceled + count) / `RequestResultItem.Outcome`(added + failed 3종)으로 모델화하고 카피 생성
- stub에 전체 케이스 포함, 카피 단위 테스트 추가
- `.scrollIndicators(.hidden)` 적용

### 결과
- 수정 반영

### 학습
- FR-06 카피 규칙은 count·failure reason을 데이터로 두고 View는 표시만 해야 한다

---

## 2026-07-17 - 유저 피드백: detent large 제거 · 스크롤 불가 · 칩 시안 불일치

### 증상
- sheet detent에 `.large`가 있어 확장됨
- 시트 본문이 스크롤되지 않음
- 추가 완료/실패 칩이 Figma와 다름 (모서리·색)

### 시도
- detent를 `.height(580)`만 남김
- 루트/`ScrollView`에 `maxHeight: .infinity`로 시트 높이를 채우게 해 ScrollView가 남는 영역에서 스크롤되도록 수정
- 칩: capsule, 완료=`black100`+`black5`, 실패=`translation`+`black80`, `caption1Semibold`

### 결과
- 수정 반영. 앱에서 강제 시트로 재확인 필요

### 학습
- 고정 높이 sheet에서 ScrollView는 부모가 높이를 채워야 스크롤이 생긴다
- 실패 칩 배경은 caution이 아니라 lyrics `translation` 토큰이다

---

## 2026-07-17 - 유저 피드백: needsToShow 없이 시트 UI를 강제 확인

### 증상
- 실제 toast API가 needsToShow=false라 시뮬에서 시트를 확인할 수 없음

### 시도
- `HomeStore.forceInterestResultSheet = true`로 섹션 로드 후(및 재 interestAppear 시) stub 시트 강제 present
- 테스트 환경(`XCTestConfigurationFilePath`)에서는 강제 노출 비활성
- 강제 노출 중 dismiss 시 mark API 호출 생략

### 결과
- 앱 실행으로 UI 확인 가능. 확인 후 플래그를 `false`로 되돌려야 함

### 학습
- UI 검증용 강제 플래그는 테스트와 분리해야 정책 테스트를 깨지 않는다

---

## 2026-07-17 - TDD red 단독 검증을 생략하고 테스트 갱신 직후 Store 구현

### 증상
- toast → 시트 Intent/상태 교체로 기존 테스트 컴파일이 깨져, 최소 stub만으로 red를 따로 돌리기보다 테스트 교체와 Store 구현을 연속으로 진행함

### 시도
- 실패 기대 테스트를 먼저 작성·교체한 뒤 HomeStore/View를 구현
- XcodeBuildMCP `HomeStoreTests`로 green 검증

### 결과
- HomeStoreTests 41개 통과

### 학습
- 공개 표면 rename이 큰 경우, 컴파일용 최소 선언으로 red를 분리하는 편이 규칙 준수에 더 맞다

---
