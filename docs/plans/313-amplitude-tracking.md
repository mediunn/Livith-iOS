# [313] 앰플리튜드 이벤트 태그 이상 징후

## 배경
- 앰플리튜드 태그(`EventTag`)와 발생 지점, 실제 전송값을 코드 기준으로 추적했다.
- 실제 전송값은 `EventTag.value`가 만든 `event_type` 문자열 하나이며, `AmplitudeService.swift:26-28`의 `track(eventType:)`으로만 나간다.
- 추적 결과 호출 111곳, 고유 이벤트명 95개를 확인했다.
- 명세서(`livith-amplitude-statement.pdf`, 26.07.24 최종 편집)와 대조해 이상 징후를 재분류했다.

## 목표
- 명세서와 실제 코드가 어긋나는 지점을 목록화한다.
- 각 항목의 처리 방향(유지·수정·삭제)을 유저가 확정할 수 있게 근거를 남긴다.

## 권한·범위
- 정본(반드시 참이어야 하는 동작·불변조건):
  - 실제 전송값은 `"ios_" + rawValue`이고, 토글만 `"_on"`/`"_off"`가 붙는다.
  - 명세서상 iOS 이벤트는 이벤트명 앞에 `ios_`를 붙인다. 따라서 base name에 `ios_`가 이미 있으면 `ios_ios_*`가 정상이다.
  - 이벤트 프로퍼티, `user_id`, `identify`는 현재 코드에 없고 이번 조사 범위 밖이다.
  - DEBUG 빌드는 `amplitude = nil`이라 이벤트를 전송하지 않는다.
- 이번 범위 밖:
  - 이벤트 프로퍼티(user·concert·검색어) 추가
  - 대시보드 이벤트명 개편, 신규 이벤트 설계
  - 런타임 로그·테스트 타깃 추가
- 코드에서 복원 불가능한 의도(있으면):
  - `comfirm` 오타는 명세서 원문과 대시보드를 맞추기 위해 의도적으로 유지한다(`AmplitudeService.swift:184` 주석, 명세서에도 `comfirm`).
  - `click_calendar_month`는 이전 기간이 있고 실제로 바뀔 때만 보낸다(`LIVD-465` 결정).

## 작업 항목
- [x] 전체 `trackEvent` 호출부와 `EventTag` raw 값 대조
- [x] 명세서와 실제 코드 대조
- [x] 명세서 기준 이상 징후 재분류
- [ ] 각 항목 처리 방향 확정
- [ ] 확정된 항목만 코드 수정 (별도 승인 후)
- [x] `trackEvent`에 이벤트명 로그, `-AmplitudeDebugLog` 실행 인자에서 device ID 로그 추가

## 명세서 대조 결과

