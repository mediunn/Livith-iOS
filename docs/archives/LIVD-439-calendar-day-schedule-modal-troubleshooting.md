# LIVD-439 캘린더 일자 일정 모달 - 트러블슈팅

## 기록

### 2026-07-19 20:20 - 계획 리뷰 Request changes

**상황**
- 일자 일정 모달 계획 초안을 서브에이전트 스펙 리뷰에 제출.

**문제**
- Verdict: Request changes (Blocking 3).

**원인**
- Domain/HomeFeature 모델 위치 모순, 정렬 우선순위 미고정, 모달 엠티에 로드실패 Empty용 `containerRelativeFrame` 오적용.

**해결**
- 계획 문서에 HomeFeature-only 모델, 정렬 3단 우선순위, 모달 본문 중앙 엠티(relative 미사용), Binding/YAGNI/CTA `.update` 근거를 반영.

**교훈**
- presentation 모델은 영향 범위의 Domain 미변경과 일치시켜야 한다. Empty 레이아웃 규칙은 컨테이너 종류별로 구분한다.

---

### 2026-07-20 21:24 - PR #290 리뷰 피드백 반영

**상황**
- youz2me Approve 리뷰: List 네이밍, Store 테스트 2-space 들여쓰기, Sorter 파일 분리 요청.

**해결**
- `dayScheduleItems`/`items`/`listItems` → `dayScheduleItemList`/`itemList`
- `CalendarHomeStoreTests` 들여쓰기 4-space
- `CalendarDayScheduleSorter`를 `CalendarDayScheduleSorter.swift`로 분리

**교훈**
- 신규 컬렉션 API는 처음부터 `List` 접미사를 쓴다. 테스트 들여쓰기는 기존 Suite와 맞춘다.

---

### 2026-07-19 21:28 - 모달 높이 비율 적용

**상황**
- 모달 높이가 상하 padding 80 고정이라 Figma(540/812)보다 큼.

**해결**
- `containerRelativeFrame(.vertical)`로 화면 높이 × `(540/812)` 적용 후 세로 중앙 배치. (`GeometryReader` 불필요)

**교훈**
- Figma 고정 px 모달은 기기별 비율로 환산하는 편이 맞다. 비율 높이는 `containerRelativeFrame`이 더 단순하다.

---

### 2026-07-19 21:27 - Figma 여백·시간 바 보정

**상황**
- 디자인 대조 후 리스트 간격·시간 바 높이 불일치.

**해결**
- 아이템 간격 20 → 16, 시간 바 높이 14 → 12.

**교훈**
- 모달 높이는 현재 상하 padding 80 고정이라 Figma 540/812 비율과 다르다.

---

### 2026-07-19 21:21 - 카드 화살표·긴 텍스트 레이아웃

**상황**
- 일정 카드 chevron이 위로 붙어 있고, 긴 텍스트 줄바꿈이 잘 안 보임.

**문제**
- `HStack(alignment: .top)`으로 chevron이 상단 정렬.

**해결**
- `.center` 정렬 + 텍스트 `fixedSize(vertical: true)` + Figma에 맞춰 chevron 24·spacing 16·긴 subtitle fixture.

**교훈**
- Figma 카드 row는 `items-center`이므로 SwiftUI도 center alignment를 기본으로 둔다.

---

### 2026-07-19 21:18 - Pressed 상태 적용

**상황**
- Figma `15:1874`가 일정 카드 pressed/hover 상태.

**문제**
- 정리 과정에서 빈 Button을 제거해 press 피드백이 없었음.

**원인**
- pressed 배경 토큰을 확인하지 않은 채 plain View만 유지.

**해결**
- Figma: default `Black80` → pressed `Black100` (`#14171b`).
- 활성 카드만 `CalendarDayScheduleItemButtonStyle`로 배경 전환. 취소 카드는 탭 불가 유지.

**교훈**
- press 상태는 plain Button이 아니라 ButtonStyle + 토큰 대비로 구현한다.

---

### 2026-07-19 21:13 - 불필요 코드 정리

**상황**
- 구현 스펙 Pass 후 불필요 코드 점검.

**문제**
- 활성 카드에 빈 `Button(action: {})`, 항상 빈 `emptyItems` fixture, Release에도 포함되는 mock fixture.

**원인**
- pressed 피드백·호출부 가독성을 위해 넣었으나 실질 이득이 없음.

**해결**
- Row는 content + 취소 opacity만 유지. `emptyItems` 제거 후 `[]` 사용. Fixture를 `#if DEBUG`로 감쌈.

**교훈**
- 네비 없는 탭 UI·항상 빈 상수·DEBUG 전용 mock은 먼저 필요 여부부터 본다.

---

### 2026-07-19 20:26 - 새로고침 테스트 기대값 오류

**상황**
- Store 모달 Intent red 검증 중 `새로고침_시_필터_선택_상태는_유지되어야_한다`도 실패.

**문제**
- Given은 `performanceDateTapped` + `myConcertsTapped`인데 Then이 `!isTicketingDateSelected` / `isPerformanceDateSelected`를 기대.

**원인**
- 공연일 off 후 예매일은 여전히 on이어야 하는데 기대값이 반대였음.

**해결**
- Then을 `isTicketingDateSelected == true`, `isPerformanceDateSelected == false`, `concertScope == .my`로 수정.

**교훈**
- 필터 토글 테스트의 Given Intent와 Then 상태를 짝지어 확인한다.
