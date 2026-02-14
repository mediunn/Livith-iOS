//
//  SetlistSongListCard.swift
//  SetlistFeature
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Amplitude
import Domain
import LivithDesignSystem

struct SetlistSongListCard: View {

    // MARK: - Property

    let songs: [SetlistSong]
    let onPlaySong: ((SetlistSong) -> Void)?

    // MARK: - Body

    var body: some View {
        VStack(spacing: 10) {
            ForEach(songs) { song in
                LivithSongItem(
                    orderIndex: song.orderIndex,
                    title: song.title,
                    artist: song.artist
                ) {
                    AmplitudeService.shared.trackEvent(tag: .click(.setlistSongDetail))
                    onPlaySong?(song)
                }
            }
        }
        .padding(.vertical, 16)
        .background(Color.livithColor(.black90))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
    }
}

#Preview {
    VStack(spacing: 8) {
        SetlistSongListCard(
            songs: [
                SetlistSong(id: 1, title: "恋 (Koi)", artist: "Hosino Gen", orderIndex: 1),
                SetlistSong(id: 2, title: "SUN", artist: "Hosino Gen", orderIndex: 2),
                SetlistSong(id: 3, title: "喜劇 (Comedy)", artist: "Hosino Gen", orderIndex: 3),
                SetlistSong(id: 4, title: "Ain't Nobody Know", artist: "Hosino Gen", orderIndex: 4),
                SetlistSong(id: 5, title: "Pop Virus", artist: "Hosino Gen", orderIndex: 5),
                SetlistSong(id: 6, title: "Eureka", artist: "Hosino Gen", orderIndex: 0)
            ],
            onPlaySong: nil
        )
    }
    .background(Color.livithColor(.black100))
}
