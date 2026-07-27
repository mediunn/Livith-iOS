# LIVD-465 1차 QA 이슈 대응 (archive)

## 결과
- 관심 목록 로드 실패 엠티뷰·결과 시트/설정 UI QA, 홈 CTA·캘린더 타이포, Web/API/Store 기간(`startDate`/`endDate`) 통일, 캘린더 Amplitude 태그를 반영했다.

## 남긴 결정
- 관심 목록 실패는 `isInterestListLoadFailed` + 고정 엠티뷰 문구. 목록이 있으면 토스트 유지·엠티뷰 전환 없음.
- pull-to-refresh는 시스템 스피너만. appear 재조회만 커스텀 로딩.
- 설정 툴팁은 FR-06(정보 요청) 왕복 후에만 숨김.
- 월 식별·조회 정본은 웹 `calendarMonthChanged`의 `startDate`/`endDate`. Repository도 동일 시그니처. `CalendarWebMonthChangeGate` 제거.
- `setCalendarData` 루트는 day 배열. Domain `CalendarMonth`는 `dayList`만.
- `click_calendar_month`는 이전 기간이 있고 실제로 바뀔 때만 (초회·동일 기간 remount 제외).

## 컴파운딩
- rules 반영: 없음 (TDD 스위트 단위 `-only-testing`은 이번 브랜치에서 이미 `tdd.md`·`project-operations.md`에 반영됨)
- 분리 확인으로 보류 (`architecture` / `security`): 없음
- archive만 유지:
  - 웹이 기간을 소유하면 네이티브는 월 경계를 다시 계산하지 않는다
  - 브릿지 날짜는 lenient Formatter만 믿지 말고 `yyyy-MM-dd` 정규식으로 형식을 먼저 검증한다
  - refreshable과 커스텀 중앙 스피너를 동시에 켜지 않는다
  - 배경 radius만 필요하면 clipShape 대신 shape fill background (오버레이 툴팁 보존)
- 반영 없음 / 사유: 캘린더·관심 QA 특화 교훈이 대부분

## 교훈
- [웹·iOS가 월 경계를 각각 계산함] → 기간 소유가 웹이면 `startDate`/`endDate`만 직통으로 쓴다.
- [Gate가 초회 monthChanged를 막음] → 초회 조회도 웹 기간을 쓰려면 inject 전 차단 Gate를 두지 않는다.
- [lenient DateFormatter가 `2026/01/01`을 통과] → 브릿지 날짜는 형식 정규식을 먼저 둔다.
- [pull-to-refresh가 isInitialLoading도 켬] → refreshable과 커스텀 중앙 로딩을 동시에 쓰지 않는다.
- [clipShape로 CTA radius] → 오버레이 툴팁이 있으면 shape fill background만 쓴다.
- [Figma `19자`를 한도로 해석] → 플레이스홀더 숫자와 표시 문자열 길이를 함께 확인한다.
- [말줄임 U+2026이 세로 중앙] → Noto 등에서는 ASCII `...`가 베이스라인에 맞다.
- [취소된 fetch 결과가 재시도 로딩을 끔] → 로딩 플래그는 취소 경로에서 끄지 않는다.
- [타겟 전체 테스트를 습관 실행] → TDD 루프는 스위트 단위 `-only-testing`으로 현재 사이클만 돌린다.

## 추가 기록

## 참조
- 브랜치: `fix/LIVD-465-1st-qa-fixes`
- 주요 경로: `CalendarHomeStore`, `CalendarWebMonthPayloadMapper`, `CalendarMonthChangedMessageParser`, `HomeStore` 관심 실패 엠티뷰, `InterestConcertSettingView`
