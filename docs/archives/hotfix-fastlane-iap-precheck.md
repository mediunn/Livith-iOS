# hotfix/fastlane-iap-precheck 설정 분리 (archive)

## 결과
- 캘린더 웹 URL을 Development와 Release 환경별 설정으로 분리하고 배포용 설정 저장소에 반영했다.

## 남긴 결정
- CI가 사용하는 xcconfig의 정본은 Livith-iOS가 아닌 비공개 Livith-Certificate 저장소에 유지한다.
- Livith-Certificate 변경은 `main`에 직접 반영하고 Livith-iOS의 `main` 대상 hotfix PR로 릴리즈를 실행한다.

## 컴파운딩
- 반영 없음 / 사유: 기존 보안 규칙으로 처리 가능하며 이번 배포에 한정된 설정 수정과 저장소 대상 오해다.

## 교훈
- [Shared 설정의 대상 환경을 잘못 추정해 첫 패치가 실패함] → 민감 설정 파일을 비열람으로 수정할 때 사용자 제공 자료의 환경과 값을 먼저 정확히 대응시킨다.
- [여러 저장소의 push 대상과 PR 대상을 같은 흐름으로 해석함] → 여러 저장소가 관련된 배포 작업에서는 push 대상과 PR 대상을 저장소별로 분리해 확인한다.

## 참조
- Livith-Certificate 커밋 `e020c7b`
- Livith-iOS 커밋 `25e650d0`
