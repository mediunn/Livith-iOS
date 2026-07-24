# 프로젝트 운영

## Purpose
- Tuist 프로젝트의 생성, 빌드, 테스트 실행 절차에서 반복되는 환경 오류를 줄인다.
- `tuist test`의 Swift Testing 집계 불안정을 우회하여 일관된 검증 방식을 고정한다.

## Scope
- 이 저장소의 모든 Tuist 명령과 `xcodebuild` 테스트 실행에 적용한다.
- 다음 용어는 이 문서에서 아래 의미로 사용한다.
- `tuist test`: `tuist test <Scheme>` 명령
- `tuist build`: `tuist build <Target>` 명령
- `xcodebuild test`: `xcodebuild test -workspace "Livith-iOS.xcworkspace" -scheme "<Scheme>" -destination "..."` 명령
- `tuist generate`: `tuist generate --no-open` 명령 (이 문서와 계획·검증에서 `tuist generate`라 하면 `--no-open`을 포함한다)
- `Executed 0 tests`: `xcodebuild` 출력에서 테스트 실행 로그에 `Executed 0 tests`가 표시되는 상태
- `생산 코드 검증 명령`: `tuist build` 명령
- `테스트 검증 명령`: `xcodebuild test` 명령

## Do

### 프로젝트 생성
- Swift 파일을 추가, 이동, 또는 삭제한 후에는 빌드 또는 테스트 전에 반드시 `tuist generate --no-open`을 실행한다.
- `tuist clean`을 실행한 후에는 `tuist install`을 먼저 실행한 뒤 `tuist generate --no-open`을 실행한다.
- 에이전트·스크립트·계획 문서의 기본 generate 명령은 `--no-open`이다. Xcode를 열 필요가 있으면 사용자가 명시할 때만 `--no-open` 없이 실행한다.

### 명령 실행 순서
- 모든 `tuist` 명령은 순차 실행한다. 같은 워크스페이스를 대상으로 하는 Tuist 명령을 병렬로 실행하지 않는다.
- `tuist clean`은 현재 DerivedData와 캐시 상태를 모두 제거하고 외부 의존성 설치도 다시 필요하게 만든다는 점을 확인한 뒤, 필요한 범위와 예상 시간을 사용자에게 보고하고 승인을 받은 후에만 실행한다.

### 테스트 실행
- 테스트 실행은 `xcodebuild test`를 우선 사용한다. `tuist test`는 Exception 조건에서만 fallback으로 사용한다.
- `xcodebuild test` 실행 전에 `xcodebuild -list`로 scheme명과 test action 존재 여부를 함께 확인한다.
- `xcodebuild test`의 destination 시뮬레이터는 직전 실패 출력의 `Available destinations`에 표시된 이름과 OS 버전을 기준으로 지정한다.
- `xcodebuild test`의 destination 시뮬레이터 이름은 이 저장소 환경에서 기본값으로 `iPhone 17`을 사용한다.
- test action이 없는 scheme은 `tuist build`로 생산 코드 컴파일만 검증한다.
- Swift Testing 기반 테스트가 포함된 scheme은 `xcodebuild test` 출력에서 `Executed 0 tests`가 표시되어도 테스트가 실행되지 않은 것으로 단정하지 않는다. 테스트 로그에서 `Test suite` 메시지 또는 결과 번들(.xcresult)의 테스트 식별자를 함께 확인한다.
- 특정 테스트 타겟 또는 테스트 클래스만 실행하려면 `xcodebuild test`에 `-only-testing:<Module>/<Class>` 옵션을 사용한다.

### 생산 코드 컴파일 검증
- `xcodebuild test` 실행이 불가능한 scheme은 `tuist build <Target>`으로 생산 코드 컴파일을 검증한다.
- `tuist build`는 테스트 타겟의 컴파일을 보장하지 않는다. 테스트 코드 컴파일 회귀는 `xcodebuild test` 또는 `tuist test`의 빌드 단계 로그로 확인한다.

## Don't
- Swift 파일 변경 후 `tuist generate --no-open` 없이 `xcodebuild test`를 실행하지 않는다.
- 사용자가 Xcode 실행을 요청하지 않았는데 `tuist generate`에서 `--no-open`을 빼지 않는다.
- `tuist build`, `tuist test` 같은 Tuist 명령을 병렬로 실행하지 않는다.
- `tuist test`의 `Executed 0 tests` 출력만으로 테스트 실행 실패를 판단하지 않는다.
- `tuist test`에서 테스트 타겟 컴파일 성공과 테스트 실행 성공을 같은 의미로 처리하지 않는다.
- 계획 문서의 검증 명령을 `tuist test`로 고정하지 않는다. 현재 환경의 검증 방식을 기준으로 명령어를 조정한다.
- `xcodebuild test`의 destination 시뮬레이터를 사용 가능 여부 확인 없이 고정값으로 지정하지 않는다.
- `tuist clean`을 테스트 scheme 확인이나 프로젝트 파일 동기화 목적으로 먼저 사용하지 않는다.
- `xcodebuild test` 실패 후 생산 코드 컴파일 검증을 생략하지 않는다.

## Exception
- `tuist test`는 `xcodebuild test`의 scheme destination이 지속적으로 실패하는 환경에서만 fallback으로 사용할 수 있다.
- `tuist clean`은 사용자가 필요성과 예상 시간을 확인하고 명시적으로 승인한 경우에만 실행한다.
- `tuist build`는 생산 코드의 컴파일 회귀 확인이 테스트 실행보다 우선인 상황에서 단독 사용할 수 있다.
- 사용자가 Xcode 프로젝트 열기를 명시한 경우에만 `tuist generate`(open)를 사용할 수 있다.
- 한 번의 예외로 현재 환경의 기본 검증 명령을 바꾸지 않는다. fallback 사용 후에는 원인을 트러블슈팅 문서에 기록한다.

## Checklist
- Swift 파일 추가/이동/삭제 후 `tuist generate --no-open`을 실행했는가
- `xcodebuild test` 실행 전에 scheme명과 test action 존재 여부를 확인했는가
- `xcodebuild test` destination이 현재 환경의 Available destinations와 일치하는가
- `xcodebuild test` 출력에서 `Executed 0 tests`만으로 테스트 실행 여부를 판단하지 않았는가
- 테스트 실행 불가 시 `tuist build`로 생산 코드 컴파일을 대신 검증했는가
- `tuist clean` 실행 전에 영향 범위와 예상 시간을 사용자에게 보고하고 승인을 받았는가
- 모든 `tuist` 명령이 병렬이 아닌 순차로 실행되었는가
