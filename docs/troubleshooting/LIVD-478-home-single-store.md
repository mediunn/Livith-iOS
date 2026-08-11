# LIVD-478 홈 단일 Store - 트러블슈팅

## 기록

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
