//
//  HomeRoute.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import ConcertFeature
import Domain
import LivithDesignSystem

enum HomeRoute: Hashable {
    case home
    case interestConcertSetting(mode: InterestConcertSettingMode)
    case interestConcertList
    case notice
    case noticeSetting
    case recommendedConcertList(concertList: [Concert])
    case preferredGenreUpdate
    case preferredArtistUpdate(selectedGenreList: [PreferredGenre])
    case instagramMatchConfirm(sourceURL: URL)
    case instagramManualSearch(context: InstagramManualSearchContext)
    case concertDetail(
        concertID: Int,
        initialTab: SegmentedTabBarType.DetailTab,
        initialSection: ConcertInfoSection?
    )
    case concertRequest
}
