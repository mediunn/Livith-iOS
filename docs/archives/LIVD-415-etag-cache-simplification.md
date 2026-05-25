# [LIVD-415] 커스텀 ETag 캐시 제거 및 URLCache 위임

## 배경
- `ETagCacheHandler` + `MemoryETagCacheStore`로 직접 ETag 캐싱을 구현하고 있으나, 시스템 `URLCache`도 ETag를 자동 처리할 수 있다.
- 현재는 서버가 `Cache-Control` 없이 `ETag`만 전송하지만, 서버 개발자가 `Cache-Control` 헤더도 추가할 예정이다.
- `urlCache = nil`로 URLCache를 비활성화한 상태인데, 이를 제거하면 URLCache가 시스템 수준에서 ETag를 자동 처리한다.
- 커스텀 캐시 저장소 대신 URLCache에 위임하면 코드가 크게 간소화된다 (~180줄 제거).

## 목표
- `ETagCacheHandler`, `ETagCacheStore`, `MemoryETagCacheStore` 파일 제거
- `NetworkClient`에서 `etagCache` 관련 속성, 로직, `removeAllETagCache()` 제거
- `NetworkEndpoint.CachePolicy`를 `RequestBuilder`가 읽어 `URLRequest.cachePolicy`로 적용
- `NetworkClient.init()`의 `urlCache = nil` 제거 → URLCache 기본 동작 복원
- `ETagCacheResult` enum 제거 (ETagCacheHandler 전용)

## 작업 항목
- [x] `NetworkClient`에서 `etagCache` 제거
  - `etagCache` 속성 제거
  - init에서 `etagStore` 파라미터 제거, `etagCache = ETagCacheHandler(store: ...)` 라인 제거
  - `removeAllETagCache()` 메서드 제거
  - `load()`에서 `key`, `etagCache.apply()`, `handleETag()` 호출 전부 제거
  - `handleETag()` 메서드 제거
  - `urlCache = nil` 제거 → `URLSessionConfiguration.ephemeral`만 사용하거나 `.default`로 전환
- [x] `RequestBuilder`에서 `CachePolicy` 적용
  - `makeURL`에서 endpoint의 `cache` 정책을 `URLRequest.cachePolicy`에 반영
  - `.disabled` → `.reloadIgnoringLocalCacheData`
  - `.enabled` → `.useProtocolCachePolicy`
- [x] Cache 파일 3개 삭제
  - `Sources/Cache/ETagCacheHandler.swift`
  - `Sources/Cache/ETagCacheStore.swift` (`ETagCacheStore`, `ETagCacheEntry`, `ETagCacheResult`)
  - `Sources/Cache/MemoryETagCacheStore.swift`
- [x] `ETagCacheResult` 제거에 따른 컴파일 오류 해결
  - 모든 참조 확인 후 처리 (현재 `NetworkClient.handleETag()`와 `ETagCacheHandler.handle()`에서만 사용)
- [x] 테스트 정리 및 수정
  - `NetworkClientTests`: ETag 관련 테스트 제거/수정 (304 캐시 hit, 304 fallback, ETag 비활성화, If-None-Match, removeAllETagCache 등)
  - 기존 캐시 관련 검증을 `URLRequest.cachePolicy` 검증으로 대체

## 영향 범위
| 모듈 | 파일 | 상태 |
|------|------|------|
| LivithNetworking | `Sources/Cache/ETagCacheHandler.swift` | 삭제 |
| LivithNetworking | `Sources/Cache/ETagCacheStore.swift` | 삭제 |
| LivithNetworking | `Sources/Cache/MemoryETagCacheStore.swift` | 삭제 |
| LivithNetworking | `Sources/Client/NetworkClient.swift` | 수정 |
| LivithNetworking | `Sources/Request/RequestBuilder.swift` | 수정 |
| LivithNetworking | `Sources/Request/NetworkEndpoint.swift` | 변경 없음 (이미 `CachePolicy` enum 보유) |
| LivithNetworking | `Tests/Client/NetworkClientTests.swift` | 수정 |

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| URLCache 활성화 방식 | A: `.ephemeral`에서 `urlCache = nil`만 제거<br>B: `.default`로 전환 | **A** | `.ephemeral`은 디스크 캐시를 안 써서 보안상 낫고, `urlCache`만 제거하면 in-memory URLCache가 생성되어 ETag 자동 처리 |
| `URLRequest.cachePolicy` 매핑 | A: `.disabled` → `.reloadIgnoringLocalCacheData`<br>B: `.disabled` → `.returnCacheDataDontLoad` | **A** | 인증/민감 데이터는 매번 서버 확인해야 함. `.reloadIgnoringLocalCacheData`는 캐시를 무시하고 서버에 요청하지만 304 응답은 허용 |
| `ETagCacheResult` | A: ETagCacheHandler와 함께 삭제<br>B: requestBuilder로 이동 | **A** | ETagCacheHandler 전용 타입이므로 함께 삭제 |

## 주의 사항
- `URLSessionConfiguration.ephemeral`의 기본 `urlCache`는 in-memory 전용이므로 앱 재시작 시 캐시가 유지되지 않는다. 디스크 캐시가 필요하면 `.default`로 변경해야 하지만, 현재는 in-memory면 충분하다.
- `NetworkEndpoint`의 `CachePolicy` enum은 `LivithNetworking` 모듈 내부 타입(`ETagCacheHandler`)에서 사용되었으나, 제거 후에는 외부에서만 사용하므로 `public` 접근 수준 유지.

## 검증 방법
1. `tuist generate` 성공
2. `LivithNetworkingTests` 전체 통과 (126개 → ETag 관련 제거 후 개수 조정)
3. `SongDataTests` 전체 통과
4. 실제 앱 실행 시 `[요청] GET /api/v6/songs/123 🔖...` 와 `[✅ 304] GET /api/v6/songs/123` 콘솔 확인 (URLCache ETag 동작 검증)
