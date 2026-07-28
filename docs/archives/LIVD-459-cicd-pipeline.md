# LIVD-459 GitHub Actions·Fastlane CI/CD 파이프라인 구현

## 배경
- 현재 배포는 로컬 Xcode에서 수동 아카이브 → TestFlight 업로드로 진행한다. 아카이브가 오래 걸려 개발자가 그 시간을 손으로 붙잡고 있어야 한다.
- 목적은 "아카이브를 빠르게"가 아니라 "아카이브·업로드를 개발자 손에서 떼는 것"이다. 브랜치에 푸시하면 CI가 대신 아카이브하고 올린다.
- fastlane·GitHub Actions 디렉토리, Gemfile 모두 없어 처음부터 구축한다.

## 목표
- QA 전용 브랜치에 푸시하면 자동으로 아카이브 → TestFlight **internal** 업로드까지 수행한다.
- `main`에 머지되면 자동으로 아카이브 → App Store Connect에 **프로덕션 빌드 업로드까지** 수행한다. (심사 신청 버튼은 사람이 수동으로 누른다.)
- 빌드 번호는 배포 시각(`YYYYMMDD.HHMM`)으로 자동 주입해 중복 없이 단조 증가시킨다.

## 작업 항목
- [x] 러너·QA 스킴·QA 브랜치명 확정 (아래 "확인 필요" 반영)
- [x] `Gemfile` + `fastlane` 초기화 (`bundle`, `fastlane init`)
  - App Store Connect API Key 기반 인증으로 구성 (Apple ID 2FA 회피)
- [x] `fastlane/Fastfile` lane 2개 작성
  - `qa` lane: 빌드 번호 주입 → `gym`(아카이브) → `pilot`(TestFlight internal 업로드)
  - `release` lane: 빌드 번호 주입 → `gym`(아카이브) → `deliver`(App Store 업로드, `skip_metadata`·`skip_screenshots`·`submit_for_review: false`)
- [x] 빌드 번호 주입 스텝 작성
  - `App-Info.plist`와 `ShareExtension-Info.plist`의 `CFBundleVersion`을 `YYYYMMDD.HHMM`로 덮어쓴다 (두 타깃 번호 일치 필수)
- [x] **로컬 검증** (workflow 작성 전 선행)
  - `tuist generate` 후 `tuist build App`으로 plist 값 변경이 빌드 회귀를 내지 않는지 확인
  - 로컬에서 `fastlane qa` 실행 → `gym` 아카이브 성공 확인
  - 빌드번호 주입 후 App·ShareExtension plist의 `CFBundleVersion`이 `YYYYMMDD.HHMM`로 일치하는지 확인
- [x] `.github/workflows/deploy-qa.yml` — `on: push`(`qa` 브랜치), `runs-on: macos-*`, Tuist 설치 → 시크릿 주입 → `tuist generate` → `fastlane qa` (로컬에서 검증된 명령 그대로 이식)
- [x] `.github/workflows/deploy-release.yml` — `on: push`(main), 나머지 동일 → `fastlane release`
- [x] CI 시크릿 주입 구성
  - `Tuist/Config/*.xcconfig`(gitignore·Livith-Certificate 소스) 주입 경로
  - 서명 인증서(.p12)·프로비저닝 프로파일 주입 (러너가 GitHub-hosted일 경우)
  - App Store Connect API Key(`.p8`)를 GitHub Secrets로
- [x] 첫 CI 실행 검증 (사용자 Secrets 등록 후) 및 트러블슈팅 문서화
  - QA→TestFlight internal 업로드까지 실제 통과 확인. cloud signing으로 archive·export 서명.

