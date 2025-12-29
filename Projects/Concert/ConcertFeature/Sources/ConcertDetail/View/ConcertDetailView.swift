//
//  ConcertDetailView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import Kingfisher
import ConcertDomain

public struct ConcertDetailView: View {

    // MARK: - Property

    @ObservedObject private var store: ConcertDetailStore
    private let concertID: Int
    private let onBack: () -> Void

    // MARK: - Initializer

    public init(
        store: ConcertDetailStore,
        concertID: Int,
        onBack: @escaping () -> Void
    ) {
        self.store = store
        self.concertID = concertID
        self.onBack = onBack

        store.send(.viewDidLoad(concertID: concertID))
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            navigationBar

            ScrollView {
                VStack(spacing: 0) {
                    posterSection
                    concertInfoSection
                    introductionSection
                }
            }
        }
        .background(Color.livithColor(.black100).ignoresSafeArea())
    }
}

// MARK: - Navigation Bar

private extension ConcertDetailView {
    var navigationBar: some View {
        HStack(spacing: 0) {
            Button {
                onBack()
            } label: {
                Image.livithIcon(.backLineDefault)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .padding(.leading, 16)

            Text(store.state.concert?.title ?? "")
                .notosans(.body2Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.leading, 12)

            Spacer()
        }
        .frame(height: 56)
        .background(Color.livithColor(.black100))
    }
}

// MARK: - Poster Section

private extension ConcertDetailView {
    var posterSection: some View {
        ZStack(alignment: .topTrailing) {
            posterImage

            favoriteButton
                .padding(.top, 16)
                .padding(.trailing, 16)
        }
    }

    var posterImage: some View {
        GeometryReader { geometry in
            if let posterURL = store.state.concert?.posterURL {
                KFImage(posterURL)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: 400)
                    .clipped()
                    .overlay {
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.livithColor(.black100).opacity(0.8),
                                Color.livithColor(.black100)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
            } else {
                Rectangle()
                    .fill(Color.livithColor(.black90))
                    .frame(width: geometry.size.width, height: 400)
            }
        }
        .frame(height: 400)
    }

    var favoriteButton: some View {
        Button {
            store.send(.favoriteButtonTapped)
        } label: {
            HStack(spacing: 4) {
                Image.livithIcon(.plusLineSmall)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 16, height: 16)

                Text("관심 콘서트 설정하기")
                    .notosans(.caption1Semibold)
            }
            .foregroundStyle(Color.livithColor(.white100))
        }
    }
}

// MARK: - Concert Info Section

private extension ConcertDetailView {
    var concertInfoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let label = store.state.concert?.label, !label.isEmpty {
                PopularBadge(text: label)
                    .padding(.bottom, 16)
            }

            concertTitle
                .padding(.bottom, 8)

            artistName
                .padding(.bottom, 16)

            dateInfo
                .padding(.bottom, 8)

            venueInfo
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, -80)
    }

    var concertTitle: some View {
        Text(store.state.concert?.title ?? "")
            .notosans(.headSemibold)
            .foregroundStyle(Color.livithColor(.white100))
    }

    var artistName: some View {
        Text(store.state.concert?.artist ?? "")
            .notosans(.body3Medium)
            .foregroundStyle(Color.livithColor(.black50))
    }

    var dateInfo: some View {
        HStack(spacing: 8) {
            Image.livithIcon(.calendarLine)
                .resizable()
                .renderingMode(.template)
                .frame(width: 20, height: 20)
                .foregroundStyle(Color.livithColor(.black50))

            Text(formatDateRange())
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black30))
        }
    }

    var venueInfo: some View {
        HStack(spacing: 8) {
            Image.livithIcon(.locationLine)
                .resizable()
                .renderingMode(.template)
                .frame(width: 20, height: 20)
                .foregroundStyle(Color.livithColor(.black50))

            Text(store.state.concert?.venue ?? "")
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black30))
        }
    }
}

// MARK: - Introduction Section

private extension ConcertDetailView {
    var introductionSection: some View {
        VStack(spacing: 0) {
            if let introduction = store.state.concert?.introduction, !introduction.isEmpty {
                ConcertIntroductionCard(introduction: introduction)
                    .padding(.horizontal, 16)
                    .padding(.top, 32)
            }

            Spacer()
                .frame(height: 100)
        }
    }
}

// MARK: - Helper Methods

private extension ConcertDetailView {
    func formatDateRange() -> String {
        guard let concert = store.state.concert else { return "" }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"

        let startDateString = formatter.string(from: concert.startDate)
        let endDateString = formatter.string(from: concert.endDate)

        if startDateString == endDateString {
            return startDateString
        } else {
            return "\(startDateString) ~\(endDateString)"
        }
    }
}

#Preview {
    ConcertDetailView(
        store: ConcertDetailStore(),
        concertID: 1,
        onBack: {}
    )
}
