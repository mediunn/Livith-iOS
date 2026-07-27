# Git 브랜치 전략

`docs/rules/git.md`의 브랜치 규칙을 배포 자동화(LIVD-459) 관점에서 정리한다.

## 브랜치 종류

| 브랜치 | 역할 | 배포 트리거 |
|--------|------|-------------|
| `main` | 릴리즈 가능한 상태만. 프로덕션 소스. | push 시 App Store Connect 업로드(심사 미신청) |
| `develop` | 통합 브랜치. 기능 브랜치가 여기로 머지된다. | 없음 |
| `qa` | **배포 전용** 브랜치. 여기 머지될 때만 QA 배포. | push 시 TestFlight internal 업로드 |
| 작업 브랜치 | `feat/`·`fix/`·`docs/`·`refactor/`·`setting/` + 이슈키 | 없음 |

작업 브랜치 예: `feat/LIVD-459-cicd-pipeline`, `fix/LIVD-237-amplitude`

## 일반 개발 흐름

```
feat/LIVD-XXX  →(PR)→  develop  →(릴리즈 시점)→  main
```

- 작업 브랜치에서 개발 → develop으로 PR·머지(Squash 금지, 히스토리 보존).
- develop이 릴리즈 가능해지면 main으로.
- `main`·`develop`에는 직접 push 금지(Hotfix 제외).

## 배포 흐름 (LIVD-459 파이프라인)

QA와 운영은 **일반 개발 흐름과 분리된 배포 트리거 브랜치**를 쓴다.

```
develop ─(배포하고 싶을 때)→ qa       →CI→ TestFlight internal (Dev/Debug, dev 서버)
develop ─(릴리즈)→ main               →CI→ App Store 업로드 (Release, 운영) → 수동 심사 신청
```

- **`qa`**: develop에서 "지금 QA 올리자" 싶을 때 머지. 작업 브랜치 커밋마다 배포되는 폭탄을 피하기 위해 전용 브랜치로 둔다.
- **`main`**: 머지가 곧 릴리즈. push 시 App Store에 프로덕션 빌드를 업로드하되, 비가역인 심사 신청은 사람이 수동으로.
- CI가 배포 후 빌드 번호(`YYYYMMDD.HHMM`)를 커밋·push하며, `[skip ci]`로 재트리거를 막는다.

## 커밋·머지 규칙 (요약)

- 커밋: `[Type] LIVD-XXX - 변경 요약` (간결체, 50자 이내, 마침표 없음, 구분자는 ` - `만).
- PR 제목: `[Type] 작업 설명` (이슈키 미포함), 본문에 `Resolved: LIVD-XXX`.
- 머지 커밋: `[Merge] 이슈키 브랜치명`, Squash 금지, 머지 후 원격 작업 브랜치 삭제.
- 커밋·push는 사용자 명시 승인 후에만.
