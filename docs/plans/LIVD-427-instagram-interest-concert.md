# [LIVD-427] 인스타그램 공유 → 관심 콘서트 등록 화면 구현

## 배경
- Figma 디자인 문서에 인스타그램 게시글 공유로 진입해 관심 콘서트를 등록하는 신규 플로우(FR-01~06)가 기능명세와 함께 정의되어 있다.
- Share Extension 타겟과 서버 파싱·매칭 API는 미결정 의존성이므로 이번 범위에서 제외하고, **앱 내 화면과 로직을 먼저 구현**한다 (사용자 확인 완료). 매칭 결과 공급부는 Domain 프로토콜로 분리해 API 확정 시 교체한다.

## 목표
- 매칭 성공/부분 성공 시 확인 화면(FR-04)에서 콘서트 1개를 선택해 관심 콘서트로 등록할 수 있다 (성공: 홈 이동+성공 토스트, 실패: 화면 유지+실패 토스트, 취소: 중단 확인 팝업).
- 매칭 실패/직접 찾기 화면(FR-05)에서 기존 검색 로직으로 콘서트를 검색·단일 선택해 등록할 수 있다.
- `livith://instagram` 딥링크로 플로우에 진입할 수 있다 (Share Extension 연동 준비).
- Store 로직은 TDD(red→green)로 구현한다.

## 작업 항목
- [x] Domain: 매칭 계약 정의
  - `ConcertMatchingRepository` 프로토콜: `fetchMatchedConcertList(sourceURL: URL) async throws(ConcertMatchingError) -> [Concert]` (최대 3개)
  - `ConcertMatchingError` enum (noConnection, serverError, matchFailed, unknown 등)
- [x] Data/UserData: `ConcertMatchingRepositoryImpl` 추가
  - 서버 API 미확정이므로 임시 스텁(고정 응답 + TODO 주석), `UserDataAssembler`에 등록
- [x] HomeFeature: 매칭 확인 화면 (FR-04) — **TDD** (red 11/12 확인 → green 12/12)
  - `InstagramMatchConfirmStore`: 추출 로딩 상태, 매칭 결과 1~3개 노출, 셀 1개만 선택(하이라이팅), 선택 시 등록하기 활성화, 등록 성공 `_registerResult` → 홈 이동+성공 토스트(콘서트명 말줄임), 실패 → 화면 유지+실패 토스트, 취소/비활성 등록하기 → 중단 확인 팝업("지금은 그만할래요"=홈 이동, "잘못 눌렀어요"=닫기), "직접 찾아볼게요" → FR-05 화면 이동
  - `InstagramMatchConfirmView`: 타이틀·설명, `LivithCard` 1~3개(단일 선택), 로딩 dots, 하단 취소/등록하기(`LivithButton`), `LivithDangerModal`, `.livithToast`
- [x] HomeFeature: 직접 검색 화면 (FR-05) — **TDD** (red 8/9 확인 → green 9/9)
  - `InstagramMatchSearchStore`: `SearchRepository.fetchFilterSearchResult` 재사용(기존 검색 로직과 동일, 300ms debounce), 단일 선택, 등록/취소는 FR-04와 동일 규칙
  - `InstagramMatchSearchView`: 진입 경로별 타이틀("공연 정보를 불러오지 못했어요…" / "등록하려는 공연을 직접 검색해보세요"), 검색 필드(`LivithTextField(.search)`), 3열 그리드(`InterestConcertSelectionGridView` 재사용), 하단 취소/등록하기
- [x] HomeFeature: 라우팅 연결
  - `HomeRoute`에 `.instagramMatchConfirm(sourceURL:)`, `.instagramMatchSearch(context:)` 케이스 추가 및 `HomeCoordinatorView.destinationView` 매핑
- [x] App: 딥링크 진입 (FR-01~03 준비)
  - `DeepLinkService.handleDeepLink`에 `case "instagram"`(url 쿼리 파라미터) 추가 → `Notification.Name.openInstagramMatch` post → `LivithMainTabView` onReceive → `HomeCoordinatorView` Binding onChange → push
- [x] 검증: `tuist generate` → `tuist build`(Livith-iOS-Dev 성공) → `xcodebuild test`(iPhone 17, 84개 중 신규 21개 포함 83개 통과 — 실패 1건은 develop 선행 이슈, 트러블슈팅 참조)
- [ ] 잔여: Figma 재접속 후 토스트·팝업 문구 대조, `xcrun simctl openurl`로 딥링크 수동 확인

## 영향 범위
- `Projects/Domain` (프로토콜·에러 추가)
- `Projects/Data/UserData` (스텁 구현·Assembler)
- `Projects/HomeFeature` (신규 View/Store 4파일 + Route/Coordinator 수정, Tests)
- `Projects/App` (DeepLinkService, LivithMainTabView)

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 매칭 결과 공급 | 서버 API 대기 / Domain 프로토콜+스텁 | 프로토콜+스텁 | API 미확정. 화면·로직 선행 개발, 교체 지점 고정 |
| 스텁 위치 | 신규 Data 모듈 / UserData | UserData | 관심 콘서트(User 도메인) 소속. 모듈 신설은 과설계 |
| FR-05 화면 | InterestConcertSettingView 모드 확장 / 신규 View·Store | 신규 View·Store | 기존은 다중 선택+변경 플로우. 단일 선택·중단 팝업 등 의미가 달라 모드 확장 시 복잡도 증가 |
| FR-06 (정보 요청 버튼·툴팁·요청 페이지) | 포함 / 후속 이슈 | **후속 이슈로 제외** | 요청 페이지 디자인이 이 섹션에 없고, 툴팁 표시 조건은 페이지 방문 상태 관리가 별도 작업 |
| Share Extension·FR-01~03 화면 | 포함 / 제외 | 제외 (딥링크만 준비) | 타겟 신설·App Group·서버 파싱 API 미확정 (사용자 확인) |
| 홈 화면(FR-04 ✅ 4번 프레임) | 수정 / 그대로 | 그대로 | 등록 성공 후 홈 이동+토스트는 기존 홈 화면 위 토스트 노출로 충족. 홈 자체 변경 없음 |

## 주의 사항
- Feature 간 직접 의존 금지: 검색은 SearchFeature가 아닌 Domain의 `SearchRepository`로 재사용한다 (기존 InterestConcertSettingStore 패턴).
- 색상·폰트는 DesignSystem 토큰 사용 (Figma 변수: Gray Scale/Black 90=#222831, Yellow 60=#FFEB56, Body2-sm 등 → 기존 매핑 준수).
- 등록은 `UserRepository.updateInterestedConcert(_ concertID:)` 단건 API 사용 (이미 존재).
- 테스트는 Swift Testing + `MockDIContainer` 패턴. `MockConcertMatchingRepository`를 Tests/Mock에 추가.
- Swift 파일 추가 후 빌드·테스트 전 `tuist generate` 필수, Tuist 명령 순차 실행.

## 검증 방법
- HomeFeature 신규 Store 테스트: `xcodebuild test -only-testing:HomeFeatureTests` (destination iPhone 17), red→green 확인
- `tuist build`로 App·HomeFeature·Domain·UserData 컴파일 검증
- Figma 스크린샷과 화면 대조 (FR-04 3종 상태: 로딩/1개/3개, FR-05 2종 타이틀)
- 딥링크 수동 확인: `xcrun simctl openurl booted "livith://instagram?url=..."`
