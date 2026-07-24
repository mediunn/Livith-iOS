# LIVD-449 알림·콘서트 요청 연동 - 트러블슈팅

## 기록

### 2026-07-24 10:53 - NotificationError에 networkError 케이스 부재

**상황**
- NoticeStore 전체 읽기 실패 테스트에서 `markAllNotificationsAsReadErrorStub = .networkError`로 스텁을 설정했다.

**문제**
- 컴파일 에러: `cannot infer contextual base in reference to member 'networkError'`.

**원인**
- `NotificationError`에는 `networkError` 케이스가 없다. 실제 케이스는 `noConnection / serverError / invalidResponse / unknown / notificationNotFound / cancelled`.

**해결**
- 스텁을 `.serverError`로 수정.

**교훈**
- 도메인 에러 스텁을 쓰기 전에 해당 에러 enum의 실제 케이스를 먼저 확인한다.

---

### 2026-07-24 10:52 - #expect 안의 keypath allSatisfy 매크로 컴파일 에러

**상황**
- NoticeStore 전체 읽기 성공 테스트에서 `#expect(sut.state.notifications.allSatisfy(\.isRead))`로 검증을 작성했다.

**문제**
- Swift Testing 매크로 확장 파일에서 `call can throw, but it is not marked with 'try'` 컴파일 에러로 테스트 빌드 실패.

**원인**
- `#expect` 매크로 확장 과정에서 keypath-as-function(`allSatisfy(\.isRead)`)이 throwing 호출로 추론된다.

**해결**
- 클로저 형태 `allSatisfy { $0.isRead }`로 변경.

**교훈**
- `#expect` 내부에서는 keypath 함수 변환 대신 명시적 클로저를 사용한다.

---

<!-- 새 항목은 위에 추가한다 (최신순 정렬) -->
