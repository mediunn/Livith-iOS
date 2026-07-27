# LIVD-459 배포 자동화 — 의사결정 기록

배포 자동화 파이프라인 설계 과정에서 내린 결정들을 과정과 결과로 정리한다. 각 항목은 "무엇을 고민했고 → 어떤 근거로 → 무엇으로 결정했는가" 순서다.

---

## 1. GitHub Actions vs Fastlane — 대체재가 아니다

**고민**: GitHub Actions와 Fastlane 중 무엇을 쓸지. GHA는 의존성이 낮지만 설정할 게 많고, Fastlane은 의존성이 높지만 간편해 보였다.

**과정**: 둘은 대립하는 선택지가 아니라 층이 다르다는 걸 확인. GitHub Actions는 **언제·어디서 도느냐**(트리거·실행 환경), Fastlane은 그 러너 **안에서 무엇을 하느냐**(빌드·서명·업로드 스텝). 현업 iOS 파이프라인은 GHA가 트리거하고 그 잡 안에서 fastlane이 도는 구조.

**결정**: **둘 다 사용.** GitHub Actions 워크플로우가 트리거하고, 그 안에서 fastlane lane이 아카이브·업로드를 수행.

---

## 2. 자동화의 목적 — "빠르게"가 아니라 "손에서 뗀다"

**고민**: 로컬 배포에서 아카이브가 너무 오래 걸림.

**과정**: 자동화가 아카이브를 빠르게 해주는 게 아님을 확인. 아카이브는 CI에서도 10~15분 걸린다. 달라지는 건 그 시간을 개발자 맥이 아니라 CI가 태운다는 것. 진짜 원하는 건 "빨리"가 아니라 "내 손에서 떼기".

**결정**: 목적을 "개발자 손에서 배포 과정을 떼는 것"으로 확정. 이 정의가 이후 러너 선택(GitHub-hosted)의 근거가 됨.

---

## 3. QA 배포 트리거 — qa 전용 브랜치 on:push

**고민**: 매 push마다 배포하면 커밋 5번에 빌드 5개가 쌓임. 트리거를 push/tag/수동 중 무엇으로?

**과정**: 작업 브랜치가 아니라 **배포 전용 `qa` 브랜치**를 따로 파는 구조로 정리. develop에서 커밋이 쌓여도 무관하고, "이거 올리자" 싶을 때 qa에 머지하면 그때 한 번 돈다. "커밋마다 폭탄" 문제가 애초에 안 생김.

**결정**: **`qa` 브랜치 `on: push`.** 배포 전용 브랜치라 머지할 때만 배포.

---

## 4. QA 배포 대상 — TestFlight internal

**고민**: TestFlight internal / external 중 어디로.

**결정**: **TestFlight internal(`pilot`).** 내부 팀 확인용, 심사 없이 즉시 배포.

---

## 5. main 배포 — 업로드까지만, 심사 신청은 수동

**고민**: main 머지 시 어디까지 자동화할지. 심사 신청까지?

**과정**: iOS 배포 단계를 분해 — ①TestFlight internal ②external ③App Store 프로덕션 업로드 ④심사 신청. main 머지 빈도가 1~2달 1회로 낮고, 심사 신청은 **비가역**(잘못 올리면 취소가 번거로움). 릴리스 노트 확인 등 눈으로 볼 것도 있음.

**결정**: **③번(App Store 업로드)까지만 자동**, ④심사 신청은 사람이 수동으로. "빈도 낮은 비가역 작업의 방아쇠는 사람이 당긴다"는 원칙.

---

## 6. 빌드 번호 — YYYYMMDD.HHMM 타임스탬프

**고민**: 빌드 번호를 run_number / 커밋 수 / 타임스탬프 중 무엇으로. TestFlight는 번호가 겹치면 업로드를 거부.

**과정**: 처음엔 "번호가 겹칠까 봐" 타임스탬프를 원했으나, run_number는 GitHub이 1씩 올려줘 겹치지 않음(근거 정정). 진짜 이유는 **"언제 배포됐는지를 번호에서 바로 읽고 싶다"**였음. 날짜만 박고 중복 시 뒤에 번호를 붙이면 "오늘 몇 번째인지" 상태 조회 로직이 생겨 복잡. 시각까지 박으면(`YYYYMMDD.HHMM`) 분 단위로 달라 중복·상태관리가 통째로 사라짐.
- 주의: 12자리 통짜 타임스탬프는 CFBundleVersion 32비트 한도 초과. 점으로 그룹을 나눠 회피.

