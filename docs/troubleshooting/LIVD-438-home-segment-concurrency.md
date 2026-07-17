# LIVD-438 홈 세그먼트 / 동시성 트러블슈팅

## 2026-07-17 - interestAppear 관심 목록 실패가 초기 에러로 전파됨

### 증상
- Intent 분리 후 `performInterestAppear`가 `._interestListResult(.failure)`를 그대로 보내 `setError`로 전파됨
- 기존 초기 로드는 관심 목록 실패를 빈 목록으로 흡수해야 함

### 시도
- `interestList(from:)`로 실패를 `[]`로 흡수한 뒤 `._interestListResult(.success)`만 전달
- 정렬 변경 등 `performFetchInterestList` 경로의 실패 전파는 유지

### 결과
- 초기 `interestAppear` 흡수 정책 복구

### 학습
- 초기 로드 흡수와 이후 명시적 refetch 실패 전파는 경로를 분리해야 한다

---

## 2026-07-17 - 관심 목록 성공이 유저 실패 에러를 지움

### 증상
- `homeAppear` 유저 실패로 `errorMessage`를 세운 뒤, `interestAppear`의 관심 목록 성공이 `errorMessage = ""`로 덮어씀
- 유저 실패 전파·재시도 관련 테스트 2개 실패

### 시도
- `._interestListResult(.success)`에서 `state.user != nil`일 때만 에러 클리어
- 정렬 재조회 성공(유저 존재) 경로는 기존처럼 클리어 유지

### 결과
- HomeStoreTests 40개 통과

### 학습
- 병렬 Intent 결과 처리 시 다른 Intent가 세운 에러를 무조건 클리어하면 안 된다

---

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
