//
//  LivithMainTabView.swift
//  Livith-iOS
//
//  Created by Youjin Lee on 12/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Amplitude
import ConcertFeature
import HomeFeature
import LivithDesignSystem
import SearchFeature
import UserFeature

struct LivithMainTabView: View {

    // MARK: - Tab

    enum Tab: Int, CaseIterable {
        case home, search, my
    }

    // MARK: - Property

    @State private var selectedTab: Tab = .home
    @State private var deepLinkConcertID: Int?
    @State private var deepLinkInitialTab: SegmentedTabBarType.DetailTab = .artistDetail
    @State private var deepLinkInitialSection: ConcertInfoSection?
    @State private var deepLinkShowInterest: Bool = false
    @State private var deepLinkInstagramURL: URL?

    // MARK: - LifeCycle

    init() {
        configureTabBarAppearance()
    }

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeCoordinatorView(
                deepLinkConcertID: $deepLinkConcertID,
                deepLinkInitialTab: $deepLinkInitialTab,
                deepLinkInitialSection: $deepLinkInitialSection,
                deepLinkShowInterest: $deepLinkShowInterest,
                deepLinkInstagramURL: $deepLinkInstagramURL
            )
            .tag(Tab.home)
            .tabItem {
                makeTabItem(.home)
            }

            SearchCoordinatorView()
                .tag(Tab.search)
                .tabItem {
                    makeTabItem(.search)
                }

            UserCoordinatorView(
                onNavigateToHome: {
                    selectedTab = .home
                }
            )
            .tag(Tab.my)
            .tabItem {
                makeTabItem(.my)
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: selectedTab) { _, newTab in
            switch newTab {
            case .home:
                AmplitudeService.shared.trackEvent(tag: .click(.navHome))
            case .search:
                AmplitudeService.shared.trackEvent(tag: .click(.navExplore))
            case .my:
                AmplitudeService.shared.trackEvent(tag: .click(.navMy))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .openConcertDetail)) { notification in
            if let concertID = notification.userInfo?["concertID"] as? Int {
                selectedTab = .home
                if let initialTab = notification.userInfo?["initialTab"] as? SegmentedTabBarType.DetailTab {
                    deepLinkInitialTab = initialTab
                }
                deepLinkInitialSection = notification.userInfo?["initialSection"] as? ConcertInfoSection
                deepLinkConcertID = concertID
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .openInterestConcert)) { _ in
            selectedTab = .home
            deepLinkShowInterest = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .openInstagramMatch)) { notification in
            if let sourceURL = notification.userInfo?["sourceURL"] as? URL {
                _ = DeepLinkService.shared.consumePendingInstagramURL()
                selectedTab = .home
                deepLinkInstagramURL = sourceURL
            }
        }
        .onAppear {
            if let sourceURL = DeepLinkService.shared.consumePendingInstagramURL() {
                selectedTab = .home
                deepLinkInstagramURL = sourceURL
            }
        }
    }
}

// MARK: - Helper

private extension LivithMainTabView {
    func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.livithColor(.black100))

        // 상단 구분선 설정
        appearance.shadowColor = UIColor(Color.livithColor(.black50))

        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.livithColor(.black50))
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.livithColor(.black50))
        ]

        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.livithColor(.yellow60))
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.livithColor(.yellow60))
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    @ViewBuilder
    func makeTabItem(_ tab: Tab) -> some View {
        (selectedTab == tab ? tab.selectedIcon : tab.defaultIcon)
            .resizable()
            .frame(width: 28, height: 28)
        Text(tab.title)
            .notosans(.caption2Semibold)
    }
}

// MARK: - Tab Extension

extension LivithMainTabView.Tab {
    var title: String {
        switch self {
        case .home: return "홈"
        case .search: return "탐색"
        case .my: return "마이"
        }
    }

    var defaultIcon: Image {
        switch self {
        case .home: return Image.livithIcon(.homeDisabled)
        case .search: return Image.livithIcon(.ticketDisabled)
        case .my: return Image.livithIcon(.myDisabled)
        }
    }

    var selectedIcon: Image {
        switch self {
        case .home: return Image.livithIcon(.homeEnabled)
        case .search: return Image.livithIcon(.ticketEnabled)
        case .my: return Image.livithIcon(.myEnabled)
        }
    }
}
