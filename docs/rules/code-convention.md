# 코드 컨벤션

## Purpose
- 이 저장소에서 AI가 기존 Swift 코드와 같은 형태로 파일을 작성하고 수정하기 위한 코드 컨벤션을 정의한다.
- 파일 구조, `MARK 섹션`, 접근 제어, 오류 선언, 제어 흐름의 흔들림을 줄이기 위한 작업 기준을 고정한다.

## Scope
- `Projects/**` 아래의 Swift 소스 파일에 적용한다.
- 아키텍처 선택보다 Swift 코드의 파일 구성, 선언 방식, 주석 형태에 적용한다.
- 다음 용어는 이 문서에서 아래 의미로 사용한다.
- `Store 파일`: `ObservableObject`를 중심으로 상태와 이벤트 처리 코드를 담는 Swift 파일
- `View 파일`: SwiftUI `View` 또는 `UIViewControllerRepresentable` 구현을 담는 Swift 파일
- `Assembler 파일`: 의존성 등록 구현을 담는 Swift 파일
- `Data 파일`: `RepositoryImpl`, `Mapper`, `Assembler` 구현을 담는 Swift 파일
- `MARK 템플릿 적용 파일`: `View 파일`, `Store 파일`, `Assembler 파일`
- `비핵심 Swift 파일`: `MARK 템플릿 적용 파일`이 아닌 Swift 소스 파일
- `같은 역할 파일`: 같은 디렉터리에 있고 파일명 접두사 또는 접미사가 같은 Swift 파일
- `도우미 extension`: 파일 하단에 두는 `private extension 타입명 { ... }` 형태의 구현 블록
- `필요한 MARK 섹션`: `docs/templates/mark-template.md`에 정의된 섹션 중 해당 파일에 실제 코드가 있는 섹션
- `로컬 모듈 import`: 저장소 내부 모듈 import
- `외부 라이브러리 import`: 저장소 밖 패키지 또는 SDK import
- `typed throws`: `throws(ErrorType)` 또는 `async throws(ErrorType)`처럼 구체적인 에러 타입을 시그니처에 명시하는 Swift 6 오류 선언 방식
- `조기 종료 조건`: 실패 조건을 먼저 검사하고 `return`, `continue`, `break`, `throw`로 흐름을 끝낼 수 있는 조건
- `MARK 템플릿 적용 파일`의 `MARK 섹션`은 `docs/templates/mark-template.md`를 기준으로 작성한다.
- 새 `비핵심 Swift 파일`의 `MARK 섹션`은 `같은 역할 파일`을 먼저 따른다.
- `같은 역할 파일`이 없으면 새 `비핵심 Swift 파일`에 `MARK 섹션`을 추가하지 않는다.
- 테스트 코드는 `docs/rules/tdd.md`를 따른다.

## Do
### File Structure
- import는 Apple 프레임워크를 먼저 두고 한 줄 비운 뒤 `로컬 모듈 import`를 두고 다시 한 줄 비운 뒤 `외부 라이브러리 import`를 둔다.
- Swift 코드는 Swift 6 문법으로 작성한다.
- 기존 Swift 파일의 헤더 주석은 임의로 수정하지 않는다.
- 새 Swift 파일을 만들 때는 같은 디렉터리의 기존 파일 헤더 형식을 따른다.
- 작성자 표기가 필요하면 실제 사용자의 이름만 사용한다.
- `View 파일`의 계산 프로퍼티, 보조 UI 조합, 이벤트 헬퍼는 본문 아래 `도우미 extension`으로 분리한다.
- `Store 파일`의 내부 처리 로직, 비동기 작업, 상태 보조 메서드는 본문 아래 `도우미 extension`으로 분리한다.

### MARK
- `MARK 섹션`은 항상 `// MARK: - 섹션명` 형식으로만 쓴다.
- `MARK 템플릿 적용 파일`에서 `필요한 MARK 섹션`이 3개 이상이면 `MARK 섹션`을 쓴다.
- `MARK 템플릿 적용 파일`의 `MARK 섹션` 이름과 순서는 `docs/templates/mark-template.md`를 그대로 따른다.
- 기존 `MARK 템플릿 적용 파일`을 수정하면서 `MARK 섹션`을 함께 수정할 때는 템플릿 이름으로 맞춘다.

### Access Control
- 모듈 밖에서 써야 하는 타입과 멤버에만 `public`을 명시한다.
- 모듈 안에서만 쓰는 타입과 멤버에는 `internal`을 명시하지 않는다.
- 같은 타입 내부 구현에는 `private`를 사용한다.
- 같은 파일의 별도 타입 또는 extension 간 공유가 꼭 필요할 때만 `fileprivate`를 사용한다.
- 상속 의도가 없는 클래스는 `final class`로 선언한다.
- `Store 파일`의 상태 노출은 `@Published private(set)` 또는 `@Published public private(set)` 형태로 제한한다.

### Private Extension
- 타입 내부의 `private 메서드`는 반복 선언하지 않고 역할별 `private extension`으로 모은다.
- `private extension` 안의 메서드는 `private func` 대신 `func`로 선언한다.

### Error Handling
- 저장소 내부에서 새로 정의하는 `throw` 가능 API는 `typed throws`를 사용한다.

### Control Flow
- `조기 종료 조건`은 `if`보다 `guard`를 우선 사용한다.
- 실패 조건, nil 검사, 타입 캐스팅 실패, 빈 값 검사는 함수 초반 `guard`로 먼저 정리한다.
- 조건 분기가 늘어날 때는 조기 반환과 보조 메서드 분리로 중첩을 줄인다.

