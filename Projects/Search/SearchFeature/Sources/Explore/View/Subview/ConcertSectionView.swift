//
//  ConcertSectionView.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/19/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import SearchDomain

struct ConcertSectionView: View {
    let concertSection: ConcertSection
    let onConcertTap: ((Concert) -> Void)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(concertSection.title)
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(concertSection.concertList) { concert in
                        LivithCard(
                            imageURL: concert.posterURL,
                            title: concert.title,
                            subtitle: concert.startDate,
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
