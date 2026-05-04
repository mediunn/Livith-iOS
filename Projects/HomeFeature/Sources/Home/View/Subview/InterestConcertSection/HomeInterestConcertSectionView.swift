//
//  HomeInterestConcertSectionView.swift
//  HomeFeature
//
//  Created by 김진웅 on 4/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import DisplaySupport
import Domain
import LivithDesignSystem

struct HomeInterestConcertSectionView: View {

    // MARK: - Properties

    let interestConcertList: [InterestConcert]
    let selectedSort: InterestConcertSort
    let onChangeTap: () -> Void
    let onTitleTap: () -> Void
    let onSortSelected: (InterestConcertSort) -> Void
    let onConcertTap: (InterestConcert) -> Void

    @State private var currentPage: Int = 0
    @State private var showSortOption: Bool = false

    // MARK: - Initializer

    init(
        interestConcertList: [InterestConcert],
        selectedSort: InterestConcertSort = .ticketing,
        onChangeTap: @escaping () -> Void = {},
        onTitleTap: @escaping () -> Void = {},
        onSortSelected: @escaping (InterestConcertSort) -> Void = { _ in },
        onConcertTap: @escaping (InterestConcert) -> Void = { _ in }
    ) {
        self.interestConcertList = interestConcertList
        self.selectedSort = selectedSort
        self.onTitleTap = onTitleTap
        self.onChangeTap = onChangeTap
        self.onSortSelected = onSortSelected
        self.onConcertTap = onConcertTap
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            headerView
                .zIndex(1)

            cardPagerView
                .padding(.top, Constants.verticalSpacing)
                .zIndex(0)

            pageIndicatorView
                .padding(.top, Constants.verticalSpacing)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(Color.livithColor(.black100))
        .onChange(of: interestConcertList) { _, newValue in
            clampCurrentPage(itemCount: newValue.count)
        }
    }
}

// MARK: - Computed Properties

private extension HomeInterestConcertSectionView {
    var nextIndex: Int {
        guard !interestConcertList.isEmpty else { return currentPage }

        return (currentPage + 1) % interestConcertList.count
    }

    var previousIndex: Int {
        guard !interestConcertList.isEmpty else { return currentPage }

        return (currentPage - 1 + interestConcertList.count) % interestConcertList.count
    }

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: Constants.minimumDragDistance)
            .onEnded(handleDragEnded)
    }
}

// MARK: - UIComponents

private extension HomeInterestConcertSectionView {
    var headerView: some View {
        HStack(alignment: .top, spacing: .zero) {
            titleView

            Spacer()

            changeButton
                .padding(.top, 6)
        }
    }

    var titleView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                sortButton

