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
        }
        .frame(height: 337)
        .scaledToFill()
        .clipped()
        
    }

    var concertInfoOverlay: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let badgeText = setlist.type.badgeText {
                TagChipView(text: badgeText)
            }

            Text(setlist.title)
                .notosans(.headSemibold)
                .foregroundStyle(Color.livithColor(.white100))
                .padding(.bottom, 6)

            Text(formattedDateRange)
                .notosans(.body4Regular)
                .foregroundStyle(Color.livithColor(.black30))
                .padding(.bottom, 2)

            Text(setlist.artist)
                .notosans(.caption1Regular)
                .foregroundStyle(Color.livithColor(.black30))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 36)
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
