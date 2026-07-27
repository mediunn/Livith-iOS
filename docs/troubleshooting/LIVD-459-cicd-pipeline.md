# LIVD-459 CI/CD 파이프라인 - 트러블슈팅

## 기록

### 2026-07-27 12:25 - CI: fastlane 상대경로로 API Key 파일 못 찾음

**상황**
- 자동 서명(API Key) 적용 후 CI. `load_api_key`의 `File.read`.

**문제**
- `No such file or directory - .certificate/ASC/api_key.json` (ENOENT, Fastfile:92).

**원인**
- fastlane이 `fastlane/` 디렉토리 기준으로 상대경로를 해석해 워크스페이스 루트의 `.certificate`를 못 찾음.

**해결**
- `GITHUB_WORKSPACE`(로컬은 `Dir.pwd`) 기준 절대경로로 `ASC_KEY_P8`·`ASC_KEY_INFO`를 구성.

**교훈**
- fastlane에서 저장소 파일을 참조할 때 상대경로는 CWD에 의존한다. CI는 `GITHUB_WORKSPACE` 절대경로를 쓴다.

### 2026-07-27 12:15 - CI 아카이브 서명 실패 (Debug config ↔ Distribution 프로파일 불일치, 자동 서명으로 전환)

**상황**
- tuist install/generate 통과 후 Fastlane qa의 `xcodebuild archive`.

**문제**
- `ARCHIVE FAILED`: "No profiles for 'com.youz2me.livith' were found ... iOS App **Development** provisioning profiles ... Automatic signing is disabled".

**원인**
- QA는 Debug config로 아카이브 → xcodebuild가 **Development** 서명을 기대. 설치한 프로파일은 **Distribution**이라 타입 불일치.
- CI는 Apple ID 자동 서명 불가. archive 단계 서명은 `export_options`(export 전용)로 해결되지 않음.
- App·Extension 프로파일이 서로 달라 gym `xcargs` 전역 override로 타깃별 매핑 불가.

**해결**
- 방향 결정 대기: ⓐ 자동 서명 + App Store Connect API Key로 `-allowProvisioningUpdates` 자동 프로비저닝, ⓑ Tuist Project.swift에 config별 수동 서명(팀·프로파일) 명시.

### 2026-07-27 12:05 - CI: tuist install 누락으로 generate 실패

**상황**
- mkdir 수정 후 두 번째 CI. Tuist generate 스텝.

**문제**
- `We could not find external dependencies. Run 'tuist install'`로 exit 1.

**원인**
- CI는 깨끗한 checkout이라 SPM 외부 의존성이 없다. 로컬은 이미 받아둬 generate만으로 됐지만 CI는 generate 전에 `tuist install`이 필요하다.

**해결**
- generate 앞에 `tuist install` 스텝을 추가했다.

**교훈**
- 로컬에 이미 존재하는 상태(의존성·폴더)를 CI가 재현하지 못하는 지점이 반복된다. clean checkout 기준으로 필요한 준비 스텝을 명시한다.

### 2026-07-27 12:00 - CI 첫 실행: Tuist/Config 디렉토리 부재로 cp 실패

**상황**
- `qa` 브랜치 push로 첫 CI 실행. Install xcconfig 스텝에서 Livith-Certificate의 xcconfig를 `Tuist/Config/`로 복사.

**문제**
- `cp: Tuist/Config is not directory`로 exit 1.

**원인**
- `.gitignore`의 `*.xcconfig`로 `Tuist/Config` 안 파일이 전부 무시되고, 빈 폴더는 git이 추적하지 않아 CI checkout에 `Tuist/Config` 폴더 자체가 없었다. cp 대상 디렉토리가 없어 마지막 인자를 파일로 해석해 실패.

**해결**
- cp 전에 `mkdir -p Tuist/Config`를 추가했다.

