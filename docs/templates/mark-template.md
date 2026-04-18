# MARK 템플릿

## Purpose
- 이 저장소에서 Swift 파일의 `MARK` 주석을 일관되게 작성하기 위한 템플릿이다.
- 파일 종류별로 사용할 `MARK` 이름과 권장 순서를 고정한다.

## Common Rules
- `MARK` 주석은 항상 `// MARK: - 섹션명` 형식으로 쓴다.
- 같은 역할에는 같은 `MARK` 이름만 쓴다.
- 허용 목록 밖의 새 `MARK` 이름을 만들지 않는다.
- 템플릿 허용 목록 기준으로 필요한 `MARK` 섹션이 2개 이하면 `MARK` 주석을 생략할 수 있다.
- 내부 구현 메서드는 타입 본문보다 `private extension`에 모은다.
- `private extension` 안의 메서드는 `private func` 대신 `func`로 선언한다.

## View File
- 허용 `MARK`: `Property`, `Initializer`, `Body`, `Computed Properties`, `UIComponents`, `Helpers`, `Preview`
- 권장 순서: `Property` -> `Initializer` -> `Body` -> `Computed Properties` -> `UIComponents` -> `Helpers` -> `Preview`

```swift
struct ExampleView: View {

    // MARK: - Property

    // MARK: - Initializer

    // MARK: - Body
}

// MARK: - Computed Properties

private extension ExampleView {}

// MARK: - UIComponents

private extension ExampleView {}

// MARK: - Helpers

private extension ExampleView {}

// MARK: - Preview

#Preview {}
```

## Store File
- 허용 `MARK`: `State`, `Intent`, `Store`, `Public Interface`, `Helpers`
- 권장 순서: `State` -> `Intent` -> `Store` -> `Public Interface` -> `Helpers`

```swift
// MARK: - State

struct ExampleState {}

// MARK: - Intent

enum ExampleIntent {}

// MARK: - Store

final class ExampleStore: ObservableObject {

    // MARK: - Public Interface
}

// MARK: - Helpers

private extension ExampleStore {}
```

## Assembler File
- 허용 `MARK`: `Repository Registration`, `Network Registration`, `Service Registration`, `Storage Registration`
- 필요한 등록 섹션만 쓴다.

```swift
public struct ExampleAssembler: DependencyAssembler {
    public func assemble(to container: any DependencyContainer) {
        registerService(to: container)
        registerRepository(to: container)
    }
}

// MARK: - Repository Registration

private extension ExampleAssembler {}

// MARK: - Service Registration

private extension ExampleAssembler {}
```

## Disallowed Names
- `Private`
- `Helper`
- `Helper Method`
- `Private Methods`
- `UI Components`
- `Public Methods`
