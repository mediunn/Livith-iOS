//
//  ExploreView.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/18/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Amplitude
import Domain
import LivithDesignSystem

struct ExploreView: View {
    @Environment(\.searchCoordinator) private var coordinator
    @StateObject private var store: ExploreStore = ExploreStore()
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: .zero) {
            LivithNavigationView(type: .logo())
            
            ZStack(alignment: .top) {
                ExploreSearchButton(onTap: handleSearchTap)
                    .zIndex(2)
                    .background(
                        scrollOffset > Constants.bannerHeight - 60
                        ? Color.livithColor(.black100)
                        : Color.clear
                    )
                
                scrollView
            }
        }
        .background(Color.livithColor(.black100))
    }
}

// MARK: - Subviews

private extension ExploreView {
    var scrollView: some View {
        ScrollView(showsIndicators: false) {
            if shouldShowEmptyState {
                LivithEmptyView(text: emptyStateMessage)
                    .containerRelativeFrame(.vertical)
            } else {
                VStack(spacing: 0) {
                    bannerView
                    
                    concertSectionView
                    
                    Spacer(minLength: Constants.emptySpaceHeight)
                }
            }
        }
        .coordinateSpace(name: Literals.scrollCoordinateName)
        .refreshable {
            store.send(.onRefresh)
        }
    }
    
    var bannerView: some View {
        BannerSectionView(
            currentPage: Binding(
                get: { store.state.currentPage },
                set: { store.send(.setCurrentPage($0)) }
            ),
            banners: store.state.banners
        )
        .frame(height: Constants.bannerHeight)
        .background(
            GeometryReader { proxy in
                Color.clear.onChange(of: proxy.frame(in: .named(Literals.scrollCoordinateName)).minY) {
                    scrollOffset = -proxy.frame(in: .named(Literals.scrollCoordinateName)).minY
                }
            }
        )
    }
    
    var concertSectionView: some View {
        ForEach(store.state.concertSections, id: \.id) { section in
            ConcertSectionView(concertSection: section) { concert in
                coordinator?.showConcertDetail(concertID: concert.id)
            }
            .padding(.top, 36)
            .padding(.leading, 16)
        }
    }
}

// MARK: - Helpers

private extension ExploreView {
    var shouldShowEmptyState: Bool {
        store.state.banners.isEmpty && store.state.concertSections.isEmpty && !store.state.isLoading
    }
    
    var emptyStateMessage: String {
        store.state.errorMessage.isEmpty ? "탐색할 콘텐츠가 없습니다." : store.state.errorMessage
    }
    
    func handleSearchTap() {
        AmplitudeService.shared.trackEvent(tag: .click(.searchBar))
        coordinator?.push(to: .search)
    }
}

// MARK: - PreferenceKey

private extension ExploreView {
    struct ScrollOffsetPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
}

// MARK: - Literals & Constants

private extension ExploreView {
    enum Literals {
        static let scrollCoordinateName = "exploreScroll"
    }
    
    enum Constants {
        static let bannerHeight: CGFloat = 365
        static let emptySpaceHeight: CGFloat = 210
    }
}
