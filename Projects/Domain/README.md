# iOS Domain 타입 관계

Domain 모듈은 가입, 공연, 캘린더, 알림 등 업무 영역의 모델과 Repository 계약을 정의한다. 이 문서에서 각 모델이 보유하는 값, Repository의 입력·반환·에러 타입, 업무 영역 사이에서 공유하는 타입을 찾을 수 있다.

[Sources](Sources)에 직접 선언한 타입 98개를 다룬다. 중첩 타입과 타입 별칭도 포함한다. 선은 Domain 내부 타입 사이의 관계를 나타낸다. Swift와 Foundation 타입은 필요한 멤버에 표기한다.

| 업무 영역 | 관계를 볼 수 있는 곳 |
| --- | --- |
| 계정 | [인증과 가입](#인증과-가입), [사용자 프로필](#사용자-프로필) |
| 공연 | [공연 탐색과 상세](#공연-탐색과-상세), [관심 공연](#관심-공연), [공연 요청과 댓글](#공연-요청과-댓글) |
| 일정과 관심사 | [캘린더](#캘린더), [선호 장르와 아티스트](#선호-장르와-아티스트), [알림](#알림) |
| 검색과 공연 콘텐츠 | [검색](#검색), [셋리스트와 곡](#셋리스트와-곡), [페이지네이션](#페이지네이션) |

`-->`는 프로퍼티나 열거형 케이스가 값을 보유하는 관계다. `..>`는 계약, 메서드, 제네릭 사용, 중첩 선언 또는 ID로 연결하는 관계다. `0..1`은 선택 값, `0..*`는 리스트를 뜻한다. 여러 영역에서 쓰는 타입은 관련 다이어그램에 함께 나온다.

## 인증과 가입

`AuthRepository`는 로그인 결과로 `LoginStatus`를 반환한다. 신규 사용자의 `TempUser`를 받아 시작한 `SignupSession`은 약관 동의와 닉네임 확인 상태를 보유한다. 필수 약관과 현재 닉네임 확인을 검증한 뒤 `SignupInfo`를 만든다. [인증과 가입 소스](Sources/Auth)

```mermaid
classDiagram
    class AuthRepository {
        <<protocol>>
        +kakaoLogin() LoginStatus
        +appleLogin() LoginStatus
        +fetchLastLoginPlatform() SocialLoginProvider
        +checkNicknameDuplicate(nickname) Bool
        +signup(signup)
        +logout()
        +withdraw(reason)
    }
    class LoginStatus {
        <<enum>>
        existingUser
        newUser(tempUser)
    }
    class SocialLoginProvider {
        <<enum>>
        apple
        kakao
    }
    class TempUser
    class Nickname {
        +value: String
    }
    class SignupSession {
        +recordTermsAgreement(agreement)
        +changeNickname(nickname)
        +confirmNickname(nickname)
        +selectPreferredGenres(genres)
        +makeSignupInfo(artists) SignupInfo
    }
    class SignupTermsAgreement {
        +termsOfService: Bool
        +privacy: Bool
        +marketing: Bool
        +hasAgreedToRequiredTerms: Bool
    }
    class SignupInfo {
        +preferredGenreIDList: [Int]
        +preferredArtistIDList: [Int]
    }
    class AuthError {
        <<enum>>
        requiredTermsNotAgreed
        nicknameNotConfirmed
        duplicateNickname
    }
    class PreferredGenre
    class PreferredArtist
    class PreferenceSelectionRule

    AuthRepository ..> LoginStatus : 로그인 결과
    AuthRepository ..> SocialLoginProvider : 최근 로그인 수단
    AuthRepository ..> Nickname : 중복 확인 입력
    AuthRepository ..> SignupInfo : 가입 요청 입력
    AuthRepository ..> AuthError : throws
    LoginStatus --> "0..1" TempUser : newUser 케이스
    TempUser --> SocialLoginProvider : provider
    SignupSession --> TempUser : tempUser
    SignupSession --> "0..1" SignupTermsAgreement : terms
    SignupSession --> "0..1" Nickname : nickname
    SignupSession --> "0..1" Nickname : confirmedNickname
    SignupSession ..> SignupInfo : 생성
    SignupSession ..> PreferredGenre : 장르 선택 입력
    SignupSession ..> PreferredArtist : 가입 정보 생성 입력
    SignupSession ..> AuthError : 제출 조건 위반
    SignupInfo --> Nickname : nickname
    SignupInfo --> SocialLoginProvider : provider
    SignupInfo ..> PreferenceSelectionRule : 선택 상한
    SignupInfo ..> AuthError : 선호 장르와 아티스트 검증
    Nickname ..> AuthError : 형식 검증
```

## 사용자 프로필

`UserRepository`는 프로필을 조회·갱신하고 검증된 `Nickname`을 받아 닉네임을 수정한다. 조회한 `User`는 닉네임을 문자열로, 알림 권한과 동의 상태를 `UserAuthority`로 가진다. [사용자 소스](Sources/User)

```mermaid
classDiagram
    class UserRepository {
        <<protocol>>
        +fetchUser() User
        +updateNickname(nickname)
    }
    class User {
        +id: Int
        +nickname: String
        +hasPreferences: Bool
    }
    class UserAuthority {
        +deviceNotification: Bool
        +marketingConsent: Bool
    }
    class UserCodingKeys["User.CodingKeys"]
    <<enum>> UserCodingKeys
    class UserError {
        <<enum>>
    }
    class Nickname

    UserRepository ..> User : 프로필 반환
    UserRepository ..> Nickname : 닉네임 수정 입력
    UserRepository ..> UserError : throws
    User --> UserAuthority : authority
    User ..> UserCodingKeys : 중첩된 Codable 키
```

## 공연 탐색과 상세

공연 섹션과 추천 공연은 별도 계약으로 조회하고, 홈 기능이 두 조회 결과를 조합한다. 상세 계약은 공연 ID로 아티스트, 굿즈, 상세 정보, 공연 문화, 일정과 셋리스트를 각각 조회한다. `Concert.artist`에는 아티스트 이름 문자열이 저장된다. [공연 소스](Sources/Concert)

```mermaid
classDiagram
    class ConcertCatalogRepository {
        <<protocol>>
        +fetchAllConcertList(startDate, concertID) Concert[]
        +fetchAllConcertList(after, size) ListResult
        +fetchSearchConcertSectionList() ConcertSection[]
    }
    class ConcertSectionRepository {
        <<protocol>>
        +fetchHomeConcertSectionList() ConcertSection[]
    }
    class ConcertRecommendationRepository {
        <<protocol>>
        +fetchRecommendedConcertList() Concert[]
    }
    class ConcertDetailRepository {
        <<protocol>>
        +fetchConcert(concertID) Concert
        +fetchConcertArtistInfo(concertID) Artist
        +fetchConcertSetlistList(concertID) Setlist[]
        +fetchMainSetlist(concertID) Setlist?
        +fetchConcertMerchandiseList(concertID) ConcertMerchandise[]
        +fetchConcertInfoList(concertID) ConcertInfo[]
        +fetchConcertCultureList(concertID) ConcertCulture[]
        +fetchConcertScheduleList(concertID) ConcertSchedule[]
    }
    class Concert {
        +id: Int
        +artist: String
    }
    class ConcertStatus {
        <<enum>>
    }
    class ConcertSection
    class Artist
    class ConcertMerchandise
    class ConcertInfo
    class ConcertCulture
    class ConcertSchedule
    class ScheduleType {
        <<enum>>
    }
    class ConcertError {
        <<enum>>
    }
    class Setlist
    class ListResult~Item~
    class PagePosition {
        <<protocol>>
    }

    ConcertCatalogRepository ..> Concert : 공연 목록
    ConcertCatalogRepository ..> ConcertSection : 검색 섹션
    ConcertCatalogRepository ..> ListResult : 공연 페이지
    ConcertCatalogRepository ..> PagePosition : 다음 페이지 입력
    ConcertCatalogRepository ..> ConcertError : throws
    ConcertSectionRepository ..> ConcertSection : 섹션 조회 결과
    ConcertSectionRepository ..> ConcertError : throws
    ConcertRecommendationRepository ..> Concert : 추천 공연
    ConcertRecommendationRepository ..> ConcertError : throws
    ConcertDetailRepository ..> Concert : 공연 상세
    ConcertDetailRepository ..> Artist : 아티스트 정보
    ConcertDetailRepository ..> Setlist : 셋리스트 목록과 대표 셋리스트
    ConcertDetailRepository ..> ConcertMerchandise : 굿즈
    ConcertDetailRepository ..> ConcertInfo : 상세 정보
    ConcertDetailRepository ..> ConcertCulture : 공연 문화
    ConcertDetailRepository ..> ConcertSchedule : 일정
    ConcertDetailRepository ..> ConcertError : throws
    ConcertSection --> "0..*" Concert : concertList
    Concert --> ConcertStatus : status
    ConcertCulture ..> Concert : concertID
    ConcertSchedule --> ScheduleType : type
```

## 관심 공연

`InterestConcert`는 공연과 해당 공연의 예매 일정을 담는다. `InterestConcertSelection`은 현재 선택한 공연 ID와 저장 기준이 되는 ID를 비교한다. 관심 공연 목록과 진입 알림의 계약은 각각 `UserError`를 사용한다. [관심 공연 소스](Sources/Concert/Interest)

```mermaid
classDiagram
    class InterestConcertRepository {
        <<protocol>>
        +fetchInterestedConcertList(filter) ListResult
        +checkInterestedConcert(id) Bool
        +updateInterestedConcert(concertID) Concert
        +updateInterestedConcertList(concertIDs) Concert[]
        +deleteInterestedConcert()
    }
    class InterestConcertEntryAlertRepository {
        <<protocol>>
        +fetchInterestConcertEntryAlerts() InterestConcertEntryAlert[]
    }
    class InterestConcert
    class InterestConcertTicketingSchedule {
        +preSaleDate: Date?
        +generalSaleDate: Date?
    }
    class InterestConcertListFilter {
        +limit: Int?
    }
    class InterestConcertSort {
        <<enum>>
        concert
        ticketing
    }
    class InterestConcertEntryAlert
    class InterestConcertEntryAlertKind {
        <<enum>>
    }
    class InterestConcertSelection {
        +concertIDs: [Int]
        +hasUnsavedChanges: Bool
        +toggle(concertID)
        +remove(concertID)
        +markSaved(concertIDs)
    }
    class Concert
    class UserError {
        <<enum>>
    }
    class ListResult~Item~
    class PagePosition {
        <<protocol>>
    }

    InterestConcertRepository ..> InterestConcertListFilter : 조회 입력
    InterestConcertRepository ..> ListResult : 관심 공연 페이지
    InterestConcertRepository ..> InterestConcert : 페이지 원소 타입
    InterestConcertRepository ..> Concert : 선택 저장 결과
    InterestConcertRepository ..> UserError : throws
    InterestConcertEntryAlertRepository ..> InterestConcertEntryAlert : 진입 알림
    InterestConcertEntryAlertRepository ..> UserError : throws
    InterestConcert --> Concert : concert
    InterestConcert --> InterestConcertTicketingSchedule : ticketingSchedule
    InterestConcertListFilter --> "0..1" InterestConcertSort : sort
    InterestConcertListFilter --> "0..1" PagePosition : position
    InterestConcertEntryAlert --> InterestConcertEntryAlertKind : kind
    InterestConcertEntryAlert ..> Concert : 선택적인 concertID
    InterestConcertSelection ..> Concert : 선택한 concertIDs
```

## 공연 요청과 댓글

공연 등록 요청과 댓글 작성은 검증을 거친 입력 타입을 Repository에 전달한다. 공연 매칭은 공유 URL을 받아 공연 목록을 반환한다. 댓글 조회는 댓글 목록과 다음 커서를 튜플로 반환한다. [공연 요청 소스](Sources/Concert/Request) · [공연 댓글 소스](Sources/Concert/Comment)

```mermaid
classDiagram
    class ConcertMatchingRepository {
        <<protocol>>
        +fetchMatchedConcertList(sourceURL) Concert[]
    }
    class ConcertRequestRepository {
        <<protocol>>
        +requestConcert(request)
    }
    class ConcertRequest {
        +title: String
        +url: String?
        +shouldAutoRegister: Bool
        +requestContent: String?
        +isTitleValid(title) Bool
    }
    class ConcertMatchingError {
        <<enum>>
    }
    class CommentRepository {
        <<protocol>>
        +fetchConcertComments(concertID, cursor, size)
        +createComment(concertID, content) ConcertComment
        +deleteComment(commentID)
        +reportComment(commentID, content)
    }
    class ConcertComment
    class ConcertCommentContent {
        +value: String
        +maxLength: Int
    }
    class CommentError {
        <<enum>>
    }
    class Concert
    class ConcertError {
        <<enum>>
    }
    class User

    ConcertMatchingRepository ..> Concert : 매칭 결과
    ConcertMatchingRepository ..> ConcertMatchingError : throws
    ConcertRequestRepository ..> ConcertRequest : 등록 요청 입력
    ConcertRequestRepository ..> ConcertError : throws
    ConcertRequest ..> ConcertError : 제목 검증
    CommentRepository ..> ConcertComment : 조회와 작성 결과
    CommentRepository ..> ConcertCommentContent : 댓글 작성 입력
    CommentRepository ..> Concert : concertID
    CommentRepository ..> CommentError : throws
    ConcertCommentContent ..> CommentError : 본문 검증
    ConcertComment ..> User : 작성자 userID
```

## 캘린더

월 조회는 날짜별 일정 요약을, 날짜 조회는 시간·상태·장소가 포함된 일정을 반환한다. 월별 이벤트와 일별 이벤트는 각자의 이벤트 종류를 `CalendarEventID`의 제네릭 인자로 사용한다. `CalendarScheduleSelection`은 마지막으로 남은 일정 종류를 해제하지 못하게 막는다. [캘린더 소스](Sources/Calendar)

```mermaid
classDiagram
    class CalendarRepository {
        <<protocol>>
        +fetchMonth(startDate, endDate, scheduleTypes, concertType) CalendarMonth
        +fetchDayEvents(date, scheduleTypes, concertType) CalendarDaySchedule
    }
    class CalendarMonth
    class CalendarMonthDay
    class CalendarMonthEvent
    class CalendarMonthEventType {
        <<enum>>
    }
    class CalendarDaySchedule
    class CalendarDayEvent
    class CalendarDayEventType {
        <<enum>>
    }
    class CalendarDayEventStatus {
        <<enum>>
    }
    class CalendarEventID~EventType~ {
        +concertID: Int
        +type: EventType
    }
    class CalendarEventTime {
        +hour: Int
        +minute: Int
    }
    class CalendarEventDetail {
        <<enum>>
        ticketOffice(text)
        venue(text)
        +make(text, type) CalendarEventDetail
    }
    class CalendarScheduleSelection {
        +contains(type) Bool
        +toggle(type) ToggleResult
    }
    class CalendarScheduleToggleResult["CalendarScheduleSelection.ToggleResult"]
    <<enum>> CalendarScheduleToggleResult
    class CalendarScheduleTypeFilter {
        <<enum>>
    }
    class CalendarConcertTypeFilter {
        <<enum>>
    }
    class CalendarError {
        <<enum>>
    }
    class Concert

    CalendarRepository ..> CalendarMonth : 월별 조회 결과
    CalendarRepository ..> CalendarDaySchedule : 날짜별 조회 결과
    CalendarRepository ..> CalendarScheduleTypeFilter : 일정 종류 필터
    CalendarRepository ..> CalendarConcertTypeFilter : 공연 범위 필터
    CalendarRepository ..> CalendarError : throws
    CalendarMonth --> "0..*" CalendarMonthDay : dayList
    CalendarMonthDay --> "0..*" CalendarMonthEvent : eventList
    CalendarMonthEvent --> CalendarMonthEventType : type 및 ID의 이벤트 타입
    CalendarMonthEvent --> CalendarEventID : id
    CalendarDaySchedule --> "0..*" CalendarDayEvent : eventList
    CalendarDayEvent --> CalendarDayEventType : type 및 ID의 이벤트 타입
    CalendarDayEvent --> CalendarDayEventStatus : status
    CalendarDayEvent --> CalendarEventID : id
    CalendarDayEvent --> "0..1" CalendarEventTime : time
    CalendarDayEvent --> "0..1" CalendarEventDetail : detail
    CalendarEventID --> "0..1" CalendarEventTime : time
    CalendarEventID ..> Concert : concertID
    CalendarEventDetail ..> CalendarDayEventType : 예매처 또는 공연장 결정
    CalendarScheduleSelection --> "1..*" CalendarScheduleTypeFilter : 선택된 일정 종류
    CalendarScheduleSelection ..> CalendarScheduleToggleResult : 중첩 타입 및 토글 결과
```

## 선호 장르와 아티스트

`PreferenceRepository`의 아티스트 검색은 `ListResult<PreferredArtist>`를 반환한다.

`PreferenceSelection<Item>`은 장르와 아티스트 선택에 쓰이는 제네릭 모델이다. 선택 상한은 `PreferenceSelectionRule`에 있고, `SignupInfo`도 제출 정보를 만들 때 같은 상한을 적용한다. [선호 소스](Sources/Preference)

```mermaid
classDiagram
    class PreferenceRepository {
        <<protocol>>
        +fetchGenreList() PreferredGenre[]
        +searchArtistList(keyword, size, after) ListResult
        +fetchUserPreferredGenreList() PreferredGenre[]
        +fetchUserPreferredArtistList() PreferredArtist[]
        +updateUserPreferredGenreList(genreIDs) PreferredGenre[]
        +updateUserPreferredArtistList(artistIDs) PreferredArtist[]
    }
    class PreferredGenre
    class PreferredArtist {
        +genreID: Int
    }
    class ListResult~Item~
    class PreferenceSelection~Item~ {
        +items: Item[]
        +hasChangesToSave: Bool
        +toggle(id, availableItem) ToggleResult
    }
    class PreferenceToggleResult["PreferenceSelection.ToggleResult"]
    <<enum>> PreferenceToggleResult
    class PreferenceSelectionRule {
        <<enum>>
        +maxCount: Int
    }
    class PreferenceError {
        <<enum>>
    }
    class SignupInfo

    PreferenceRepository ..> PreferredGenre : 장르 조회 및 수정 결과
    PreferenceRepository ..> PreferredArtist : 아티스트 조회 및 수정 결과
    PreferenceRepository ..> ListResult : 아티스트 검색 페이지
    PreferenceRepository ..> PreferenceError : throws
    ListResult ..> PreferredArtist : Item 타입
    PreferredArtist ..> PreferredGenre : genreID
    PreferenceSelection ..> PreferredGenre : 장르 선택에서 사용하는 Item
    PreferenceSelection ..> PreferredArtist : 아티스트 선택에서 사용하는 Item
    PreferenceSelection ..> PreferenceToggleResult : 중첩 타입 및 토글 결과
    PreferenceSelection ..> PreferenceSelectionRule : 선택 상한
    SignupInfo ..> PreferenceSelectionRule : 제출 시 선택 상한
```

## 알림

알림함은 `NotificationItem`과 읽음 상태를 다룬다. 알림 설정은 동의 항목을 받아 결과를 반환하며, FCM 토큰은 별도 Repository에서 등록·삭제한다. 세 계약은 `NotificationError`를 공유한다. [알림 소스](Sources/Notification)

```mermaid
classDiagram
    class NotificationRepository {
        <<protocol>>
        +fetchNotificationList(cursor, size) NotificationItem[]
        +fetchUnreadNotificationCount() Int
        +markNotificationAsRead(id)
        +markAllNotificationsAsRead()
    }
    class NotificationSettingsRepository {
        <<protocol>>
        +fetchNotificationSettings() NotificationSettings
        +updateNotificationConsent(field, isAgreed) NotificationConsentResult
        +updateMarketingConsent() NotificationConsentResult
    }
    class NotificationTokenRepository {
        <<protocol>>
        +registerFCMToken(token)
        +deleteFCMToken(token)
    }
    class NotificationItem {
        +targetID: Int?
        +isRead: Bool
    }
    class NotificationType {
        <<enum>>
    }
    class NotificationSettings
    class NotificationConsentField {
        <<enum>>
    }
    class NotificationConsentResult
    class NotificationError {
        <<enum>>
    }

    NotificationRepository ..> NotificationItem : 알림함 조회
    NotificationRepository ..> NotificationError : throws
    NotificationItem --> NotificationType : type
    NotificationSettingsRepository ..> NotificationSettings : 설정 조회 결과
    NotificationSettingsRepository ..> NotificationConsentField : 설정 변경 입력
    NotificationSettingsRepository ..> NotificationConsentResult : 동의 변경 결과
    NotificationSettingsRepository ..> NotificationError : throws
    NotificationTokenRepository ..> NotificationError : throws
```

## 검색

`SearchRepository`의 필터 검색은 장르, 정렬, 공연 상태를 입력받는다. 필터 검색은 공연 목록과 이어 조회할 위치를 `ListResult<Concert>`로 반환한다. [검색 소스](Sources/Search)

```mermaid
classDiagram
    class SearchRepository {
        <<protocol>>
        +fetchBanners() Banner[]
        +fetchFilterSearchResult(genre, sort, status, keyword, after, size) ListResult
        +fetchRecommendedSearchResult(keyword) String[]
    }
    class Banner
    class ConcertGenre {
        <<enum>>
    }
    class SearchSort {
        <<enum>>
    }
    class ListResult~Item~
    class SearchError {
        <<enum>>
    }
    class Concert
    class ConcertStatus {
        <<enum>>
    }

    SearchRepository ..> Banner : 배너 반환
    SearchRepository ..> ConcertGenre : 장르 필터
    SearchRepository ..> SearchSort : 정렬 입력
    SearchRepository ..> ConcertStatus : 상태 필터
    SearchRepository ..> ListResult : 필터 검색 페이지
    SearchRepository ..> SearchError : throws
    ListResult ..> Concert : Item 타입
```

## 셋리스트와 곡

`SetlistRepository`는 셋리스트 상세와 곡 목록을 각각 반환한다. `SongRepository`는 곡 ID로 가사를 조회하고, 셋리스트 ID와 곡 ID를 함께 받아 응원법을 반환한다. [셋리스트 소스](Sources/Setlist) · [곡 소스](Sources/Song)

```mermaid
classDiagram
    class SetlistRepository {
        <<protocol>>
        +fetchSetlist(concertID, setlistID) Setlist
        +fetchSetlistSongs(setlistID) SetlistSong[]
    }
    class Setlist
    class SetlistType {
        <<enum>>
    }
    class SetlistStatus {
        <<enum>>
    }
    class SetlistSong {
        +id: Int
        +orderIndex: Int
    }
    class SetlistSongList {
        <<typealias>>
    }
    class SetlistError {
        <<enum>>
    }
    class SongRepository {
        <<protocol>>
        +fetchSongLyrics(songID) SongLyrics
        +fetchSongFanchant(setlistID, songID) SongFanchant
    }
    class SongLyrics
    class SongFanchant {
        +setlistID: Int
        +songID: Int
    }
    class SongError {
        <<enum>>
    }
    class Concert

    SetlistRepository ..> Concert : 상세 조회의 concertID
    SetlistRepository ..> Setlist : 상세 반환
    SetlistRepository ..> SetlistSong : 곡 목록 반환
    SetlistRepository ..> SetlistError : throws
    Setlist --> SetlistType : type
    Setlist --> "0..1" SetlistStatus : status
    SetlistSongList ..> SetlistSong : 배열의 원소 타입
    SongRepository ..> SongLyrics : 가사 반환
    SongRepository ..> SongFanchant : 응원법 반환
    SongRepository ..> SongError : throws
    SongRepository ..> SetlistSong : 조회 입력 songID
    SongFanchant ..> Setlist : setlistID
    SongFanchant ..> SetlistSong : songID
```

## 페이지네이션

`ListResult<Item>`은 원소 목록과 이어 조회할 위치(`PagePosition?`)를 담는다. 전체 공연 조회와 필터 검색은 `Concert`, 관심 공연 조회는 `InterestConcert`, 아티스트 검색은 `PreferredArtist`를 원소 타입으로 사용한다. [페이지네이션 소스](Sources/Pagination)

검색을 시작하거나 조건을 바꿀 때는 Repository의 `after`에 `nil`을 전달한다. 같은 조건의 다음 페이지는 응답의 `position`을 `after`에 전달해서 조회한다. Data는 서버 커서와 조회 위치를 서로 변환한다. `position`이 `nil`이면 더 조회할 페이지가 없다.

```mermaid
classDiagram
    class ListResult~Item~ {
        +items: Item[]
    }
    class PagePosition {
        <<protocol>>
    }
    class ConcertCatalogRepository {
        <<protocol>>
    }
    class InterestConcertRepository {
        <<protocol>>
    }
    class SearchRepository {
        <<protocol>>
    }
    class PreferenceRepository {
        <<protocol>>
    }
    class InterestConcertListFilter
    class Concert
    class InterestConcert
    class PreferredArtist

    ListResult --> "0..1" PagePosition : position
    ConcertCatalogRepository ..> ListResult : 공연 페이지 반환
    ConcertCatalogRepository ..> Concert : Item 타입
    ConcertCatalogRepository ..> PagePosition : 다음 페이지 입력
    InterestConcertRepository ..> ListResult : 관심 공연 페이지 반환
    InterestConcertRepository ..> InterestConcert : Item 타입
    InterestConcertRepository ..> InterestConcertListFilter : 조회 입력
    InterestConcertListFilter --> "0..1" PagePosition : position
    SearchRepository ..> ListResult : 공연 검색 페이지 반환
    SearchRepository ..> Concert : Item 타입
    SearchRepository ..> PagePosition : 다음 페이지 입력
    PreferenceRepository ..> ListResult : 아티스트 검색 페이지 반환
    PreferenceRepository ..> PreferredArtist : Item 타입
    PreferenceRepository ..> PagePosition : 다음 페이지 입력
```
