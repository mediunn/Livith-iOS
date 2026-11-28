//
//  ConcertCoordinatorView.swift
//  ConcertFeature
//
//  Created by on 6/16/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Domain
import LivithDesignSystem
import SetlistFeature
import SongFeature

public struct ConcertCoordinatorView: View {

    private let concertID: Int
    private let initialTab: SegmentedTabBarType.DetailTab
    private let initialSection: ConcertInfoSection?
    private let onTicketSiteReturn: () -> Void

    public init(
        concertID: Int,
        initialTab: SegmentedTabBarType.DetailTab = .artistDetail,
        initialSection: ConcertInfoSection? = nil,
        onTicketSiteReturn: @escaping () -> Void = {}
    ) {
        self.concertID = concertID
        self.initialTab = initialTab
        self.initialSection = initialSection
        self.onTicketSiteReturn = onTicketSiteReturn
    }

    public var body: some View {
        ConcertView(
            concertID: concertID,
            initialTab: initialTab,
            initialSection: initialSection,
            onTicketSiteReturn: onTicketSiteReturn
        )
        .navigationDestination(for: ConcertRoute.self) { route in
            destinationView(for: route)
        }
    }

    @ViewBuilder
    private func destinationView(for route: ConcertRoute) -> some View {
        switch route {
        case .setlistDetail(let concertID, let setlistID):
            SetlistDetailContainerView(
                concertID: concertID,
                setlistID: setlistID
            )
        case .songLyrics(let songID, let setlistID, let songTitle):
            SongLyricsView(
                songID: songID,
                setlistID: setlistID,
                songTitle: songTitle
            )
        case .merchandiseDetail(let merchandiseList, let ticketingOfficeURL):
            MerchandiseDetailView(
                merchandiseList: merchandiseList,
                ticketingOfficeURL: ticketingOfficeURL,
                onTicketSiteReturn: onTicketSiteReturn
            )
        case .detail:
            EmptyView()
        }
    }
}
