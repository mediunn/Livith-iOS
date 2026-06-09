# LIVD-418 TokenManager 리팩토링

## 배경
- develop 브랜치 머지 후 AppRootView.swift에 `TokenService`를 사용하는 코드가 추가됨
- 현재 브랜치는 LivithNetwork 모듈을 삭제하고 LivithNetworking으로 재작성한 상태
- TokenService는 존재하지 않으며, 토큰 관리를 위한 단일 진입점이 필요함
- TokenManager가 이미 존재하지만 internal로 선언되어 App 모듈에서 접근 불가

## 목표
- TokenManager를 public으로 만들어 토큰 관리의 단일 진입점으로 활용
- TokenStore는 internal로 캡슐화하여 TokenManager를 통해서만 토큰 접근
- AppRootView와 AuthRepositoryImpl이 TokenManager를 주입받아 사용하도록 수정

## 작업 항목
- [x] TokenManager protocol을 public으로 확장
  - accessToken(), refresh(), save(), remove(), isTokenValid() 메서드 포함
  - TokenManagerImpl은 actor로 유지하면서 protocol 준수
- [x] TokenStore를 internal로 변경
  - public protocol을 internal로 변경
  - KeychainTokenStore도 internal로 변경
- [x] NetworkClientBuilder 수정
  - build() 메서드가 TokenManager도 반환하도록 수정
  - TokenManagerImpl을 생성해서 AuthInterceptor와 함께 반환
- [x] App 모듈의 DI 컨테이너 수정
  - TokenManager를 DI 컨테이너에 등록
  - AuthRepositoryImpl이 TokenManager를 주입받도록 수정
- [x] AppRootView 수정
  - TokenService 대신 TokenManager를 주입받도록 수정
  - import LivithNetwork를 import LivithNetworking으로 변경
  - tokenService.removeToken() → tokenManager.remove()
  - tokenService.refresh() → tokenManager.refresh()
- [x] AuthRepositoryImpl 수정
  - TokenStore 대신 TokenManager를 주입받도록 수정
  - tokenStore 관련 코드를 tokenManager로 변경
- [x] 빌드 및 테스트
  - xcodebuild로 빌드 성공 확인
  - 관련 유닛 테스트 통과 확인

## 트러블슈팅
- [트러블슈팅 문서](../troubleshooting/LIVD-418-troubleshooting.md) 참고

## 영향 범위
- LivithNetworking 모듈: TokenManager, TokenStore, NetworkClientBuilder
- App 모듈: DIContainer, AppRootView
- AuthData 모듈: AuthRepositoryImpl

## 기술 결정

| 결정 사항 | 선택지 | 결정 | 근거 |
|-----------|--------|------|------|
| TokenManager 접근 제어 | public vs internal | public | AppRootView와 AuthRepositoryImpl에서 사용 필요 |
| TokenStore 접근 제어 | public vs internal | internal | TokenManager를 통해서만 토큰 접근하여 캡슐화 유지 |
| TokenManager 메서드 | 최소 vs 전체 | 전체 | accessToken(), refresh(), save(), remove(), isTokenValid() 모두 포함하여 단일 진입점 확보 |

## 주의 사항
- TokenManager를 actor로 유지해야 동시성 안전성 보장
- NetworkClientBuilder에서 TokenManager를 생성할 때 TokenStore와 TokenRefreshService를 주입해야 함
- AuthRepositoryImpl의 생성자 파라미터가 변경되므로 호출부도 수정 필요
- AppRootView의 @Injected 프로퍼티 타입이 변경됨
- 기존 TokenService 관련 코드는 모두 제거해야 함

## 검증 방법
- xcodebuild로 빌드 성공 확인
- 관련 유닛 테스트 통과 확인
- 앱 실행 시 자동 로그인 동작 확인
- TokenManager를 통해서만 토큰이 저장/조회/삭제되는지 확인
