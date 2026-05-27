# LIVD-418 Networking Service 계층 제거 - 트러블슈팅

## 기록

### 2026-05-27 13:40 - Mermaid 다이어그램 특수문자 이스케이프 누락

**상황**
- `LivithNetworking/README.md`의 Service 계층 제거 내용을 반영하면서 mermaid 다이어그램을 갱신함.
- `현재 범위` flowchart에 추가한 `*API` 관련 노드가 GitHub에서 렌더링되지 않음.

**문제**
- `[*API 네임스페이스 (10종)]` 구문에서 mermaid 파서 에러 발생.
- GitHub README에서 해당 다이어그램 전체가 표시되지 않음.
- 파서 에러 메시지: `Parse error on line 17:...--> API[*API 네임스페이스 (10종)] ^ Expecting 'SQE', 'DOUBLECIRCLEEND', ... got 'PS'`

**원인**
- `*` 문자는 mermaid flowchart에서 노드 모양 modifier로 해석됨 (`[` 바로 뒤에 오는 `*`는 특수 구문).
- `(`와 `)`도 mermaid가 노드 라벨의 일부가 아닌 문법 토큰으로 인식함.
- 클래스 다이어그램의 `+build(...) (NetworkClient, TokenStore)`도 동일한 문제 — return type의 괄호가 메서드 시그니처 파싱을 깨트림.
- `+data(for:) async -> (Data, URLResponse)`의 `->`가 mermaid에서 화살표로 오해석됨.

**해결**
1. `[*API 네임스페이스 (10종)]` → `["*API 네임스페이스 (10종)"]` — 따옴표로 감싸 라벨 전체를 리터럴로 처리.
2. `+build(config, ...) (NetworkClient, TokenStore)` → `+build(config, ...)` — return type 제거.
3. `+data(for:) async -> (Data, URLResponse)` → `+data(for:) async` — Swift 반환 타입 표기 제거.

**교훈**
- mermaid 노드 라벨에 `*`, `(`, `)`, `->` 등 특수문자가 포함되면 반드시 큰따옴표로 감싼다.
- 클래스 다이어그램의 메서드 시그니처는 mermaid 고유 문법을 따라야 하며, Swift 문법(`->`, 튜플 반환)을 그대로 쓰면 파싱 실패한다.
- 라벨에 특수문자가 있는지 검증할 때는 정규식 `\[[^\]]*[*()<>-][^\]]*\]`로 일괄 확인 가능.

---

<!-- 새 항목은 위에 추가한다 (최신순 정렬) -->
