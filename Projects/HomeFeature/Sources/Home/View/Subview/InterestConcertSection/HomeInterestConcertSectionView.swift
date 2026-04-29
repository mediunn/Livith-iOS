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

    let concert: Concert
    let onChangeTap: () -> Void
    let onTitleTap: () -> Void

    @State private var currentPage: Int = 0
    @State private var showSortOption: Bool = false
    @State private var selectedSortOption: HomeInterestConcertSortOption = .ticketDate

    // MARK: - Initializer

    init(
        concert: Concert,
        onChangeTap: @escaping () -> Void = {},
        onTitleTap: @escaping () -> Void = {}
    ) {
        self.concert = concert
        self.onTitleTap = onTitleTap
        self.onChangeTap = onChangeTap
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
    }
}

// MARK: - Computed Properties

private extension HomeInterestConcertSectionView {
    var visibleItemList: [HomeInterestConcertSectionItem] {
        [makeItem(from: concert)]
    }

    var nextIndex: Int {
        (currentPage + 1) % visibleItemList.count
    }

    var previousIndex: Int {
        (currentPage - 1 + visibleItemList.count) % visibleItemList.count
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
                Text(selectedSortOption.title)
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
            ForEach(HomeInterestConcertSortOption.allCases, id: \.self) { option in
                LivithOptionButton(option.title, isSelected: selectedSortOption == option) {
                    selectedSortOption = option
                    currentPage = 0
                    showSortOption = false
                }
                .padding(.bottom, option == HomeInterestConcertSortOption.allCases.last ? .zero : 8)
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
    func makeItem(from concert: Concert) -> HomeInterestConcertSectionItem {
        HomeInterestConcertSectionItem(
            id: concert.id,
            ticketDate: concert.startDate,
            concertDate: concert.startDate,
            posterURL: concert.posterURL,
            badgeText: badgeText(from: concert),
            titleText: ConcertDisplayText.title(for: concert),
            dateText: dateText(from: concert),
            locationText: ConcertDisplayText.venue(for: concert),
            bottomText: bottomText(from: concert)
        )
    }

    func badgeText(from concert: Concert) -> String {
        guard concert.status == .upcoming else {
            return concert.status.filterText
        }

        guard let daysLeft = concert.daysLeft else {
            return ConcertDisplayText.unknownDaysLeft
        }

        guard daysLeft > 0 else {
            return "공연 D-Day"
        }

        return "공연 D-\(daysLeft)"
    }

    func dateText(from concert: Concert) -> String {
        ConcertDisplayText.dateRange(for: concert)
    }

    func bottomText(from concert: Concert) -> String {
        guard let ticketingOffice = concert.ticketingOffice else {
            return "예매 정보가 곧 공개될 예정이에요"
        }

        return "예매처 · \(ticketingOffice)"
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
    let ticketDate: Date?
    let concertDate: Date?
    let posterURL: URL?
    let badgeText: String
    let titleText: String
    let dateText: String
    let locationText: String
    let bottomText: String
}

private enum HomeInterestConcertSortOption: CaseIterable {
    case ticketDate
    case concertDate

    var title: String {
        switch self {
        case .ticketDate:
            return "예매일"
        case .concertDate:
            return "공연 일정"
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        HomeInterestConcertSectionView(concert: HomeInterestConcertSectionView.previewConcert)
    }
}
