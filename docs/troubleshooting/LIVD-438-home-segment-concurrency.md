# LIVD-438 홈 세그먼트 / 동시성 트러블슈팅

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
