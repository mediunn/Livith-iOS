//
//  HomeStore.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation
import WidgetKit

import DIContainer
import Domain

enum HomeIntent {
    case onAppear
    case onErrorToastDisappear
    case onToastDisappear

    case onDelete
    case onRefreshInterestConcert
    case _fetchUserInterestConcertResult(Result<Concert?, Error>)
    case _fetchScheduleListResult(Result<[ConcertSchedule], Error>)
    case _fetchMainSetlistResult(Result<Setlist, Error>)
    case _fetchSetlistSongListResult(Result<[SetlistSong], Error>)
    case _deleteInterestConcertResult(Result<Void, Error>)
    case _fetchUserResult(Result<User, Error>)

    case onRefreshSections
    case _fetchHomeSectionListResult(Result<[ConcertSection], Error>)
}

struct HomeState {
    var userName: String = ""
    var interestConcert: Concert? = nil
    var toastMessage: String = ""
    var errorMessage: String = ""

    var scheduleList: [ConcertSchedule] = []
    var setlist: Setlist? = nil
    var songList: [SetlistSong] = []

    var sectionList: [ConcertSection] = []
    var isSectionsLoading: Bool = false
}

final class HomeStore: ObservableObject {
    @Published private(set) var state: HomeState = .init()

    @Injected private var userRepository: UserRepository
    @Injected private var concertRepository: ConcertRepository
    @Injected private var setlistRepository: SetlistRepository
    
    private var cancellables = [CancelID: Task<Void, Never>]()
    
    init() {
        performFetchHomeSectionList()
    }
    
    @MainActor
    func send(_ intent: HomeIntent) {
        switch intent {
        case .onAppear:
            performFetchUser()
            performFetchUserInterestedConcert()
            
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
                
                if let concert {
                    performFetchScheduleList(concertID: concert.id)
                    performFetchMainSetlist(concertID: concert.id)
                } else {
                    state.scheduleList = []
                    state.setlist = nil
                    state.songList = []
                }
            case .failure(let error):
                state.interestConcert = nil
                state.errorMessage = getErrorMessage(from: error)
            }
            
        case ._fetchScheduleListResult(let result):
            switch result {
            case .success(let schedules):
                state.scheduleList = schedules
            case .failure(let error):
                state.scheduleList = []
                state.errorMessage = getErrorMessage(from: error)
            }
            
        case ._fetchMainSetlistResult(let result):
            switch result {
            case .success(let setlist):
                state.setlist = setlist
            case .failure(let error):
                state.setlist = nil
                state.songList = []
                state.errorMessage = getErrorMessage(from: error)
            }
            
        case ._fetchSetlistSongListResult(let result):
            switch result {
            case .success(let songs):
                state.songList = songs
            case .failure(let error):
                state.songList = []
                state.errorMessage = getErrorMessage(from: error)
            }
            
        case ._deleteInterestConcertResult(let result):
            switch result {
            case .success:
                state.interestConcert = nil
                state.scheduleList = []
                state.setlist = nil
                state.songList = []
                state.toastMessage = "관심 공연을 삭제했어요"
            case .failure(let error):
                state.errorMessage = error.localizedDescription
            }

        case ._fetchUserResult(let result):
            switch result {
            case .success(let user):
                state.userName = user.nickname
            case .failure(let error):
                state.errorMessage = getErrorMessage(from: error)
            }
        
        case .onRefreshSections:
            state.isSectionsLoading = true
            performFetchHomeSectionList()
            performFetchUserInterestedConcert()

        case ._fetchHomeSectionListResult(let result):
            state.isSectionsLoading = false
            switch result {
            case .success(let sectionList):
                state.sectionList = sectionList
            case .failure(let error):
                state.errorMessage = getErrorMessage(from: error)
            }
        }
    }
}

// MARK: - Helpers

private extension HomeStore {
    func performFetchUserInterestedConcert() {
        cancellables[.fetchInterestedConcert]?.cancel()
        cancellables[.fetchInterestedConcert] = Task {
            do {
                let result = try await userRepository.fetchInterestedConcert()
                await send(._fetchUserInterestConcertResult(.success(result)))
            } catch {
                await send(._fetchUserInterestConcertResult(.failure(error)))
            }
        }
    }

    func performFetchUser() {
        cancellables[.fetchUser]?.cancel()
        cancellables[.fetchUser] = Task {
            do {
                let result = try await userRepository.fetchUser()
                await send(._fetchUserResult(.success(result)))
            } catch {
                await send(._fetchUserResult(.failure(error)))
            }
        }
    }

    func performFetchScheduleList(concertID: Int) {
        cancellables[.fetchScheduleList]?.cancel()
        cancellables[.fetchScheduleList] = Task {
            do {
                let schedules = try await concertRepository.fetchConcertScheduleList(concertID: concertID)
                await send(._fetchScheduleListResult(.success(schedules)))
            } catch {
                await send(._fetchScheduleListResult(.failure(error)))
            }
        }
    }

    func performFetchMainSetlist(concertID: Int) {
        cancellables[.fetchMainSetlist]?.cancel()
        cancellables[.fetchMainSetlist] = Task {
            do {
                guard let setlist = try await concertRepository.fetchMainSetlist(concertID: concertID) else {
                    await send(._fetchMainSetlistResult(.failure(ConcertError.cancelled)))
                    return
                }
                let songList = try await setlistRepository.fetchSetlistSongs(setlistID: setlist.id)
                await send(._fetchMainSetlistResult(.success(setlist)))
                await send(._fetchSetlistSongListResult(.success(songList)))
            } catch ConcertError.invalidResponse {
                await send(._fetchMainSetlistResult(.failure(ConcertError.cancelled)))
            } catch {
                await send(._fetchMainSetlistResult(.failure(error)))
            }
        }
    }

    func performFetchSetlistSongList(setlistID: Int) {
        cancellables[.fetchSetlistSongList]?.cancel()
        cancellables[.fetchSetlistSongList] = Task {
            do {
                let songList = try await setlistRepository.fetchSetlistSongs(setlistID: setlistID)
                await send(._fetchSetlistSongListResult(.success(songList)))
            } catch {
                await send(._fetchSetlistSongListResult(.failure(error)))
            }
        }
    }

    func performDeleteInterestConcert() {
        Task {
            do {
                try await userRepository.deleteInterestedConcert()
                WidgetCenter.shared.reloadAllTimelines()
                await send(._deleteInterestConcertResult(.success(())))
            } catch {
                await send(._deleteInterestConcertResult(.failure(error)))
            }
        }
    }

    func getErrorMessage(from error: Error) -> String {
        if error is CancellationError {
            return ""
        }

        if case let error as ConcertError = error, error == .cancelled {
            return ""
        }

        return error.localizedDescription
    }

    func performFetchHomeSectionList() {
        cancellables[.refreshSections]?.cancel()
        cancellables[.refreshSections] = Task {
            do {
                let result = try await concertRepository.fetchHomeConcertSectionList()
                await send(._fetchHomeSectionListResult(.success(result)))
            } catch {
                await send(._fetchHomeSectionListResult(.failure(error)))
            }
        }
    }
}

// MARK: - CancelID

private extension HomeStore {
    enum CancelID {
        case fetchInterestedConcert
        case fetchScheduleList
        case fetchMainSetlist
        case fetchSetlistSongList
        case refreshSections
        case fetchUser
    }
}
