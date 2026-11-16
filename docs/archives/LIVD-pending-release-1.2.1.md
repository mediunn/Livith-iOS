# 1.2.1 릴리즈 준비 (archive)

## 결과
- develop의 db34ce7e에서 release/1.2.1을 분기하고 앱·Share Extension 버전을 1.2.1로 변경했다.
- xcodebuild로 Release 시뮬레이터 빌드 성공, iPhone 17 / iOS 27.2에서 SearchStoreTests 3개 실행·통과를 확인했다.
- 실기기·서명 아카이브·운영 업로드는 미수행이며 develop 재반영은 main 머지 후 진행한다.

## 남긴 결정
- 앱 버전만 변경하고 빌드 번호는 기존 운영 CI에서 자동 갱신한다.
- 릴리즈에는 최근 두 수정뿐 아니라 기준 develop에 포함된 main 이후 변경 전체를 포함한다.

## 컴파운딩
- rules 반영: 없음.
- 분리 확인으로 보류 (architecture / security): 없음.
- archive만 유지: 로컬 Tuist 명령·접근 권한과 Git 참조 차이, 릴리즈 검증 결과.
- 반영 없음 / 사유: 이번 환경에 한정된 사항이며 기존 규칙 확장이 필요하지 않다.

## 교훈
- [Tuist 세션 접근 제한과 build 명령 역할 차이] → 설치된 도구의 help를 확인하고 실제로 지원되는 검증 명령을 사용한다.
- [로컬 main 부재로 변경 범위 비교 실패] → 실제 존재하는 origin/main 참조로 배포 범위를 비교한다.

## 참조
- Release: xcodebuild build -workspace Livith-iOS.xcworkspace -scheme Livith-iOS -configuration Release -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO
- 검색 테스트: xcodebuild test -workspace Livith-iOS.xcworkspace -scheme SearchFeature -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.2' -only-testing:SearchFeatureTests/SearchStoreTests CODE_SIGNING_ALLOWED=NO
