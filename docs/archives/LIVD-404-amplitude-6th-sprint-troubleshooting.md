# LIVD-404 6차 스프린트 앰플리튜드 반영 - 트러블슈팅

## 기록

### 2026-05-18 19:10 - 일반/선예매 분류를 Domain 속성 대신 명시적 switch case로 변경

**상황**
- 계획상 `NotificationType`에 `isPreTicketing`/`isGeneralTicketing` 속성을 TDD로 추가하고, NoticeView·DeepLinkService 두 곳에서 재사용하기로 결정했다.
- 속성 추가 및 단위 테스트(red→green)까지 완료한 뒤 호출처에 적용을 시도했다.

**문제**
- NoticeView·DeepLinkService의 트래킹 함수는 `NotificationType` 전 케이스를 다루는 exhaustive switch였다.
- 속성을 사용하려면 `case let t where t.isPreTicketing` + `default` 형태가 되어, Swift 컴파일러의 케이스 누락 검사를 잃는다(향후 enum 케이스 추가 시 트래킹 누락이 컴파일 단계에서 잡히지 않음).

**원인**
- 두 호출처가 단순 분기 없는 1:1 exhaustive switch라는 점을 계획 수립 시 충분히 고려하지 못함.
- 동일 작업 내 장르 탭은 "trivial exhaustive switch → 테스트 생략"으로 결정했는데, 예매 분류도 구조상 동일했음.

**해결**
- 명시적 case 분리(`case .preTicketingOpen, .preTicketing1D, .preTicketing30M:` / `case .generalTicketingOpen, ...:`)로 구현해 exhaustiveness를 유지.
- 소비처가 없어진 `isPreTicketing`/`isGeneralTicketing` 속성과 `NotificationTypeTests`를 제거.
- 계획 문서의 작업 항목·기술 결정 표를 실제 구현에 맞게 수정.

**교훈**
- 분류 로직 추출 여부는 호출처의 제어 흐름(exhaustive switch vs if/guard)을 먼저 확인하고 결정한다.
- exhaustive switch에 1:1 매핑되는 분류는 별도 속성 추출보다 명시적 case가 더 안전하다.
