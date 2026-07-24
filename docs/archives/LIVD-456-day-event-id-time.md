# LIVD-456 일자 일정 동일 concertID·다른 시간 행 표시

## 배경
- `/calendar/events`가 같은 `id`(concertID)·`type`에 시간이 다른 행을 여러 개 줄 수 있다 (예: 1978 @ 12:20, 17:00).
- `CalendarDayEvent.id`가 `CalendarEventID(concertID, type)`만 사용해 SwiftUI `ForEach`에서 중복 id로 한 행이 누락된다.

## 목표
- 같은 concertID·type이라도 **시간이 다르면 별도 행**으로 모달에 모두 표시된다.
- 월별 점(`CalendarMonthEvent`) identity는 기존과 동일하게 concertID+type (time nil).

## 작업 항목
- [x] Domain: `CalendarEventID`에 `time: CalendarEventTime?` 추가 (기본 nil)
- [x] `CalendarDayEvent` init에서 `id = CalendarEventID(concertID:type:time:)`
- [x] TDD: 동일 concertID·type·다른 time → id 상이 / ForEach용 uniqueness
- [x] Mapper 테스트: 동일 id CONCERT 두 시각 + 다른 콘서트 → eventList.count == 3
- [x] 기존 CalendarEventID/DayEvent 생성부·테스트 컴파일 맞춤
- [x] 검증: Domain/CalendarData 관련 테스트 + Dev 빌드
- [x] 수동: 7/26 모달에 12:20·17:00·18:00 세 행

## 영향 범위
- `Projects/Domain/Sources/Entity/Calendar/CalendarEvent.swift`
- `Projects/Domain/Sources/Entity/Calendar/CalendarDaySchedule.swift`
- Domain/CalendarData/HomeFeature 테스트·생성 호출부

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| identity | A) ID에 time / B) View only | **A** | Identifiable·Hashable 일관 |
| month event | time 포함 vs nil | **nil** | 월 뷰는 시각 행이 없음 |
| 동일 time 중복 | detail/index 추가 vs 비범위 | **비범위** | 현 API 케이스는 시각이 다름 |

## 주의 사항
- `time == nil`인 동일 concert·type 두 행은 여전히 id 충돌 가능 — 이번 비범위.
- 콘서트 상세 이동은 `concertID` 유지.

## 검증 방법
- Mapper/Domain 테스트 + `Livith-iOS-Dev` 빌드
- 수동: 7/26 모달에 12:20·17:00·18:00 세 행
