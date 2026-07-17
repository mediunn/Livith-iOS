//
//  HomeView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

import Amplitude

struct HomeView: View {

    // MARK: - Properties

    @EnvironmentObject private var homeRouter: HomeRouter
    @StateObject private var store: HomeStore = .init()

    @State private var showErrorToast = false
    @State private var showInterestConcertToast = false
    @State private var isPreferenceBannerExpanded: Bool = true

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
            store.send(.onAppear)
        }
        .onChange(of: store.state.errorMessage) { _, newValue in
            if !newValue.isEmpty {
                showErrorToast = true
                showInterestConcertToast = false
            }
        }
        .onChange(of: store.state.interestConcertToastMessage) { _, newValue in
            if !newValue.isEmpty && store.state.errorMessage.isEmpty {
                showInterestConcertToast = true
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
        .livithToast(
            isPresented: Binding(
                get: {
                    showInterestConcertToast
                    && !store.state.interestConcertToastMessage.isEmpty
                    && !(showErrorToast && !store.state.errorMessage.isEmpty)
                },
                set: { if !$0 { showInterestConcertToast = false; store.send(.onInterestConcertToastDisappear) } }
            ),
            type: .success,
            message: store.state.interestConcertToastMessage
        )
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

    var preferenceBannerBackgroundColor: Color {
        Color.livithColor(store.state.interestConcertList.isEmpty ? .black100 : .black90)
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
            scrollView
        case .calendar:
            calendarPlaceholderView
        }
    }

    var calendarPlaceholderView: some View {
        VStack {
            Spacer()
            Text(Constants.calendarPlaceholderText)
                .notosans(.body2Semibold)
                .foregroundStyle(Color.livithColor(.black50))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var scrollView: some View {
        ScrollView {
            if store.state.isConcertSectionLoading {
                loadingView
            } else {
                VStack(spacing: .zero) {
                    preferenceBannerSection
                        .zIndex(2)

                    headerSection
                        .padding(.top, Constants.headerSectionTopPadding)
                        .zIndex(1)

                    concertContentSection
                }
            }
        }
        .scrollIndicators(.never)
        .refreshable { store.send(.onRefresh) }
        .ignoresSafeArea(edges: .bottom)
    }

    var loadingView: some View {
        VStack(spacing: .zero) {
            Spacer(minLength: Constants.loadingMinHeight)

            ProgressView()
                .scaleEffect(1.6, anchor: .center)

            Spacer(minLength: Constants.loadingMinHeight)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    var preferenceBannerSection: some View {
        if store.state.shouldShowPreferenceBanner {
            PreferenceBannerView(
                isExpanded: $isPreferenceBannerExpanded,
                onTapBanner: {
                    AmplitudeService.shared.trackEvent(tag: .click(.setPreferenceBannerMain))
                    homeRouter.push(.preferredGenreUpdate)
                },
                backgroundColor: preferenceBannerBackgroundColor
            )
            .padding(.horizontal, Constants.sectionHorizontalPadding)
            .padding(.top, Constants.headerSectionTopPadding)
        }
    }

    @ViewBuilder
    var headerSection: some View {
        if !store.state.interestConcertList.isEmpty {
            HomeInterestConcertSectionView(
                interestConcertList: store.state.interestConcertList,
                selectedSort: store.state.interestConcertSort,
                onChangeTap: { homeRouter.push(.interestConcertSetting(mode: .update)) },
                onTitleTap: { homeRouter.push(.interestConcertList) },
                onSortSelected: { store.send(.interestConcertSortSelected($0)) },
                onConcertTap: { interestConcert in
                    homeRouter.push(.concertDetail(
                        concertID: interestConcert.concert.id,
                        initialTab: .artistDetail,
                        initialSection: nil
                    ))
                }
            )
        } else {
            EmptyInterestConcertSectionView(
                nickname: store.state.user?.nickname ?? "라이빗",
                onSettingTap: {
                    AmplitudeService.shared.trackEvent(tag: .click(.interestConcertMain))
                    homeRouter.push(.interestConcertSetting(mode: .initialSetup))
                }
            )
        }
    }

    var concertContentSection: some View {
        HomeConcertContentSectionView(
            nickname: store.state.user?.nickname ?? "라이빗",
            sectionList: store.state.concertSectionList,
            recommendedConcertList: store.state.recommendedConcertList,
            shouldShowRecommendedConcertSection: !store.state.shouldShowPreferenceBanner,
            onRecommendedConcertTap: { concert in
                AmplitudeService.shared.trackEvent(tag: .click(.recommendedConcertCell))
                homeRouter.push(.concertDetail(
                    concertID: concert.id,
                    initialTab: .artistDetail,
                    initialSection: nil
                ))
            },
            onRecommendedSeeAllTap: {
                homeRouter.push(.recommendedConcertList(concertList: store.state.recommendedConcertList))
            },
            onConcertTap: { concert in
                AmplitudeService.shared.trackEvent(tag: .click(.concertCellMain))
                homeRouter.push(.concertDetail(
                    concertID: concert.id,
                    initialTab: .artistDetail,
                    initialSection: nil
                ))
            }
        )
    }
}

// MARK: - Constants

private extension HomeView {
    enum Constants {
        static let headerSectionTopPadding: CGFloat = 16
        static let sectionHorizontalPadding: CGFloat = 16
        static let loadingMinHeight: CGFloat = 240
        static let calendarPlaceholderText = "준비 중"
    }
}
