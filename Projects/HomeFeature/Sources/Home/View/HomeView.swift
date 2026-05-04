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

    @Environment(\.homeCoordinator) private var coordinator
    @StateObject private var store: HomeStore = .init()

    @State private var showErrorToast = false
    @State private var isPreferenceBannerExpanded: Bool = true

    // MARK: - Body
    
    var body: some View {
        VStack(spacing: .zero) {
            navigationView

            scrollView
        }
        .background(backgroundColor.ignoresSafeArea())
        .onAppear {
            isPreferenceBannerExpanded = true
            store.send(.onAppear)
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
    }
}

// MARK: - Computed Properties

private extension HomeView {
    var backgroundColor: Color {
        Color.livithColor(store.state.interestConcertList.isEmpty ? .black90 : .black100)
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
            onNoticeTap: { coordinator?.push(to: .notice) }
        ))
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
                    coordinator?.push(to: .preferredGenreUpdate)
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
                onChangeTap: { coordinator?.push(to: .interestConcertSetting(mode: .update)) },
                onTitleTap: { coordinator?.push(to: .interestConcertList) },
                onSortSelected: { store.send(.interestConcertSortSelected($0)) },
                onConcertTap: { interestConcert in
                    coordinator?.showConcertDetail(concertID: interestConcert.concert.id)
                }
            )
        } else {
            EmptyInterestConcertSectionView(
                nickname: store.state.user?.nickname ?? "라이빗",
                onSettingTap: {
                    AmplitudeService.shared.trackEvent(tag: .click(.interestConcertMain))
                    coordinator?.push(to: .interestConcertSetting(mode: .initialSetup))
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
                coordinator?.showConcertDetail(concertID: concert.id)
            },
            onRecommendedSeeAllTap: {
                coordinator?.push(to: .recommendedConcertList(concertList: store.state.recommendedConcertList))
            },
            onConcertTap: { concert in
                AmplitudeService.shared.trackEvent(tag: .click(.concertCellMain))
                coordinator?.showConcertDetail(concertID: concert.id)
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
    }
}