**결정**: **`YYYYMMDD.HHMM`.** App·ShareExtension 두 plist에 동일 값 주입(불일치 시 App Store가 거부).

---

## 7. 빌드 번호 커밋 갱신 — [skip ci]로 루프 차단

**고민**: CI가 갱신한 빌드 번호를 저장소에 커밋할지.

**과정**: 커밋하면 CI가 push → `on: push`가 재트리거 → 무한루프. 커밋 메시지에 `[skip ci]`를 박아 차단.

**결정**: **커밋 갱신 + `[skip ci]`.** 저장소 plist 값을 최신 배포 번호와 일치시킴.

---

## 8. 러너 — GitHub-hosted

**고민**: GitHub-hosted(설정 없음, 느릴 수 있음, 분당 과금) vs self-hosted(빠름, 과금 없음, 내 맥에 묶임).

**과정**: 목적이 "손에서 떼기"인데 self-hosted는 결국 내 맥에 묶여 반쯤만 뗀 것. 러너는 `runs-on` 한 줄이라 되돌리기가 거의 공짜 → 일단 GitHub-hosted로 시작, 느리거나 한도 태우면 그때 전환.

**결정**: **GitHub-hosted(macos).** 되돌릴 수 있는 결정은 오래 붙잡지 않는다.

---

## 9. QA=Dev / main=운영 — 운영 서버 오염 방지

**고민**: QA를 어느 스킴으로 올릴지.

**과정**: App 타깃 번들ID는 config 무관하게 `com.youz2me.livith` 하나. Dev/Prod는 같은 앱이며 차이는 config(Debug/Release)뿐. QA를 Dev로 올리면 **Debug config, dev 서버** 빌드가 TestFlight에 올라감. QA를 항상 Dev로 하는 이유는 **배포(운영) 서버 오염 방지**.

**결정**: **QA = Livith-iOS-Dev(Debug, dev 서버), main = Livith-iOS(Release, 운영).** 빌드 번호 시퀀스는 공유하지만 타임스탬프라 충돌 없음.

---

## 10. 서명 — 자동 서명 + API Key (수동 프로파일에서 전환)

**고민**: 처음엔 "CI는 자동 서명 불가하니 수동 프로파일"로 설계.

**과정**: 실제 CI에서 여러 관문에 부딪힘.
- 수동 Distribution 프로파일 + Debug archive → "Development 서명 기대" 불일치.
- `Shared.xcconfig`에 이미 `CODE_SIGN_STYLE = Automatic`·`DEVELOPMENT_TEAM`이 있음을 확인.
- archive는 API Key 자동 서명으로 통과. export의 cloud signing은 API Key **App Manager 권한으로 부족** → **Admin 권한**으로 재발급.
- Ad Hoc 프로파일이 App Store export를 거부하는 문제도, Admin 키 cloud signing으로 프로파일 자동 생성하며 해소.

**결정**: **archive·export 모두 cloud signing(Admin API Key).** 수동 프로파일 준비가 불필요해짐.

---

## 11. 시크릿 관리 — Livith-Certificate에서 당기기, Secret 최소화

**고민**: xcconfig·프로파일·인증서·API Key를 GitHub Secret에 넣을지.

**과정**: 이들은 이미 private 저장소 `mediunn/Livith-Certificate`에 있음. Secret에 넣으면 값이 바뀔 때마다 손으로 재등록해야 함(이중 관리). CI가 그 저장소를 checkout하면 값이 바뀌어도 저장소만 갱신하면 자동 반영.

**결정**: **xcconfig·프로파일·.p12·.p8·API 식별자는 Livith-Certificate에서 checkout.** GitHub Secret은 `CERT_REPO_PAT`(저장소 접근)·`DIST_CERT_PASSWORD`(개인키 암호) 2개로 축소.

---

## 12. API 식별자 노출 — public 저장소 대응

**고민**: key_id·issuer_id를 Fastfile에 하드코딩할지.

**과정**: **Livith-iOS가 public 저장소**임을 확인. .p8 개인키가 없으면 식별자만으로는 무용하지만, public에 API 식별자를 굳이 박을 이유가 없음.

**결정**: key_id·issuer_id는 **Livith-Certificate(private)의 `ASC/api_key.json`에서 읽음.** teamID·프로파일 이름은 앱 번들에 공개되는 정보라 하드코딩 유지.
