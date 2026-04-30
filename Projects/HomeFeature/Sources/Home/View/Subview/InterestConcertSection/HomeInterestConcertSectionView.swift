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

    @State private var currentPage: Int = 0
    @State private var showSortOption: Bool = false

    // MARK: - Initializer

    init(
        interestConcertList: [InterestConcert],
        selectedSort: InterestConcertSort = .concert,
        onChangeTap: @escaping () -> Void = {},
        onTitleTap: @escaping () -> Void = {},
        onSortSelected: @escaping (InterestConcertSort) -> Void = { _ in }
    ) {
        self.interestConcertList = interestConcertList
        self.selectedSort = selectedSort
        self.onTitleTap = onTitleTap
        self.onChangeTap = onChangeTap
        self.onSortSelected = onSortSelected
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
    var visibleItemList: [HomeInterestConcertSectionItem] {
        interestConcertList.map(makeItem)
    }

    var nextIndex: Int {
        guard !visibleItemList.isEmpty else { return currentPage }

        return (currentPage + 1) % visibleItemList.count
    }

    var previousIndex: Int {
        guard !visibleItemList.isEmpty else { return currentPage }

        return (currentPage - 1 + visibleItemList.count) % visibleItemList.count
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
                    .notosans(.body1Semibold)
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
                    .notosans(.body1Semibold)
                    .foregroundStyle(Color.livithColor(.white100))

                Image.livithIcon(showSortOption ? .upLineSmall : .down1_5LineSmall)
                    .renderingMode(.template)
                    .foregroundStyle(Color.livithColor(.white100))
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
            // TODO: 관심 콘서트 목록/상세 뷰 확정 후 이동을 연결한다.
            onTitleTap()
        } label: {
            HStack(spacing: 4) {
                Text("관심 콘서트")
                    .notosans(.body1Semibold)

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
            // TODO: 새 관심 콘서트 변경 플로우 확정 후 interestConcertSearch 이동을 연결한다.
            onChangeTap()
        } label: {
            Text("변경하기")
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black50))
        }
    }

    var cardPagerView: some View {
        ZStack {
            ForEach(Array(visibleItemList.enumerated()), id: \.element.id) { index, item in
                InterestConcertCardView(
                    posterURL: item.posterURL,
                    badgeText: item.badgeText,
                    titleText: item.titleText,
                    dateText: item.dateText,
                    locationText: item.locationText,
                    bottomText: item.bottomText
                )
                .opacity(index == currentPage ? 1 : 0)
            }
        }
        .contentShape(Rectangle())
        .gesture(dragGesture)
    }

    var pageIndicatorView: some View {
        LivithPageIndicatorView(
            currentPage: currentPage,
            pageCount: visibleItemList.count
        )
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Helpers

private extension HomeInterestConcertSectionView {
    func makeItem(from interestConcert: InterestConcert) -> HomeInterestConcertSectionItem {
        let concert = interestConcert.concert

        return HomeInterestConcertSectionItem(
            id: concert.id,
            posterURL: concert.posterURL,
            badgeText: badgeText(from: concert),
            titleText: ConcertDisplayText.title(for: concert),
            dateText: dateText(from: concert),
            locationText: ConcertDisplayText.venue(for: concert),
            bottomText: bottomText(from: interestConcert.ticketingSchedule)
        )
    }

    func handleSortOptionSelected(_ sort: InterestConcertSort) {
        showSortOption = false

        guard selectedSort != sort else { return }

        currentPage = 0
        onSortSelected(sort)
    }

    func ticketDate(from schedule: InterestConcertTicketingSchedule) -> Date? {
        [schedule.preSaleDate, schedule.generalSaleDate]
            .compactMap { $0 }
            .min()
    }

    func badgeText(from concert: Concert) -> String {
        guard concert.status == .upcoming else {
            return concert.status.filterText
        }

        guard let daysLeft = concert.daysLeft else {
            return ConcertDisplayText.unknownDaysLeft
        }

        guard daysLeft != 0 else {
            return "공연 D-Day"
        }

        guard daysLeft > 0 else {
            return ConcertStatus.completed.filterText
        }

        return "공연 D-\(daysLeft)"
    }

    func dateText(from concert: Concert) -> String {
        ConcertDisplayText.dateRange(for: concert)
    }

    func bottomText(from schedule: InterestConcertTicketingSchedule) -> String {
        guard let ticketDate = ticketDate(from: schedule) else {
            return ConcertDisplayText.unknownTicketingDate
        }

        let prefix = schedule.preSaleDate == ticketDate ? "선예매 오픈" : "일반 예매 오픈"
        return "\(prefix) · \(ConcertDisplayText.ticketingDate(ticketDate))"
    }

    func handleDragEnded(_ value: DragGesture.Value) {
        let horizontalAmount = value.translation.width
        let newIndex = calculateNewIndex(from: horizontalAmount)

        guard newIndex != currentPage else { return }

        withAnimation(.easeInOut(duration: Constants.animationDuration)) {
            currentPage = newIndex
        }
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

private struct HomeInterestConcertSectionItem: Identifiable, Equatable {
    let id: Int
    let posterURL: URL?
    let badgeText: String
    let titleText: String
    let dateText: String
    let locationText: String
    let bottomText: String
}

private extension InterestConcertSort {
    static let homeOptionList: [InterestConcertSort] = [.concert, .ticketing]

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
