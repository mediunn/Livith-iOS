# LIVD-456 홈 캘린더 WebView 연동 - 트러블슈팅

## 기록

### 2026-07-24 - calendarMonthChanged 월 변경 브릿지

**상황**
- 웹이 `calendarMonthChanged` + `{year, month}` 계약을 제공.

**문제**
- iOS `selectedYear`/`selectedMonth`가 웹 월 이동과 동기화되지 않음.

**원인**
- 초기 LIVD-456 범위에서 월 이동 브릿지 비범위.

**해결**
- 파서 + `monthChanged` Intent(모달 닫기·일자 fetch 취소·월 fetch). 실패는 기존 `isLoadFailed` 엠티뷰. WebView 핸들러 등록.

**교훈**
- 월/일자 비동기 요청은 requestID·Task 취소로 레이스를 끊는다.

---

### 2026-07-24 - WebView 높이 (maxBottom)

**상황**
- 네이티브 ScrollView 안에 WebView 전체를 펼쳐야 함. `scrollHeight`/추정 높이로는 실패.

**문제**
- 웹 `RootLayout` `min-h-screen` 때문에 `scrollHeight` ≈ WebView bounds. 추정 높이를 먼저 넣으면 `maxBottom`이 프레임에 동조.

**원인**
- viewport-fill 레이아웃 + 측정 전 프레임 고정.

**해결**
- `WKUserScript`로 min-height unlock 유지. 요소 `maxBottom`만으로 `contentHeight` 갱신. 초기값은 fallback 700. 측정은 generation + 0.25/0.5초.

**교훈**
- embed 높이는 `scrollHeight`/선반영 추정 금지. unlock + maxBottom.

---

### 2026-07-24 - inject · 로드 실패 · 메시지

**상황**
- Bugbot 리뷰 및 날짜 탭/설정 이슈.

**문제**
- `lastInjected` 선반영 시 재주입 불가. 실패 후 blank 고착. 메시지 스레드/body 타입 누락.

**원인**
- 비동기 완료 전 플래그 갱신. `calendarURL` nil 처리. Store 메인 액터·parser 범위 부족.

**해결**
- inject 성공 시에만 `lastInjected`. 실패 시 URL 유지 + blank 재load. `Task { @MainActor }`. parser는 dict/JSON/날짜 문자열 수용. Helper에 mapper/parser.

**교훈**
- WebView 플래그는 completion에서만. 메시지 → Store는 메인 액터.

---

### 2026-07-24 - 설정 · 빌드

**상황**
- URL blank, Dev scheme 테스트, proxy 접근 제어.

**문제**
- Dev/Release 빈 `CALENDAR_WEB_URL=`가 Shared 덮어씀. Dev 스킴에 test action 없음. `private` proxy 타입 컴파일 실패.

**원인**
- xcconfig include 계층. 스킴 역할 혼동. Coordinator와 private 타입 충돌.

**해결**
- Dev/Release 빈 키 제거. 빌드=`Livith-iOS-Dev`, 테스트=`HomeFeature`. proxy는 `fileprivate`. `blankURL`은 `URL?`.

**교훈**
- Shared 키는 하위 xcconfig에 빈 재정의 금지. Feature 테스트 스킴 분리.

---

<!-- 새 항목은 위에 추가한다 (최신순 정렬) -->
