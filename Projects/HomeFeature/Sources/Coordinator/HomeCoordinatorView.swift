//
//  HomeCoordinatorView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import ConcertFeature
import Coordinator
import LivithDesignSystem
import UserFeature

// MARK: - HomeRouter

typealias HomeRouter = Router<HomeRoute>

// MARK: - HomeCoordinatorView

public struct HomeCoordinatorView: View {

    // MARK: - Property

    @StateObject private var router: HomeRouter

    @Binding private var deepLinkConcertID: Int?
    @Binding private var deepLinkInitialTab: SegmentedTabBarType.DetailTab
    @Binding private var deepLinkInitialSection: ConcertInfoSection?
    @Binding private var deepLinkShowInterest: Bool

    // MARK: - Initializer

    public init(
        deepLinkConcertID: Binding<Int?> = .constant(nil),
        deepLinkInitialTab: Binding<SegmentedTabBarType.DetailTab> = .constant(.artistDetail),
        deepLinkInitialSection: Binding<ConcertInfoSection?> = .constant(nil),
        deepLinkShowInterest: Binding<Bool> = .constant(false)
    ) {
        _router = StateObject(wrappedValue: HomeRouter())
        self._deepLinkConcertID = deepLinkConcertID
        self._deepLinkInitialTab = deepLinkInitialTab
        self._deepLinkInitialSection = deepLinkInitialSection
        self._deepLinkShowInterest = deepLinkShowInterest
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: HomeRoute.self) { route in
                    destinationView(for: route)
                        .toolbar(.hidden, for: .tabBar, .navigationBar)
                }
        }
        .environmentObject(router)
        .ignoresSafeArea()
        .onChange(of: deepLinkConcertID) { newValue in
            if let concertID = newValue {
                router.popToRoot()
                router.push(.concertDetail(
                    concertID: concertID,
                    initialTab: deepLinkInitialTab,
                    initialSection: deepLinkInitialSection
                ))
                deepLinkConcertID = nil
                deepLinkInitialTab = .artistDetail
                deepLinkInitialSection = nil
            }
        }
        .onChange(of: deepLinkShowInterest) { newValue in
            if newValue {
                router.popToRoot()
                router.push(.interestConcertSetting(mode: .update))
                deepLinkShowInterest = false
            }
        }
    }

    @ViewBuilder
    private func destinationView(for route: HomeRoute) -> some View {
        switch route {
        case .home:
            HomeView()
        case .interestConcertSetting(let mode):
            InterestConcertSettingView(mode: mode)
        case .interestConcertList:
            InterestConcertListView()
        case .notice:
            NoticeView(
                onBack: { router.pop() },
                onSettingTap: { router.push(.noticeSetting) },
                onInterestTap: { router.push(.interestConcertSetting(mode: .update)) },
                onConcertTap: { concertID, initialTab, initialSection in
                    router.push(.concertDetail(
                        concertID: concertID,
                        initialTab: initialTab,
                        initialSection: initialSection
                    ))
                }
            )
        case .noticeSetting:
            NoticeSettingView(onBack: { router.pop() })
        case .recommendedConcertList(let concertList):
            RecommendedConcertGridView(concertList: concertList)
        case .preferredGenreUpdate:
            GenreUpdateView()
        case .preferredArtistUpdate(let selectedGenreList):
            ArtistUpdateView(selectedGenreList: selectedGenreList)
        case .concertDetail(let concertID, let initialTab, let initialSection):
            ConcertCoordinatorView(
                concertID: concertID,
                initialTab: initialTab,
                initialSection: initialSection
            )
        }
    }
}
