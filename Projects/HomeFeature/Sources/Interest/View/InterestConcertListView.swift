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

    @EnvironmentObject private var homeRouter: HomeRouter
    @State private var viewModel: InterestConcertListViewModel

    @State private var showSortOption: Bool = false

    @State private var showSortFailure = false

    init(repository: any InterestConcertRepository) {
        _viewModel = State(initialValue: InterestConcertListViewModel(repository: repository))
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            headerView
                .zIndex(2)

            sortControlRow
                .padding(.top, 24)
                .padding(.horizontal, 16)
                .zIndex(1)

            if !viewModel.isInitialLoading {
                gridView
                    .padding(.top, 24)
                    .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.livithColor(.black100))
        .overlay(alignment: .center) {
            if viewModel.isInitialLoading {
                LivithLoader()
                    .allowsHitTesting(false)
            }
        }
        .task { await viewModel.loadIfNeeded() }
        .livithToast(
            isPresented: $showSortFailure,
            type: .failure,
            message: "정렬을 변경하지 못했어요"
        )
    }
}

// MARK: - UIComponents

private extension InterestConcertListView {
    var headerView: some View {
        HStack(spacing: 4) {
            Button {
                homeRouter.pop()
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
            homeRouter.push(.interestConcertSetting(mode: .update))
        } label: {
            Text("변경하기")
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black50))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background {
                    Capsule()
                        .strokeBorder(Color.livithColor(.black50), lineWidth: 1)
                }
        }
    }

    var sortControlRow: some View {
        HStack(spacing: .zero) {
            Spacer()

            if viewModel.isChangingSort {
                LivithLoader()
                    .controlSize(.small)
                    .padding(.trailing, 6)
            }
            sortButton
                .disabled(viewModel.isChangingSort)
        }
    }

    var sortButton: some View {
        Button {
            showSortOption.toggle()
        } label: {
            HStack(spacing: 4) {
                Text(viewModel.selectedSort.title)
                    .notosans(.body4Medium)
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
                LivithOptionButton(option.title, isSelected: viewModel.selectedSort == option) {
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

    var gridView: some View {
        ScrollView(showsIndicators: false) {
            if shouldShowErrorEmptyView {
                errorEmptyView
            } else {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: 3),
                    spacing: 24
                ) {
                    ForEach(viewModel.interestConcertList, id: \.id) { interestConcert in
                        concertCard(for: interestConcert)
                    }
                }
                .id(viewModel.selectedSort)

                if viewModel.isLoadingMore {
                    ProgressView()
                        .tint(Color.livithColor(.white100))
                        .padding(.vertical, 16)
                }
            }
        }
    }

    var errorEmptyView: some View {
        LivithEmptyView(text: viewModel.errorMessage)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .containerRelativeFrame(.vertical)
    }

    func concertCard(for interestConcert: InterestConcert) -> some View {
        let concert = interestConcert.concert

        return LivithCard(
            imageURL: concert.posterURL,
            title: ConcertDisplayHelper.title(for: concert),
            subtitle: ConcertDisplayHelper.dateRange(for: concert),
            secondaryText: concert.artist,
            badge: .status(text: ConcertDisplayHelper.statusBadge(for: concert), remainDays: nil),
            onTap: {
                homeRouter.push(.concertDetail(
                    concertID: concert.id,
                    initialTab: .artistDetail,
                    initialSection: nil
                ))
            }
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .onAppear {
            if interestConcert.id == viewModel.interestConcertList.last?.id {
                Task { await viewModel.loadNextPage() }
            }
        }
    }
}

// MARK: - Computed Properties

private extension InterestConcertListView {
    var shouldShowErrorEmptyView: Bool {
        viewModel.interestConcertList.isEmpty && !viewModel.errorMessage.isEmpty
    }
}

// MARK: - Helpers

private extension InterestConcertListView {
    func handleSortOptionSelected(_ sort: InterestConcertSort) {
        showSortOption = false

        guard viewModel.selectedSort != sort else { return }

        Task {
            await viewModel.selectSort(sort)
            showSortFailure = viewModel.selectedSort != sort && !viewModel.errorMessage.isEmpty
        }
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
