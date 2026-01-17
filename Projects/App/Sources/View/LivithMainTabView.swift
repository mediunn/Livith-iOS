//
//  LivithMainTabView.swift
//  Livith-iOS
//
//  Created by Youjin Lee on 12/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem
import HomeFeature
import UserFeature
import SearchFeature

struct LivithMainTabView: View {
    
    // MARK: - Tab
    
    enum Tab: Int, CaseIterable {
        case home, search, my
    }
    
    // MARK: - Property
    
    @Binding private var nickname: String
    @State private var selectedTab: Tab = .home
    @State private var isTabBarHidden: Bool = false
    @State private var showToast: Bool = false
    @State private var toastType: LivithToastType = .success
    @State private var toastMessage: String = ""
    @State private var deepLinkConcertID: Int?
    
    // MARK: - LifeCycle
    
    init(nickname: Binding<String>) {
        self._nickname = nickname
        configureTabBarAppearance()
    }
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeContentView(
                nickname: $nickname,
                isTabBarHidden: $isTabBarHidden,
                deepLinkConcertID: $deepLinkConcertID,
                showToast: { type, message in
                    toastType = type
                    toastMessage = message
                    showToast = true
                }
            )
            .tag(Tab.home)
            .tabItem {
                makeTabItem(.home)
            }
            .toolbar(isTabBarHidden ? .hidden : .visible, for: .tabBar)
            
            SearchContentView(isTabBarHidden: $isTabBarHidden)
                .tag(Tab.search)
                .tabItem {
                    makeTabItem(.search)
                }
                .toolbar(isTabBarHidden ? .hidden : .visible, for: .tabBar)
            
            UserView(
                nickname: $nickname,
                isTabBarHidden: $isTabBarHidden,
                showToast: { type, message in
                    toastType = type
                    toastMessage = message
                    showToast = true
                }
            )
            .tag(Tab.my)
            .tabItem {
                makeTabItem(.my)
            }
            .toolbar(isTabBarHidden ? .hidden : .visible, for: .tabBar)
        }
        .preferredColorScheme(.dark)
        .livithToast(
            isPresented: $showToast,
            type: toastType,
            message: toastMessage,
            position: .safeAreaTop
        )
        .onReceive(NotificationCenter.default.publisher(for: .openConcertDetail)) { notification in
            if let concertID = notification.userInfo?["concertID"] as? Int {
                selectedTab = .home
                deepLinkConcertID = concertID
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
