# LIVD-478 홈 단일 Store - 트러블슈팅

## 기록

### 2026-08-12 20:50 - child 이름을 Reducer로 되돌림, Interest refresh도 DiscardableTask

**상황**
- 방향성 리뷰 후 사용자가 child 명칭과 Interest refresh 계약을 확정했다.

**문제**
- Handler로 바꾼 명칭이 팀 선호(Reducer)와 어긋났다. Interest `.refreshable`은 아직 `send`만 호출해 await가 없었다.

**원인**
- “순수하지 않음”을 이름에 드러내려다 TCA 어휘(Reducer)와의 일관성을 잃었다. Interest refresh 계약은 Slice 2 이슈로 미뤄 둔 상태였다.

**해결**
- `CalendarHomeHandler` → `CalendarHomeReducer`로 리네임. Interest/캘린더 pull-to-refresh 모두 `await send(...).wait()` + `DiscardableTask`로 통일. 순수하지 않음은 계획 문서에만 명시.

**교훈**
- 홈 child는 Reducer로 부르되 순수 reduce가 아님을 문서에 남긴다. refresh await 계약은 탭마다 다르게 두지 않는다.
- 승격 후보: no

---

### 2026-08-12 20:45 - child 이름을 Handler로, refresh를 DiscardableTask로 확정

**상황**
- 캘린더 흡수 스파이크에서 Reducer 명칭·`performRefresh` 유지 vs Scope/`send`만으로 pull-to-refresh를 맞출지 재논의했다.

**문제**
- “Reducer”는 순수 reduce 기대를 깨고, View가 Store의 `performRefresh`를 알면 Scope 경계를 깨뜨린다. `getState`/`setState`/`bind` 형태의 위임 API는 거부됐다.

**원인**
- 초기 계획의 TCA 어휘(Reducer)와, 실제로는 Repo·CancelID를 가진 비동기 객체의 역할이 어긋났다. refresh await는 child month Task와 동일 수명이 필요했다.

**해결**
- `CalendarHomeHandler.reduce(_:state:) -> DiscardableTask`, Store는 `lazy` Handler + `withCalendar` copy/assign, Scope `send`는 `DiscardableTask`를 돌려 `.refreshable { await scope.send(.pullToRefresh).wait() }`.

**교훈**
- 순수하지 않은 child는 Handler로 이름 짓고, View refresh await는 DiscardableTask로 Scope `send`에 실어 보낸다. `inout` reduce 중 sync `send` 재진입은 피한다.
- 승격 후보: no (홈 한정 스파이크; 2~3 Feature 반복 후 architecture 후보)

---

### 2026-08-11 22:19 - develop에 계획 문서 직접 커밋

**상황**
- 사용자가 계획 문서 커밋을 요청해 `docs/plans/LIVD-478-home-single-store.md`를 커밋했다.

**문제**
- 작업 브랜치를 만들지 않고 `develop`에 직접 커밋했다. 사용자는 브랜치로 옮겨 작업해야 한다고 지적했다.

**원인**
- `git.md`의 “작업 브랜치는 develop에서 분기” 규칙을 커밋 전에 적용하지 않았다. 브랜치가 `develop`인 채로 승인된 커밋만 수행했다.

**해결**
- 커밋이 있는 HEAD에서 `refactor/LIVD-478-home-single-store` 브랜치를 만들고, `develop`을 `origin/develop`으로 hard reset한 뒤 작업 브랜치로 체크아웃한다.

**교훈**
- 커밋 승인 전이라도, 현재 브랜치가 `develop`/`main`이면 먼저 `type/LIVD-XXX-슬러그`로 분기한 뒤 커밋한다.
- 승격 후보: yes (`git.md`에 “develop 직접 커밋 금지”가 이미 있는지 확인 후, 없으면 Do에 명시)

---

<!-- 새 항목은 위에 추가한다 (최신순 정렬) -->