**교훈**
- gitignore된 폴더는 CI checkout에 존재하지 않는다. 복사 대상 디렉토리는 명시적으로 mkdir한다.

### 2026-07-27 10:20 - 서명 인증서 팀 불일치 (잘못된 인증서 지목)

**상황**
- CI 수동 서명용 인증서·팀ID를 확정하려고 `security find-identity`로 키체인 배포 인증서를 조회했다.

**문제**
- 처음 `grep ... | head`로 목록을 잘라 봐서 `Apple Distribution: SEUNGHEON LEE (HGVD26K7DP)`를 배포 인증서로 지목하고 `APPLE_TEAM_ID`도 그 값으로 안내했다.
- 그러나 Livith-Certificate의 배포 프로파일 TeamID는 `2DF5SKQK2R`였고, 프로파일이 참조하는 인증서는 `Apple Distribution: Youjin Lee (2DF5SKQK2R)`였다. 지목한 인증서로 서명했다면 프로파일 팀 불일치로 실패했을 것이다.

**원인**
- `find-identity` 출력을 `head`로 잘라 하위 인덱스(5번 Youjin Lee 인증서)를 놓쳤다.
- 인증서 이름 괄호값을 프로파일과 대조하지 않고 팀ID로 단정했다.

**해결**
- 프로파일의 `TeamIdentifier`와 `DeveloperCertificates`를 추출해 정본을 확인했다. teamID `2DF5SKQK2R`, App 프로파일 `Livith-Distribution`, Extension 프로파일 `LivithShareExtension-Distribution`으로 확정하고 Fastfile에 하드코딩했다.

**교훈**
- 서명 자산은 인증서 목록만 보지 말고 **프로파일 기준으로 역추적**한다(프로파일의 TeamID·참조 인증서가 정본).
- 후보를 좁히는 조회에서 `head`로 목록을 자르지 않는다.

### 2026-07-27 09:30 - fastlane 로컬 설치 실패 (ruby 환경 혼재)

**상황**
- CI/CD 로컬 검증을 위해 `Gemfile`(fastlane) 작성 후 `bundle install`로 fastlane 설치를 시도했다.

**문제**
- `bundle install`이 exit 0처럼 보였으나 실제로는 rake 13.4.2 설치에서 `Bundler::SudoNotPermittedError`로 실패했다 — 시스템 gem 경로(`/Library/Ruby/Gems/2.6.0`)에 설치하려다 sudo를 요구.
- 이어 `bundle exec fastlane -v`는 homebrew ruby 3.4.7 경로에서 bundler/setup 에러를 냈다.

**원인**
- `which ruby/bundle/gem`이 모두 `/usr/bin`(Apple 시스템 ruby 2.6.10)을 가리켜, 보호된 시스템 gem 경로에 설치하려다 권한 부족으로 막혔다.
- 동시에 PATH에 homebrew ruby 3.4.7이 존재해 `bundle exec`가 다른 ruby를 잡으며 환경이 혼재됐다.
- `| tail` 파이프로 install 명령의 exit code가 tail의 것(0)으로 잡혀 실패가 가려졌다.

**해결**
- `export PATH="/opt/homebrew/opt/ruby/bin:$PATH"`로 homebrew ruby 3.4.7을 고정한 뒤 `bundle config set --local path vendor/bundle` + `bundle install`로 프로젝트 내 `vendor/bundle`에 로컬 설치해 sudo를 회피했다.
- CI(GitHub-hosted)는 ruby setup 액션으로 버전을 고정하므로 이 혼재 문제는 발생하지 않는다.

**교훈**
- 로컬 fastlane 실행은 homebrew ruby(`vendor/bundle`)로 고정한다. 시스템 ruby 2.6은 사용하지 않는다.
- 명령 성패를 `| tail`의 exit code로 판단하지 않는다. 로그 본문을 확인하거나 `set -o pipefail`을 쓴다.

---

<!-- 새 항목은 위에 추가한다 (최신순 정렬) -->
