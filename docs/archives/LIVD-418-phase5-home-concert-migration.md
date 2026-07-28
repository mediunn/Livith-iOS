# [LIVD-418] Phase 5 — HomeService + ConcertService → UserData + ConcertData

## 배경
- 마이그레이션 마지막 단계. Phase 1~4 완료.
- HomeService는 UserData·ConcertData 양쪽이 의존하는 공유 서비스다.
- ConcertData는 4개 서비스(ConcertService, HomeService, SearchService, SetlistService)에 의존하는 가장 복잡한 Data 모듈이다.
- SetlistService는 이미 마이그레이션 완료. `fetchConcertMainSetlist` 1개 메서드만 추가한다.

## 목표
- `UserData`·`ConcertData` 모듈이 `LivithNetwork` 대신 `LivithNetworking`을 사용하도록 변경.
- `LivithNetworking`에 HomeService, ConcertService 신규 선언. SetlistService에 `fetchConcertMainSetlist` 추가.
- `NetworkingFactory`에서 모든 서비스를 생성·제공.
- 모든 기존 테스트가 새 `NetworkError` 기반으로 통과.

---

## 포팅 대상 DTO

### HomeService (7개 파일)
| 파일 | 종류 | 용도 |
|------|------|------|
| `FetchHomeSectionList.swift` | Response | 홈 섹션 목록 |
| `FetchUserInterestConcert.swift` | Request + Response | 관심 콘서트 목록 조회 |
| `CheckInterestedConcert.swift` | Response | 관심 콘서트 여부 확인 |
| `UpdateUserInterestConcert.swift` | Request + Response | 관심 콘서트 등록 |
| `UpdateUserInterestConcertList.swift` | Request + Response | 관심 콘서트 목록 수정 |
| `InterestConcertToast.swift` | Request + Response | 관심 콘서트 토스트 정책/표시 |
| `FetchRecommendedConcertList.swift` | Response | 추천 콘서트 목록 |

**제외:** `FetchConcertMainSetlist.swift` — `FetchConcertSetlist`와 필드 동일하므로 DTO 통합. SetlistService 메서드만 추가.

### ConcertService (7개 파일)
| 파일 | 종류 | 용도 |
|------|------|------|
| `FetchConcertInfo.swift` | Response | 콘서트 상세 |
| `FetchConcertSchedule.swift` | Response | 콘서트 일정 |
| `FetchConcertCultureList.swift` | Response | 공연 문화 정보 |
| `FetchConcertInfoList.swift` | Response | 공연 정보 목록 |
| `FetchConcertMerchandiseList.swift` | Response | MD 상품 목록 |
| `FetchConcertSetlistList.swift` | Response | 콘서트 셋리스트 목록 |
| `FetchConcertArtistInfo.swift` | Response | 아티스트 정보 |

---

## Service 설계

### HomeService

| 메서드 | Method | Task | Auth |
|--------|--------|------|------|
| `fetchSectionList()` | GET | `.plain` | `.none` |
| `fetchInterestedConcertList(sort:, size:, cursorDate:, cursorID:)` | GET | `.query(...)` | `.required` |
| `checkInterestedConcert(concertID:)` | GET | `.plain` | `.required` |
| `updateInterestedConcert(concertID:)` | POST | `.body(...)` | `.required` |
| `updateInterestedConcertList(concertIDList:)` | PUT | `.body(...)` | `.required` |
| `deleteInterestedConcert()` | DELETE | `.plain` | `.required` |
| `fetchRecommendedConcertList()` | GET | `.plain` | `.required` |
| `fetchInterestConcertToast()` | GET | `.plain` | `.required` |
| `markInterestConcertToastShown()` | PATCH | `.plain` | `.required` |

### ConcertService

| 메서드 | Method | Task | Auth |
|--------|--------|------|------|
| `fetchConcertInfo(concertID:)` | GET | `.plain` | `.none` |
| `fetchConcertSchedule(concertID:)` | GET | `.plain` | `.none` |
| `fetchConcertCultureList(concertID:)` | GET | `.plain` | `.none` |
| `fetchConcertInfoList(concertID:)` | GET | `.plain` | `.none` |
| `fetchConcertMerchandiseList(concertID:)` | GET | `.plain` | `.none` |
| `fetchConcertSetlistList(concertID:)` | GET | `.plain` | `.none` |
| `fetchConcertArtistInfo(concertID:)` | GET | `.plain` | `.none` |

