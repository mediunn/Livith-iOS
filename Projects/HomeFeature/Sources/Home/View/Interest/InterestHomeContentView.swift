//
//  InterestHomeContentView.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/17/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

import Amplitude

struct InterestHomeContentView: View {

    // MARK: - Properties

    @EnvironmentObject private var homeRouter: HomeRouter
    @ObservedObject var store: HomeStore

    @Binding var isPreferenceBannerExpanded: Bool

    // MARK: - Body

    var body: some View {
        scrollView
            .onAppear {
                store.send(.interestAppear)
            }
    }
}

// MARK: - Computed Properties

private extension InterestHomeContentView {
    var preferenceBannerBackgroundColor: Color {
        Color.livithColor(store.state.interestConcertList.isEmpty ? .black100 : .black90)
    }

    var headerSectionTopPadding: CGFloat {
        let isEmptyInterestWithoutBanner = store.state.interestConcertList.isEmpty
            && !store.state.shouldShowPreferenceBanner
        return isEmptyInterestWithoutBanner ? .zero : Constants.headerSectionTopPadding
    }
}

// MARK: - UIComponents

private extension InterestHomeContentView {
    var scrollView: some View {
        ScrollView {
            if store.state.isSectionLoading || store.state.isInterestListRetryLoading {
                loadingView
            } else if store.state.isInterestListLoadFailed {
                loadFailedEmptyView
            } else {
                VStack(spacing: .zero) {
                    preferenceBannerSection
                        .zIndex(2)

                    headerSection
                        .padding(.top, headerSectionTopPadding)
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

    var loadFailedEmptyView: some View {
        LivithEmptyView(text: HomeStore.Constants.interestListLoadFailedEmptyMessage)
            .frame(maxWidth: .infinity)
            .containerRelativeFrame(.vertical)
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

private extension InterestHomeContentView {
    enum Constants {
        static let headerSectionTopPadding: CGFloat = 16
        static let sectionHorizontalPadding: CGFloat = 16
        static let loadingMinHeight: CGFloat = 240
    }
}
