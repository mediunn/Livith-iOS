//
//  HomeConcertSectionView.swift
//  HomeFeature
//
//  Created by Youjin Lee on 12/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Domain

import LivithDesignSystem

struct HomeConcertSectionView: View {
    @Environment(\.homeCoordinator) private var coordinator
    @ObservedObject private var store: HomeStore
    
    init(store: HomeStore) {
        self.store = store
    }
    
    private var sectionState: HomeState.ConcertSectionState { store.state.sections }
    
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
        .onAppear { store.send(.concertSection(.onAppear)) }
    }
}

// MARK: - Subviews

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
                    isExpanded: Binding(
                        get: { sectionState.isPreferenceBannerExpanded },
                        set: { _ in store.send(.concertSection(.collapsePreferenceBanner)) }
                    ),
                    onTapBanner: { coordinator?.push(to: .preferredGenreUpdate) }
                )
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            
            HomeHeaderView(
                nickname: store.state.user?.nickname ?? "라이빗",
                action: { coordinator?.push(to: .interest) }
            )
        }
        .background(Color.livithColor(.black90))
    }
    
    var contentView: some View {
        VStack(spacing: .zero) {
            recommendedConcertSection
            
            concertSection
            
            Spacer(minLength: Constants.emptySpaceHeight)
        }
        .background(Color.livithColor(.black100))
    }
    
    @ViewBuilder
    var recommendedConcertSection: some View {
        if !sectionState.shouldShowPreferenceBanner {
            RecommendedConcertSectionView(
                title: "\(store.state.user?.nickname ?? "라이빗")님의\n취향이 담긴 콘서트",
                concertList: sectionState.recommendedConcertList
            ) { concert in
                coordinator?.showConcertDetail(concertID: concert.id)
            } onSeeAllTap: {
                coordinator?.push(to: .recommendedConcertList(concertList: sectionState.recommendedConcertList))
            }
            .padding(.top, Constants.sectionTopPadding)
            .padding(.leading, Constants.sectionLeadingPadding)
        }
    }
    
    @ViewBuilder
    var concertSection: some View {
        if !sectionState.isLoading && sectionState.sectionList.isEmpty {
            LivithEmptyView(text: emptyMessage)
                .padding(.top, Constants.sectionTopPadding)
        } else {
            ForEach(sectionState.sectionList, id: \.id) { section in
                concertSectionRow(for: section)
                    .padding(.top, Constants.sectionTopPadding)
                    .padding(.leading, Constants.sectionLeadingPadding)
            }
        }
    }
}

// MARK: - Helper

private extension HomeConcertSectionView {
    func concertSectionRow(for section: ConcertSection) -> some View {
        ConcertSectionView(concertSection: section) { concert in
            coordinator?.showConcertDetail(concertID: concert.id)
        }
    }
    
    var emptyMessage: String {
        sectionState.errorMessage.isEmpty ? "콘텐츠가 없습니다." : sectionState.errorMessage
    }
}

// MARK: - Constants

private extension HomeConcertSectionView {
    enum Constants {
        static let emptySpaceHeight: CGFloat = 210
        static let sectionTopPadding: CGFloat = 28
        static let sectionLeadingPadding: CGFloat = 16
        static let loadingMinHeight: CGFloat = 240
    }
}
