# [#327] iOS 도메인 구조와 책임 재구성 — 작업 아카이브

## 결과·범위

`develop`의 `f538f1d3`을 기준으로 단일 Domain 타깃 안의 Swift 파일 65개를 업무 영역별로 이동했다. 공연 목록·상세·홈·요청과 관심 공연·진입 알림, 알림함·설정·푸시 토큰의 Repository 계약을 나눴다. Store와 서비스는 필요한 계약을 주입받고 기존 Data 구현체와 서버 계약을 재사용한다.

가입 진행 상태는 `SignupSession`이 관리한다. 약관 동의와 현재 닉네임의 중복 확인을 검증한 뒤 `SignupInfo`를 생성하고, 프로필 수정에도 `Nickname`을 사용한다. 캘린더 마지막 필터 해제 제한, 선호 선택 상한, 관심 공연 편집 기준, 공연 요청·댓글 입력 검증은 Domain의 모델이 담당한다. 서버 응답 해석은 Data로, 사용자 문구는 `DisplaySupport`로 옮겼다.

## 남긴 결정

- 파일 이동과 계약 분리를 나눠 검증했다. 계약 분리는 호출자의 의존 범위를 좁히는 데 집중했고, 사용자 캐시와 관심 공연 빈 응답 처리를 기존 구현에 유지했다.
- 검색 공연 섹션과 대표 셋리스트 메서드는 각각 목록·상세 계약에 보존했다.
- 도메인별 에러와 typed throws를 유지했다. 같은 종류의 실패에 대해 기능마다 기존 표시 문구가 달라 공통 에러 타입 도입은 별도 결정으로 남겼다.
- 공연일의 날짜 전용 타입, 새 모듈과 의존성은 별도 변경으로 남겼다.

## 검증 결과

| 방법·명령 | 기대 신호 | 실제 결과 |
|---|---|---|
| `tuist generate --no-open`, `xcodebuild build -scheme Livith-iOS-Dev` | 앱·Feature·Data와 DI 컴파일 | iPhone 17, iOS 26.5에서 기준점과 각 구현 단계 빌드 성공 |
| 단계별 모듈 스킴의 `xcodebuild test` | 공연·홈 Repository, 가입과 닉네임, 필터·선호·편집 규칙 검증 | 공연 요청 5건과 홈 계약 113건, 가입 3건과 닉네임 17건, 모델 단계 99건 통과 |
| `xcodebuild test -scheme Livith-iOS-Workspace` | 기존 테스트 실패 해결 및 전체 영향 범위 확인 | 수정한 두 스위트 39건 및 통합 405건 통과. 변경 범위 밖인 `LivithNetworkingTests` 제외 |
| 시뮬레이터에서 Dev 앱 실행 | 초기 화면이 정상 표시 | 로그인 화면과 최초 알림 권한 팝업 확인 |

## 교훈·규칙 반영

- 더 이상 사용하지 않는 일정 타입과 실행 시점에 의존하는 고정 예매일이 검증을 막았다 → 테스트 입력은 현재 API 계약을 따르고, 미래와 과거를 구별하는 경우 실행 시점에 맞춰 생성한다.
- 앱 실행 스킴에 테스트 타깃이 없었다 → 앱은 Dev 스킴으로 검증하고 단위 테스트는 모듈 또는 Workspace 스킴으로 실행한다.
- 별도의 규칙 변경은 없다. 이번 작업에 적용한 판단과 결과는 이 문서에 남긴다.

## 미해결·후속 사항

로그인 후 서버 연동 흐름과 실제 푸시 수신은 수동 확인이 남아 있다.

관심 공연을 저장하는 중에 편집하면, 저장 성공 후 화면이 닫힐 때 그 변경 내용은 사라진다.

`ArtistSearchResult`와 `SearchResult`의 `ListResult` 통합은 보류한다. Repository와 Data 매퍼에 이어 검색 화면의 Store도 수정해야 한다. 다시 진행할 때 아티스트 검색 응답의 커서가 없으면 마지막 페이지인지 확인한다.

## 추가 기록

2026-11-18에 드러난 기존 실패를 별도 테스트 커밋 `b65eb0b0`으로 수정했다. 공연 일정 테스트의 `.ticketing` 기대값과 응답을 `.generalTicketing` 및 `GENERAL_TICKETING`으로 맞췄다. 잘못된 시작일이 있는 공연은 목록에 남고 시작일만 `nil`이 되는 동작을 검증했다. 관심 공연 표시 테스트에는 실행 시각 기준의 미래 예매일을 사용했다. 수정 뒤 `ConcertMapperTests.swift`를 다시 포함해 통합 테스트를 실행했다.

2026-11-18 리뷰 후속으로 `SignupInfo`의 생성자를 Domain 내부로 제한했다. 다른 모듈은 `SignupSession.makeSignupInfo`에서 검증된 값을 받는다. `Livith-iOS-Dev` 빌드와 `SignupSessionTests` 3건이 통과했다.

2026-11-18에 `HomeSectionRepository`를 `ConcertSectionRepository`와 `ConcertRecommendationRepository`로 나눴다. 홈 기능이 두 조회를 조합하고, 각각 기존 API와 Data 구현을 사용한다. `Livith-iOS-Dev` 빌드와 `HomeStoreTests` 54건이 통과했다.

## 참조

- [GitHub 이슈 #327](https://github.com/mediunn/Livith-iOS/issues/327)
- 통합한 원본 `docs/plans/327-domain-restructure.md`, `docs/troubleshooting/327-domain-restructure.md`
