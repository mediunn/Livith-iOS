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
    public var lyrics: SongLyrics?
    public var songTitle: String = ""
    public var fanchant: SongFanchant?

    public var isLoading: Bool = false
    public var fetchError: String?

    public var showOriginal: Bool = true
    public var showFanchant: Bool = true
    public var showTranslation: Bool = true
    public var showPronunciation: Bool = true
    
    public var toggleWarningMessage: String?

    public var hasLyrics: Bool {
        guard let lyrics else { return false }
        return !lyrics.lyrics.isEmpty
    }

    public var hasFanchant: Bool {
        fanchant != nil && !(fanchant?.fanchant.isEmpty ?? true)
    }
    
    public var hasYouTubeVideo: Bool {
        lyrics?.youtubeID != nil && !(lyrics?.youtubeID?.isEmpty ?? true)
    }
    
    public var hasFanchantPoint: Bool {
        fanchant?.fanchantPoint != nil && !(fanchant?.fanchantPoint?.isEmpty ?? true)
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
            handleToggleOriginal()
        case .togglePronunciation:
            handleTogglePronunciation()
        case .toggleTranslation:
            handleToggleTranslation()
        case .toggleFanchant:
            handleToggleFanchant()
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

// MARK: - Toggle Validation

private extension SongLyricsStore {
    var activeToggleCount: Int {
        [state.showOriginal, state.showPronunciation, state.showTranslation, state.showFanchant]
            .filter { $0 }
            .count
    }

    var mainToggleCount: Int {
        [state.showOriginal, state.showPronunciation, state.showTranslation]
            .filter { $0 }
            .count
    }

    func handleToggleOriginal() {
        // 원어를 끄려고 할 때
        if state.showOriginal {
            // 응원법이 켜져 있으면 불가능
            if state.showFanchant {
                showWarning("응원법은 원어에서만\n표시가 돼요")
                return
            }
            // 마지막 하나 남은 토글이면 불가능 (응원법 제외)
            if mainToggleCount <= 1 {
                showWarning("원어, 발음, 해석 중\n하나는 켜져야 해요")
                return
            }
        }
        state.showOriginal.toggle()
    }

    func handleTogglePronunciation() {
        // 끄려고 할 때 마지막 하나면 불가능 (응원법 제외)
        if state.showPronunciation && mainToggleCount <= 1 {
            showWarning("원어, 발음, 해석 중\n하나는 켜져야 해요")
            return
        }
        state.showPronunciation.toggle()
    }

    func handleToggleTranslation() {
        // 끄려고 할 때 마지막 하나면 불가능 (응원법 제외)
        if state.showTranslation && mainToggleCount <= 1 {
            showWarning("원어, 발음, 해석 중\n하나는 켜져야 해요")
            return
        }
        state.showTranslation.toggle()
    }

    func handleToggleFanchant() {
        // 응원법을 켜려고 할 때
        if !state.showFanchant {
            // 해석만 켜져 있는 경우
            if state.showTranslation && !state.showOriginal && !state.showPronunciation {
                showWarning("해석에는 응원법이\n표시되지 않아요")
                return
            }
            // 원어가 꺼져 있으면 불가능
            if !state.showOriginal {
                showWarning("응원법은 원어에서만\n표시가 돼요")
                return
            }
        }
        state.showFanchant.toggle()
    }

    func showWarning(_ message: String) {
        state.toggleWarningMessage = message
    }
}

// MARK: - Fetch Methods

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
