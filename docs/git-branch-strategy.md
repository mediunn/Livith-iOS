# Git 브랜치 전략

`docs/rules/git.md`의 브랜치 규칙을 배포 자동화(LIVD-459) 관점에서 정리한다.

## 브랜치 종류

| 브랜치 | 역할 | 배포 트리거 |
|--------|------|-------------|
| `main` | 릴리즈 가능한 상태만. 프로덕션 소스. | push 시 App Store Connect 업로드(심사 미신청) |
| `develop` | 통합 브랜치. 기능 브랜치가 여기로 머지된다. | 없음 |
| `qa` | **배포 전용** 브랜치. 여기 머지될 때만 QA 배포. | push 시 TestFlight internal 업로드 |
| `release/<앱 버전>` | 배포할 develop 커밋을 고정하고 버전 변경·배포 전 수정·검증을 수행한다. | 없음 |
| 작업 브랜치 | `feat/`·`fix/`·`docs/`·`refactor/`·`setting/` + GitHub 이슈 번호 | 없음 |

새 작업은 Linear 키 대신 이 저장소의 GitHub 이슈 번호를 사용한다.

작업 브랜치 예: `feat/#459-cicd-pipeline`, `fix/#237-amplitude`

## 일반 개발 흐름

```
feat/#번호  →(PR)→  develop
                         └→ release/1.2.1 →(PR)→ main
                                  └─────→(PR)→ develop
```

- 작업 브랜치에서 개발 → develop으로 PR·머지(Squash 금지, 히스토리 보존).
- 배포할 develop 커밋에서 release 브랜치를 분기하고, 검증 후 main으로 PR·머지한다.
- `main`·`develop`에는 직접 push 금지(Hotfix 제외).

## 배포 흐름 (LIVD-459 파이프라인)

QA와 운영은 **일반 개발 흐름과 분리된 배포 트리거 브랜치**를 쓴다.

```
develop ─(배포하고 싶을 때)→ qa       →CI→ TestFlight internal (Dev/Debug, dev 서버)
develop ─(배포 범위 확정)→ release/<앱 버전> ─(검증 후 PR)→ main
                                                        →CI→ App Store 업로드 (Release, 운영) → 수동 심사 신청
```

- **`qa`**: develop에서 "지금 QA 올리자" 싶을 때 머지. 작업 브랜치 커밋마다 배포되는 폭탄을 피하기 위해 전용 브랜치로 둔다.
- **`main`**: 머지가 곧 릴리즈. push 시 App Store에 프로덕션 빌드를 업로드하되, 비가역인 심사 신청은 사람이 수동으로.
- **`release/*`**: 배포 준비 전용이며 push만으로 배포되지 않는다. 기존 CI 트리거는 변경하지 않는다.
- CI가 배포 후 빌드 번호(`YYYYMMDD.HHMM`)를 `[CI]` 커밋(author `github-actions[bot]`)으로 push하며, `[skip ci]`로 재트리거를 막는다.
- 빌드 번호 커밋은 `qa`/`main`에만 쌓인다. `develop → qa`, `release/* → main` 머지에서 `CFBundleVersion`이 충돌하면 **배포 대상 브랜치의 최신 빌드 번호를 유지**한다. `CFBundleVersion` 값 라인만 텍스트로 치환해 충돌 범위를 그 한 줄로 최소화했다.

## 릴리즈 브랜치 수명

세부 규칙의 정본은 `docs/rules/git.md`의 릴리즈 준비·배포·재반영 항목이다.

1. 배포 범위와 앱 버전을 확정하고 해당 develop 커밋에서 `release/<앱 버전>`을 분기한다.
2. 앱과 Share Extension의 `CFBundleShortVersionString`을 같은 값으로 변경해 커밋한다. 빌드 번호는 CI가 관리한다.
3. 해당 배포에 필요한 수정만 반영하고 Release 빌드와 변경 범위를 검증한다. 분기 후 develop의 새 기능은 일괄 머지하지 않는다.
4. release → main PR을 Squash 없이 머지해 기존 운영 배포 CI를 실행한다.
5. 같은 release → develop PR을 Squash 없이 머지해 앱 버전 변경과 배포 전 수정을 재반영한다. main 전체를 머지해 CI 빌드 번호 커밋을 가져오지 않는다. develop의 앱 버전이 이미 더 높으면 높은 버전을 유지한다.
6. 운영 배포 CI 업로드 성공과 develop 재반영 완료를 확인한 뒤 원격·로컬 release 브랜치를 삭제한다. 심사 신청은 기존처럼 수동으로 진행한다.

main 머지 이후 추가 수정은 Hotfix 규칙을 따르고 develop에도 반영한다.

## 커밋·머지 규칙 (요약)

- 커밋: `[Type] #번호 - 변경 요약` (간결체, 50자 이내, 마침표 없음, 구분자는 ` - `만).
- PR 제목: `[Type] 작업 설명` (GitHub 이슈 번호 미포함), 본문에 `Resolved: #번호`.
- 현재 프론트엔드는 1인 개발 체제다. PR과 필요한 검증은 유지하며, 리뷰어 지정과 타인의 승인 없이 작성자가 직접 머지할 수 있다.
- 머지 커밋: `docs/rules/git.md` 형식 준수, Squash 금지. 일반 작업 브랜치는 머지 후 원격에서 삭제하며 release 브랜치는 위의 수명 규칙을 따른다.
- 로컬 커밋은 자율 수행한다. push는 명시적인 사용자 지시가 필요하며 머지·배포는 별도 권한이다.
