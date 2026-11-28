//
//  SetlistDetailContainerView.swift
//  ConcertFeature
//
//  Created by on 6/16/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Domain
import SetlistFeature
import SongFeature

struct SetlistDetailContainerView: View {

    let concertID: Int
    let setlistID: Int

    @State private var pendingSong: SetlistSong?

    var body: some View {
        SetlistDetailView(
            concertID: concertID,
            setlistID: setlistID,
            onPlaySong: { song in pendingSong = song }
        )
        .navigationDestination(item: $pendingSong) { song in
            SongLyricsView(
                songID: song.id,
                setlistID: setlistID,
                songTitle: song.title
            )
        }
    }
}
