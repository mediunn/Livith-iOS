//
//  SetlistHeaderView.swift
//  SetlistFeature
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import SetlistDomain

struct SetlistHeaderView: View {

    // MARK: - Property

    let setlist: Setlist

    private var formattedDateRange: String {
        DateFormatter.formatDateRange(from: setlist.startDate, to: setlist.endDate)
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            posterImage

            BackgroundGradient(
                baseColor: .livithColor(.black100),
                transparentOpacity: 0,
                startPoint: .bottom,
                endPoint: .top
            )

            concertInfoOverlay
        }
    }
}

// MARK: - Subviews

private extension SetlistHeaderView {
    var posterImage: some View {
        AsyncImageView(url: URL(string: setlist.imageURL ?? "")) {
            Rectangle()
                .fill(Color.livithColor(.black80))
        }
        .aspectRatio(1, contentMode: .fit)
    }

    var concertInfoOverlay: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let badgeText = setlist.type.badgeText {
                badgeView(text: badgeText)
                    .padding(.bottom, 16)
            }

            Text(setlist.title)
                .notosans(.headSemibold)
                .foregroundStyle(Color.livithColor(.white100))
                .lineLimit(2)
                .padding(.bottom, 10)

            Text(formattedDateRange)
                .notosans(.body2Medium)
                .foregroundStyle(Color.livithColor(.black30))
                .padding(.bottom, 4)

            Text(setlist.artist)
                .notosans(.body2Medium)
                .foregroundStyle(Color.livithColor(.black30))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }

    func badgeView(text: String) -> some View {
        Text(text)
            .notosans(.body2Semibold)
            .foregroundStyle(Color.livithColor(.black100))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.livithColor(.white100))
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    SetlistHeaderView(
        setlist: Setlist(
            id: 1,
            title: "Gen Hoshino presents MAD HOPE Asia Tour in SEOUL",
            imageURL: nil,
            type: .expected,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 2),
            venue: "Tokyo Dome",
            artist: "Hoshino Gen"
        )
    )
    .background(Color.livithColor(.black100))
}
