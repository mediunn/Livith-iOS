//
//  SongLyricsStore.swift
//  SongFeature
//
//  Created by Youjin Lee on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import LivithConcurrency
import SongDomain

// MARK: - State

public struct SongLyricsState {
    public var songID: Int = 0
    public var setlistID: Int?
    public var songTitle: String = ""

    public var lyrics: SongLyrics?
    public var fanchant: SongFanchant?

    public var isLoading: Bool = false
    public var fetchError: String?

    // Toggle States
    public var showOriginal: Bool = true
    public var showPronunciation: Bool = true
    public var showTranslation: Bool = true
    public var showFanchant: Bool = true

    public var hasLyrics: Bool {
        guard let lyrics else { return false }
        return !lyrics.lyrics.isEmpty
    }

    public var hasFanchant: Bool {
        fanchant != nil && !(fanchant?.fanchant.isEmpty ?? true)
    }

    public var hasFanchantPoint: Bool {
        fanchant?.fanchantPoint != nil && !(fanchant?.fanchantPoint?.isEmpty ?? true)
    }

    public var hasYouTubeVideo: Bool {
        lyrics?.youtubeID != nil && !(lyrics?.youtubeID?.isEmpty ?? true)
    }

    public init() {}
}

// MARK: - Intent

public enum SongLyricsIntent {
    case onAppear(songID: Int, setlistID: Int?, songTitle: String)
    case onFetchErrorDismiss

    case toggleOriginal
    case togglePronunciation
    case toggleTranslation
    case toggleFanchant

    case _setLoading(Bool)
    case _setLyrics(SongLyrics?)
    case _setFanchant(SongFanchant?)
    case _setFetchError(String?)
}

// MARK: - Store

public final class SongLyricsStore: ObservableObject {

    // MARK: - Property

    private var fetchTask: Task<Void, Never>?
    @Published private(set) var state = SongLyricsState()

    @Injected private var repository: SongRepository

    // MARK: - Initializer

    public init() {}

    // MARK: - Intent Handler

    @MainActor
    public func send(_ intent: SongLyricsIntent) {
        switch intent {
        case .onAppear(let songID, let setlistID, let songTitle):
            state.songID = songID
            state.setlistID = setlistID
            state.songTitle = songTitle
            fetchSongData(songID: songID, setlistID: setlistID)

        case .onFetchErrorDismiss:
            state.fetchError = nil

        case .toggleOriginal:
            state.showOriginal.toggle()
        case .togglePronunciation:
            state.showPronunciation.toggle()
        case .toggleTranslation:
            state.showTranslation.toggle()
        case .toggleFanchant:
            state.showFanchant.toggle()

        case ._setLoading(let isLoading):
            state.isLoading = isLoading
        case ._setLyrics(let lyrics):
            state.lyrics = lyrics
        case ._setFanchant(let fanchant):
            state.fanchant = fanchant
        case ._setFetchError(let error):
            state.fetchError = error
        }
    }
}

// MARK: - Private Methods

private extension SongLyricsStore {
    func fetchSongData(songID: Int, setlistID: Int?) {
        fetchTask?.cancel()

        fetchTask = Task { @MainActor in
            send(._setLoading(true))

            do {
                let lyrics = try await repository.fetchSongLyrics(songID: songID)

                guard await Task.wait() else { return }
                send(._setLyrics(lyrics))
            } catch {
                guard !Task.isCancelled else { return }
                send(._setLyrics(nil))
            }

            if let setlistID {
                do {
                    let fanchant = try await repository.fetchSongFanchant(setlistID: setlistID, songID: songID)

                    guard await Task.wait() else { return }
                    send(._setFanchant(fanchant))
                } catch {
                    guard !Task.isCancelled else { return }
                    send(._setFanchant(nil))
                }
            }

            send(._setLoading(false))
        }
    }
}
