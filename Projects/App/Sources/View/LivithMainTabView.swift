//
//  LivithMainTabView.swift
//  Livith-iOS
//
//  Created by Youjin Lee on 12/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import HomeFeature
import UserFeature
import SearchFeature

public struct LivithMainTabView: View {

    // MARK: - Enum

    enum Tab: Int, CaseIterable {
        case home, search, my

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

    // MARK: - Property
    
    @State private var selectedTab: Tab = .home
    @State private var isTabBarHidden: Bool = false
    
    // MARK: - LifeCycle

    public init() { }

    // MARK: - Body

    public var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .search:
                    SearchView(store: SearchStore())
                case .my:
                    UserView(nickname: "유짐이", isTabBarHidden: $isTabBarHidden)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if !isTabBarHidden {
                customTabBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isTabBarHidden)
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Components Extension

private extension LivithMainTabView {
    var customTabBar: some View {
        HStack(spacing: 73) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 0) {
                        (selectedTab == tab ? tab.selectedIcon : tab.defaultIcon)
                            .resizable()
                            .frame(width: 38, height: 38)

                        Text(tab.title)
                            .notosans(.caption2Semibold)
                            .foregroundStyle(Color.livithColor(selectedTab == tab ? .yellow60 : .black50))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(Color.livithColor(.black100))
    }
}
