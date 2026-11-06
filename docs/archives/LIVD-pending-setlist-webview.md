# GitHub #315 셋리스트 iOS WebView (archive)

## 결과
- Debug 실기기·시뮬레이터에서 셋리스트 상세와 곡을 하나의 WebView로 열고, 웹 행동을 기존 iOS Amplitude 이벤트로 연결한다.
- URL 구성, 행동 매핑, 입력 거부, 내비게이션 정책의 Swift 대역 검증과 앱/ConcertFeature 컴파일을 통과했다. 실기기 Vercel 로그인 완료부터 셋리스트 복귀, 최종 닫기 및 Amplitude 서버 수집은 후속 검증 대상으로 남긴다.

## 남긴 결정
- Release는 기존 네이티브 상세를 유지한다. Debug 웹뷰 지원을 운영 전환 완료로 간주하지 않는다.
- 앱은 로그인 후 진입한다. 앱 인증 정보를 웹에 공유하는 작업과 웹 로그인 유도 생략은 별개다. 인증 공유는 이번 범위에서 구현하지 않는다.
- WEB_BASE_URL 값은 사용자가 xcconfig에 설정한다. 캘린더의 CALENDAR_WEB_URL 설정은 유지한다.
- 웹 상단바와 하나의 웹뷰를 사용한다. 로드 실패 시 네이티브 LivithEmptyView와 “셋리스트를 불러오지 못했어요” 문구를 보여주고 상단 뒤로 가기로 복귀한다. 네이티브 상세로 자동 fallback하지 않는다.
- 자동 HTTP(S) 인증 이동은 웹뷰 안에서 진행한다. 사용자가 누른 외부 링크와 정보 제보만 Safari로 연다. 메시지 수신 출처는 설정된 기본 주소로 제한한다.
- 토글 이벤트는 변경 성공이 아니라 사용자가 요청한 값을 기록하는 기존 의미를 유지한다.
- 웹 수정은 Livith-Web #422/PR #423, iOS 연결은 #315로 분리한다. Android 구현은 후속 작업이다.

## 컴파운딩
- rules 반영: 없음. 이번 웹뷰의 동작 결정은 작업별 보관 문서에 남긴다.
- 분리 확인으로 보류 (architecture / security): 없음.
- archive만 유지: Vercel 인증 리다이렉트, location.href 기반 정보 제보, Debug 진입 범위와 분석 전송 비활성화, 저장소별 이슈 분리, 로컬 검증 도구 제약.
- 반영 없음 / 사유: 설정·보안·테스트 실행의 일반 규칙은 기존 문서에 정의돼 있다. 이번 사례를 전역 규칙으로 확장하지 않는다.

## 교훈
- [다른 출처의 이동을 모두 Safari로 보내 Vercel 인증 리다이렉트도 앱 밖으로 나감] → 자동 이동과 사용자 링크 클릭을 구분하고, 인증 페이지에서 앱 메시지를 받도록 출처 제한을 넓히지 않는다.
- [정보 제보가 앵커 클릭 대신 location.href를 사용해 linkActivated로 분류되지 않음] → 기존 report tap 메시지로 다음 외부 이동의 사용자 의도를 구분한다.
- [Vercel 배포 보호가 앱 로그인과 별도로 동작함] → 앱 로그인 여부와 Vercel 인증 완료를 분리해서 확인한다. 실제 인증 후 복귀는 대역 검증으로 완료 처리하지 않는다.
- [Debug와 시뮬레이터를 동시에 요구해 실기기에서 네이티브 화면이 열림] → 지원하는 실행 환경과 Release 전환 범위를 명시한다.
- [Debug에서 Amplitude SDK가 비활성화되어 서버에 이벤트가 수집되지 않음] → 메시지 수신·태그 매핑과 실제 서버 수집 검증을 구분한다.
- [기본 주소가 바뀌어도 localhost 기반 검증을 유지하면 이동과 메시지가 거부됨] → URL 결합과 출처 검증에 같은 주입 설정을 사용하고 기본 포트 표기 차이를 정규화한다.
- [여러 저장소의 구현을 한 이슈에 섞음] → 저장소별 이슈를 만들고 연계 작업은 링크로 연결한다.
- [샌드박스에서 Tuist·CoreSimulator 접근 및 개발 서버 포트 바인딩이 제한됨] → 필요한 도구 권한으로 검증하고 UI 도구 접근 실패를 제품 검증 완료로 취급하지 않는다.

## 참조
- iOS 이슈: https://github.com/mediunn/Livith-iOS/issues/315
- 웹 이슈: https://github.com/mediunn/Livith-Web/issues/422
- 웹 PR: https://github.com/mediunn/Livith-Web/pull/423
- Projects/ConcertFeature/Sources/View/SetlistWebView.swift
- Projects/ConcertFeature/Sources/Model/SetlistWebConfig.swift
