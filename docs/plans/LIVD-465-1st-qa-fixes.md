# LIVD-465 1차 QA 이슈 대응

## 배경
- 홈 관심 콘서트 탭에서 목록 조회 실패 시, 미설정 CTA(`EmptyInterestConcertSectionView`)와 `errorMessage` 토스트가 뜬다.
- Figma(`47:4093` 관심 콘서트 엠티뷰)는 로드 실패 전용 `LivithEmptyView`("콘서트 목록을\n불러오지 못했어요")를 요구한다.
- 캘린더 탭은 이미 `isLoadFailed` + `LivithEmptyView` 패턴을 사용한다.

## 목표
- 관심 콘서트 목록 조회 실패를 토스트가 아닌 엠티뷰로 표시한다.
- 목록이 비어 있는 실패 상태에서는 미설정 CTA를 보여주지 않는다.

## 권한·범위
- 정본(반드시 참이어야 하는 동작·불변조건):
  - 관심 콘서트 목록 조회 실패이고 목록이 비어 있으면 `LivithEmptyView(text: "콘서트 목록을\n불러오지 못했어요")`를 표시한다.
  - 위 실패 상태에서는 관심 헤더·추천·콘서트 섹션을 모두 숨기고 탭 콘텐츠를 엠티뷰만 보여준다.
  - 위 실패 경로에서는 `errorMessage` 토스트를 올리지 않는다.
  - `isInterestListLoadFailed`이면 관심 콘서트 결과 시트를 띄우지 않는다.
  - 목록이 이미 있는 상태에서 재조회(정렬 등)가 실패하면 기존 목록을 유지하고, 엠티뷰로 전체 화면을 덮지 않는다.
  - ScrollView 안 엠티뷰는 `containerRelativeFrame(.vertical)`로 배치한다 (고정 `padding(.vertical, 160)` 금지).
  - 성공 재조회 시 실패 플래그/메시지를 해제하고 정상 UI로 복귀한다.
  - 엠티뷰 상태에서 pull-to-refresh와 interest appear 재진입 시 관심 목록을 다시 조회한다.
  - 재조회 중 UI: pull-to-refresh는 시스템 스피너만 사용하고 커스텀 로딩으로 바꾸지 않는다. appear 재조회일 때만 로딩 인디케이터로 교체한다.
- 이번 범위 밖:
  - `LivithEmptyView` 공통 텍스트 색(Black80 → Black50) 변경
  - 홈 섹션/추천 조회 실패 UX 변경
  - 캘린더 탭 동작 변경
  - 세그먼트 탭 타이틀("관심 콘서트"/"캘린더") 변경
- 코드에서 복원 불가능한 의도(있으면):
  - Figma 문구·레이아웃이 로드 실패 엠티뷰의 정본이다.

## 작업 항목
- [x] 이슈1: 관심 콘서트 로드 실패 엠티뷰 (Store)
  - `HomeState`에 관심 목록 로드 실패를 표현하는 상태 추가 (캘린더의 `isLoadFailed` 패턴 권장)
  - `_interestListResult` 실패 시: 목록이 비어 있으면 실패 상태 설정 + `errorMessage`는 비움 / 목록이 있으면 기존 목록 유지(토스트 유지 여부: 기술 결정 표)
  - 성공 시 실패 상태 해제
  - TDD: red → green
- [x] 이슈1: 관심 콘서트 로드 실패 엠티뷰 (View)
  - `InterestHomeContentView`에서 실패 상태면 CTA/섹션 대신 `LivithEmptyView` 표시
  - 실패 경로에서 토스트가 뜨지 않도록 Store와 맞춤
- [x] 이슈1: 기존 테스트 갱신
  - 목록 비어 있는 실패 → 엠티뷰용 상태, `errorMessage` 비움
  - 목록 있는 재조회 실패 → 기존 목록 유지

## 영향 범위
- `Projects/HomeFeature` — `HomeStore`, `InterestHomeContentView`, `HomeView`, `HomeStoreTests`
- DesignSystem / Domain / Data 변경 없음

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| 실패 표현 | A. `isInterestListLoadFailed` 플래그 + 고정 문구 / B. `errorMessage` 재사용 | A | 캘린더와 동일. 토스트와 엠티뷰 채널을 분리 |
| 엠티뷰 트리거 | A. 관심 목록 실패 + 목록 empty만 / B. 섹션·유저 실패 포함 | A | Figma 문구가 콘서트 목록 조회에 한정 |
| 목록 있는 재조회 실패 | A. 기존처럼 `errorMessage` 토스트 / B. 무시 / C. 엠티뷰로 전환 | A | 콘텐츠를 가리지 않음. Figma는 빈 목록 실패 화면 |
| 엠티뷰 문구 | 고정 `"콘서트 목록을\n불러오지 못했어요"` | 고정 | Figma 정본. `localizedDescription` 사용 안 함 |
| 복구 경로 | A. refresh + appear 재조회 / B. refresh만 / C. 별도 재시도 버튼 | A | 캘린더 재시도와 맞춤. Figma에 CTA 없음 |
| 재조회 중 UI | A. 항상 커스텀 로딩 / B. refresh는 시스템 스피너만, appear만 커스텀 로딩 | B | refreshable과 풀스크린 로딩 이중 표시 방지 |
| 결과 시트 | A. 로드 실패 시 미노출 / B. errorMessage만 가드 | A | 실패 화면과 시트 동시 노출 방지 |
| `LivithEmptyView` 색 | 이번 이슈에서 수정 / 보류 | 보류 | 공통 컴포넌트 영향. 별도 QA로 분리 |

## 주의 사항
- `errorMessage`를 비우는 경로와 토스트 `onChange`가 맞물려 회귀하지 않게 기존 HomeStore 에러 테스트를 함께 확인한다.
- 관심 결과 시트는 `errorMessage.isEmpty` 가드를 쓰므로, 엠티뷰 전환이 시트 노출에 부작용을 주는지 확인한다. 로드 실패 플래그일 때도 시트를 띄우지 않도록 가드를 맞춘다.

## 검증 방법
- [x] 명령: `xcodebuild test -workspace "Livith-iOS.xcworkspace" -scheme "HomeFeature" -only-testing:HomeFeatureTests -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5'`
- [x] 기대 신호: 관심 목록 실패·정렬 실패 관련 테스트 통과
- [x] 실제 결과: `HomeStoreTests` 포함 163 tests passed
- [ ] 명령: 수동 — 관심 목록 API 실패 유도 후 홈 관심 탭
- [ ] 기대 신호: CTA/토스트 없이 엠티뷰 문구 표시
- [ ] 실제 결과: 

## 컴파운딩 (아카이브 전)
- [ ] 교훈 분류 완료
- rules 반영 (`기본 승격 규칙`):
  - 
- 분리 확인 제안 (`architecture` / `security`, 있으면):
  - 
- archive만 유지:
  - 
- 반영 없음 / 사유: 
