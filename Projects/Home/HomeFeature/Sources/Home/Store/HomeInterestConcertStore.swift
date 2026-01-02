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
    case onDelete
    case _fetchScheduleListResult(Result<ConcertScheduleList, Error>)
    case _fetchMainSetlistResult(Result<Setlist, Error>)
    case _fetchSetlistSongListResult(Result<SetlistSongList, Error>)
    case _deleteInterestConcertResult(Result<Void, Error>)
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

    private var onDeleteConcert: (() -> Void)?
    
    init(interestConcert: Concert, onDeleteConcert: (() -> Void)? = nil) {
        print(">>> [\(#line): \(#function)] - \(interestConcert)")
        self.state = HomeInterestConcertState(interestConcert: interestConcert)
        self.onDeleteConcert = onDeleteConcert
    }
    
    @MainActor
    func send(_ intent: HomeInterestConcertIntent) {
        switch intent {
        case .onAppear:
            performFetchScheduleList(concertID: state.interestConcert.id)
            performFetchMainSetlist(concertID: state.interestConcert.id)
        
        case .onDelete:
            performDeleteInterestConcert()

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

        case ._deleteInterestConcertResult(let result):
            switch result {
            case .success:
                onDeleteConcert?()
            case .failure(let error):
                state.errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Helpers

private extension HomeInterestConcertStore {
    func performFetchScheduleList(concertID: Int) {
        Task {
            do {
                let schedules = try await repository.fetchScheduleList(for: concertID)
                print(">>> [HomeInterestConcertStore] fetched schedules for concertID \(concertID): \(schedules.count)")
                await send(._fetchScheduleListResult(.success(schedules)))
            } catch {
                print(">>> [HomeInterestConcertStore] failed to fetch schedules for concertID \(concertID): \(error)")
                await send(._fetchScheduleListResult(.failure(error)))
            }
        }
    }

    func performFetchMainSetlist(concertID: Int) {
        Task {
            do {
                let setlist = try await repository.fetchMainSetlist(for: concertID)
                let songList = try await repository.fetchSongList(for: setlist.id)
                await send(._fetchMainSetlistResult(.success(setlist)))
                await send(._fetchSetlistSongListResult(.success(songList)))
            } catch {
                await send(._fetchMainSetlistResult(.failure(error)))
            }
        }
    }

    func performFetchSetlistSongList(setlistID: Int) {
        Task {
            do {
                let songList = try await repository.fetchSongList(for: setlistID)
                await send(._fetchSetlistSongListResult(.success(songList)))
            } catch {
                await send(._fetchSetlistSongListResult(.failure(error)))
            }
        }
    }
    
    func performDeleteInterestConcert() {
        Task {
            do {
                try await repository.deleteInterestedConcert()
                await send(._deleteInterestConcertResult(.success(())))
            } catch {
                await send(._deleteInterestConcertResult(.failure(error)))
            }
        }
    }
}