## 영향 범위
- 신규: `Gemfile`, `Gemfile.lock`, `fastlane/Fastfile`, `fastlane/Appfile`, `.github/workflows/deploy-qa.yml`, `.github/workflows/deploy-release.yml`
- 수정: `Projects/App/Resources/App-Info.plist`, `Projects/App/ShareExtension/Resources/ShareExtension-Info.plist` (빌드 번호는 배포 후 `qa`/`main`에 `[CI]` 커밋으로 갱신 — `CFBundleVersion` 값 라인만 텍스트 치환, `[skip ci]`로 루프 차단)
- 저장소 설정: GitHub Secrets (인증서, 프로파일, API Key, xcconfig)

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 도구 조합 | GHA만 / Fastlane만 / 둘 다 | GitHub Actions + Fastlane | 둘은 대체재가 아님. GHA는 트리거·실행 환경, Fastlane은 그 안의 빌드·업로드 스텝 |
| QA 배포 트리거 | push / tag / 수동 | QA 브랜치 `on: push` | 배포 전용 브랜치라 머지할 때만 도는 구조. 작업 브랜치 커밋 폭탄 문제 없음 |
| QA 배포 대상 | internal / external | TestFlight internal (`pilot`) | 내부 팀 확인용, 심사 없이 즉시 |
| main 배포 트리거 | push / tag / 수동 | main `on: push` | main 머지 빈도 낮음(1~2달 1회), 머지 ≈ 릴리스 |
| main 배포 대상 | 업로드만 / 심사 신청까지 | 업로드까지 (`submit_for_review: false`) | 심사 신청은 비가역. 빈도 낮은 비가역 작업의 방아쇠는 사람이 당긴다 |
| 빌드 번호 | run_number / 커밋수 / 타임스탬프 | `YYYYMMDD.HHMM` 타임스탬프 | "언제 배포됐나"를 번호에서 바로 읽는 게 목적. 시각까지 박아 중복·상태관리 제거 |
| 빌드 번호 커밋 | CI 런타임만 / 커밋 갱신 | 커밋 갱신 (`[skip ci]`로 루프 차단) | 저장소 plist 값을 최신 배포 번호와 일치시킴 |
| 러너 | GitHub-hosted / self-hosted | GitHub-hosted (macos) | 유진 맥에 묶이지 않고 "손에서 뗀다"는 목적 달성. 서명·xcconfig는 Secrets 주입으로 해결 |
| QA 스킴 | Livith-iOS / Livith-iOS-Dev | Livith-iOS-Dev | QA는 별도 dev 앱으로 |
| main 스킴 | Livith-iOS / Livith-iOS-Dev | Livith-iOS | 프로덕션 배포 |
| QA 브랜치명 | qa / release / deploy/qa | `qa` | 배포 전용 브랜치 |

## 주의 사항
- **빌드 번호 하드코딩**: `CFBundleVersion`이 plist에 `3`으로 박혀 있다. CI에서 App·ShareExtension 두 plist를 모두 덮어써야 하며, 둘의 번호가 다르면 App Store가 업로드를 거부한다.
- **xcconfig 부재**: `Tuist/Config/*.xcconfig`는 `.gitignore`(`*.xcconfig`) 대상이라 저장소에 없다. Livith-Certificate에서 동기화되는 시크릿(BASE_URL, NATIVE_APP_KEY 등)이므로, CI에서 빌드하려면 이 파일들을 주입해야 `tuist generate` 후 빌드가 성공한다.
- **서명 자산**: GitHub-hosted 러너는 키체인이 비어 있다. 로컬(개발자 맥)에서 서명이 안 깨지는 것은 이미 인증서·프로파일이 깔려 있어서다. GitHub-hosted로 가면 `.p12` + 프로비저닝 프로파일을 러너 키체인에 주입하는 스텝이 필수다. self-hosted(개발자 맥)면 이 스텝이 사실상 불필요해 초기 구축이 훨씬 단순하다 → 러너 결정에 반영.
- **`deliver` 메타데이터**: 기본값이 스크린샷·설명까지 올리려 해 첫 실행에서 막힌다. `skip_metadata: true`, `skip_screenshots: true`로 빌드만 올린다.
- **App Store Connect 인증**: Apple ID + 2FA는 CI에서 막히므로 App Store Connect API Key(`.p8`)로 인증한다.
- **빌드 번호 커밋 루프**: CI가 갱신한 빌드 번호를 커밋·push하면 `on: push`가 재트리거되어 무한루프가 난다. 커밋 메시지에 `[skip ci]`를 박고, 워크플로우에도 방어적으로 조건을 건다.
- **QA/main 동일 앱 레코드**: App 타깃 번들ID는 config와 무관하게 `com.youz2me.livith` 하나다(`Module+TargetID.swift`). Dev/Prod는 같은 앱이며 차이는 config(Debug/Release)와 배포 대상(TestFlight internal / App Store)뿐이다. 빌드 번호 시퀀스도 이 하나의 앱에서 공유되며, 타임스탬프 방식이라 QA·main이 섞여도 충돌하지 않는다. QA는 Dev 스킴이므로 **Debug config 아카이브**가 TestFlight에 올라간다(dev 서버 빌드).
- **러너 Xcode 버전**: 로컬 빌드는 Xcode 26.2다. GitHub-hosted 러너 이미지에 26.2가 없으면 `setup-xcode`가 실패한다. 첫 CI 실행에서 러너의 가용 Xcode를 확인해 버전을 맞춘다(필요 시 프로젝트 최소 요구 버전으로 하향). 로컬에서 검증 불가한 CI 전용 리스크.
- **CI 서명(cloud signing)**: 로컬은 자동 서명으로 아카이브된다. CI도 Apple ID 대신 App Store Connect **Admin API Key** cloud signing으로 archive·export를 처리한다. Fastfile은 `is_ci`일 때만 `-allowProvisioningUpdates` + API Key 인증(`signing_xcargs`)을 넘겨 프로파일을 자동 생성한다. 수동 프로파일 매핑·하드코딩은 사용하지 않는다.
- **커밋/푸시 승인**: 모든 커밋·푸시는 사용자 명시 승인 후 진행한다 (git.md).

