//
//  SetlistStore.swift
//  SetlistFeature
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import LivithFoundation
import SetlistDomain

public struct SetlistState {
    public var concertID: Int = 0
    public var setlistID: Int = 0
    public var setlist: Setlist?
    public var songs: [SetlistSong] = []
    public var isLoading: Bool = false
    public var fetchError: String?

    public init() {}
}

public enum SetlistIntent {
    case onAppear(concertID: Int, setlistID: Int)
    case onFetchErrorDismiss

    case _setLoading(Bool)
    case _setSetlist(Setlist)
    case _setSongs([SetlistSong])
    case _setFetchError(String?)
}

public final class SetlistStore: ObservableObject {

    // MARK: - Property

    private var fetchTask: Task<Void, Never>?
    @Published private(set) var state = SetlistState()

    @Injected private var repository: SetlistRepository

    // MARK: - Initializer

    public init() {}

    // MARK: - Intent Handler

    @MainActor
    public func send(_ intent: SetlistIntent) {
        switch intent {
        case .onAppear(let concertID, let setlistID):
            state.concertID = concertID
            state.setlistID = setlistID
            fetchSetlistData(concertID: concertID, setlistID: setlistID)
        case .onFetchErrorDismiss:
            state.fetchError = nil
        case ._setLoading(let isLoading):
            state.isLoading = isLoading
        case ._setSetlist(let setlist):
            state.setlist = setlist
        case ._setSongs(let songs):
            state.songs = songs
        case ._setFetchError(let error):
            state.fetchError = error
        }
    }
}

// MARK: - Private Methods

private extension SetlistStore {
    func fetchSetlistData(concertID: Int, setlistID: Int) {
        fetchTask?.cancel()

        let repo = repository

        fetchTask = Task { @MainActor in
            send(._setLoading(true))

            do {
                async let setlistResult = repo.fetchSetlist(concertID: concertID, setlistID: setlistID)
                async let songsResult = repo.fetchSetlistSongs(setlistID: setlistID)

                let (setlist, songs) = try await (setlistResult, songsResult)

                guard await Task.wait() else { return }

                send(._setSetlist(setlist))
                send(._setSongs(songs))
            } catch {
                guard !Task.isCancelled else { return }
                send(._setFetchError("데이터를 불러오는데 실패했어요"))
            }

            send(._setLoading(false))
        }
    }
}