## Don't
### File Structure
- `View 파일`에서 계산 프로퍼티와 헬퍼 메서드를 `body` 주변에 흩어 놓지 않는다.
- `Store 파일`에서 내부 처리 로직을 공개 인터페이스 사이에 섞어 넣지 않는다.
- 작성자 이름에 AI 에이전트 이름이나 도구 이름을 넣지 않는다.
- 실제 사용자의 이름을 확실히 알 수 없으면 작성자 이름을 추측해 넣지 않는다.

### MARK
- 같은 파일 안에서 `// MARK:` 형식과 임의의 구분 주석 형식을 혼용하지 않는다.
- `MARK 템플릿 적용 파일`에 `docs/templates/mark-template.md`에 없는 `MARK 섹션명`을 임의로 만들지 않는다.
- 기존 `MARK 템플릿 적용 파일`이 예전에 다른 `MARK 섹션명`을 썼다는 이유로 새 코드에도 그 이름을 복제하지 않는다.

### Access Control
- 모듈 밖에서 쓰지 않는 타입과 멤버에 `public`을 추가하지 않는다.
- 같은 타입 내부 구현에 `fileprivate`를 사용하지 않는다.
- 상속하지 않는 클래스에 `open class`나 일반 `class`를 사용하지 않는다.
- `Store`의 상태를 외부에서 직접 수정할 수 있게 공개 setter로 열어 두지 않는다.

### Private Extension
- 같은 타입 본문 안에 `private func`를 여러 개 나열하지 않는다.
- `private extension` 안의 메서드에 `private func`를 반복해서 쓰지 않는다.

### Error Handling
- 저장소 내부에서 새로 정의하는 `throw` 가능 API를 untyped `throws`로 선언하지 않는다.

### Control Flow
- `조기 종료 조건`을 본문 안쪽 `if` 중첩으로 처리하지 않는다.
- 여러 단계의 `if` 중첩으로 깊은 중첩을 만들지 않는다.

## Exception
- `MARK 템플릿 적용 파일`에서 `필요한 MARK 섹션`이 2개 이하면 `MARK 섹션`을 생략할 수 있다.
- `NSObject` 상속, delegate 연결, 시스템 프로토콜 적합성 때문에 `final class`가 맞지 않는 경우에는 예외로 둘 수 있다.
- 외부 프로토콜, 시스템 API, 서드파티 API 시그니처가 untyped `throws`를 강제하는 경우에는 그 시그니처를 그대로 따른다.
- 생성 코드, 매크로 확장 결과, 외부 도구가 고정 출력하는 Swift 코드는 해당 도구 출력 형식을 우선 따른다.
- `비핵심 Swift 파일`은 `같은 역할 파일`을 따른다.
- `같은 역할 파일`이 없으면 새 `비핵심 Swift 파일`에 `MARK 섹션`을 추가하지 않는다.
- 한 번의 예외로 템플릿 밖 `MARK 섹션명`이나 untyped `throws` 사용을 다른 내부 API로 확장하지 않는다.

## Checklist
### File Structure
- Apple 프레임워크 import와 `로컬 모듈 import` 사이에 한 줄이 비어 있는지 확인한다.
- `로컬 모듈 import`와 `외부 라이브러리 import` 사이에 한 줄이 비어 있는지 확인한다.
- 기존 Swift 파일의 헤더 주석을 임의로 바꾸지 않았는지 확인한다.
- 새 Swift 파일의 헤더가 같은 디렉터리의 기존 파일 형식을 따르는지 확인한다.
- 작성자 이름에 실제 사용자 이름만 사용했고, 에이전트 이름이나 추측한 이름을 넣지 않았는지 확인한다.
- `View 파일`에서 계산 프로퍼티와 보조 UI 조합이 `도우미 extension`으로 내려가 있는지 확인한다.
- `Store 파일`에서 내부 처리 로직이 `도우미 extension`으로 내려가 있는지 확인한다.

### MARK
- `MARK 섹션`이 항상 `// MARK: - 섹션명` 형식인지 확인한다.
- `MARK 템플릿 적용 파일`에서 `필요한 MARK 섹션`이 3개 이상이면 `MARK 섹션`을 썼는지 확인한다.
- `MARK 템플릿 적용 파일`의 `MARK 섹션` 이름과 순서가 `docs/templates/mark-template.md`와 일치하는지 확인한다.

### Access Control
- 모듈 밖에서 쓰지 않는 타입과 멤버에 `public`을 붙이지 않았는지 확인한다.
- 모듈 안에서만 쓰는 타입과 멤버에 `internal`을 명시하지 않았는지 확인한다.
- 같은 타입 내부 구현에 `private`를 사용했는지 확인한다.
- 같은 파일의 별도 타입 또는 extension 간 공유가 꼭 필요할 때만 `fileprivate`를 사용했는지 확인한다.
- 상속 의도가 없는 클래스가 `final class`로 선언됐는지 확인한다.
- `Store`의 상태가 `private(set)`으로 보호되고 있는지 확인한다.

### Private Extension
- 타입 내부의 `private 메서드`가 역할별 `private extension`으로 묶여 있는지 확인한다.
- `private extension` 안의 메서드가 `private func`가 아니라 `func`로 선언됐는지 확인한다.

### Error Handling
- 저장소 내부에서 새로 정의한 `throw` 가능 API가 `typed throws`를 사용하고 있는지 확인한다.

### Control Flow
- `조기 종료 조건`을 `guard`로 먼저 정리했는지 확인한다.
- 여러 단계의 조건문이 조기 반환이나 보조 메서드 분리 없이 깊게 중첩되지 않았는지 확인한다.
