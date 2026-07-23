# LIVD-452 홈 캘린더 API 연동 — Troubleshooting

## 2026-07-23 raw value enum의 불필요 Hashable 제거

### 상황
- 캘린더 raw value enum에 `Hashable`을 명시해 두었다.
- 유저 피드백: 원시값 enum은 자동 합성되는데 왜 넣었냐.

### 원인
- 필요 없이 습관적으로 프로토콜을 나열했다.

### 조치
- `CalendarDayEventType` / `CalendarDayEventStatus` / `CalendarMonthEventType` / `CalendarScheduleTypeFilter` / `CalendarConcertTypeFilter`에서 `Hashable` 제거.

## 2026-07-23 Domain Entity 파일을 개념별 4개로 통합

### 상황
- `Entity/Calendar/`에 타입당 1파일로 13개가 쌓여 탐색 비용이 커졌다.
- grill로 타입 의미는 유지하고 파일만 합치기로 했다.

### 조치
- `CalendarMonth.swift` / `CalendarDaySchedule.swift` / `CalendarEvent.swift` / `CalendarFilter.swift`로 통합 (파일 내 MARK 구분).
- `CalendarError`·`CalendarRepository`는 기존 위치 유지.

## 2026-07-23 Mapper 선행 작성 피드백 → 삭제

### 상황
- Domain 완료 후 CalendarData Mapper·ErrorMapper를 바로 작성하려 했고, 파일까지 생겨 있었다.
- 유저 피드백: Mapper는 지우고 **단계별로** 진행하고 싶다.

### 원인
- 계획상 다음 항목이 Data/Mapper여서 범위를 한 번에 밀어붙였다.

### 조치
- `CalendarMapper.swift`, `CalendarErrorMapper.swift` 삭제.
- 이후 단계는 유저 확인 후 한 단계씩 진행한다.

## 2026-07-23 Domain 나머지 Entity를 일괄 추가

### 상황
- `CalendarEventID`·`CalendarEventDetail`는 red→green을 개별 확인했다.
- 이후 Time/Status/Entity/Error/Repository는 계획·그릴 합의가 이미 고정되어 있어, 타입 선언을 한꺼번에 추가한 뒤 행동 테스트로 검증했다.

### 원인
- 모든 필드에 의도적 깨진 stub red를 반복하면 비용만 늘고, 이미 합의된 구조 재확인에 가깝다.

### 조치
- Domain 공개 API에 대한 `CalendarDomainModelTests` 행동 테스트로 합성 id·Detail 정렬·Time 비교·MonthDay id·sparse month를 검증한다.
- Mapper/Store 구간은 다시 엄격한 red→green을 적용한다.
