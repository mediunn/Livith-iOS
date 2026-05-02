# LIVD-362 관심 콘서트 설정 검색 API 전환 - 트러블슈팅

## 기록

### 2026-05-01 21:00 - LivithCard 표시 정책 구분

**상황**
- 관심 콘서트 목록 조회 UI의 `LivithCard` 표시 문자열을 확인했다.

**문제**
- `LivithCard`로 `Concert` 카드를 표시하는 UI에서 `InterestConcertDisplayText`를 사용하면 카드 표시 정책이 다른 Concert 기반 카드와 달라질 수 있다.

**원인**
- `InterestConcertDisplayText`는 예매 일정과 하단 문구처럼 `InterestConcert.ticketingSchedule`이 필요한 UI 정책을 포함한다.

**해결**
- `LivithCard`로 `Concert`를 표시하는 UI는 `ConcertDisplayText`를 사용한다.
- `InterestConcertDisplayText`는 홈 관심 콘서트 섹션처럼 예매 일정, 장소, 하단 문구가 필요한 `InterestConcert` 전용 UI에서만 사용한다.

**교훈**
- 추후 `LivithCard` 기반 Concert 카드 UI를 추가하거나 수정할 때는 `ConcertDisplayText` 정책을 우선 적용한다.

---

### 2026-05-01 20:46 - HomeFeature Swift Testing 테스트 0개 실행

**상황**
- `tuist test HomeFeature`로 Store 검색 흐름 테스트를 검증했다.

**문제**
- HomeFeature와 HomeFeatureTests는 컴파일/링크됐지만 XCTest 로그에는 `Executed 0 tests`가 표시되고 xcodebuild가 65로 종료됐다.

**원인**
- Tuist/Xcode 테스트 러너가 현재 설정에서 Swift Testing 테스트를 실제 실행하지 못하는 것으로 보인다.

**해결**
- `tuist build HomeFeature`로 생산 코드 컴파일 성공을 별도 확인했다.
- 테스트 타깃은 `tuist test HomeFeature` 로그에서 컴파일/링크 성공까지 확인했다.

**교훈**
- HomeFeature의 Swift Testing 기반 테스트는 빌드/링크 성공과 실제 테스트 실행 성공 여부를 분리해서 보고한다.

---

### 2026-05-01 20:40 - ConcertData 테스트 타깃 기존 컴파일 오류

**상황**
- `tuist test ConcertData`로 ConcertData mapper 변경과 테스트를 검증했다.

**문제**
- `Projects/Data/ConcertData/Tests/ConcertMapperTests.swift:416`에서 `ScheduleType.ticketing` 멤버가 없어 테스트 타깃 빌드가 실패했다.

**원인**
- 기존 XCTest 파일의 스케줄 타입 기대값이 현재 Domain 타입과 맞지 않는다.

**해결**
- 이번 단계 변경과 무관한 기존 테스트 오류이므로 수정하지 않았다.
- `tuist build ConcertData`로 생산 코드 컴파일은 별도 검증했다.

**교훈**
- ConcertData 테스트 검증 시 기존 XCTest 컴파일 오류와 이번 변경의 실패를 분리해서 판단한다.

---

### 2026-05-01 20:39 - Tuist 병렬 실행 상태 파일 충돌

**상황**
- `tuist build LivithNetwork`, `tuist build SearchData`, `tuist build ConcertData`를 병렬 실행했다.

**문제**
- `SearchData` 빌드가 Tuist 상태 파일 `recent-paths.json` rename 충돌로 실행 전 실패했다.

**원인**
- 여러 Tuist 명령이 동시에 동일한 상태 파일을 갱신했다.

**해결**
- `tuist build SearchData`를 단독 재실행해 성공을 확인했다.

**교훈**
- Tuist 명령은 상태 파일 충돌을 피하기 위해 순차 실행한다.

---

### 2026-05-01 20:38 - Swift Testing 테스트 0개 실행

**상황**
- `tuist test LivithNetwork`, `tuist test SearchData`로 새 `Testing` 기반 테스트를 검증했다.

**문제**
- 테스트 타깃 빌드와 링크는 됐지만 XCTest 로그에는 `Executed 0 tests`로 표시됐다.

**원인**
- Tuist/Xcode 테스트 러너가 현재 설정에서 Swift Testing 테스트를 XCTest 실행 개수로 노출하지 않는 것으로 보인다.

**해결**
- `tuist test LivithNetwork`, `tuist test SearchData`는 명령 성공 여부와 테스트 타깃 컴파일/링크 성공을 확인했다.
- 생산 코드 컴파일은 각 모듈 `tuist build`로 별도 검증했다.

**교훈**
- Swift Testing 기반 테스트는 실행 개수 로그와 명령 성공 여부를 분리해서 기록한다.

---

<!-- 새 항목은 위에 추가한다 (최신순 정렬) -->
