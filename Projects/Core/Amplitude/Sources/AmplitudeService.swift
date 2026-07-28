//
//  AmplitudeService.swift
//  Amplitude
//
//  Created by Youjin Lee on 2/14/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import AmplitudeSwift

public final class AmplitudeService {
    public static let shared = AmplitudeService()

    private let amplitude: Amplitude?

    private init() {
        #if DEBUG
        amplitude = nil
        #else
        amplitude = Amplitude(configuration: Configuration(apiKey: Bundle.amplitudeAppKey))
        #endif
    }

    public func trackEvent(tag: EventTag) {
        amplitude?.track(eventType: tag.value)
    }
}

// MARK: - EventTag

public extension AmplitudeService {
    enum EventTag {
        case click(ClickEvent)
        case setFilter(FilterEvent)
        case toggle(ToggleEvent, isOn: Bool)
        case confirm(ConfirmEvent)
        case cancel(CancelEvent)

        private static let prefix = "ios_"

        var value: String {
            switch self {
            case .click(let event):
                return Self.prefix + event.rawValue
            case .setFilter(let event):
                return Self.prefix + event.rawValue
            case .toggle(let event, let isOn):
                return Self.prefix + event.rawValue + (isOn ? "_on" : "_off")
            case .confirm(let event):
                return Self.prefix + event.rawValue
            case .cancel(let event):
                return Self.prefix + event.rawValue
            }
        }
    }

    // MARK: - Click Events

    enum ClickEvent: String {
        // 홈 메인
        case interestConcertMain = "click_interest_concert_main"
        case concertCellMain = "click_concert_cell_main"
        case moreInfoMain = "click_more_info_main"
        case concertScheduleSegmentMain = "click_concert_schedule_segment_main"
        case setlistSegmentMain = "click_setlist_segment_main"
        case setlistSongMain = "click_setlist_song_main"
        case moreSongsMain = "click_more_songs_main"
        case changeConcertMain = "click_change_concert_main"
        case setPreferenceBannerMain = "click_set_preference_banner_main"

        // 탐색 메인
        case searchBar = "click_search_bar"

        // 탐색 장르 탭
        case genreAll = "click_genre_all"
        case genreJpop = "click_genre_jpop"
        case genreRockMetal = "click_genre_rock_metal"
        case genreRapHiphop = "click_genre_rap_hiphop"
        case genrePop = "click_genre_pop"
        case genreIndie = "click_genre_indie"

        // 네비게이션
        case navHome = "click_nav_home"
        case navExplore = "click_nav_explore"
        case navMy = "click_nav_my"

        // 관심 콘서트 수정/삭제
        case changeMainConcert = "click_change_main_concert"
        case deleteConcert = "click_delete_concert"

        // 검색
        case sortLatest = "click_sort_latest"
        case sortAlphabetical = "click_sort_alphabetical"
        case applyFilter = "click_apply_filter"
        case resetFilter = "click_reset_filter"
        case searchComplete = "click_search_complete"
        case searchCell = "click_search_cell"

        // 콘서트 상세
        case interestConcertDetail = "click_interest_concert_detail"
        case artistDetailSegment = "click_artist_detail_segment"
        case concertDetailSegment = "click_concert_detail_segment"
        case setlistSegmentDetail = "click_setlist_segment_detail"
        case reportArtistInfo = "click_report_artist_info"
        case reportFanTips = "click_report_fan_tips"
        case reportConcertInfo = "click_report_concert_info"
        case reportSchedule = "click_report_schedule"
        case reportSetlistSection = "click_report_setlist_section"
        case setlistCell = "click_setlist_cell"

        // 셋리스트 상세
        case reportSetlist = "click_report_setlist"
        case songCell = "click_song_cell"

        // 노래 재생
        case reportSong = "click_report_song"

        // 추천 콘서트
        case recommendedConcertCell = "click_recommended_concert_cell"

        // 취향 설정
        case skipArtistPreference = "click_skip_artist_preference"
        case setGenrePreference = "click_set_genre_preference"
        case setArtistPreference = "click_set_artist_preference"
        case searchBarArtistPreference = "click_search_bar_artist_preference"
        case searchCompleteArtistPreference = "click_search_complete_artist_preference"
        case searchCellArtistPreference = "click_search_cell_artist_preference"
        case backPreference = "click_back_preference"
        case cancelPreference = "click_cancel_preference"