### A. 명세서에 있으나 코드가 보내지 않는 이벤트
| 이벤트 | 명세서 트리거 | 코드 상태 | 판단 |
|---|---|---|---|
| `confirm_interest_concert` | 관심 콘서트 설정 화면 "설정하기" | 호출 없음. `InterestConcertSettingView`의 `onSubmit`은 `store.send(.submit)`만 호출 | 누락 |
| `click_change_concert_main` | 메인 홈에서 수정하기 버튼 | `HomeInterestConcertSectionView.swift:190`에 "변경하기" 버튼이 있으나 이벤트 없음 | 누락 |
| `cancel_change_interest` | 관심 콘서트 변경 팝업 "변경하지 않아요" | 호출 없음. 변경 팝업 자체가 없고 예매 후 스낵바만 있음 | 누락·UI 변경 확인 |
| `click_set_artist_preference` | 마이페이지 아티스트 "설정하기" | `UserView.swift:209`에서 `ios_click_set_genre_preference` 전송 | 오용 |
| `click_calendar_today` | 캘린더 "오늘" 버튼 | 호출 없음. 캘린더는 웹뷰라 네이티브 버튼이 없음 | UI 소유 확인 |
| `set_filter_electronic` | 바텀시트 "일렉트로닉" | enum 없음 | 명세서·앱 장르 불일치 |
| `set_filter_acoustic` | 바텀시트 "어쿠스틱" | enum 없음 | 명세서·앱 장르 불일치 |
| `set_filter_classic_jazz` | 바텀시트 "클래식/재즈" | enum 없음 | 명세서·앱 장르 불일치 |
| `click_delete_concert` | 삭제 바텀시트 "콘서트 삭제하기" | enum만 있고 호출 없음 | UI 확인 |
| `click_confirm_delete` | 삭제 팝업 "지금은 삭제할래요" | enum만 있고 호출 없음 | UI 확인 |
| `click_cancel_delete` | 삭제 팝업 "잘못 눌렀어요" | enum만 있고 호출 없음 | UI 확인 |
| `click_change_main_concert` | 바텀시트 "메인 콘서트 바꾸기" | enum만 있고 호출 없음 | UI 확인 |
| `click_more_info_main` | 메인 홈 "더 많은 정보 확인하기" | enum만 있고 호출 없음 | 구 홈 UI 확인 |
| `click_concert_schedule_segment_main` | 메인 홈 "콘서트 일정" 세그먼트 | enum만 있고 호출 없음 | 구 홈 UI 확인 |
| `click_setlist_segment_main` | 메인 홈 "셋리스트" 세그먼트 | enum만 있고 호출 없음 | 구 홈 UI 확인 |
| `click_setlist_song_main` | 메인 홈 셋리스트 노래 셀 | enum만 있고 호출 없음 | 구 홈 UI 확인 |
| `click_more_songs_main` | 메인 홈 "더 많은 노래" 버튼 | enum만 있고 호출 없음 | 구 홈 UI 확인 |

### B. 명세서와 트리거가 다른 이벤트
| 이벤트 | 명세서 트리거 | 코드 트리거 | 판단 |
|---|---|---|---|
| `confirm_change_interest` | 관심 콘서트 변경 팝업 "변경할래요" | 예매 후 "콘서트 설정" 스낵바 액션 (`ConcertView.swift:231`) | 트리거 불일치. 실제 등록 결과와 무관 |
| `click_calendar_month` | 이전·다음 달 이동, 명세서상 iOS x | 구현됨 (`CalendarHomeContentView.swift:192`) | 명세서 상태가 오래됐거나 결정 변경. 확인 필요 |

### C. 코드에만 있는 이벤트
| 이벤트 | 명세서 | 코드 |
|---|---|---|
| `set_filter_pop` | 없음 (장르 탭 `click_genre_pop`만 있음) | `FilterBottomSheetView.swift:158` |
| `set_filter_indie` | 없음 (장르 탭 `click_genre_indie`만 있음) | `FilterBottomSheetView.swift:160` |

- 앱의 장르 필터는 `ConcertGenre` 5종(J-POP, 락/메탈, 랩/힙합, POP, INDIE) 기준이다.
- 명세서의 필터 목록은 일렉트로닉·어쿠스틱·클래식/재즈를 포함하고 POP·INDIE를 포함하지 않는다. 명세서와 앱 장르 목록 중 어느 쪽이 정본인지 확인이 필요하다.

### D. 정상 확인 (오해 방지, 수정 대상 아님)
| 항목 | 이유 |
|---|---|
| `ios_ios_*` 5건 (`igParsing*`, `igSearch*`, `iosNotificationSettings`) | 명세서 base name에 이미 `ios_`가 있어 iOS 접두사가 붙으면 두 번 붙는 것이 정상 |
| `click_interest_concert_main` | 명세서 트리거가 "관심 콘서트 설정 버튼"이라 빈 상태 CTA와 일치 |
| `comfirm` 오타 | 명세서에도 `comfirm`으로 표기됨 |
| 토글 `_on`/`_off` 분리 | 명세서가 ON/OFF를 별도 이벤트로 정의 |
| 필터 설정 시 N+1건 발생 | 명세서 주의사항이 "중복된 칩 모두 이벤트 발생"을 요구 |
| `click_calendar_month`의 발생 조건 | 이전 기간이 있고 실제 변경 시에만 보내는 `LIVD-465` 결정 |

### E. 검증 제약
- `AmplitudeService.swift:18-24`의 `#if DEBUG` 분기 때문에 Debug 빌드는 이벤트를 전송하지 않는다.
- Debug에서 확인하려면 로그를 추가하거나 Release·TestFlight에서 확인해야 한다.

