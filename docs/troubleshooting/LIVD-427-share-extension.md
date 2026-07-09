# [LIVD-427] 공유 시트 진입 Share Extension 추가 - 트러블슈팅

## 기록

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
