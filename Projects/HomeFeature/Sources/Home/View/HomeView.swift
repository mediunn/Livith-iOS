//
//  HomeView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct HomeView: View {

    // MARK: - Properties

    @EnvironmentObject private var homeRouter: HomeRouter
    @StateObject private var store: HomeStore = .init()

    @State private var showErrorToast = false
    @State private var isPreferenceBannerExpanded: Bool = true
    @State private var interestResultSheetHeight: CGFloat = 320

    // MARK: - Body
    
    var body: some View {
        VStack(spacing: .zero) {
            navigationView

            segmentedTabBar

            tabContent
        }
        .background(backgroundColor.ignoresSafeArea())
        .onAppear {
            isPreferenceBannerExpanded = true
            store.send(.homeAppear)
        }
        .onChange(of: store.state.errorMessage) { _, newValue in
            if !newValue.isEmpty {
                showErrorToast = true
            }
        }
        .livithToast(
            isPresented: Binding(
                get: { showErrorToast && !store.state.errorMessage.isEmpty },
                set: { if !$0 { showErrorToast = false; store.send(.onErrorToastDisappear) } }
            ),
            type: .failure,
            message: store.state.errorMessage
        )
        .livithSheet(
            isPresented: interestResultSheetBinding,
            detents: [.height(interestResultSheetHeight)],
            background: .livithColor(.black90)
        ) {
            if let content = store.state.interestResultSheetContent {
                InterestConcertResultSheetView(
                    content: content,
                    sheetHeight: $interestResultSheetHeight,
                    onConfirm: { store.send(.onInterestResultSheetDismiss) },
                    onCheckTap: {},
                    onRetryTap: {}
                )
            }
        }
    }
}

// MARK: - Computed Properties

private extension HomeView {
    var backgroundColor: Color {
        switch store.state.selectedHomeTab {
        case .interestConcert:
            return Color.livithColor(store.state.interestConcertList.isEmpty ? .black90 : .black100)
        case .calendar:
            return Color.livithColor(.black100)
        }
    }

    var interestResultSheetBinding: Binding<Bool> {
        Binding(
            get: { store.state.shouldShowInterestResultSheet },
            set: { isPresented in
                if !isPresented {
                    store.send(.onInterestResultSheetDismiss)
                }
            }
        )
    }
}

// MARK: - UIComponents

private extension HomeView {
    var navigationView: some View {
        LivithNavigationView(type: .logo(
            hasNewNotice: store.state.hasNewNotice,
            onNoticeTap: { homeRouter.push(.notice) }
        ))
    }

    var segmentedTabBar: some View {
        SegmentedTabBar(type: .home(
            selectedTab: store.state.selectedHomeTab,
            onTabSelected: { store.send(.homeTabSelected($0)) }
        ))
    }

    @ViewBuilder
    var tabContent: some View {
        switch store.state.selectedHomeTab {
        case .interestConcert:
            InterestHomeContentView(
                store: store,
                isPreferenceBannerExpanded: $isPreferenceBannerExpanded
            )
        case .calendar:
            CalendarHomeContentView(store: store)
        }
    }
}
