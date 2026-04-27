//
//  HomeConcertSectionView.swift
//  HomeFeature
//
//  Created by Youjin Lee on 12/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Amplitude
import LivithDesignSystem

struct HomeConcertSectionView: View {

    // MARK: - Property

    @Environment(\.homeCoordinator) private var coordinator
    @ObservedObject private var store: HomeStore
    @State private var isPreferenceBannerExpanded: Bool = true
    
    init(store: HomeStore) {
        self.store = store
    }
    
    private var sectionState: HomeState.ConcertSectionState { store.state.concertSection }

    // MARK: - Body
    
    var body: some View {
        VStack(spacing: .zero) {
            LivithNavigationView(type: .logo(
                hasNewNotice: store.state.hasNewNotice,
                onNoticeTap: { coordinator?.push(to: .notice) }
            ))
            
            ScrollView {
                if sectionState.isLoading {
                    loadingView
                } else {
                    VStack(spacing: .zero) {
                        headerView
                        contentView
                    }
                }
            }
            .scrollIndicators(.never)
            .refreshable { store.send(.concertSection(.onRefresh)) }
            .ignoresSafeArea(edges: .bottom)
        }
        .background(.livithColor(.black90))
        .onAppear {
            isPreferenceBannerExpanded = true
        }
    }
}

// MARK: - UIComponents

private extension HomeConcertSectionView {
    var loadingView: some View {
        VStack(spacing: .zero) {
            Spacer(minLength: Constants.loadingMinHeight)
            
            ProgressView()
                .scaleEffect(1.6, anchor: .center)
            
            Spacer(minLength: Constants.loadingMinHeight)
        }
        .frame(maxWidth: .infinity)
    }
    
    var headerView: some View {
        VStack(spacing: .zero) {
            if sectionState.shouldShowPreferenceBanner {
                PreferenceBannerView(
                    isExpanded: $isPreferenceBannerExpanded,
                    onTapBanner: {
                        AmplitudeService.shared.trackEvent(tag: .click(.setPreferenceBannerMain))
                        coordinator?.push(to: .preferredGenreUpdate)
                    }
                )
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            
            HomeHeaderView(
                nickname: store.state.user?.nickname ?? "라이빗",
                action: {
                    AmplitudeService.shared.trackEvent(tag: .click(.interestConcertMain))
                    coordinator?.push(to: .interestConcertSearch)
                }
            )
        }
        .background(Color.livithColor(.black90))
        .zIndex(1)
    }
    
    var contentView: some View {
        HomeConcertContentSectionView(
            nickname: store.state.user?.nickname ?? "라이빗",
            sectionList: sectionState.sectionList,
            recommendedConcertList: sectionState.recommendedConcertList,
            shouldShowRecommendedConcertSection: !sectionState.shouldShowPreferenceBanner,
            onRecommendedConcertTap: { concert in
                AmplitudeService.shared.trackEvent(tag: .click(.recommendedConcertCell))
                coordinator?.showConcertDetail(concertID: concert.id)
            },
            onRecommendedSeeAllTap: {
                coordinator?.push(to: .recommendedConcertList(concertList: sectionState.recommendedConcertList))
            },
            onConcertTap: { concert in
                AmplitudeService.shared.trackEvent(tag: .click(.concertCellMain))
                coordinator?.showConcertDetail(concertID: concert.id)
            }
        )
    }
}

// MARK: - Helpers

private extension HomeConcertSectionView {
    enum Constants {
        static let loadingMinHeight: CGFloat = 240
    }
}
