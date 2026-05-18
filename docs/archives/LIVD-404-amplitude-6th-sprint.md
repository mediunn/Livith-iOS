# LIVD-404 6차 스프린트 앰플리튜드 반영

## 배경
- 6차 스프린트 Amplitude Event DB("01. 태깅 요청" 상태)에 신규/재정의 이벤트가 추가되었다.
- 장르 탭 클릭은 현재 트래킹이 전혀 없고, 예매 일정 알림은 일반/선예매가 하나의 이벤트로 통합 추적되고 있어 분리가 필요하다.

## 목표
- 스크린샷 기준 9개 이벤트가 정확한 트리거 시점에 전송된다.
  - `click_signup_banner_main`은 대상 UI 부재로 이번 범위에서 제외(사용자 확인 완료).

## 작업 항목
- [x] 1. `AmplitudeService.ClickEvent`에 신규 이벤트 케이스 추가
  - `genreAll/genreJpop/genreRockMetal/genreRapHiphop/genrePop/genreIndie` = `click_genre_*`
  - `preBookingScheduleNotification` = `click_pre_booking_schedule_notification`
  - `pushPreBookingSchedule` = `click_push_pre_booking_schedule`
- [x] 2. ExploreView 장르 탭 클릭 트래킹 추가
  - `genreTabButton`의 Button action에서 `ConcertGenre` → 해당 `click_genre_*` 이벤트 전송.
  - `ConcertGenre` → `ClickEvent` 매핑은 ExploreView 파일 내 `fileprivate` 확장(Domain의 Amplitude 역의존 방지).
- [x] 3. NoticeView 예매 알림 트래킹 일반/선예매 분리
  - 선예매(`.preTicketingOpen/.preTicketing1D/.preTicketing30M`) → `preBookingScheduleNotification`
  - 일반예매(`.generalTicketingOpen/.generalTicketing1D/.generalTicketing30M`) → `bookingScheduleNotification`(기존 유지)
- [x] 4. DeepLinkService 푸시 예매 알림 트래킹 일반/선예매 분리
  - 선예매 → `pushPreBookingSchedule`
  - 일반예매 → `pushBookingSchedule`(기존 유지)
- [ ] 5. 빌드 검증 후 변경 내용 보고 (커밋은 사용자 승인 후)

> 변경 이력: 당초 `NotificationType`에 `isPreTicketing`/`isGeneralTicketing`를 TDD로 추가해 재사용하려 했으나, 두 호출처가 모두 exhaustive switch라 명시적 case 분리가 컴파일 안전성 측면에서 우수하여 속성/테스트를 제거하고 명시적 case로 구현. 상세는 `docs/troubleshooting/LIVD-404-amplitude-6th-sprint.md` 참고.

## 영향 범위
- `Projects/Core/Amplitude/Sources/AmplitudeService.swift` (이벤트 정의)
- `Projects/SearchFeature/Sources/Explore/View/ExploreView.swift` (장르 탭)
- `Projects/HomeFeature/Sources/Notice/View/NoticeView.swift` (알림 셀)
- `Projects/App/Sources/Service/DeepLinkService.swift` (푸시)

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 일반/선예매 분류 위치 | View 내 명시적 case / Domain 속성 추출 | View 내 명시적 case | 두 호출처 모두 exhaustive switch → 명시적 case가 컴파일 누락 검사 유지, Domain 속성은 `where`/`default` 필요로 안전성 저하 |
| `click_booking_schedule_notification` 처리 | 신규 추가 / 기존 재점검 | 기존 재점검(일반만 매핑) | 사용자 지시("전체 재점검"). 기존엔 일반+선예매 통합 → 일반 전용으로 의미 정정 |
| 분류 로직 TDD | 단위 테스트 작성 / 생략 | 생략 | 장르 탭·예매 분류 모두 분기 없는 1:1 exhaustive switch (trivial). 컴파일러 exhaustiveness가 매핑 누락을 보장 |
| 가입 배너 이벤트 | 포함 / 제외 | 제외 | 대상 "가입하러 가기" 배너 UI 부재(사용자 확인 완료) |

## 주의 사항
- `bookingScheduleNotification` / `pushBookingSchedule` 기존 이벤트 **문자열 값은 변경하지 않는다** (일반예매 매핑으로 의미만 정정).
- `NotificationType` 케이스 누락 시 트래킹 누락 → switch는 ticket 타입을 빠짐없이 포함.
- 장르 탭은 이미 선택된 탭 재클릭 시에도 트리거(스펙상 "탭 클릭 시").

## 검증 방법
- `Domain` 단위 테스트 통과(`isPreTicketing`/`isGeneralTicketing`).
- 전체 빌드 성공.
- 코드 리뷰: 9개 이벤트가 각 트리거 지점에 1:1로 매핑되는지 표로 대조.
