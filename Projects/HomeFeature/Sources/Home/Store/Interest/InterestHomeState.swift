//
//  InterestHomeState.swift
//  HomeFeature
//
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

// MARK: - State

struct InterestHomeState {
    var interestConcertList: [InterestConcert] = []
    var interestConcertSort: InterestConcertSort = .ticketing
    var errorMessage: String = ""
    var concertSectionList: [ConcertSection] = []
    var isSectionLoading: Bool = false
    var isInterestListLoadFailed: Bool = false
    var isInterestListRetryLoading: Bool = false
    var needsInitialSectionLoad: Bool = true
    var shouldShowPreferenceBanner: Bool = false
    var recommendedConcertList: [Concert] = []
    var shouldShowInterestResultSheet: Bool = false
    var interestResultAlertList: [InterestConcertEntryAlert] = []
}

// MARK: - Constants

enum InterestHomeConstants {
    static let interestListLoadFailedEmptyMessage = "콘서트 목록을\n불러오지 못했어요"
}

// MARK: - Intent

enum InterestHomeIntent {
    case onAppear
    case onRefresh
    case onErrorToastDisappear
    case onInterestResultSheetDismiss
    case interestConcertSortSelected(InterestConcertSort)
    case _interestListResult(Result<[InterestConcert], Error>)
    case _interestResultAlertListResult(Result<[InterestConcertEntryAlert], Error>)
    case _sectionLoadResult(Result<(sectionList: [ConcertSection], recommendedConcertList: [Concert]?), Error>)
}
