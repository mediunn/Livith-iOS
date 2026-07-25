# LIVD-447 트러블슈팅

## 기록

### 2026-07-22 22:01 - 아카이브 시 동일 파일명으로 계획 문서 덮어씀

**상황**
- 계획·트러블슈팅을 `docs/archives/`로 이동하려 했다. 두 파일명이 모두 `LIVD-447-interest-concert-cleanup-api.md`였다.

**문제**
- `mv` 두 번으로 계획 문서가 트러블슈팅에 덮어써져 최신 계획 내용이 유실되었다.

**원인**
- LIVD-438처럼 트러블슈팅에 `-troubleshooting` 접미사를 쓰지 않고 동일 파일명으로 아카이브했다.

**해결**
- 트러블슈팅을 `LIVD-447-interest-concert-cleanup-api-troubleshooting.md`로 분리하고, 계획은 HEAD+작업 반영본으로 복구해 아카이브했다.

**교훈**
- 아카이브 시 계획과 트러블슈팅 파일명을 반드시 구분한다 (`*-troubleshooting.md`).

---

### 2026-07-22 21:59 - DEBUG entry-alerts 목 데이터 제거

**상황**
- 디버그 스킴에서 `UserRepositoryImpl`이 entry-alerts를 고정 샘플로 반환하도록 구현되어 있었다.

**문제**
- 유저 피드백: 디버그 스킴일 때 목으로 만들어내는 코드를 없애 달라고 요청했다.

**원인**
- 초기 계획(시뮬 확인용 DEBUG stub)이 실서버 연동 확인과 맞지 않았다.

**해결**
- `#if DEBUG` stub·`debugInterestConcertEntryAlerts` 샘플을 삭제하고, Debug/Release 모두 실 API(`POST /notifications/entry-alerts`)만 호출하도록 변경했다.
- 계획 문서의 디버그 목 결정을 철회로 갱신했다.

**교훈**
- 시뮬 확인용 DEBUG stub는 실연동 검증이 목표면 조기에 제거하고 실 API로 통일한다.

---

### 2026-07-22 21:58 - 서브에이전트 점검으로 불필요 코드 제거

**상황**
- entry-alerts 구현 후 서브에이전트로 불필요 코드를 점검했다.

**문제**
- identity-only `CodingKeys`, SheetView의 Array extension 포워딩 computed property, dismiss 테스트의 의미 없는 `fetchCallCount == 0` assert가 남아 있었다.

**원인**
- DTO/View/테스트 작성 시 관례·이전 mark API 검증을 그대로 옮겨 와 중복·무의미한 코드가 생겼다.

**해결**
- `InterestConcertEntryAlerts.AlertItem.CodingKeys` 삭제 (프로퍼티명 합성 decode 사용)
- `InterestConcertResultSheetView`의 `autoCleanupAlertList` / `requestResultAlertList` 포워딩 프로퍼티 삭제 → `alertList.*` 직접 사용
- dismiss 테스트에서 `fetchInterestConcertEntryAlertsCallCount == 0` 제거, 메서드명 `…WithoutMark` → `…ClosesSheet`
- Array extension 자체 제거는 보류(기존 합의)

**교훈**
- 마이그레이션 직후 서브에이전트 점검으로 identity CodingKeys·포워딩 래퍼·구 API assert를 바로 걷어낸다.

---

### 2026-07-22 - `tuist generate --no-open`이 external dependencies 없음으로 실패

**상황**
- Swift 파일 추가/삭제 후 `tuist generate --no-open`을 실행했다.

**문제**
- `We could not find external dependencies. Run tuist install before you continue.`로 실패했다.

**원인**
- 로컬에 Tuist 외부 의존성 캐시/설치가 없는 상태에서 generate만 실행했다.

**해결**
- `mise exec -- tuist install` 후 `mise exec -- tuist generate --no-open` 재실행

**교훈**
- generate 실패 메시지가 install을 안내하면 먼저 `tuist install`을 수행한다.
