# LIVD-478 홈 단일 Store (archive)

## 결과
- 홈을 단일 `HomeStore` SSOT로 합치고, 관심/캘린더는 Scope + child Reducer로 분리했다. `send`는 refresh await용 `DiscardableTask`를 반환한다.

## 남긴 결정
- Reducer는 순수 reduce가 아니다. Repo·CancelID를 갖고 Effect enum은 두지 않는다.
- `UserAvailability`는 셸(Store)에 남기고, Interest Reducer는 `waitForUser`만 받는다.
- 토스트·결과 시트는 `InterestHomeState`. `homeAppear` 유저 실패만 Store가 interest에 에러를 쓴다.
- `DiscardableTask` / Scope / Reducer는 HomeFeature 한정. Shared·architecture 승격은 패턴이 반복된 뒤로 미룬다.
- child Intent는 바깥 case가 문맥이므로 `onAppear`처럼 탭 접두를 뺀다 (`.interest(.onAppear)`).

## 컴파운딩
- rules 반영:
  - 없음
- 분리 확인으로 보류 (`architecture` / `security`):
  - Feature 합성(Scope+Reducer+DiscardableTask)을 architecture에 올릴지는 2~3 Feature 반복 후
- archive만 유지:
  - develop에 계획만 커밋했다가 브랜치로 옮긴 사건 → 작업 전 브랜치 확인
  - Handler ↔ Reducer 명칭 왕복 → 순수하지 않음은 문서에, 이름은 팀 어휘(Reducer)
  - refresh는 Scope `send` + DiscardableTask로 통일 (Store `performRefresh` 제거)
- 반영 없음 / 사유: `git.md`에 작업 브랜치 분기가 이미 있고, 합성 패턴은 홈 1회라 rules 승격 시기 아님

## 교훈
- [develop에 계획 문서를 바로 커밋함] → 커밋 전에 브랜치가 develop/main이면 먼저 `type/LIVD-XXX-슬러그`로 분기한다
- [inout reduce 중 sync send로 exclusivity가 깨질 수 있음] → nested 결과 Intent는 Task에서만 재진입한다
- [View가 Store refresh API를 알면 Scope 경계가 무너짐] → pull-to-refresh는 `await scope.send(...).wait()` + DiscardableTask
- [nest 후 `.interest(.interestAppear)`처럼 접두가 겹침] → child Intent는 `onAppear`처럼 짧게 맞춘다
- [셸↔관심 조율 상태를 Interest로 옮기면 homeAppear 순서가 깨짐] → `UserAvailability`는 Store에 둔다

## 추가 기록

### 2026-08-13 - child Reducer 제거, `HomeStore+` 확장으로 흡수
- 하위 Reducer 타입을 없애고 `HomeStore+Interest` / `HomeStore+Calendar`에 로직을 옮김.
- Scope · nest State/Intent · `DiscardableTask`는 유지.
- Swift `private`는 파일 단위라 extension이 쓰는 Store 멤버는 모듈 내부로 열음.

### 2026-08-14 - User를 InterestHomeState로 이동
- `HomeState.user`를 없애고 `InterestHomeState.user`에 둔다. 조회는 `homeAppear`, 저장·소비는 관심.
- `waitForUser` 대신 섹션 결과를 pending으로 붙잡아 유저 이후에 추천을 조회한다.
- `._fetchUserResult`는 프로덕션 `send`가 없어 제거했다.

## 참조
- 브랜치: `refactor/LIVD-478-home-single-store`
- 경로: `HomeStore`, `HomeStore+Interest`, `HomeStore+Calendar`, `InterestHomeState`, `DiscardableTask`, `*HomeScope`
