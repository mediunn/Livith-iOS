# LIVD-458 에이전트 하네스 간소화 및 아카이브 컴파운딩

## 배경
- 에이전트 하네스(`AGENTS.md`, `docs/rules/*`, plan/troubleshooting/archive)는 신중함 위주로 잘 동작하지만, 문서량·트리거 애매함·Checklist 중복으로 해석이 갈리기 쉽다.
- 아카이빙은 plan·troubleshooting을 `docs/archives/`로 옮기는 수준이라, 교훈이 다음 사이클의 `docs/rules`로 환류되지 않는다 (컴파운딩 부재).
- 실제 증상: `develop`에도 `docs/plans/`, `docs/troubleshooting/`에 LIVD-427·LIVD-457 문서가 남아 있다. PR/브랜치 종료와 아카이브가 묶여 있지 않다.
- [dryforge](https://github.com/fn-opt/dryforge)의 권한 분리·비례 의식·증거 기반 완료·문서 밀도 원칙은 **아이디어만** 차용한다. 플러그인·`.dryforge`·`ready`/`go`는 도입하지 않는다.

## 목표
- plan 필수/예외·권한(정본)·완료 증거가 규칙만으로 갈리지 않는다.
- 규칙 문서의 Checklist·중복 서술이 줄어 로드 비용이 낮아진다.
- 유저가 기능 완료를 선언하면 **컴파운딩 게이트**가 돌고, 교훈이 유저 승인 후 `docs/rules`로 승격되거나 archive에만 남는지가 명시된다.
- 아카이브는 **단일 압축 문서**다. 교훈에는 원인 한 줄을 남긴다.
- `plans/`·`troubleshooting/`에 해당 슬러그 문서가 남은 채 PR을 만들지 않는다.
- Claude 전용 레이어(`CLAUDE.md`, `.claude/**`)는 변경하지 않는다. plan 여부의 정본은 `docs/rules/plan.md`이며 `AGENTS.md`에 명시한다.

## 작업 항목
- [x] `docs/rules/plan.md` — plan 트리거·예외·권한·비례 의식 명시
  - 필수: 모듈 2개 이상 / Domain·Repository·API 계약 변경 / 동작·데이터·보안·UX를 바꾸는 설계 선택이 남음
  - 예외: 동일 패턴 기계적 다파일 변경, 한 모듈·레이어 경계 안 버그·UI 배치, 긴급 hotfix(사후 archive 가능)
  - 권한: 목표·불변조건 = 동작 정본, 작업 항목 = 실행 순서(충돌 시 정본 우선), 코드 ≠ 원하는 동작의 증거, 완료 = 검증 명령 결과만
- [x] `docs/rules/plan.md` — 아카이브·컴파운딩 절차 (그릴 확정 반영)
  - **하드 트리거**: 유저가 기능 완료를 선언한 때. 유저가 「아카이브해」「이슈 닫자」「계획 종료」를 명시한 때도 동일 게이트
  - **PR 전**: 해당 슬러그 plan/TS 잔여가 있으면 게이트를 다시 돌리고, 없으면 통과
  - 대상 선정: 브랜치명·현재 plan과 **슬러그가 일치**하는 `docs/plans/LIVD-XXX-슬러그.md` 및 동명 troubleshooting만. `LIVD-XXX-*` 전체 일괄 아카이브 금지. 애매하면 유저에게 목록을 보여 고르게 함
  - 순서: 교훈 분류 → rules 변경안(있으면) + 압축 archive 초안 → **유저 승인** → rules 반영 → `docs/archives/LIVD-XXX-슬러그.md` 단일 압축본 저장 → plans/TS 원본 제거
  - rules 변경이 없어도 압축 archive 초안 승인은 필수
  - 압축본 교훈: `[원인 한 줄] → 교훈 한 줄`
  - 승격 목적지: `docs/rules`만. 기본 승격 가능: `plan`, `project-operations`, `git`, `tdd`, `code-convention`. `architecture`·`security`는 제안 가능하나 **분리 확인** 표시, 같은 호흡에 기본 승격과 섞지 않음
  - 아카이브 후 추가 수정: 기본은 plan 없이. 새 설계·모듈 경계를 열면 후속 plan → 기존 압축 archive에 **追記** (원본 복구·전체 재작성 금지)
  - 강제 수단(훅/CI) 없음. 문서 게이트만
- [x] `docs/templates/plan.md` — `권한·범위`, 증거형 검증, `컴파운딩` 섹션
- [x] `docs/templates/archive.md` 신설 — 단일 압축 양식(결과 / 코드로 안 보이는 결정 / 컴파운딩 / 교훈(원인→교훈) / 追記 / 참조)
- [x] `docs/templates/troubleshooting.md` — 교훈에 `승격 후보: yes/no` 한 줄
- [x] `docs/rules/git.md` — `docs` / `[Docs]`; PR 전 해당 슬러그 plan/TS 없음(또는 게이트 완료) 확인
- [x] `docs/rules/architecture.md` / `code-convention.md` — typed throws·Store `private(set)` 정본 architecture, convention은 참조
- [x] `tdd.md` / `code-convention.md` — Checklist ≤10 (반복 위반 중심)
- [x] `docs/templates/rule-template.md` — Checklist Do/Don't 복붙 금지 명시
- [x] `AGENTS.md` — Hard gates, routing, deep-interview, plan SoT=`docs/rules/plan.md`, complete/PR gate (English only)
  - Constraint: `AGENTS.md` must be written in English; Korean rules stay in `docs/rules/*`.
- [x] `project-operations.md` — destination 고정값 규범 제거
- [x] 잔여 LIVD-427·LIVD-457 일괄 아카이브는 본 이슈 범위 밖
- [x] 본 이슈 완료 조건은 **규칙·템플릿 병합**이다. 458 plan 셀프 아카이브는 의무가 아니다
## 영향 범위
- `AGENTS.md`
- `docs/rules/plan.md`, `git.md`, `architecture.md`, `code-convention.md`, `tdd.md`, `project-operations.md`
- `docs/templates/plan.md`, `archive.md`(신설), `troubleshooting.md`, `rule-template.md`
- **변경하지 않음**: `CLAUDE.md`, `.claude/**`, `.agents/skills/**` 본문

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| dryforge | 플러그인 / 아이디어만 | 아이디어만 | Claude·이중 체계 회피 |
| 교훈 중간층 | notes / rules만 | rules만 | 레이어 단순화 |
| archive 형태 | 원본 이동 / 각각 압축 / 단일 압축 | 단일 압축 + 교훈에 원인 한 줄 | 노이즈↓, 추적성 최소 유지 |
| rules 승격 승인 | 사전 / 사후 | 사전 필수 (rules 0건이어도 archive 승인 필수) | 규칙·보관본 권한은 사용자 |
| 하드 트리거 | PR만 / 완료 선언 / 머지 전 | 유저 기능 완료 선언 (+ PR 전 잔여 재확인) | 너무 이른 아카이브·잔여 방치 균형 |
| 대상 선정 | 이슈키 전체 / 슬러그 / 에이전트 판단 | 슬러그 일치 (+ 애매 시 유저) | 427 다중 plan 오아카이브 방지 |
| 아카이브 후 수정 | 복구 / 追記 / 새 이슈만 | plan 없이 또는 후속 plan→追記 | 히스토리 보존 |
| arch/security 승격 | 동일 / 분리 확인 / 금지 | 분리 확인 | 무게 있는 규칙 혼입 방지 |
| 강제 | 문서만 / 훅 | 문서만 | 이번 범위; 무시 지속 시 후속 |
| Claude 불일치 | 무시 / AGENTS 정본 / 동기화 | AGENTS에 정본=plan.md, Claude 미수정 | 제외 유지 + Cursor 경로 명확화 |
| 458 셀프 아카이브 | 의무 / 비의무 | 비의무 | 완료=규칙 병합 |
| 잔여 427·457 | 일괄 / 보류 | 보류 | 규칙 정착이 목표 |

## 주의 사항
- `CLAUDE.md`의 plan 트리거와 `plan.md` 불일치는 허용된 부채다. Cursor/`AGENTS.md` 경로의 정본은 `docs/rules/plan.md`다.
- 승격 기준을 엄격히 적용하고, 이미 있는 규칙은 추가하지 않는다.
- 기존 `docs/archives/` 소급 압축은 하지 않는다. 신규 아카이브부터 새 양식을 쓴다.
- 문서만 변경하므로 앱 빌드·테스트는 검증에 쓰지 않는다.

## 검증 방법
- [x] 명령: `git diff --name-only`
- [x] 기대 신호: 변경 목록에 `CLAUDE.md`, `.claude/` 경로가 없음
- [x] 실제 결과: Claude 경로 없음. 변경은 AGENTS + docs/rules/* + docs/templates/* (+ plans/LIVD-458)
- [x] 명령: Checklist 항목 수, archive 템플릿 존재, engineering-notes 파일 없음
- [x] 기대 신호: tdd/code-convention Checklist ≤10, `docs/templates/archive.md` 존재
- [x] 실제 결과: tdd 8항, code-convention 8항, archive 템플릿 있음. engineering-notes 파일 없음
- [ ] 유저 확인: 변경된 rules·템플릿·AGENTS 리뷰

## 컴파운딩 (아카이브 전)
- [ ] 교훈 분류 완료
- rules 반영:
  - (작업 종료 시 기입)
- archive만 유지:
  - (작업 종료 시 기입)
- 반영 없음 / 사유: (해당 시)
