# 문서 작성

## Purpose
- 에이전트 진입점과 규칙·템플릿 문서의 언어·역할을 고정한다.
- 하네스 문서를 수정할 때 어디에 무엇을 쓸지 갈리지 않게 한다.

## Scope
- `AGENTS.md`, `docs/rules/*.md`, `docs/templates/*.md` 작성·수정에 적용한다.
- 앱 제품 UI 카피, PR 본문, 커밋 메시지 작성에는 적용하지 않는다. 커밋·PR은 `docs/rules/git.md`를 따른다.
- 다음 용어는 이 문서에서 아래 의미로 사용한다.
- `규칙 문서`: `docs/rules/*.md`
- `템플릿 문서`: `docs/templates/*.md`

## Do
- `AGENTS.md`는 영어로만 작성한다.
- 한글 상세 규범은 `규칙 문서`에 작성한다.
- `규칙 문서`와 `템플릿 문서`는 한글로 작성한다. `docs/templates/rule-template.md`의 Writing Notes를 따른다.
- `AGENTS.md`에는 Hard gates·라우팅·진입 안내만 두고, Do/Don't 상세는 `규칙 문서`에 둔다.
- 계획·트러블슈팅·압축 archive 양식은 각각 `docs/templates/plan.md`, `docs/templates/troubleshooting.md`, `docs/templates/archive.md`를 따른다.

## Don't
- `AGENTS.md` 본문에 한글 규범 문장을 넣지 않는다.
- `규칙 문서`에 써야 할 상세 규범을 `AGENTS.md`에만 두지 않는다.
- 유저 대면 응답 언어 규칙(한국어)을 `AGENTS.md` 작성 언어 규칙과 섞어 바꾸지 않는다.

## Exception
- `AGENTS.md`의 "All user-facing responses must be written in Korean."처럼 응답 언어를 영어로 지시하는 문장은 허용한다.
- `규칙 문서`·`템플릿 문서`의 코드 식별자, 파일 경로, 명령어는 영어 그대로 둔다.
- 한 번의 예외를 다른 진입점 파일이나 다른 언어 규칙으로 확장하지 않는다.

## Checklist
- `AGENTS.md` 변경분이 영어인가
- 한글 상세 규범이 `규칙 문서`에 있는가
- `규칙 문서`·`템플릿 문서`가 한글인가 (경로·식별자 제외)
- `AGENTS.md`에 Do/Don't 상세를 중복으로 넣지 않았는가
