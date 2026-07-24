# [LIVD-427] 공유 시트 진입 Share Extension 추가

## 배경
- 인스타그램 게시글의 공유 시트에서 Livith를 선택해 관심 콘서트 등록 플로우(FR-01~03)로 진입해야 하는데, 현재는 공유 시트에 Livith가 뜨지 않아 진입이 불가능하다.
- iOS 공유 시트로 URL을 수신하려면 App Intent가 아니라 **Share Extension**이 표준이다 (App Intents는 Siri/단축어용이며 공유 시트에 URL 수신자로 노출되지 않는다).
- FR-04/05 매칭·검색 화면과 `livith://instagram?url=` 딥링크는 이미 구현되어 있어, 공유 진입점만 추가하면 end-to-end 경로가 완성된다.

## 목표
- 인스타그램(및 URL/텍스트를 공유하는 앱)의 공유 시트에서 Livith를 선택하면, 공유된 게시글 URL로 메인 앱이 열리고 매칭 확인 화면(FR-04, 현재 스텁이라 매칭 실패→직접 검색 FR-05)까지 진입한다.

## 작업 항목
- [x] `Projects/App/ShareExtension/` 신설
  - `Sources/ShareViewController.swift`: 공유 항목에서 URL(또는 텍스트 속 URL) 추출 → `livith://instagram?url=<encoded>` 생성 → 메인 앱 open → 익스텐션 종료
  - `Sources/ShareURLExtractor.swift`: `NSExtensionItem` 배열에서 첫 URL을 뽑는 순수 로직 (테스트 대상)
  - `Resources/ShareExtension-Info.plist`: `NSExtensionActivationRule`(WebURL 1개 + Text 지원), `NSExtensionPointIdentifier=com.apple.share-services`
  - entitlements 없음 — 딥링크 방식이라 App Group 등 capability 불필요 (서명 오류 방지, 트러블슈팅 참조)
- [x] `Projects/App/Project.swift`: `.make(name:product:.appExtension)` 타겟 추가 + App 타겟 dependency에 익스텐션 추가(임베드)
- [x] TDD: App 프로젝트에 익스텐션 전용 테스트 타겟이 없어, Share Extension은 `docs/rules/tdd.md`의 예외 허용 작업(시스템 delegate 연결·UI 배선)으로 처리. `ShareURLExtractor.makeDeepLink`는 순수 함수로 분리해 두어 추후 테스트 타겟 추가 시 바로 검증 가능
- [x] 검증: `tuist generate` → `tuist build Livith-iOS-Dev`(앱+익스텐션 임베드 빌드 성공)
- [ ] 잔여: 시뮬레이터 앱 설치 후 공유 시트에서 Livith 노출 및 선택 시 매칭 화면 진입 수동 확인

## 영향 범위
- `Projects/App/Project.swift` (타겟 추가)
- `Projects/App/ShareExtension/` (신규 타겟 소스·리소스·entitlements)
- 기존 앱 코드 변경 없음 (딥링크 수신부는 이미 구현됨)

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 공유 진입 방식 | App Intent / Share Extension | Share Extension | 공유 시트 URL 수신은 Share Extension만 지원 |
| 메인 앱 전달 | App Group 공유 저장소 / URL scheme(딥링크) | URL scheme | 기존 `livith://instagram` 딥링크 재사용, 앱을 즉시 전면 실행 |
| 익스텐션 UI | 커스텀 폼 / UI 없이 바로 앱 실행 | UI 없이 실행 | 명세상 공유 즉시 서비스 진입 (FR-01) |
| 메인 앱 open 방식 | `extensionContext.open` / responder chain `UIApplication.open` | responder chain | Share Extension에서 `extensionContext.open`은 동작이 불안정, responder chain이 관행 |
| 번들 ID | — | `com.youz2me.livith.shareextension` | baseBundleID 규칙 준수 |

## 주의 사항
- Share Extension은 시스템 연결·UI 배선이라 `docs/rules/tdd.md`의 예외 허용 작업에 해당한다. 단, URL 추출 순수 로직(`ShareURLExtractor`)은 테스트 가능하면 TDD를 적용한다.
- 서버 파싱 API가 스텁이라, 공유→앱 진입→매칭 화면 진입까지만 동작하고 실제 매칭 결과는 나오지 않는다 (의도된 범위).
- 새 타겟은 실기기 서명 시 별도 provisioning profile이 필요할 수 있다 (시뮬레이터 빌드는 자동 서명으로 무방).
- 디스크 여유가 빠듯하므로 빌드는 앱 스킴 단위로 검증한다.

## 검증 방법
- `ShareURLExtractor` 단위 테스트 (green)
- `tuist build Livith-iOS-Dev`로 앱+익스텐션 컴파일 검증
- 시뮬레이터에 앱 설치 후 Safari/사진 등에서 공유 시트에 Livith 노출 및 선택 시 매칭 화면 진입 확인
