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

        // 탐색 메인
        case searchBar = "click_search_bar"
        case firstConcertCell = "click_first_concert_cell"
        case secondConcertCell = "click_second_concert_cell"

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
    }

    // MARK: - Filter Events

    enum FilterEvent: String {
        case jpop = "set_filter_jpop"
        case rockMetal = "set_filter_rock_metal"
        case rapHiphop = "set_filter_rap_hiphop"
        case classicJazz = "set_filter_classic_jazz"
        case acoustic = "set_filter_acoustic"
        case electronic = "set_filter_electronic"
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
    }

    // MARK: - Confirm Events

    enum ConfirmEvent: String {
        case interestConcert = "confirm_interest_concert"
        case changeInterest = "confirm_change_interest"
        case delete = "click_confirm_delete"
    }

    // MARK: - Cancel Events

    enum CancelEvent: String {
        case delete = "click_cancel_delete"
        case changeInterest = "cancel_change_interest"
    }
}
