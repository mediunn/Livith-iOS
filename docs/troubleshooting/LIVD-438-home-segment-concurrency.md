# LIVD-438 홈 세그먼트 / 동시성 트러블슈팅

## 2026-07-17 - 유저 피드백: HomeStore 상태 변경을 send로 집중

### 증상
- `perform*` / Task 본문에서 `state`를 직접 바꿔 MVI(`send` 단일 진입)와 어긋남

### 시도
- 로딩·초기 로드·토스트 예약 플래그 변경을 `send`의 Intent 분기로 이동
- `perform*`는 네트워크/Task만 수행하고 결과는 `._fetch*` Intent로만 반영

### 결과
- `HomeStore` 리팩터 반영. HomeStoreTests 36개 통과

### 학습
- 취소 재시도를 위해 `isConcertSectionInitialLoad` 소진은 섹션 결과 Intent에서 유지
- `perform*` / Task에서는 `state`를 건드리지 않고 Intent로만 되돌린다

---

## 2026-07-17 - 유저 피드백: 관심 콘서트 없을 때 상단 배경 색 단차

### 증상
- 관심 콘서트가 비어 있을 때 네비/세그먼트와 빈 상태 영역 배경이 달라 가로 단차가 보임

### 시도
- `SegmentedTabBar`가 `.home`에서도 `black100` 고정 → 빈 홈(`black90`)과 불일치
- `.home` 세그먼트 배경을 clear로 바꿔 `HomeView` 배경(`black90`/`black100`)이 비치도록 수정

### 결과
- 수정 반영. 관심 없을 때 세그먼트·빈 영역이 동일 `black90`으로 이어짐

### 학습
- 세그먼트는 홈 빈 상태의 `black90` 배경 전략과 맞춰야 한다

---

## 2026-07-17 - Bugbot round 2: 섹션 대기 중 재 onAppear 시 파이프라인 스킵

### 증상
- 유저 성공 직후 `isConcertSectionInitialLoad = false`로 소진한 뒤 섹션 대기 중 Task가 취소되면, 후속 `onAppear`는 섹션을 건너뛰고 로딩만 남을 수 있음

### 시도
- 플래그 소진을 섹션(·추천) 결과 `send` 직전으로 미룸. 취소 체크 통과 후에만 소진
- 재현 테스트: 유저 즉시 성공 + 섹션 delay 중 재 onAppear

### 결과
- HomeStoreTests 36개 통과. Bugbot 재리뷰에서 잔여 이슈 없음 (SPEC REVIEW PASS)

### 학습
- “초기 1회” 플래그는 해당 파이프라인이 취소 없이 끝까지 도달한 뒤에만 소진해야 한다

---

## 2026-07-17 - Bugbot: 유저 실패 후 섹션 재로드 불가 · 취소 시 로딩 고착

### 증상
- `isConcertSectionInitialLoad`를 유저 성공 전에 소진하면 실패 후 재시도 시 섹션 스킵
- 취소된 Task가 loading을 끄면 후속 Task와 레이스

### 시도
1. 취소 경로에서 loading clear 제거
2. 유저 실패 시 초기 로드 플래그 유지
3. 재현 테스트 추가

### 결과
- 유저 실패 재시도는 개선. 섹션 대기 중 재진입 이슈는 round 2로 이어짐

### 학습
- 병렬 시작과 플래그 소진 시점 분리 필요