## 확정 사항
- 러너 GitHub-hosted(macos) / QA=Dev 스킴 · main=Livith-iOS 스킴 / QA 브랜치 `qa` / 빌드 번호 커밋 갱신(`[skip ci]`)

## 사용자 준비물

### GitHub Secrets (2개)
- `DIST_CERT_PASSWORD` — `P12/distribution.p12` 개인키 암호
- `CERT_REPO_PAT` — Livith-Certificate(private) 접근용 PAT (Contents read)

서명은 cloud signing(Admin API Key + `-allowProvisioningUpdates`)이 처리하므로 teamID·프로파일 이름을 Fastfile에 하드코딩하지 않는다. teamID는 `Shared.xcconfig`의 `DEVELOPMENT_TEAM`이 담당한다.

### Livith-Certificate (`mediunn/Livith-Certificate`, CI가 checkout)
- 존재: `Config/*.xcconfig`, `Provisioning/*.mobileprovision`, `P12/distribution.p12`, `P8/AppStoreConnectAPI_AppManager.p8`
- **추가 필요**: `ASC/api_key.json` — key_id·issuer_id만 담은 JSON. **Livith-iOS가 public**이라 API 식별자를 Fastfile에 두지 않고 private 저장소에서 읽는다.

xcconfig·프로파일·ASC 키가 바뀌면 이 저장소만 갱신하면 CI가 자동으로 최신을 쓴다. 인증서(.p12)만 개인키 때문에 Secret으로 둔다. cloud signing 전환 후 프로파일은 CI에서 자동 생성되므로 수동 프로파일 복사 스텝은 제거했다.
빌드 번호 push는 `GITHUB_TOKEN`(contents:write)으로 하므로 별도 PAT는 불필요하다.

## 검증 방법
- **로컬 (CI 이식 전 선행)**
  - `tuist build App` 성공 — plist 값 변경이 빌드 회귀를 내지 않음.
  - 로컬 `fastlane qa` → `gym` 아카이브 성공.
  - 빌드번호 주입 후 App·ShareExtension plist `CFBundleVersion` = `YYYYMMDD.HHMM` 일치 확인.
- **CI**
  - `qa` 브랜치에 테스트 푸시 → GHA 잡 성공 → TestFlight(internal)에 `YYYYMMDD.HHMM` 빌드 번호로 새 빌드 노출 확인.
  - `main`에 테스트 머지 → App Store Connect에 프로덕션 빌드 업로드 확인(심사 미신청 상태).
  - 빌드번호 커밋이 `[skip ci]`로 재트리거 없이 반영되는지 확인.
