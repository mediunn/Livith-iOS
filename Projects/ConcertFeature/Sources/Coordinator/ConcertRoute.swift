//
//  ConcertRoute.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithDesignSystem
import Coordinator

public enum ConcertRoute: Route {
    case detail(
        concertID: Int,
        initialTab: SegmentedTabBarType.DetailTab = .artistDetail,
        initialSection: ConcertInfoSection? = nil
    )
    case setlistDetail(concertID: Int, setlistID: Int)
    case songLyrics(songID: Int, setlistID: Int, songTitle: String)
    case safari(URL)
    case ticketSafari(URL)
    case merchandiseDetail([ConcertMerchandise], ticketingOfficeURL: URL?)
}
