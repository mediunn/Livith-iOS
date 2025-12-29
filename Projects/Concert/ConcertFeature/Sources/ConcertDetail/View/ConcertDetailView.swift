//
//  ConcertDetailView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Kingfisher

import ConcertDomain
import DSKit

public struct ConcertDetailView: View {

    // MARK: - Property
    
    private let concertID: Int
    private let onDismiss: () -> Void

    @State private var isPosterLoaded: Bool = false
    @ObservedObject private var store: ConcertDetailStore

    // MARK: - Initializer

    public init(
        store: ConcertDetailStore = ConcertDetailStore(),
        concertID: Int,
        onDismiss: @escaping () -> Void
    ) {
        self.store = store
        self.concertID = concertID
        self.onDismiss = onDismiss

        store.send(.onAppear(concertID: concertID))
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            navigationBar

            ScrollView {
                ZStack {
                    posterSection
                        .frame(maxWidth: .infinity)
                        .frame(height: 340)
                    
                    concertInfoSection
                        .padding(.top, 120)
                }
            }
        }
        .background(Color.livithColor(.black100).ignoresSafeArea())
    }
}

// MARK: - Navigation Bar

private extension ConcertDetailView {
    var navigationBar: some View {
        HStack(spacing: 4) {
            Button {
                onDismiss()
            } label: {
                Image.livithIcon(.backLineDefault)
                    .resizable()
                    .frame(width: 38, height: 38)
            }

            Text(store.state.concert?.title ?? "")
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .lineLimit(1)
                .truncationMode(.tail)
             
            Spacer()
                
        }
        .padding(.horizontal, 16)
        .frame(height: 66)
        .background(Color.livithColor(.black100))
    }
}

// MARK: - Poster Section

private extension ConcertDetailView {
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

private extension ConcertDetailView {
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

            Text(formatDateRange())
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

// MARK: - Helper Methods

private extension ConcertDetailView {
    func formatDateRange() -> String {
        guard let concert = store.state.concert else { return "" }

        let calendar = Calendar.current
        let startYear = calendar.component(.year, from: concert.startDate)
        let endYear = calendar.component(.year, from: concert.endDate)

        let fullFormatter = DateFormatter()
        fullFormatter.dateFormat = "yyyy.MM.dd"

        let startDateString = fullFormatter.string(from: concert.startDate)
        let endDateString = fullFormatter.string(from: concert.endDate)

        if startDateString == endDateString {
            return startDateString
        } else if startYear == endYear {
            let shortFormatter = DateFormatter()
            shortFormatter.dateFormat = "MM.dd"
            let endShortString = shortFormatter.string(from: concert.endDate)
            return "\(startDateString)~\(endShortString)"
        } else {
            return "\(startDateString)~\(endDateString)"
        }
    }
}

#Preview {
    ConcertDetailView(
        store: ConcertDetailStore(),
        concertID: 1,
        onDismiss: {}
    )
}