### SetlistService 확장

| 메서드 | Method | Task | Auth |
|--------|--------|------|------|
| `fetchConcertMainSetlist(concertID:)` | GET | `.plain` | `.none` |

Response DTO는 기존 `DTO.Response.FetchConcertSetlist` 재사용. 별도 DTO 파일 생성하지 않음.

---

## 영향 범위

| 모듈 | 파일 | 유형 |
|------|------|------|
| LivithNetworking | `DTO/Home/` (7개) | 신규 |
| LivithNetworking | `DTO/Concert/` (7개) | 신규 |
| LivithNetworking | `Service/HomeService.swift` | 신규 |
| LivithNetworking | `Service/ConcertService.swift` | 신규 |
| LivithNetworking | `Service/SetlistService.swift` | 수정 (메서드 1개 추가) |
| LivithNetworking | `Service/NetworkingFactory.swift` | 수정 |
| LivithNetworking | `Tests/.../NetworkingFactoryTests.swift` | 수정 |
| Data | `Project.swift` | 수정 (userData, concertData) |
| UserData | `Assembler`, `RepositoryImpl`, `Mapper`, `ErrorMapper`, `Tests` | 수정 |
| ConcertData | `Assembler`, `RepositoryImpl`, `Mapper`, `ErrorMapper`, `Tests` | 수정 |

---

## 작업 항목

- [ ] LivithNetworking에 Home DTO 선언 (7개)
- [ ] LivithNetworking에 Concert DTO 선언 (7개)
- [ ] LivithNetworking에 HomeService 선언 (protocol + impl, 9 메서드)
- [ ] LivithNetworking에 ConcertService 선언 (protocol + impl, 7 메서드)
- [ ] SetlistService에 `fetchConcertMainSetlist` 추가
- [ ] NetworkingFactory에 `makeHomeService()`, `makeConcertService()` 추가
- [ ] NetworkingFactoryTests 업데이트
- [ ] Data/Project.swift: userData, concertData 의존성 변경
- [ ] UserData 마이그레이션 (Assembler, RepositoryImpl, Mapper, ErrorMapper, Tests)
- [ ] ConcertData 마이그레이션 (Assembler, RepositoryImpl, Mapper, ErrorMapper, Tests)
- [ ] `tuist generate` + `xcodebuild test` 검증
- [ ] 서브에이전트 리뷰
- [ ] 계획 문서 아카이브

---

## 주의 사항

### UserData 특이사항
- UserData는 3개 서비스(UserService, OnboardingService, HomeService)를 주입받는다. Phase 4에서 UserService·OnboardingService는 이미 LivithNetworking으로 변경됐지만 UserData는 아직 아니다. 이번에 한꺼번에 변경.
- `UserRepositoryImpl`에서 `EmptyResponse`를 `DTO.Response.EmptyResponse`가 아닌 `EmptyResponse`로 참조해야 한다 (NotificationData와 동일 이슈).
- `fetchInterestedConcertList`는 `InterestConcertListNextToken` 등 복잡한 cursor/token 변환 로직 포함.

### ConcertData 특이사항
- ConcertData는 4개 서비스 의존. SearchService·SetlistService는 이미 LivithNetworking에 있으므로 ConcertService·HomeService만 추가하면 된다.
- `ConcertRepositoryImpl`의 `fetchMainSetlist`는 `setlistService.request(.fetchConcertMainSetlist(...))` 호출. 새 SetlistService의 `fetchConcertMainSetlist`로 변경.
- `fetchAllConcertList`는 `searchService.request(.fetchConcertList(...))` 호출. 이미 마이그레이션된 SearchService의 `fetchConcertList`로 변경.

### EmptyResponse
- UserData의 `deleteInterestedConcert`, `markInterestConcertToastShown`는 `EmptyResponse`를 사용한다. `DTO.Response.EmptyResponse` 대신 `EmptyResponse` 사용.

### 인증 정책
- ConcertService: 전부 `.none` (기존 `requiresInterceptor: false`)
- HomeService: `fetchSectionList`만 `.none`, 나머지 전부 `.required`
- SetlistService 추가 메서드: `.none`

---

## 검증 방법
1. `tuist generate` 성공
2. `xcodebuild test`로 UserData·ConcertData 테스트 통과
3. `NetworkingFactoryTests` 전체 통과
4. `import LivithNetwork` 잔존 0건 확인 (UserData, ConcertData)
