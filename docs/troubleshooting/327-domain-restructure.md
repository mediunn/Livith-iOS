# [#327] 트러블슈팅

## 2026-11-18 · 기존 테스트의 일정 타입과 날짜 기준 수정

공연 매퍼의 컴파일 오류를 해결하자 섹션 매퍼 테스트에서 날짜가 잘못된 공연을 목록에서 제외한다는 기존 기대값도 실패했다.

### 원인

현재 매퍼는 날짜를 선택 값으로 변환한다. 유효하지 않은 시작일은 `nil`이 되고 공연은 목록에 남는다. 예매 일정의 현재 응답 값은 `GENERAL_TICKETING`이며 표시 테스트의 고정 날짜는 미래 예매를 만드는 조건으로 쓸 수 없었다.

### 조치

공연 매퍼 테스트의 일정 타입과 기대값을 현행 계약에 맞췄다. 관심 공연 표시 테스트의 미래 예매일은 테스트 실행 시각 기준으로 만들었다.

### 검증

- 두 관련 스위트 39건 통과.
- `Livith-iOS-Workspace` 통합 테스트 405건 통과. `ConcertMapperTests.swift`를 다시 포함했고 변경 범위 밖인 `LivithNetworkingTests`만 제외했다.

## 2026-11-18 · 고정 예매일을 사용하는 기존 표시 테스트 실패

통합 테스트에서 `InterestConcertDisplayHelperTests`의 선예매 우선 표시 검증 1건이 실패했다. 테스트는 8월 22일 선예매 문구를 기대했고, 실행 결과는 8월 23일 일반 예매 문구였다.

### 원인

테스트의 두 날짜가 실행일보다 이전이다. 기존 표시 함수는 현재보다 이전인 날짜를 미래 예매 목록에서 제외하고, 미래 일정이 없으면 일반 예매일을 표시한다. `develop`과 비교했을 때 해당 테스트와 구현 파일은 동일하다.

### 조치

표시 규칙과 기존 테스트를 유지하고 선행 실패로 기록했다.

### 검증

- 나머지 통합 테스트 388건이 통과했다. 테스트 결과 번들의 전체 집계는 389건 중 실패 1건이다.

## 2026-11-18 · 통합 테스트 타깃 컴파일 실패

`Livith-iOS-Dev` 빌드가 통과한 뒤 `Livith-iOS-Workspace`에서 테스트를 시작하면 `ConcertMapperTests.swift:417`의 `ScheduleType.ticketing`에서 컴파일이 멈춘다.

### 원인

`develop`에 동일한 테스트 코드가 있고, 기준 커밋의 `ScheduleType`에는 `.preTicketing`, `.generalTicketing`, `.concert`, `.none`만 있다. 이번 이동 전후의 `ConcertSchedule.swift`는 바이트 단위로 동일하다.

### 조치

테스트 타깃을 실행 대상에서 빼도 Workspace 스킴의 빌드 목록에 포함되어 동일하게 실패했다. 기존 테스트를 수정하지 않고 통합 검증 명령에만 `EXCLUDED_SOURCE_FILE_NAMES=ConcertMapperTests.swift`를 지정했다. 공연 에러 매퍼 테스트는 실행 대상으로 유지했다.

### 검증

- `git diff --quiet develop -- Projects/Data/ConcertData/Tests/ConcertMapperTests.swift`와 원본 `ConcertSchedule.swift` 비교가 통과했다.
- 재실행 결과는 [계획의 검증 표](../plans/327-domain-restructure.md#검증-방법)에 기록한다.
