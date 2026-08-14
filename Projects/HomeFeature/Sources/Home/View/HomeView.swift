//
//  HomeView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Amplitude
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
        .background(Color.livithColor(.black100).ignoresSafeArea())
        .onAppear {
            isPreferenceBannerExpanded = true
            store.send(.homeAppear)
        }
        .onChange(of: store.state.interest.errorMessage) { _, newValue in
            if !newValue.isEmpty {
                showErrorToast = true
            }
        }
        .livithToast(
            isPresented: Binding(
                get: { showErrorToast && !store.state.interest.errorMessage.isEmpty },
                set: {
                    if !$0 {
                        showErrorToast = false
                        store.send(.interest(.onErrorToastDisappear))
                    }
                }
            ),
            type: .failure,
            message: store.state.interest.errorMessage
        )
        .livithSheet(
            isPresented: interestResultSheetBinding,
            detents: [.height(interestResultSheetHeight)],
            background: .livithColor(.black90)
        ) {
            if store.state.interest.shouldShowInterestResultSheet {
                InterestConcertResultSheetView(
                    alertList: store.state.interest.interestResultAlertList,
                    sheetHeight: $interestResultSheetHeight,
                    onConfirm: { store.send(.interest(.onInterestResultSheetDismiss)) },
                    onCheckTap: { concertID in
                        store.send(.interest(.onInterestResultSheetDismiss))
                        guard let concertID else { return }
                        homeRouter.push(.concertDetail(
                            concertID: concertID,
                            initialTab: .artistDetail,
                            initialSection: nil
                        ))
                    },
                    onRetryTap: {
                        AmplitudeService.shared.trackEvent(tag: .click(.concertRequestRetry))
                        store.send(.interest(.onInterestResultSheetDismiss))
                        homeRouter.push(.concertRequest)
                    }
                )
            }
        }
    }
}

// MARK: - Computed Properties

private extension HomeView {
    var interestResultSheetBinding: Binding<Bool> {
        Binding(
            get: { store.state.interest.shouldShowInterestResultSheet },
            set: { isPresented in
                if !isPresented {
                    store.send(.interest(.onInterestResultSheetDismiss))
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
            onTabSelected: { tab in
                AmplitudeService.shared.trackEvent(
                    tag: .click(tab == .interestConcert ? .interestConcertTab : .interestCalendarTab)
                )
                store.send(.homeTabSelected(tab))
            }
        ))
    }

    @ViewBuilder
    var tabContent: some View {
        switch store.state.selectedHomeTab {
        case .interestConcert:
            InterestHomeContentView(
                scope: InterestHomeScope(
                    state: store.state.interest,
                    send: { store.send(.interest($0)) }
                ),
                isPreferenceBannerExpanded: $isPreferenceBannerExpanded
            )
        case .calendar:
            CalendarHomeContentView(
                scope: CalendarHomeScope(
                    state: store.state.calendar,
                    send: { store.send(.calendar($0)) }
                )
            )
        }
    }
}
