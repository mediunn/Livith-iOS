# LIVD-413 네트워킹 모듈 팩토리 등록

## 배경
- 새 네트워킹 모듈(`LivithNetworking`)이 구축되었으나, App 모듈에서 초기화 및 DIContainer 등록이 되어 있지 않음.
- 기존 `LivithNetwork`는 리프레시 토큰 만료 시 토큰 삭제 + `NotificationCenter`에 직접 포스트했으나, 새 모듈은 `onAuthenticationExpired` 클로저로 위임함.
- 토큰 삭제는 클로저가 아닌 `TokenManagerImpl`에서 수행하도록 수정하여 책임을 명확히 분리해야 함.

## 목표
- App 모듈의 plist에서 `BASE_URL`을 읽어온다.
- 읽어온 `baseURL`과 인증 만료 이벤트 핸들러를 `NetworkingFactoryImpl`에 주입한다.
- `TokenManagerImpl`이 리프레시 토큰 만료 시 토큰을 직접 삭제하도록 수정한다.
- App 모듈에서 `NetworkingFactory`를 DIContainer에 직접 등록한다.
- 빌드가 정상적으로 통과한다.

## 작업 항목
- [x] App-Info.plist에 BASE_URL 키 추가
  - `$(BASE_URL)` 빌드 설정 변수를 값으로 가지는 `BASE_URL` 키를 `<dict>` 내에 추가
  - 기존 `NATIVE_APP_KEY` 참고하여 동일한 패턴 적용
- [x] App 모듈 Project.swift에 LivithNetworking 의존성 추가
  - `dependencies` 배열에 `.livithNetworking(.livithNetworking)` 추가
- [x] TokenManagerImpl에서 unauthorized 실패 시 토큰 삭제 추가
  - 파일: `Projects/LivithNetworking/Sources/Token/TokenManager.swift`
  - `tokenRefreshService.refresh(with:)` 호출의 `catch` 블록 내부, `if case .unauthorized = error { ... }` 블록을 수정
  - 기존: `onRefreshTokenExpired?()`만 호출
  - 수정: `onRefreshTokenExpired?()` 호출 후 `try? await tokenStore.remove()` 호출
  - **위치 주의**: `try? await tokenStore.remove()`는 `catch` 블록의 `throw error` 문장 이전에 삽입해야 함
  - 순서 이유: 먼저 앱 이벤트를 발송하여 UI 전환을 시작하고, 이후 토큰 삭제는 백그라운드에서 처리
  - `remove()`는 `async throws(TokenError)`이므로 `try? await`로 호출하여 실패 및 await 처리

- [x] App 모듈에서 baseURL 읽기 및 NetworkingFactory 직접 등록
  - 파일: `Projects/App/Sources/LivithApp+InjectDependency.swift`
  - 상단에 `import LivithNetworking` 추가
  - `registerDependency()` 메서드 내에서 assemblers 등록 **이전**에 `NetworkingFactory` 등록 로직 추가 (assemblers가 factory를 resolve할 가능성 대비)
  - baseURL 읽기: `Bundle.main.infoDictionary?["BASE_URL"] as? String`로 읽어 `URL(string:)`로 파싱. 실패 시 `fatalError("BASE_URL is missing or invalid in Info.plist")`
  - `onAuthenticationExpired` 클로저 구현:
    ```swift
    let onAuthenticationExpired: @Sendable () -> Void = {
        Task { @MainActor in
            NotificationCenter.default.post(name: Notification.Name("reloginRequired"), object: nil)
        }
    }
    ```
  - `NetworkingFactoryImpl` 생성 및 등록:
    ```swift
    let config = NetworkConfig(baseURL: baseURL)
    let factory = NetworkingFactoryImpl(
        config: config,
        onAuthenticationExpired: onAuthenticationExpired
    )
    DIContainer.shared.register(factory, for: NetworkingFactory.self)
    ```
- [x] Tuist generate 및 빌드 검증
  - `tuist generate` 실행하여 모듈 그래프 재생성
  - Xcode에서 빌드하거나 `xcodebuild build`로 빌드 성공 확인

## 영향 범위
- `Projects/App/Resources/App-Info.plist`
- `Projects/App/Project.swift`
- `Projects/App/Sources/LivithApp+InjectDependency.swift`
- `Projects/LivithNetworking/Sources/Token/TokenManager.swift`

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 등록 위치 | A) LivithNetworking 모듈 내부에 Assembler 생성<br>B) App 모듈에서 직접 등록 | B | 요구사항. App 모듈에서 직접 팩토리 생성 및 등록. |
| baseURL 전달 방식 | A) DIContainer에 NetworkConfig 등록<br>B) App 모듈에서 직접 NetworkConfig 생성 후 전달 | B | App 모듈에서 직접 등록하므로 생성자 주입이 가장 단순. |
| 인증 만료 핸들러 | A) 별도 프로토콜/타입 추상화<br>B) `@Sendable` 클로저 직접 전달 | B | `NetworkingFactoryImpl`이 이미 `@Sendable` 클로저를 받도록 설계되어 있음. |
| 토큰 삭제 위치 | A) `onAuthenticationExpired` 클로저 내부<br>B) `TokenManagerImpl` 내부 | B | 토큰 관리 객체가 직접 삭제하는 것이 책임에 맞음. 클로저는 순수하게 앱 이벤트 전파만 담당. |
| 토큰 삭제 실패 처리 | A) 에러를 상위로 전파<br>B) `try?`로 호출하여 무시 | B | 토큰 삭제 실패가 리프레시 토큰 만료 플로우를 중단시켜서는 안 됨. 이미 인증이 만료된 상태이므로 삭제 실패는 무시하고 계속 진행. |
| URL 파싱 실패 처리 | A) `fatalError`<br>B) 기본값 하드코딩<br>C) 옵셔널 언래핑 with early return | A | 빌드 설정 누락은 개발 환경에서 즉시 발견되어야 함. `fatalError`로 개발자에게 명확히 알림. 릴리즈 환경에서도 실행되지 않도록 `assertionFailure`로 변경 고려 가능. |

## 주의 사항
- `App-Info.plist`의 `BASE_URL`은 `$(BASE_URL)` 변수이며 실제 값은 xcconfig에서 주입됨.
- `onAuthenticationExpired` 클로저는 `@Sendable`이므로 `@MainActor`로 노티피케이션 발송하려면 `Task { @MainActor in ... }`로 감싸야 함.
- `.reloginRequired` 노티피케이션은 기존 `LivithNetwork` 모듈에 정의되어 있으나, 문자열 리터럴 `Notification.Name("reloginRequired")`를 사용하여 `import LivithNetwork`를 피함.
- App 모듈에 LivithNetworking 의존성 추가 시 Tuist generate로 모듈 그래프 재생성 필요.
- 기존 Data 모듈 교체는 별도 작업으로 분리.
- `TokenManagerImpl`은 `actor`이므로 `tokenStore.remove()` 호출 시 `await` 필요.

## 검증 방법
- `tuist generate` 실행 성공
- `xcodebuild build` 성공
- `NetworkingFactory`를 DIContainer에서 resolve할 수 있는지 확인 (런타임 또는 단위 테스트)
  - 예: `let factory: NetworkingFactory = DIContainer.shared.resolve(NetworkingFactory.self)`가 정상 동작하는지 확인
