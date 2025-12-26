//
//  ExploreView.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/18/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import SearchDomain

struct ExploreView: View {
    @EnvironmentObject private var router: SearchRouter
    @StateObject private var store: ExploreStore = ExploreStore()
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: .zero) {
            LivithLogoHeaderView()
            
            ZStack(alignment: .top) {
                ExploreSearchButton(onTap: { router.push(.search) })
                    .zIndex(2)
                    .background(
                        scrollOffset > Constants.bannerHeight - 60
                        ? Color.livithColor(.black100)
                        : Color.clear
                    )
                
                scrollContent
            }
        }
        .background(Color.livithColor(.black100))
    }
}

// MARK: - UI Components

private extension ExploreView {
    var loadingIndicator: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .scaleEffect(1.2)
    }
    
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                if store.state.isLoading {
                    loadingIndicator
                        .padding(.vertical, 20)
                }
                
                bannerView
                
                ForEach(store.state.concertSections, id: \.id) { section in
                    concertSectionRow(for: section)
                        .padding(.top, 36)
                        .padding(.leading, 16)
                }
                
                Spacer(minLength: Constants.emptySpaceHeight)
            }
        }
        .coordinateSpace(name: Literals.scrollCoordinateName)
        .refreshable {
            store.send(.onRefresh)
        }
        .overlay {
            if store.state.banners.isEmpty && store.state.concertSections.isEmpty && !store.state.isLoading {
                ExploreEmptyView(message: store.state.errorMessage)
            }
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
    
    func concertSectionRow(for section: ConcertSection) -> some View {
        ConcertSectionView(
            concertSection: section,
            onConcertTap: { concert in
                // TODO: Router를 이용한 콘서트 상세 화면 이동 + Concert 전달
            }
        )
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
