//
//  SetlistSongCardView.swift
//  SetlistFeature
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import SetlistDomain

struct SetlistSongRowView: View {

    // MARK: - Property

    let song: SetlistSong
    let onPlayTapped: () -> Void

    private var isEncore: Bool {
        song.orderIndex == 0
    }

    private var displayTitle: String {
        if isEncore {
            return "Ancore. \(song.title)"
        } else {
            return String(format: "%02d. %@", song.orderIndex, song.title)
        }
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(displayTitle)
                    .notosans(.body1Semibold)
                    .foregroundStyle(Color.livithColor(.white100))
                    .lineLimit(1)

                Text(song.artist)
                    .notosans(.caption1Regular)
                    .foregroundStyle(Color.livithColor(.black50))
                    .lineLimit(1)
            }

            Spacer()

            playButton
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Subviews

private extension SetlistSongRowView {
    var playButton: some View {
        Button(action: onPlayTapped) {
            Circle()
                .fill(Color.livithColor(.black100))
                .frame(width: 40, height: 40)
                .overlay {
                    Image.livithIcon(.playFillDefault)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color.livithColor(.yellow60))
                }
        }
    }
}

// MARK: - Song List Card

struct SetlistSongListCard: View {

    // MARK: - Property

    let songs: [SetlistSong]
    let onPlaySong: ((SetlistSong) -> Void)?

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            ForEach(songs) { song in
                SetlistSongRowView(song: song) {
                    onPlaySong?(song)
                }
            }
        }
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
