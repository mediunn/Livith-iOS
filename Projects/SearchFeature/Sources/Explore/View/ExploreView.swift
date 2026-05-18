//
//  ExploreView.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/18/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Amplitude
import DisplaySupport
import Domain
import LivithDesignSystem

struct ExploreView: View {

    // MARK: - Property

    @Environment(\.searchCoordinator) private var coordinator
    @Environment(\.openURL) private var openURL
    @StateObject private var store: ExploreStore = ExploreStore()

    @State private var showFilter: Bool = false
    @State private var showSort: Bool = false
    @State private var scrollOffset: CGFloat = 0

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            LivithNavigationView(type: .logo())

            ZStack(alignment: .top) {
                ExploreSearchButton(onTap: handleSearchTap)
                    .zIndex(2)
                    .background(
                        scrollOffset > Constants.bannerHeight - 60
                        ? Color.livithColor(.black100)
                        : Color.clear
                    )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        bannerView

                        genreTabView
                            .padding(.top, 20)

                        filterView
                            .padding(.top, 16)
                            .padding(.bottom, 46)
                            .zIndex(100)

                        if store.state.concertList.isEmpty {
                            emptyView
                                .padding(.top, 100)
                                .padding(.bottom, 200)
                        } else {
                            concertGridView
                        }
                    }
                }
                .coordinateSpace(name: Literals.scrollCoordinateName)
                .refreshable {
                    store.send(.onRefresh)
                }
            }
        }
        .background(Color.livithColor(.black100).ignoresSafeArea())
        .livithSheet(
            isPresented: $showFilter,
            detents: [.fraction(196.0 / 812.0)]
        ) {
            StatusFilterBottomSheetView(
                selectedStatusList: Binding(
                    get: { store.state.selectedStatusList },
                    set: { store.send(.statusListChanged($0)) }
                ),
                showFilter: $showFilter
            )
        }
    }
}

// MARK: - UIComponents

private extension ExploreView {
    var bannerView: some View {
        BannerSectionView(
            currentPage: Binding(
                get: { store.state.currentPage },
                set: { store.send(.setCurrentPage($0)) }
            ),
            banners: store.state.banners,
            onTapBanner: handleBannerTap
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

    var genreTabView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(ConcertGenre.allCases, id: \.self) { genre in
                    genreTabButton(genre: genre)
                }
            }
        }
        .frame(height: Constants.genreTabHeight)
    }

    func genreTabButton(genre: ConcertGenre) -> some View {
        let isSelected = store.state.selectedGenre == genre
        return Button {
            AmplitudeService.shared.trackEvent(tag: .click(genre.amplitudeClickEvent))
            store.send(.selectGenre(genre))
        } label: {
            VStack(spacing: 0) {
                Text(genre.genreEnglishText)
                    .notosans(.body2Semibold)
                    .foregroundStyle(
                        Color.livithColor(isSelected ? .white100 : .black50)
                    )
                    .padding(.horizontal, 12)
                    .frame(maxHeight: .infinity)

                Rectangle()
                    .fill(isSelected ? Color.livithColor(.white100) : Color.clear)
                    .frame(height: 2)
            }
            .frame(height: Constants.genreTabHeight)
        }
    }

    var filterView: some View {
        HStack(alignment: .center, spacing: 0) {
            LivithFilterButton(
                style: .status,
                selectedText: statusSelectedText,
                action: { showFilter = true },
                onClear: {
                    store.send(.statusListChanged([]))
                }
            )
            .padding(.leading, 16)

            Spacer()

            sortButton
                .padding(.trailing, 16)
        }
    }

    var sortButton: some View {
        Button {
            showSort.toggle()
        } label: {
            HStack(alignment: .center, spacing: 4) {
                Text(store.state.sortState == .latest ? "최신순" : "가나다순")
                    .notosans(.caption1Bold)
                    .foregroundStyle(Color.livithColor(.white100))

                Image.livithIcon(showSort ? .upLineSmall : .down1_5LineSmall)
                    .renderingMode(.template)
                    .foregroundStyle(Color.livithColor(.white100))
            }
        }
        .overlay(alignment: .topTrailing) {
            if showSort {
                sortView
                    .offset(y: 30)
                    .zIndex(1000)
            }
        }
    }

    var sortView: some View {
        VStack(alignment: .center, spacing: 0) {
            LivithOptionButton("최신순", isSelected: store.state.sortState == .latest) {
                AmplitudeService.shared.trackEvent(tag: .click(.sortLatest))
                store.send(.sortStateChanged(.latest))
                showSort = false
            }
            .padding(.bottom, 8)

            LivithOptionButton("가나다순", isSelected: store.state.sortState == .alphabetical) {
                AmplitudeService.shared.trackEvent(tag: .click(.sortAlphabetical))
                store.send(.sortStateChanged(.alphabetical))
                showSort = false
            }
        }
        .fixedSize()
        .padding(.horizontal, 14)
        .padding(.vertical, 16)
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: 16,
                bottomLeadingRadius: 16,
                bottomTrailingRadius: 16,
                topTrailingRadius: 0
            )
            .fill(Color.livithColor(.black90))
            .strokeBorder(Color.livithColor(.black80), lineWidth: 1)
            .shadow(color: .black.opacity(0.25), radius: 5.2)
        }
    }

    var concertGridView: some View {
        VStack(spacing: 0) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: 3),
                spacing: 16
            ) {
                ForEach(store.state.concertList, id: \.id) { concert in
                    LivithCard(
                        imageURL: concert.posterURL,
                        title: ConcertDisplayText.title(for: concert),
                        subtitle: concert.formattedStartDate,
                        secondaryText: concert.artist,
                        badge: .status(text: ConcertDisplayText.statusBadge(for: concert), remainDays: nil),
                        onTap: {
                            AmplitudeService.shared.trackEvent(tag: .click(.searchCell))
                            coordinator?.showConcertDetail(concertID: concert.id)
                        }
                    )
                    .onAppear {
                        if concert.id == store.state.concertList.last?.id {
                            store.send(.loadNextPage)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)

            if store.state.isLoadingMore {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
        }
    }

    var emptyView: some View {
        LivithEmptyView(text: "콘서트가 없어요")
    }
}

// MARK: - Helpers

private extension ExploreView {
    var statusSelectedText: String? {
        guard !store.state.selectedStatusList.isEmpty else { return nil }
        let names = store.state.selectedStatusList.map { $0.filterText }
        guard let first = names.first else { return nil }
        return names.count > 1 ? "\(first), ..." : first
    }

    func handleSearchTap() {
        AmplitudeService.shared.trackEvent(tag: .click(.searchBar))
        coordinator?.push(to: .search)
    }

    func handleBannerTap(_ banner: Banner) {
        guard let url = banner.linkURL,
              url.scheme?.lowercased() == "https",
              url.host?.isEmpty == false
        else {
            return
        }

        openURL(url)
    }
}

// MARK: - Literals & Constants

private extension ExploreView {
    enum Literals {
        static let scrollCoordinateName = "exploreScroll"
    }

    enum Constants {
        static let bannerHeight: CGFloat = 470
        static let genreTabHeight: CGFloat = 54
    }
}

// MARK: - ConcertGenre + Amplitude

fileprivate extension ConcertGenre {
    var amplitudeClickEvent: AmplitudeService.ClickEvent {
        switch self {
        case .all:
            return .genreAll
        case .jpop:
            return .genreJpop
        case .rockMetal:
            return .genreRockMetal
        case .rapHiphop:
            return .genreRapHiphop
        case .pop:
            return .genrePop
        case .indie:
            return .genreIndie
        }
    }
}
