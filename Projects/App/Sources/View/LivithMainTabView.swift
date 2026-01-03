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

struct LivithMainTabView: View {

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

    @Binding private var nickname: String
    @State private var selectedTab: Tab = .home
    @State private var isTabBarHidden: Bool = false
    @State private var showToast: Bool = false
    @State private var toastType: LivithToastType = .success
    @State private var toastMessage: String = ""
    
    // MARK: - LifeCycle

    init(nickname: Binding<String>) {
        self._nickname = nickname
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeContentView(nickname: $nickname, isTabBarHidden: $isTabBarHidden, showToast: { type, message in
                        toastType = type
                        toastMessage = message
                        showToast = true
                    })
                    .tag(Tab.home)
                    .toolbar(.hidden, for: .tabBar)
                
                SearchContentView(isTabBarHidden: $isTabBarHidden)
                    .tag(Tab.search)
                    .toolbar(.hidden, for: .tabBar)
                
                UserView(
                        isTabBarHidden: $isTabBarHidden,
                        showToast: { type, message in
                            toastType = type
                            toastMessage = message
                            showToast = true
                        }
                    )
                    .tag(Tab.my)
                    .toolbar(.hidden, for: .tabBar)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if !isTabBarHidden {
                customTabBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isTabBarHidden)
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
        .ignoresSafeArea(edges: .bottom)
        .livithToast(
            isPresented: $showToast,
            type: toastType,
            message: toastMessage,
            position: .safeAreaTop
        )
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
        .padding(.bottom, 28)
        .background(Color.livithColor(.black100))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.livithColor(.black80))
                .frame(height: 1)
        }
    }
}
