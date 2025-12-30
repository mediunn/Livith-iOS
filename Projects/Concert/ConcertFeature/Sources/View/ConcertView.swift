//
//  ConcertView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Kingfisher

import ConcertDomain
import DSKit

public struct ConcertView: View {

    // MARK: - Property
    
    private let concertID: Int
    private let onDismiss: () -> Void

    @State private var isPosterLoaded: Bool = false
    @ObservedObject private var store: ConcertStore

    // MARK: - Initializer

    public init(
        store: ConcertStore = ConcertStore(),
        concertID: Int,
        onDismiss: @escaping () -> Void
    ) {
        self.store = store
        self.concertID = concertID
        self.onDismiss = onDismiss
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            ConcertNavigationBar(
                title: store.state.concert?.title ?? "",
                onBack: onDismiss
            )

            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    headerSection

                    Section {
                        tabContentView
                    } header: {
                        segmentTabBar
                    }
                }
            }
        }
        .background(Color.livithColor(.black100).ignoresSafeArea())
        .onAppear {
            store.send(.onAppear(concertID: concertID))
        }
    }
}

// MARK: - Header Section

private extension ConcertView {
    var headerSection: some View {
        ZStack {
            posterSection
                .frame(maxWidth: .infinity)
                .frame(height: 340)

            concertInfoSection
                .padding(.top, 120)
                .padding(.bottom, 30)
        }
    }
}

// MARK: - Segment TabBar

private extension ConcertView {
    var segmentTabBar: some View {
        ConcertSegmentTabBar(
            selectedTab: store.state.selectedTab,
            communityCount: store.state.communityCount,
            onTabSelected: { tab in
                withAnimation(.easeInOut(duration: 0.2)) {
                    store.send(.tabSelected(tab))
                }
            }
        )
    }
}

// MARK: - Tab Content

private extension ConcertView {
    @ViewBuilder
    var tabContentView: some View {
        switch store.state.selectedTab {
        case .artistDetail:
            ArtistDetailTabView(introduction: store.state.concert?.introduction ?? "")
        case .concertInfo:
            ConcertInfoTabView()
        case .setlist:
            SetlistTabView()
        case .community:
            CommunityTabView()
        }
    }
}

// MARK: - Poster Section

private extension ConcertView {
    var posterSection: some View {
        ZStack(alignment: .topTrailing) {
            posterImage

            FavoriteButton {
                store.send(.favoriteButtonTapped)
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
    }

    var posterImage: some View {
        Group {
            if let posterURL = store.state.concert?.posterURL {
                KFImage(posterURL)
                    .onSuccess { _ in isPosterLoaded = true }
                    .onFailure { _ in isPosterLoaded = false }
                    .placeholder {
                        Image.livithImage(.concertCardEmpty)
                            .resizable()
                            .scaledToFill()
                    }
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .overlay {
                        if isPosterLoaded {
                            BackgroundGradient(
                                baseColor: .livithColor(.black100),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        }
                    }
            } else {
                Image.livithImage(.concertCardEmpty)
                    .resizable()
                    .scaledToFill()
            }
        }
    }
}

// MARK: - Concert Info Section

private extension ConcertView {
    var concertInfoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let label = store.state.concert?.label, !label.isEmpty {
                PopularBadge(text: label)
                    .padding(.bottom, 10)
            }

            concertTitle
                .padding(.bottom, 10)

            artistName
                .padding(.bottom, 10)

            dateInfo
                .padding(.bottom, 4)

            venueInfo
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }

    var concertTitle: some View {
        Text(store.state.concert?.title ?? "")
            .notosans(.headSemibold)
            .foregroundStyle(Color.livithColor(.white100))
    }

    var artistName: some View {
        Text(store.state.concert?.artist ?? "")
            .notosans(.body2Medium)
            .foregroundStyle(Color.livithColor(.black30))
    }

    var dateInfo: some View {
        HStack(spacing: 4) {
            Image.livithIcon(.calendarLine)
                .resizable()
                .frame(width: 24, height: 24)

            Text(store.state.formattedDateRange)
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black30))
        }
    }

    var venueInfo: some View {
        HStack(spacing: 4) {
            Image.livithIcon(.locationLine)
                .resizable()
                .frame(width: 24, height: 24)

            Text(store.state.concert?.venue ?? "")
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black30))
        }
    }
}

#Preview {
    ConcertView(
        store: ConcertStore(),
        concertID: 1,
        onDismiss: {}
    )
}
