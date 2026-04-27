//
//  RecommendedConcertSectionView.swift
//  HomeFeature
//
//  Created by 김진웅 on 2/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Domain
import LivithDesignSystem

struct RecommendedConcertSectionView: View {

    // MARK: - Property

    let title: String
    let concertList: [Concert]
    let onConcertTap: ((Concert) -> Void)
    let onSeeAllTap: () -> Void

    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerView
            
            if concertList.isEmpty {
                emptyStateView
            } else {
                concertListView
            }
        }
    }
}

// MARK: - UIComponents

private extension RecommendedConcertSectionView {
    var headerView: some View {
        HStack(alignment: .bottom) {
            Text(title)
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))
            
            Spacer()
            
            if concertList.count > Constants.maxVisibleConcertCount {
                Button(action: onSeeAllTap) {
                    Image.livithIcon(.rightLineDefault)
                        .resizable()
                        .frame(width: Constants.iconSize, height: Constants.iconSize)
                }
                .padding(.trailing, 16)
            }
        }
    }
    
    var concertListView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(concertList.prefix(Constants.maxVisibleConcertCount)) { concert in
                    LivithCard(
                        imageURL: concert.posterURL,
                        title: concert.title,
                        subtitle: DateFormatter.formatDateRange(from: concert.startDate, to: concert.endDate),
                        secondaryText: concert.artist,
                        badge: .status(text: concert.status.statusChipText, remainDays: concert.daysLeft),
                        onTap: { onConcertTap(concert) }
                    )
                }
            }
            .padding(.trailing, 16)
        }
    }
    
    var emptyStateView: some View {
        LivithEmptyView(text: Literals.emptyMessage)
            .aspectRatio(Constants.emptyViewRatio, contentMode: .fit)
    }
}

// MARK: - Helpers

private extension RecommendedConcertSectionView {
    enum Constants {
        static let maxVisibleConcertCount = 10
        static let iconSize: CGFloat = 24
        static let emptyViewRatio: CGFloat = 343 / 160
    }

    enum Literals {
        static let emptyMessage = "아직 공연 소식이 없어요 :(\n알림으로 가장 먼저 알려드릴게요"
    }
}

private extension Concert {
    static let mockConcerts: [Concert] = [
        Concert(
            id: 1,
            title: "2026 IU CONCERT",
            artist: "아이유",
            status: .ongoing,
            daysLeft: 0,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
            posterURL: URL(string: "https://picsum.photos/200/300")!,
            venue: "잠실실내체육관",
            ticketSite: "인터파크",
            ticketURL: URL(string: "https://ticket.interpark.com"),
            introduction: "2026년 아이유 콘서트",
            label: "추천"
        ),
        Concert(
            id: 2,
            title: "BTS WORLD TOUR",
            artist: "방탄소년단",
            status: .upcoming,
            daysLeft: 15,
            startDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 45, to: Date())!,
            posterURL: URL(string: "https://picsum.photos/200/301")!,
            venue: "서울월드컵경기장",
            ticketSite: "예스24",
            ticketURL: URL(string: "https://ticket.yes24.com"),
            introduction: "방탄소년단 월드투어",
            label: nil
        ),
        Concert(
            id: 3,
            title: "NewJeans Live",
            artist: "뉴진스",
            status: .upcoming,
            daysLeft: 7,
            startDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 9, to: Date())!,
            posterURL: URL(string: "https://picsum.photos/200/302")!,
            venue: "고척스카이돔",
            ticketSite: "멜론티켓",
            ticketURL: URL(string: "https://ticket.melon.com"),
            introduction: "뉴진스 라이브 공연",
            label: "인기"
        )
    ]
}

// MARK: - Preview

#Preview("Empty State") {
    RecommendedConcertSectionView(
        title: "유지미님의\n취향이 담긴 콘서트",
        concertList: []
    ) { concert in
        print("\(concert)눌림")
    } onSeeAllTap: {
        print("상세 눌림")
    }
    .background(.livithColor(.black100))
}

#Preview("With Concerts") {
    RecommendedConcertSectionView(
        title: "유지미님의\n취향이 담긴 콘서트",
        concertList: Concert.mockConcerts
    ) { concert in
        print("\(concert.title) 탭")
    } onSeeAllTap: {
        print("전체보기 탭")
    }
    .background(.livithColor(.black100))
}
