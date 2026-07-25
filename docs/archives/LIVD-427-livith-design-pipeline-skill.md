# [LIVD-427] livith-design-pipeline 스킬 추가

## 배경
- Figma 디자인 변경을 사람이 화면마다 수동으로 옮기는 반복 작업이 크다. Figma URL 하나로 화면 분류부터 코드 반영, 빌드·테스트 검증, PR 준비까지 이어지는 파이프라인 스킬이 필요하다.
- 기계 게이트(빌드·테스트)로 검증 가능한 작업만 자동 실행하고, 사람 판단이 필요한 지점(신규 화면, 계획 확인, 커밋/PR)은 사용자에게 되돌리는 구조로 설계한다.
- 이 저장소의 환경(Tuist, MVI, figma-desktop MCP, docs/rules 게이트)에 맞춘다.

## 목표
- `/livith-design-pipeline` 스킬 호출 시: Figma 디자인 수집 → 화면별 changeType 분류(new/modify/qa-only) → 기존 화면은 파이프라인으로 자동 수정·검증 → 신규 화면은 계획 문서 경로로 분기 → 최종 리포트 및 커밋/PR 승인 요청까지 진행된다.
- 모든 게이트가 이 저장소의 규칙 문서(`docs/rules/*.md`)를 그대로 강제한다.

## 작업 항목
- [x] `.claude/skills/livith-design-pipeline/SKILL.md` 작성
  - 트리거: "디자인 반영", "피그마 반영", Figma URL + 반영 요청
  - Step 0: 이슈 키(LIVD-XXX) 확인, develop 기준 작업 브랜치 확인
  - Step 1: figma-desktop MCP(get_metadata → get_design_context → get_screenshot → get_variable_defs)로 디자인 수집
  - Step 2: 화면별 changeType 분류 (new / modify / qa-only)
  - Step 3: `new` → 파이프라인 제외, `docs/rules/plan.md` 절차(계획 문서 + 유저 확인)로 분기
  - Step 4: `modify`/`qa-only` → 워크플로우 스크립트 실행
  - Step 5: 리포트 출력 후 커밋/PR은 사용자 승인 대기 (`docs/rules/git.md`)
- [x] `.claude/workflows/livith-design-pipeline.js` 작성 (Workflow 도구 스크립트)
  - Phase Modify: UI 전용 화면 병렬 수정 (Figma 재대조로 차이 0건 수렴 게이트, DesignSystem 토큰 우선) + 로직 포함 화면은 직렬 TDD(red→green) 강제 (`docs/rules/tdd.md`)
  - Phase Compare: qa-only 화면의 Figma 대조 리포트 (읽기 전용)
  - Phase Verify: **직렬 단일 에이전트**가 `tuist generate` → `tuist build` → `xcodebuild test` (iPhone 17) 실행 — Tuist 명령 병렬 금지 규칙 반영
  - 결과 반환: 화면별 성공/드롭 사유 집계, 게이트 실패는 트러블슈팅 문서에 기록하도록 nextSteps 안내
- [x] `.claude/skills/livith-design-pipeline/README.md` 작성 (사용법, 설계 결정)
- [x] 기능명세 반영 지원 추가 (사용자 피드백)
  - Step 1에 기능명세 수집 단계 추가 (디자인 옆 명세 프레임/주석을 화면별로 연결)
  - 분류 항목에 `spec` 필드 추가, 명세에 동작 요구가 있으면 `touchesLogic=true` 판정
  - 워크플로우 프롬프트에 명세 반영·TDD 요구사항화·qa-only 동작 대조 반영

## 영향 범위
- `.claude/skills/livith-design-pipeline/` (신규)
- `.claude/workflows/` (신규 디렉토리)
- 앱 소스 코드는 변경하지 않는다 (스킬 인프라만 추가)

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| Figma 접근 | REST API / figma-desktop MCP | figma-desktop MCP | 이미 연결되어 있고 토큰 관리 불필요 |
| 시뮬레이터 QA 자동 조작 | 포함 / 제외 | 제외 | 시뮬레이터 조작 CLI(axe) 미설치. 빌드+테스트 게이트와 Figma 스크린샷 대조로 대체. 추후 확장 가능 |
| 커스텀 에이전트 파일 | `.claude/agents/*.md` 생성 / 워크플로우 인라인 프롬프트 | 인라인 프롬프트 | Simplicity First. 프롬프트가 워크플로우와 함께 버전 관리됨 |
| 검증 병렬성 | 화면별 병렬 빌드 / 직렬 통합 검증 | 직렬 통합 검증 | `project-operations.md`의 Tuist 명령 병렬 실행 금지 |
| 커밋/PR 자동화 | 자동 커밋 / 승인 게이트 | 승인 게이트 | `git.md`의 커밋·푸시 명시적 승인 규칙 |

## 주의 사항
- 신규 화면(new)은 절대 파이프라인이 자동 구현하지 않는다 — 계획 문서 + 유저 확인이 필요한 사람 게이트.
- 워크플로우 실행 중 게이트 실패 시 해당 화면만 드롭하고 사유를 기록한다 (전역 중단 없음).
- 로직 포함 화면(touchesLogic)은 TDD 중 xcodebuild를 실행하므로 반드시 직렬로 처리한다.

## 검증 방법
- 스킬 문서 lint: SKILL.md frontmatter(name/description) 형식 확인 및 스킬 목록 등록 확인
- 워크플로우 스크립트: `node --check`로 구문 검증 (ESM이므로 .mjs 복사본으로 검사)
- 실제 Figma 프레임 하나로 드라이런하여 분류→리포트 흐름 확인 (코드 수정 없는 qa-only 케이스)
