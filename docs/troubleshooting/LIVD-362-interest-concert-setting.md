# LIVD-362 관심 콘서트 설정 UI 및 API 반영 - 트러블슈팅

## 기록

### 2026-05-01 17:47 - HomeFeature 테스트 러너 0개 테스트 후 실패

**상황**
- 관심 콘서트 조회 구조 리팩터링 후 `tuist test HomeFeature`로 Store 테스트를 검증하려 했다.

**문제**
- 테스트 타깃 빌드와 링크는 성공했지만 xcodebuild가 `Executed 0 tests`를 출력한 뒤 exit code 65로 종료됐다.
- 이전 검증에서도 같은 형태의 HomeFeature 테스트 실행 문제가 있었다.

**원인**
- 원인 미파악. 테스트 코드 컴파일 단계는 통과했으나 테스트 러너가 Swift Testing 테스트를 발견하거나 실행하지 못하는 환경 이슈로 보인다.

**해결**
- 미해결. 대신 `tuist build HomeFeature`, `tuist build UserData`, `tuist test UserData`로 컴파일과 일부 테스트 타깃 검증을 수행했다.
- `tuist test HomeFeature`의 미검증 범위는 최종 보고에 남긴다.

**교훈**
- HomeFeature 테스트는 빌드 성공과 테스트 실행 성공을 분리해서 기록한다.
- 같은 0 tests 문제가 반복되면 테스트 러너 설정 또는 Tuist scheme 설정을 별도 작업으로 확인한다.

---

### 2026-05-01 17:10 - Store State와 MainActor Task 책임 분리

**상황**
- `InterestConcertSettingStore`를 실제 콘서트 목록 조회와 관심 콘서트 설정/수정 API에 연결했다.
- 구현 리뷰 중 Store의 `State` 의미와 `@MainActor` Store 내부 Task 사용 방식에 대한 피드백을 받았다.

**문제**
- `InterestConcertSettingState`에 View 렌더링 상태가 아닌 내부 구현 세부사항이 함께 노출됐다.
- `nextToken`, 원본 `concertList`, 초기 선택 기준값은 View가 알 필요 없는 Store 내부 값이다.
- Store 타입이 `@MainActor`인데 비동기 작업에서 `Task { @MainActor in ... }`를 다시 사용해 actor 지정이 중복됐다.

**원인**
- API 연결 과정에서 목록 원본, 페이지 토큰, 초기 선택 기준을 View 상태와 Store 내부 상태로 구분하지 않고 한 State에 넣었다.
- `Task` 내부에서 상태 변경을 안전하게 하려는 의도로 `@MainActor`를 중복 지정했다.

**해결**
- `InterestConcertSettingState`에는 View 렌더링과 View 이벤트 판단에 필요한 값만 남겼다.
- 원본 목록, 초기 선택 기준값, `NextToken`, 선택 콘서트 복원용 dictionary는 Store private property로 이동했다.
- `Task { @MainActor in ... }` 중복 지정을 제거하고 repository를 지역 상수로 캡처하도록 정리했다.
- Store가 `@MainActor`로 격리되어 있어 `send` 호출의 불필요한 `await`도 제거했다.

**교훈**
- MVI Store의 State는 View가 렌더링하거나 View 이벤트 판단에 필요한 값만 담는다.
- 페이지 토큰, 원본 목록, 초기 비교 기준처럼 API/Store 내부 구현에 가까운 값은 private property로 둔다.
- `@MainActor` Store에서 비동기 작업을 만들 때는 actor 중복 지정 대신 상태 변경 경계를 명확히 한다.

---

<!-- 새 항목은 위에 추가한다 (최신순 정렬) -->
