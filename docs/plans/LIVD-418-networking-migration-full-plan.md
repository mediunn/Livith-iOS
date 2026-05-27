# [LIVD-418] 전체 Data 모듈 LivithNetworking 마이그레이션 — 전체 계획

## 배경
- 기존 `LivithNetwork`(Alamofire) → `LivithNetworking`(URLSession) 교체 작업.
- 이미 완료: SongData(LIVD-415), SetlistData(LIVD-418), CommentData(LIVD-418).
- 남은 6개 Data 모듈도 동일한 패턴으로 마이그레이션 필요.
- 단순한 모듈과 달리, 남은 모듈들은 **하나의 서비스를 여러 Data가 공유**하는 구조다 (예: `HomeService`는 UserData·ConcertData가 함께 사용).

## 남은 Data 모듈 및 서비스 의존 관계

```
SearchService ──── SearchData, ConcertData
PreferenceService ──── PreferenceData
NotificationService ──── NotificationData
UserService ──── AuthData, UserData
OnboardingService ──── AuthData, UserData
HomeService ──── UserData, ConcertData
ConcertService ──── ConcertData
SetlistService(확장) ──── ConcertData
```

**핵심 전략:** "서비스를 먼저 만들고, 그 서비스를 쓰는 Data 모듈을 업데이트한다."

---

## 마이그레이션 순서 (5 Phase)

### Phase 1: SearchService → SearchData
- **DTO**: SearchFeature 5개 (`FetchBannerList`, `FetchConcertList`, `FetchFilterSearchResult`, `FetchRecommendKeywordList`, `FetchSectionList`)
- **특징**: 전부 GET, 인증 불필요(`.none`), 단일 서비스
- **복잡도**: 하

### Phase 2: PreferenceService → PreferenceData
- **DTO**: PreferenceFeature 6개 (GET+PUT 혼합)
- **특징**: 인증 혼재 (조회 `.none` / 수정 `.required`)
- **복잡도**: 중

### Phase 3: NotificationService → NotificationData
- **DTO**: NotificationFeature 5개 (GET+POST+PATCH+DELETE)
- **특징**: 전부 인증 필요(`.required`), Persistence 의존
- **복잡도**: 중

### Phase 4: UserService + OnboardingService → UserData + AuthData
- **DTO**: UserFeature 4개 + OnboardingFeature 4개 (`UpdateToken`은 LivithNetwork 내부 Interceptor 전용이므로 포팅 제외)
- **특징**: 두 Data 모듈이 UserService·OnboardingService를 공유, 중복 API(`CheckNicknameDuplicate`) 제거
- **복잡도**: 상

### Phase 5: HomeService + ConcertService + SetlistService 확장 → ConcertData
- **DTO**: HomeFeature 7개 + ConcertFeature 7개, SetlistService에 `fetchConcertMainSetlist` 1개 메서드 추가
- **특징**: 4개 서비스 의존, 가장 많은 DTO, SearchService 선행 필요
- **참고**: `FetchConcertMainSetlist` DTO는 기존 `FetchConcertSetlist`와 동일 구조이므로 DTO 통합. HomeFeature의 `FetchConcertMainSetlist.swift` 파일은 포팅 제외.
- **복잡도**: 최상

---

## 중복 API

### 1. `CheckNicknameDuplicate` — 완전 중복

| Endpoint | Path | Method | 결과 |
|----------|------|--------|------|
| `OnboardingEndpoint.checkNicknameDuplicate` | `/users/check-nickname` | GET | **미사용 → 제거** |
| `UserEndpoint.checkNicknameDuplicate` | `/users/check-nickname` | GET | **유지** (AuthData에서 실제 사용) |

Phase 4에서 UserService 쪽만 포팅하고 OnboardingService에선 제외한다.

### 2. `FetchConcertSetlist` ↔ `FetchConcertMainSetlist` — 구조 중복
- 동일한 필드·CodingKeys. Phase 5에서 기존 `FetchConcertSetlist` DTO 하나로 통합.

---

## 각 Phase별 공통 작업 항목

1. LivithNetworking에 DTO 디렉토리 생성 (`Sources/DTO/<Feature>/`)
2. LivithNetworking에 Service 선언 (protocol + impl, `NetworkEndpoint` 직접 생성)
3. `NetworkingFactory`에 서비스 생성 메서드 추가
4. `NetworkingFactoryTests`에 테스트 케이스 추가
5. 해당 Data 모듈의 `Project.swift` 의존성 변경
6. Assembler·RepositoryImpl·Mapper·ErrorMapper 마이그레이션
7. Test 마이그레이션 (NetworkError 케이스 대응)
8. `tuist generate` + `xcodebuild test` 검증
9. 서브에이전트 리뷰
10. 계획 문서 아카이브

---

## 영향 범위 (전체)

| 모듈 | 변경 유형 |
|------|----------|
| LivithNetworking | DTO 41개 신규, Service 7+1개 신규, Factory 확장 |
| Data/Project.swift | 6개 타겟 의존성 변경 |
| SearchData | Assembler·RepositoryImpl·Mapper·ErrorMapper·Tests |
| PreferenceData | Assembler·RepositoryImpl·Mapper·ErrorMapper·Tests |
| NotificationData | Assembler·RepositoryImpl·Mapper·ErrorMapper·Tests |
| UserData | Assembler·RepositoryImpl·Mapper·ErrorMapper·Tests |
| AuthData | Assembler·RepositoryImpl·Mapper·ErrorMapper·Tests |
| ConcertData | Assembler·RepositoryImpl·Mapper·ErrorMapper·Tests |

---

## 기술 결정

| 결정 사항 | 결정 | 근거 |
|-----------|------|------|
| 마이그레이션 단위 | 서비스 단위 (Data 모듈 단위 ❌) | 서비스가 여러 Data에 공유되므로, 서비스 먼저 만들고 Data 업데이트 |
| 각 Phase 계획 | 개별 상세 계획 문서로 분리 | 각 Phase마다 DTO·인증 정책·Mapper가 달라 상세 계획 필요 |
| Assembler 패턴 | Service 등록 생략, Factory 직접 사용 | `factory.makeXxxService()`로 바로 Repository에 주입 |
| DTO 네임스페이스 | `DTO.Request.*` / `DTO.Response.*` | 기존 LivithNetwork와 동일 구조 유지 |
| ErrorMapper 패턴 | SongData 기준 (`checkForCancellation` → `NetworkError` switch) | 기존 완료된 모듈과 일관성 |

---

## 주의 사항

- 서비스가 여러 Data 모듈에서 공유되므로, DTO와 Service 프로토콜이 특정 Data 모듈에 종속되지 않도록 설계해야 한다.
- Phase 5(ConcertData)는 Phase 1(SearchService)이 완료된 후에만 시작 가능 — SearchService를 의존한다.
- Phase 4(UserData+AuthData)는 `CheckNicknameDuplicate` 중복을 해소하며 진행한다.
- 각 Phase 시작 전에 해당 Phase의 상세 계획 문서를 별도 작성한다.

---

## 검증 방법 (공통)

1. `tuist generate` 성공
2. 각 Data 모듈의 MapperTests + ErrorMapperTests 전체 통과
3. `NetworkingFactoryTests` 전체 통과 (기존 테스트 깨지지 않음)
4. `import LivithNetwork` 잔존 0건 확인
