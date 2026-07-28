# LIVD-424 DebugNetworkPlugin 출력 형식 변경

## 배경
- 현재 `DebugNetworkPlugin`은 한 줄 로그(`[✅ 200] GET /concerts`)만 출력한다.
- 디버깅 시 응답 body, 헤더 정보 등 더 풍부한 정보가 필요해졌다.
- 민감 정보(토큰, 이메일, providerID)가 로그에 노출되지 않도록 마스킹이 필요하다.

## 목표
- REQUEST / RESPONSE / ERROR 블록을 멀티라인 박스 프레임으로 구조화된 출력으로 변경한다.
- URL은 path만 출력한다 (기존과 동일).
- 요청 헤더(Authorization, Cookie)의 민감 값은 `***`로 마스킹한다.
- 요청/응답 body는 JSON으로 포맷팅하고, 민감 키(`accessToken`, `refreshToken`, `identityToken`, `token`, `email`, `providerID`, `providerId`)의 값을 `***`로 마스킹한다.
- HTTP status code는 설명(`200 OK`)과 함께 출력한다.
- 오류 발생 시 `❌ ERROR` 블록으로 출력한다.

## 작업 항목
- [x] 1. 테스트: 새 출력 형식에 대한 실패 테스트 작성
  - 요청 로그 멀티라인 포맷 검증 (🌐 REQUEST 블록, Method, URL path, Headers 마스킹, Body 마스킹)
  - 성공 응답 로그 멀티라인 포맷 검증 (📥 RESPONSE 블록, Status 설명, Body 마스킹)
  - 실패 응답 로그 멀티라인 포맷 검증 (❌ ERROR 블록, Reason)
  - body 없는 케이스 `(none)` 처리 검증
  - 비JSON body 처리 검증
  - 중첩 JSON 마스킹 검증 (예: `{"user": {"email": "test@test.com"}}` → 내부까지 `***` 처리)
  - 기존 테스트가 새 포맷에 맞게 업데이트

- [x] 2. 구현: Body 포맷팅 및 마스킹
  - JSON body 파싱 → `[String: Any]` 재귀 탐색 → 민감 키 값 `"***"` 치환 → pretty print
  - 중첩 객체(`user.email`, `tempUser.email`) 및 배열 내 객체까지 재귀적으로 마스킹
  - 비JSON body는 바이트 수만 출력
  - body 없는 경우 `(none)` 출력

- [x] 3. 구현: Header 마스킹
  - `Authorization`, `Cookie` 값 `***` 처리

- [x] 4. 구현: 새 출력 형식
  - `willSend`: 🌐 REQUEST 블록 → Method, URL(path), Headers, Body
  - `didReceive .success`: 📥 RESPONSE 블록 → Status, URL(path), Body
  - `didReceive .failure`: ❌ ERROR 블록 → Reason, URL(path)

- [x] 5. 검증: 전체 테스트 실행 및 통과 확인

- [x] 6. 구현 리뷰: `impl-review` 스킬을 통해 계획 대비 산출물 검증
  - 서브에이전트(fork)를 통해 계획 문서(`docs/plans/LIVD-424-networking-plugin-debug-output.md`) 대비 실제 코드 산출물을 리뷰
  - Critical / Major 이슈 없음 — PASS
  - 6개 차원(Spec Compliance, Simplicity, Correctness, Consistency, Quality, Fresh Perspective) 모두 통과

## 영향 범위
| 파일 | 변경 내용 |
|------|-----------|
| `Projects/LivithNetworking/Sources/Foundation/Plugin/DebugNetworkPlugin.swift` | 출력 형식 전면 재작성, body/header 포맷터 추가 |
| `Projects/LivithNetworking/Tests/Plugin/DebugNetworkPluginTests.swift` | 기존 테스트 업데이트 + 새 포맷 검증 테스트 추가 |

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| URL 표시 범위 | path only vs full URL | path only | 민감 쿼리 파라미터 노출 방지, 기존 정책 유지 |
| Body 마스킹 전략 | 키 기반 vs 휴리스틱 vs 하이브리드 | 키 기반 단독 | 프로젝트 민감 필드가 명확한 키 이름으로 제한됨, 오탐 0건 |
| 마스킹 대상 키 | — | `accessToken`, `refreshToken`, `identityToken`, `token`, `email`, `providerID`, `providerId` | DTO 전체 분석 결과 |
| Header 마스킹 대상 | — | `Authorization`, `Cookie` | 토큰/세션 정보 보호 |
| 비JSON body 처리 | raw 출력 vs 바이트 수 | 바이트 수(`(N bytes)`) | binary body는 디버깅 가치 낮음 |
| 소요 시간 표시 | 포함 vs 제외 | 제외 | 이번 작업 범위 아님 |
| Status 코드 설명 | 숫자만 vs 설명 포함 | `200 OK` 형식 | 가독성 |

## 주의 사항
- body 마스킹은 JSON 파싱 실패 시 원본 body를 출력하지 않는다 (바이트 수만 표시).
- `NetworkPlugin` 프로토콜 시그니처 변경 없음.
- 보안 규칙(`docs/rules/security.md`): FCM Token, 인증 응답 원문 노출 없음 확인.

## 출력 포맷 템플릿

### REQUEST (willSend)
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌐 REQUEST
  Method:  GET
  URL:     /concerts
  Headers: [Authorization: Bearer ***]
  Body:    {"email":"***","nickname":"진웅"}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### RESPONSE (didReceive .success)
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📥 RESPONSE
  Status:  200 OK
  URL:     /concerts
  Body:    {"accessToken":"***","user":{"email":"***"}}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### ERROR (didReceive .failure)
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ ERROR
  Reason:  timeout
  URL:     /concerts
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 검증 방법
- `xcodebuildmcp`의 `XcodeBuildMCP_test_sim` 도구를 사용하여 테스트 실행 및 통과 확인.
- `XcodeBuildMCP_build_sim` 도구를 사용하여 빌드 성공 확인.
- 사전 설정: `XcodeBuildMCP_session_set_defaults`로 scheme(`LivithNetworking`)과 시뮬레이터(`iPhone 16`)를 지정한다.
