//
//  InterestConcertListView.swift
//  HomeFeature
//
//  Created by 김진웅 on 5/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import DisplaySupport
import Domain
import LivithDesignSystem

struct InterestConcertListView: View {

    // MARK: - Properties

    @Environment(\.homeCoordinator) private var coordinator
    @StateObject private var store: InterestConcertListStore = .init()

    @State private var showSortOption: Bool = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            headerView
                .zIndex(2)

            sortControlRow
                .padding(.top, 24)
                .padding(.horizontal, 16)
                .zIndex(1)

            contentView
                .padding(.top, 24)
                .padding(.horizontal, 16)
                .zIndex(0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.livithColor(.black100))
        .onAppear { store.send(.onAppear) }
    }
}

// MARK: - UIComponents

private extension InterestConcertListView {
    var headerView: some View {
        HStack(spacing: 4) {
            Button {
                coordinator?.pop()
            } label: {
                Image.livithIcon(.backLineDefault)
                    .resizable()
                    .frame(width: 36, height: 36)
            }

            Text("나의 관심 콘서트")
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))

            Spacer()

            changeButton
        }
        .padding(.top, 24)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .frame(height: 66)
    }

    var changeButton: some View {
        Button {
            coordinator?.push(to: .interestConcertSearch)
        } label: {
            Text("변경하기")
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black80))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background {
                    Capsule()
                        .strokeBorder(Color.livithColor(.black80), lineWidth: 1)
                }
        }
    }

    var sortControlRow: some View {
        HStack(spacing: .zero) {
            Spacer()

            sortButton
        }
    }

    var sortButton: some View {
        Button {
            showSortOption.toggle()
        } label: {
            HStack(spacing: 4) {
                Text(store.state.selectedSort.title)
                    .notosans(.caption1Bold)
                    .foregroundStyle(Color.livithColor(.white100))

                Image.livithIcon(showSortOption ? .upLineSmall : .down1_5LineSmall)
                    .renderingMode(.template)
                    .foregroundStyle(Color.livithColor(.white100))
            }
        }
        .overlay(alignment: .topTrailing) {
            if showSortOption {
                sortOptionView
                    .offset(y: 30)
                    .zIndex(1000)
            }
        }
    }

    var sortOptionView: some View {
        VStack(alignment: .center, spacing: .zero) {
            ForEach(InterestConcertSort.sortOptionList, id: \.self) { option in
                LivithOptionButton(option.title, isSelected: store.state.selectedSort == option) {
                    handleSortOptionSelected(option)
                }
                .padding(.bottom, option == InterestConcertSort.sortOptionList.last ? .zero : 8)
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
                topTrailingRadius: .zero
            )
            .fill(Color.livithColor(.black90))
            .strokeBorder(Color.livithColor(.black80), lineWidth: 1)
            .shadow(color: .black.opacity(0.25), radius: 5.2)
        }
    }

    @ViewBuilder
    var contentView: some View {
        if store.state.isInitialLoading {
            loadingView
        } else {
            gridView
        }
    }

    var loadingView: some View {
        VStack {
            Spacer()

            ProgressView()
                .tint(Color.livithColor(.white100))

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var gridView: some View {
        ScrollView(showsIndicators: false) {
            if shouldShowErrorEmptyView {
                errorEmptyView
            } else {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: 3),
                    spacing: 24
                ) {
                    ForEach(store.state.interestConcertList, id: \.id) { interestConcert in
                        concertCard(for: interestConcert)
                    }
                }

                if store.state.isLoadingMore {
                    ProgressView()
                        .tint(Color.livithColor(.white100))
                        .padding(.vertical, 16)
                }
            }
        }
    }

    var errorEmptyView: some View {
        LivithEmptyView(text: store.state.errorMessage)
            .frame(maxWidth: .infinity)
            .containerRelativeFrame(.vertical)
    }

    func concertCard(for interestConcert: InterestConcert) -> some View {
        let concert = interestConcert.concert

        return LivithCard(
            imageURL: concert.posterURL,
            title: InterestConcertDisplayText.title(for: interestConcert),
            subtitle: InterestConcertDisplayText.dateRange(for: interestConcert),
            secondaryText: concert.artist,
            badge: .status(text: InterestConcertDisplayText.badge(for: interestConcert), remainDays: nil),
            onTap: { coordinator?.showConcertDetail(concertID: concert.id) }
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .onAppear {
            if interestConcert.id == store.state.interestConcertList.last?.id {
                store.send(.loadNextPage)
            }
        }
    }
}

// MARK: - Computed Properties

private extension InterestConcertListView {
    var shouldShowErrorEmptyView: Bool {
        store.state.interestConcertList.isEmpty && !store.state.errorMessage.isEmpty
    }
}

// MARK: - Helpers

private extension InterestConcertListView {
    func handleSortOptionSelected(_ sort: InterestConcertSort) {
        showSortOption = false

        guard store.state.selectedSort != sort else { return }

        store.send(.sortSelected(sort))
    }
}

private extension InterestConcertSort {
    static let sortOptionList: [InterestConcertSort] = [.ticketing, .concert]

    var title: String {
        switch self {
        case .concert:
            return "공연 일정"
        case .ticketing:
            return "예매일"
        }
    }
}
