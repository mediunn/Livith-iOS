# LIVD-439 홈 캘린더 UI 골격 - 트러블슈팅

## 규칙

- ScrollView(또는 리스트) 안 `LivithEmptyView`는 **`containerRelativeFrame(.vertical)`** 로 영역을 잡는다.
- 엠티뷰 위치·높이 맞춤에 **고정 pt `padding` / `minHeight` 상수를 쓰지 않는다.** (예: `padding(.vertical, 160)` 금지)
- 참고 구현: `InterestConcertListView.errorEmptyView`, `InterestConcertSelectionGridView.emptyView`

## 기록

### 2026-07-19 20:12 - 엠티뷰에 고정 패딩 대신 `containerRelativeFrame` 사용

**상황**
- 캘린더 로드 실패 `LivithEmptyView`를 ScrollView에 넣으면서, Figma `py 160`을 보고 `padding(.vertical, 160)` 상수(`emptyVerticalPadding`)를 사용함.

**문제**
- 기기·가용 높이마다 엠티뷰 위치가 달라질 수 있음.
- 프로젝트 내 엠티뷰는 이미 relative 방식(`containerRelativeFrame`)을 쓰는데 캘린더만 고정 패딩 패턴을 택함.

**원인**
- ScrollView 자식의 높이를 화면에 맞추려고 Figma pt 값을 코드 상수로 옮김.
- 기존 Feature의 `containerRelativeFrame(.vertical)` 관례를 먼저 확인하지 않음.

**해결**
- 고정 패딩 제거 후 relative 선언으로 교체:

```swift
LivithEmptyView(text: ...)
    .frame(maxWidth: .infinity)
    .containerRelativeFrame(.vertical)
```

**교훈**
- **EmptyView는 relative 방식(`containerRelativeFrame`)으로 선언한다. 고정 패딩으로 맞추지 않는다.**
