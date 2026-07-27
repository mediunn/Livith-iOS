# LIVD-465 1차 QA 이슈 대응 - 트러블슈팅

## 기록

### 2026-07-27 20:30 - 취소된 관심 목록 결과가 재조회 로딩을 꺼버리는 순서 버그

**상황**
- 구현 후 코드 점검 중 `_interestListResult` 처리 순서를 검토했다.

**문제**
- `isInterestListRetryLoading = false`를 cancellation 체크보다 먼저 수행하면, 재조회 중 이전 Task 취소 결과가 로딩을 끄고 엠티뷰가 잠깐 보일 수 있다.

**원인**
- 재조회 로딩 해제와 cancellation early return 순서를 분리하지 않았다.

**해결**
- cancellation이면 상태를 건드리지 않고 return한다. 비취소 결과에만 `isInterestListRetryLoading`을 해제한다.
- 목록이 있는 실패 분기에서 불필요한 `isInterestListLoadFailed = false` 대입을 제거했다.

**교훈**
- 재시도 로딩 플래그는 취소 결과에서 끄지 않는다. 최신 요청 완료에서만 끈다.
- 승격 후보: no

---

<!-- 새 항목은 위에 추가한다 (최신순 정렬) -->
