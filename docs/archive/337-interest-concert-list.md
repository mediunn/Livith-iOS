# [#337] 관심 콘서트 목록의 Environment DI와 Observable ViewModel

## 결과와 결정
공연 요청에 이어 관심 콘서트 목록을 화면별 DI 예외에 추가했다. App이 등록된 Repository를 조회하고 Home 경로에서 화면 모델에 전달한다. 설정 화면과 Domain 계약은 기존 구조를 유지한다. DI 이전과 ViewModel 전환을 별도 커밋으로 분리했다.

## 상태 복원
정렬 변경 전에 진행 중이던 페이지 요청은 취소한다. 정렬 변경이 실패하면 마지막 목록과 커서를 복원하고 로딩 표시를 해제해 이전 커서로 다시 조회할 수 있다. 요청 번호가 지난 응답은 무시한다.

## 검증
- Tuist 프로젝트 생성과 iOS 26.5 시뮬레이터용 Livith-iOS-Dev 빌드 성공.
- HomeFeature의 InterestConcertListViewModelTests 12건을 각각 3회 반복해 통과했다. 정렬 실패 후 이전 커서로 다시 조회하는 경우를 포함한다.
- 중간 검증에서 고정 100ms 대기 후 페이지 조회가 누락되는 테스트 실패를 확인했다. 완료된 로딩 상태를 기다리도록 변경한 후 반복 검증했다.
- 실제 화면 조작은 수동 검증하지 않았다.

[GitHub 이슈 #337](https://github.com/mediunn/Livith-iOS/issues/337)