## 영향 범위
- 이번 로그 작업: `Projects/Core/Amplitude/Sources/AmplitudeService.swift`
- 이번 문서 작업: `docs/plans/313-amplitude-tracking.md`
- 수정 확정 시:
  - `Projects/Core/Amplitude/Sources/AmplitudeService.swift`
  - `Projects/UserFeature/Sources/View/UserView.swift`
  - `Projects/HomeFeature/Sources/Interest/View/InterestConcertSettingView.swift`
  - `Projects/HomeFeature/Sources/Home/View/Interest/Subview/InterestConcertSection/HomeInterestConcertSectionView.swift`
  - `Projects/ConcertFeature/Sources/View/ConcertView.swift`
  - 검색 필터 바텀시트와 캘린더 호출부

## 기술 결정
| 결정 사항 | 선택지 | 결정 | 근거 |
|---|---|---|---|
| `set_filter` 목록 | 앱 장르 5종 유지 / 명세서 3종 추가 | 미정 | 명세서와 앱 장르 목록 중 정본 확인 필요 |
| `setArtistPreference` 오용 | `click_set_artist_preference`로 수정 / 유지 | 미정 | 명세서가 두 이벤트를 명확히 구분 |
| 누락 이벤트 연결 | 명세서대로 연결 / UI 없으면 보류 | 미정 | UI 존재 여부와 배포 상태 확인 필요 |
| `confirm_change_interest` 시점 | 스낵바 유지 / 변경 팝업으로 이동 | 미정 | 명세서 트리거와 현재 UI 불일치 |
| `click_calendar_month` | 유지 / 제거 | 미정 | 명세서상 iOS x이나 `LIVD-465`에서 추가됨 |
| 구 홈 이벤트 5건 | 유지 / enum 삭제 | 미정 | 현재 홈 화면에 해당 UI 없음 |
| device ID 로그 게이트 | 항상 출력 / 실행 인자 플래그 / 마스킹 | 실행 인자 플래그 | `security.md`가 사용자 식별값 원문 로그를 금지하므로, `-AmplitudeDebugLog`가 있을 때만 원문을 출력한다. 마스킹하면 User Activity에서 기기를 특정할 수 없다 |

## 주의 사항
- 이벤트명을 바꾸면 대시보드의 기존 데이터와 단절된다. 수정 전에 대시보드 사용 현황을 먼저 확인한다.
- 명세서가 항상 정본은 아니다. `click_calendar_month`처럼 코드가 더 최신인 경우가 있으므로 항목별로 확인한다.
- `comfirm` 오타는 의도적 예외이므로 일괄 오타 수정 대상에 넣지 않는다.
- 실제 전송값의 정본은 `AmplitudeService.swift`의 raw 값과 `EventTag.value` 조합이다. 호출부 이름만 보고 판단하지 않는다.
- 코드 수정은 유저가 항목별 방향을 확정한 뒤 진행한다.

## 검증 방법
- [ ] 명령: `rg -n "AmplitudeService.shared.trackEvent" Projects --glob '*.swift' | wc -l`
- [ ] 기대 신호: 111
- [x] 실제 결과: 111
- [ ] 명령: `rg -n 'click_ios_' Projects/Core/Amplitude/Sources/AmplitudeService.swift`
- [ ] 기대 신호: 5건
- [x] 실제 결과: 5건
- [ ] 명령: `rg -n "setArtistPreference" Projects --glob '*.swift'`
- [ ] 기대 신호: 정의 1건, 호출 0건
- [x] 실제 결과: 정의 1건, 호출 0건
- [ ] Release·TestFlight에서 Amplitude Debugger로 실제 `event_type` 확인 (수정 시)
- [ ] 명령: `tuist build Amplitude`
- [ ] 기대 신호: 빌드 성공
- [x] 실제 결과: 빌드 성공

## 컴파운딩 (아카이브 전)
- [ ] 교훈 분류 완료
- rules 반영 (`기본 승격 규칙`):
  -
- 분리 확인 제안 (`architecture` / `security`, 있으면):
  -
- archive만 유지:
  -
- 반영 없음 / 사유:
