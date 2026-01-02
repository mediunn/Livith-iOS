//
//  HomeStore.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import HomeDomain

enum HomeIntent {
    case onAppear
    case onErrorToastDisappear
    case onToastDisappear
    
    case onAppearInterestConcert
    case onDelete
    case onRefreshInterestConcert
    case _fetchUserInterestConcertResult(Result<Concert?, Error>)
    case _fetchScheduleListResult(Result<ConcertScheduleList, Error>)
    case _fetchMainSetlistResult(Result<Setlist, Error>)
    case _fetchSetlistSongListResult(Result<SetlistSongList, Error>)
    case _deleteInterestConcertResult(Result<Void, Error>)
}

struct HomeState {
    var interestConcert: Concert? = nil
    var toastMessage: String = ""
    var errorMessage: String = ""
    
    var scheduleList: ConcertScheduleList = []
    var setlist: Setlist? = nil
    var songList: SetlistSongList = []
} 

final class HomeStore: ObservableObject {
    @Published private(set) var state: HomeState = .init()
    
    @Injected private var repository: HomeRepository
    
    @MainActor
    func send(_ intent: HomeIntent) {
        switch intent {
        case .onAppear:
            performFetchUserInterestedConcert()
            
        case .onAppearInterestConcert:
            if let concert = state.interestConcert {
                performFetchScheduleList(concertID: concert.id)
                performFetchMainSetlist(concertID: concert.id)
            }
            
        case .onErrorToastDisappear:
            state.errorMessage = ""
            
        case .onToastDisappear:
            state.toastMessage = ""
            
        case .onDelete:
            performDeleteInterestConcert()
            
        case .onRefreshInterestConcert:
            if let concert = state.interestConcert {
                performFetchScheduleList(concertID: concert.id)
                performFetchMainSetlist(concertID: concert.id)
            } else {
                performFetchUserInterestedConcert()
            }
            
        case ._fetchUserInterestConcertResult(let result):
            switch result {
            case .success(let concert):
                state.interestConcert = concert
                
                if let concert = concert {
                    performFetchScheduleList(concertID: concert.id)
                    performFetchMainSetlist(concertID: concert.id)
                } else {
                    state.scheduleList = []
                    state.setlist = nil
                    state.songList = []
                }
            case .failure(let error):
                state.errorMessage = error.localizedDescription
            }
            
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
                state.interestConcert = nil
                state.scheduleList = []
                state.setlist = nil
                state.songList = []
                state.toastMessage = "관심 콘서트가 삭제되었어요"
            case .failure(let error):
                state.errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Helpers

private extension HomeStore {
    func performFetchUserInterestedConcert() {
        Task {
            do {
                let result = try await repository.fetchInterestedConcert()
                await send(._fetchUserInterestConcertResult(.success(result)))
            } catch {
                await send(._fetchUserInterestConcertResult(.failure(error)))
            }
        }
    }
    
    func performFetchScheduleList(concertID: Int) {
        Task {
            do {
                let schedules = try await repository.fetchScheduleList(for: concertID)
                await send(._fetchScheduleListResult(.success(schedules)))
            } catch {
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
            } catch HomeError.noResponse {
                return
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