        // 알림 목록
        case interestConcertNotification = "click_interest_concert_notification"
        case bookingScheduleNotification = "click_booking_schedule_notification"
        case preBookingScheduleNotification = "click_pre_booking_schedule_notification"
        case concertUpdateSetlistNotification = "click_concert_update_setlist_notification"
        case concertUpdateMdNotification = "click_concert_update_md_notification"
        case concertUpdateDetailNotification = "click_concert_update_detail_notification"
        case concertUpdateScheduleNotification = "click_concert_update_schedule_notification"
        case concertUpdateTicketNotification = "click_concert_update_ticket_notification"
        case favoriteArtistConcertOpenNotification = "click_favorite_artist_concert_open_notification"
        case recommendedConcertNotification = "click_recommended_concert_notification"

        // iOS 푸시 알림
        case pushInterestConcert = "click_push_interest_concert"
        case pushBookingSchedule = "click_push_booking_schedule"
        case pushPreBookingSchedule = "click_push_pre_booking_schedule"
        case pushConcertUpdateSetlist = "click_push_concert_update_setlist"
        case pushConcertUpdateMd = "click_push_concert_update_md"
        case pushConcertUpdateDetail = "click_push_concert_update_detail"
        case pushConcertUpdateSchedule = "click_push_concert_update_schedule"
        case pushConcertUpdateTicket = "click_push_concert_update_ticket"
        case pushFavoriteArtistConcertOpen = "click_push_favorite_artist_concert_open"
        case pushRecommendedConcert = "click_push_recommended_concert"

        // 취향 수정
        case changeGenrePreference = "click_change_genre_preference"
        case changeArtistPreference = "click_change_artist_preference"

        // 알림 설정
        case iosNotificationSettings = "click_ios_notification_settings"

        // 홈 탭
        case interestConcertTab = "click_interest_concert_tab"
        case interestCalendarTab = "click_interest_calendar_tab"

        // 캘린더 필터
        case calendarChipConcertDate = "click_chip_concert_date"
        case calendarChipBookingDate = "click_chip_booking_date"
        case calendarToggleAllConcert = "click_toggle_all_concert"
        case calendarToggleMyConcerts = "click_toggle_my_concerts"
        case calendarDate = "click_calendar_date"
        case calendarMonth = "click_calendar_month"

        // 인스타 파싱
        case igParsingSuccess = "click_ios_ig_parsing_success"
        case igParsingFail = "click_ios_ig_parsing_fail"
        case igSearch = "click_ios_ig_search"
        case igSearchSuccess = "click_ios_ig_search_success"

        // 공연 요청
        case concertRequest = "click_concert_request"
        // 명세서 원문 오타(comfirm) 유지 — 대시보드 이벤트명과 일치시키기 위함
        case concertRequestConfirm = "click_concert_request_comfirm"
        case concertRequestAdded = "click_concert_request_added"
        case concertRequestRetry = "click_concert_request_retry"
    }

    // MARK: - Filter Events

    enum FilterEvent: String {
        case jpop = "set_filter_jpop"
        case rockMetal = "set_filter_rock_metal"
        case rapHiphop = "set_filter_rap_hiphop"
        case pop = "set_filter_pop"
        case indie = "set_filter_indie"
        case ongoing = "set_filter_ongoing"
        case upcoming = "set_filter_upcoming"
        case completed = "set_filter_completed"
    }

    // MARK: - Toggle Events

    enum ToggleEvent: String {
        case original = "toggle_original"
        case pronunciation = "toggle_pronunciation"
        case translation = "toggle_translation"
        case cheer = "toggle_cheer"

        // 알림 설정
        case nightNotification = "toggle_night_notification"
        case benefitNotification = "toggle_benefit_notification"
        case bookingScheduleNotification = "toggle_booking_schedule_notification"
        case concertUpdateNotification = "toggle_concert_update_notification"
        case favoriteArtistConcertOpenNotification = "toggle_favorite_artist_concert_open_notification"
        case recommendedConcertNotification = "toggle_recommended_concert_notification"
    }

    // MARK: - Confirm Events

    enum ConfirmEvent: String {
        case interestConcert = "confirm_interest_concert"
        case changeInterest = "confirm_change_interest"
        case delete = "click_confirm_delete"

        // 취향 설정
        case genrePreference = "confirm_genre_preference"
        case artistPreference = "confirm_artist_preference"
        case backPreference = "confirm_back_preference"

        // 취향 수정
        case changeGenrePreference = "confirm_change_genre_preference"
        case changeArtistPreference = "confirm_change_artist_preference"
    }

    // MARK: - Cancel Events

    enum CancelEvent: String {
        case delete = "click_cancel_delete"
        case changeInterest = "cancel_change_interest"
    }
}
