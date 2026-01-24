//
//  ConcertSectionView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/26/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem
import Domain

struct ConcertSectionView: View {
    let concertSection: ConcertSection
    let onConcertTap: ((Concert) -> Void)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(concertSection.title)
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(concertSection.concertList) { concert in
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
    }
}
