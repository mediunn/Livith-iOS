//
//  HomeInterestConcertStore.swift
//  HomeFeature
//
//  Created by 김진웅 on 1/2/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import HomeDomain
import DIContainer

enum HomeInterestConcertIntent {
    case onAppear
    case _fetchScheduleListResult(Result<ConcertScheduleList, Error>)
    case _fetchMainSetlistResult(Result<Setlist, Error>)
    case _fetchSetlistSongListResult(Result<SetlistSongList, Error>)
}

struct HomeInterestConcertState {
    let interestConcert: Concert
    var scheduleList: ConcertScheduleList = []
    var setlist: Setlist?
    var songList: SetlistSongList = []
    var errorMessage: String = ""
}

final class HomeInterestConcertStore: ObservableObject {
    @Published private(set) var state: HomeInterestConcertState
    
    @Injected private var repository: HomeRepository
    
    init(interestConcert: Concert) {
        self.state = HomeInterestConcertState(interestConcert: interestConcert)
    }
    
    @MainActor
    func send(_ intent: HomeInterestConcertIntent) {
        switch intent {
        case .onAppear:
            performFetchContents()

        case ._fetchScheduleListResult(let result):
            switch result {
            case .success(let schedules):
                state.scheduleList = schedules
            case .failure(let error):
                state.errorMessage = error.localizedDescription
            }

        case ._fetchMainSetlistResult(let result):
            switch result {
            case .success(let setlist):
                state.setlist = setlist
            case .failure(let error):
                state.errorMessage = error.localizedDescription
            }

        case ._fetchSetlistSongListResult(let result):
            switch result {
            case .success(let songs):
                state.songList = songs
            case .failure(let error):
                state.errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Helpers

private extension HomeInterestConcertStore {
    func performFetchContents() {
        let concertID = state.interestConcert.id
        Task {
            async let scheduleListTask: () = performFetchScheduleList(concertID: concertID)
            async let mainSetlistTask: () = performFetchMainSetlist(concertID: concertID)
            
            await scheduleListTask
            await mainSetlistTask

            let setlistID: Int? = await MainActor.run { state.setlist?.id }
            if let id = setlistID {
                await performFetchSetlistSongList(setlistID: id)
            }
        }
    }

    func performFetchScheduleList(concertID: Int) async {
        do {
            let schedules = try await repository.fetchScheduleList(for: concertID)
            await send(._fetchScheduleListResult(.success(schedules)))
        } catch {
            await send(._fetchScheduleListResult(.failure(error)))
        }
    }

    func performFetchMainSetlist(concertID: Int) async {
        do {
            let setlist = try await repository.fetchMainSetlist(for: concertID)
            await send(._fetchMainSetlistResult(.success(setlist)))
        } catch {
            await send(._fetchMainSetlistResult(.failure(error)))
        }
    }

    func performFetchSetlistSongList(setlistID: Int) async {
        do {
            let songList = try await repository.fetchSongList(for: setlistID)
            await send(._fetchSetlistSongListResult(.success(songList)))
        } catch {
            await send(._fetchSetlistSongListResult(.failure(error)))
        }
    }
}
