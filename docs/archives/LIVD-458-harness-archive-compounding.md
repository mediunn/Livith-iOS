# LIVD-458 에이전트 하네스 간소화 및 아카이브 컴파운딩 (archive)

## 결과
- plan 트리거·권한·컴파운딩/압축 아카이브 게이트를 규칙·템플릿·AGENTS에 정착했고, Checklist·architecture/convention 중복을 줄였다.

## 남긴 결정
- dryforge는 아이디어만 차용 (플러그인 미도입).
- engineering-notes 없이 교훈은 `docs/rules`로만 승격.
- Claude 레이어(`CLAUDE.md`, `.claude/**`)는 이번 이슈에서 변경하지 않음. plan 정본은 `docs/rules/plan.md`.
- 하드 트리거 = 유저 기능 완료 선언 (+ PR 전 잔여 재확인).
- 아카이브는 슬러그 일치 단일 압축본; 교훈에 원인 한 줄; rules 0건이어도 압축본 승인 필수.
- 기본 승격 규칙과 architecture/security 분리 확인.
- 아카이브 후 추가 수정은 追記; 원본 복구 금지.
- 강제 훅 없음. 잔여 427·457 일괄 아카이브는 범위 밖.
- 문서 작성 메타(AGENTS 영어 / rules 한글)는 `docs/rules/documentation.md`로 분리.

## 컴파운딩
- rules 반영:
  - `documentation.md` (신설) — AGENTS.md 영어만, 한글 규범은 docs/rules, 템플릿·규칙 한글
  - `plan.md` — 기본 승격 규칙에 `documentation.md` 포함
  - `AGENTS.md` — documentation.md 라우팅 추가
- 분리 확인으로 보류: 없음
- archive만 유지:
  - `.agents`/`.claude` 스킬 미러는 유저가 지정한 쪽만 삭제
- 반영 없음 / 사유: 해당 없음

## 교훈
- [AGENTS에 한글 Hard gate를 넣음] → AGENTS.md는 영어만, 한글 규칙은 docs/rules에 둔다.
- [스킬이 .agents와 .claude에 미러됨] → 삭제 시 유저가 지정한 경로만 변경한다.
- [문서 작성 제약을 plan에 넣으려 함] → AGENTS/rules/템플릿 작성 규칙은 documentation.md로 둔다.
- [PR을 Summary/Test plan 형식으로 올림] → PR 본문은 `.github/PULL_REQUEST_TEMPLATE.md`를 따르고 `git.md`에 명시한다.

## 追記

### 2026-07-25 - PR 본문 템플릿
- `git.md` Pull Request Do에 `.github/PULL_REQUEST_TEMPLATE.md` 준수를 추가했다. PR #297 본문을 템플릿에 맞게 수정했다.

## 참조
- 브랜치: `refactor/LIVD-458-harness-archive-compounding`
- PR: https://github.com/mediunn/Livith-iOS/pull/297