                Text("이 가까운")
                    .notosans(.headSemibold)
                    .foregroundStyle(Color.livithColor(.white100))
            }

            titleButton
        }
        .overlay(alignment: .topLeading) {
            if showSortOption {
                sortOptionView
                    .offset(y: 30)
                    .zIndex(1000)
            }
        }
    }

    var sortButton: some View {
        Button {
            showSortOption.toggle()
        } label: {
            HStack(spacing: 4) {
                Text(selectedSort.title)
                    .notosans(.headSemibold)
                    .foregroundStyle(Color.livithColor(.white100))

                Image.livithIcon(showSortOption ? .sortUp : .sortDown)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.livithColor(.black50))
                    .frame(width: 8, height: 8)
            }
        }
    }

    var sortOptionView: some View {
        VStack(alignment: .center, spacing: .zero) {
            ForEach(InterestConcertSort.homeOptionList, id: \.self) { option in
                LivithOptionButton(option.title, isSelected: selectedSort == option) {
                    handleSortOptionSelected(option)
                }
                .padding(.bottom, option == InterestConcertSort.homeOptionList.last ? .zero : 8)
            }
        }
        .fixedSize()
        .padding(.horizontal, 14)
        .padding(.vertical, 16)
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: .zero,
                bottomLeadingRadius: 16,
                bottomTrailingRadius: 16,
                topTrailingRadius: 16
            )
            .fill(Color.livithColor(.black90))
            .strokeBorder(Color.livithColor(.black80), lineWidth: 1)
            .shadow(color: .black.opacity(0.25), radius: 5.2)
        }
    }

    var titleButton: some View {
        Button {
            onTitleTap()
        } label: {
            HStack(spacing: 4) {
                Text("관심 콘서트")
                    .notosans(.headSemibold)

                Image.livithIcon(.rightLineDefault)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 20, height: 20)
            }
            .foregroundStyle(Color.livithColor(.white100))
        }
    }

    var changeButton: some View {
        Button {
            onChangeTap()
        } label: {
            Text("변경하기")
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black50))
        }
    }

    var cardPagerView: some View {
        ZStack {
            ForEach(Array(interestConcertList.enumerated()), id: \.element.id) { index, interestConcert in
                let concert = interestConcert.concert

                InterestConcertCardView(
                    posterURL: concert.posterURL,
                    badgeText: InterestConcertDisplayText.badge(for: interestConcert),
                    titleText: InterestConcertDisplayText.title(for: interestConcert),
                    dateText: InterestConcertDisplayText.dateRange(for: interestConcert),
                    locationText: InterestConcertDisplayText.venue(for: interestConcert),
                    bottomText: InterestConcertDisplayText.bottom(for: interestConcert)
                )
                .opacity(index == currentPage ? 1 : 0)
            }
        }
        .contentShape(Rectangle())
        .gesture(dragGesture)
        .onTapGesture(perform: handleCardTapped)
    }

    var pageIndicatorView: some View {
        LivithPageIndicatorView(
            currentPage: currentPage,
            pageCount: interestConcertList.count
        )
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Helpers

private extension HomeInterestConcertSectionView {
    func handleSortOptionSelected(_ sort: InterestConcertSort) {
        showSortOption = false

        guard selectedSort != sort else { return }

        currentPage = 0
        onSortSelected(sort)
    }

    func handleDragEnded(_ value: DragGesture.Value) {
        let horizontalAmount = value.translation.width
        let newIndex = calculateNewIndex(from: horizontalAmount)

        guard newIndex != currentPage else { return }

        withAnimation(.easeInOut(duration: Constants.animationDuration)) {
            currentPage = newIndex
        }
    }

    func handleCardTapped() {
        guard interestConcertList.indices.contains(currentPage) else { return }

        onConcertTap(interestConcertList[currentPage])
    }

    func calculateNewIndex(from horizontalAmount: CGFloat) -> Int {
        if horizontalAmount < -Constants.dragThreshold {
            return nextIndex
        } else if horizontalAmount > Constants.dragThreshold {
            return previousIndex
        }
        return currentPage
    }

    func clampCurrentPage(itemCount: Int) {
        guard itemCount > 0 else {
            currentPage = 0
            return
        }

        guard currentPage >= itemCount else { return }

        currentPage = itemCount - 1
    }
}

// MARK: - Constants

private extension HomeInterestConcertSectionView {
    enum Constants {
        static let verticalSpacing: CGFloat = 20
        static let dragThreshold: CGFloat = 50
        static let minimumDragDistance: CGFloat = 20
        static let animationDuration: Double = 0.5
    }

    static let previewConcert = Concert(
        id: 1,
        title: "원 오크 록 내한공연",
        artist: "ONE OK ROCK",
        status: .upcoming,
        daysLeft: 20,
        startDate: Date(timeIntervalSince1970: 1_783_584_000),
        endDate: Date(timeIntervalSince1970: 1_783_670_400),
        posterURL: URL(string: "https://kopis.or.kr/upload/pfmPoster/PF_PF278958_251113_113650.jpg")!,
        venue: "잠실 실내 체육관",
        ticketSite: "인터파크 티켓",
        ticketURL: URL(string: "https://ticket.example.com"),
        introduction: "",
        label: nil
    )
}

private extension InterestConcertSort {
    static let homeOptionList: [InterestConcertSort] = [.ticketing, .concert]

    var title: String {
        switch self {
        case .concert:
            return "공연 일정"
        case .ticketing:
            return "예매일"
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        HomeInterestConcertSectionView(
            interestConcertList: [
                InterestConcert(
                    concert: HomeInterestConcertSectionView.previewConcert,
                    ticketingSchedule: InterestConcertTicketingSchedule(
                        preSaleDate: Date(timeIntervalSince1970: 1_782_201_600),
                        generalSaleDate: Date(timeIntervalSince1970: 1_782_288_000)
                    )
                )
            ]
        )
    }
}
