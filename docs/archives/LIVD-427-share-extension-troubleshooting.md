# [LIVD-427] 공유 시트 진입 Share Extension 추가 - 트러블슈팅

## 기록

### 2026-07-09 - 공유 진입 시 매칭 화면 대신 홈으로 이동 (콜드 런치 딥링크 유실)

**상황**
- 사용자가 실기기/시뮬레이터에서 공유 시트로 Livith를 선택하자 앱은 열리지만 매칭 화면이 아닌 홈이 표시됐다.

**문제**
- 앱이 종료된 상태(콜드 런치)에서 `onOpenURL`이 런치 스크린 단계에 발사되고, `DeepLinkService`가 `NotificationCenter.post(.openInstagramMatch)`를 즉시 쏘는데, 구독자인 `LivithMainTabView`는 토큰 갱신 후 `.main` 전환 뒤에야 마운트되어 알림이 유실됐다.

**원인**
- NotificationCenter 기반 딥링크 전달은 구독자가 살아 있는 웜 런치에서만 동작한다. 콜드 런치와 로그인 경유(FR-01의 미로그인 분기) 시나리오를 고려하지 않았다.

**해결**
- `DeepLinkService`에 `pendingInstagramURL`을 보관하고(@MainActor), `LivithMainTabView`가 `onAppear`에서 `consumePendingInstagramURL()`로 소비하도록 했다. 웜 런치의 onReceive 경로에서도 consume해 중복 진입을 방지했다. 로그인 경유 시에도 로그인 완료 → 메인 탭 마운트 시점에 소비되므로 FR-01 분기가 함께 해결된다.

**교훈**
- 딥링크를 NotificationCenter로 전달할 때는 콜드 런치(구독자 부재) 유실을 항상 고려하고, pending 보관 + 진입 시점 소비 패턴을 함께 둔다.

---

### 2026-07-09 - Xcode 서명 오류: App Groups 프로비저닝 미지원

**상황**
- 사용자가 Xcode에서 실행하자 LivithShareExtension 타겟에 서명 오류 4건이 발생했다: Apple ID 로그인 거부 1건 + "iOS Team Provisioning Profile: *"이 App Groups capability/entitlement를 포함하지 않는다는 오류 3건.

**문제**
- 익스텐션 entitlements에 App Group(`group.com.youz2me.livith`)을 선언했지만, 자동 생성 프로비저닝 프로파일에 해당 capability가 없어 서명이 실패했다.

**원인**
- 이 익스텐션은 딥링크(URL scheme)로 메인 앱을 여는 구조라 App Group 공유 저장소를 사용하지 않는데, 앱 entitlements를 관성적으로 복사해 불필요한 capability를 선언했다.

**해결**
- 익스텐션의 entitlements 파일과 Project.swift의 entitlements 지정을 제거해 서명 요구사항 자체를 없앴다. Apple ID 로그인 거부는 Xcode > Settings > Accounts에서 재로그인 필요 (사용자 액션).

**교훈**
- 익스텐션 entitlements는 실제 사용하는 capability만 선언한다. App Group은 데이터 공유가 필요해지는 시점(예: 익스텐션에서 직접 저장)에만 추가한다.

---

### 2026-07-09 - 익스텐션 번들 ID 접두사 불일치 (Info.plist 표준 키 누락)

**상황**
- 번들 버전 키를 맞춘 뒤 재빌드했다.

**문제**
- `error: Embedded binary's bundle identifier is not prefixed with the parent app's bundle identifier`로 실패. 익스텐션 appex의 CFBundleIdentifier를 PlistBuddy로 읽으면 값이 없었다.

**원인**
- `.file(path:)` 방식 Info.plist는 Xcode가 CFBundleIdentifier를 자동 주입하지 않는다. 익스텐션 plist에 `CFBundleIdentifier=$(PRODUCT_BUNDLE_IDENTIFIER)` 등 표준 키를 넣지 않아 번들 ID가 비었고, 접두사 검증에 실패했다.

**해결**
- 앱 App-Info.plist를 참고해 `CFBundleIdentifier`, `CFBundleExecutable`, `CFBundleName`, `CFBundlePackageType`, `CFBundleDevelopmentRegion`, `CFBundleInfoDictionaryVersion` 표준 키를 익스텐션 plist에 추가했다.

**교훈**
- Tuist에서 `infoPlist: .file(path:)`로 직접 지정하는 타겟은 CFBundleIdentifier 등 표준 키를 plist에 명시해야 한다 (`.default`/`.extendingDefault`와 달리 자동 주입 없음).

---

### 2026-07-09 - ValidateEmbeddedBinary 실패 (익스텐션 번들 버전 불일치)

**상황**
- Share Extension 타겟을 추가하고 `tuist build Livith-iOS-Dev`로 앱+익스텐션 임베드 빌드를 검증했다.

**문제**
- 익스텐션 컴파일은 통과했으나 `ValidateEmbeddedBinary ... LivithShareExtension.appex` 단계에서 BUILD FAILED (error 65).

**원인**
- 익스텐션 Info.plist에 `CFBundleShortVersionString`/`CFBundleVersion`이 없어 기본값이 되어, 앱(1.1.1 / 3)과 버전이 불일치했다. iOS는 임베드된 익스텐션 버전이 호스트 앱과 일치해야 검증을 통과한다.

**해결**
- 익스텐션 Info.plist에 앱과 동일한 `CFBundleShortVersionString=1.1.1`, `CFBundleVersion=3`을 추가했다.

**교훈**
- 앱 익스텐션 타겟을 추가할 때는 Info.plist에 호스트 앱과 동일한 번들 버전 키를 반드시 넣는다. 앱이 버전을 하드코딩하는 프로젝트에서는 익스텐션도 같은 값으로 맞추고, 버전 업 시 두 곳을 함께 갱신한다.

---

<!-- 새 항목은 위에 추가한다 (최신순 정렬) -->
