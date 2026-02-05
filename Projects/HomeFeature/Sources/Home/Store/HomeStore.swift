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
    case _fetchUserResult(Result<User, Error>)
    case interestConcert(InterestConcertIntent)
    case concertSection(ConcertSectionIntent)
    
    enum InterestConcertIntent {
        case onDelete
        case onRefresh
        case _fetchUserInterestConcertResult(Result<Concert?, Error>)
        case _fetchScheduleListResult(Result<[ConcertSchedule], Error>)
        case _fetchMainSetlistResult(Result<Setlist, Error>)
        case _fetchSetlistSongListResult(Result<[SetlistSong], Error>)
        case _deleteInterestConcertResult(Result<Void, Error>)
    }
    
    enum ConcertSectionIntent {
        case onRefreshSections
        case checkShowBanner
        case _fetchHomeSectionListResult(Result<[ConcertSection], Error>)
        case _fetchUserPreferredGenreListResult(Result<[PreferredGenre], Error>)
    }
}

struct HomeState {
    var userName: String = ""
    var toastMessage: String = ""
    var errorMessage: String = ""
    var interestConcert: InterestConcertState = .init()
    var sections: ConcertSectionState = .init()
    var hasNewNotice: Bool = false
    
    struct InterestConcertState {
        var concert: Concert? = nil
        var scheduleList: [ConcertSchedule] = []
        var setlist: Setlist? = nil
        var songList: [SetlistSong] = []
    }
    
    struct ConcertSectionState {
        var sectionList: [ConcertSection] = []
        var isLoading: Bool = false
        var shouldShowPreferenceBanner: Bool = false
    }
}

@MainActor
final class HomeStore: ObservableObject {
    
    // MARK: - CancelID
    
    private enum CancelID {
        case fetchInterestedConcert
        case fetchScheduleList
        case fetchMainSetlist
        case fetchSetlistSongList
        case refreshSections
        case fetchUser
        case fetchUserPreferredGenreList
    }
    
    @Published private(set) var state: HomeState = .init()
    
    @Injected private var userRepository: UserRepository
    @Injected private var concertRepository: ConcertRepository
    @Injected private var setlistRepository: SetlistRepository
    @Injected private var preferenceRepository: PreferenceRepository
    
    private var cancellables = [CancelID: Task<Void, Never>]()
    
    init() {
        performFetchHomeSectionList()
    }
    
    func send(_ intent: HomeIntent) {
        switch intent {
        case .onAppear:
            performFetchUser()
            performFetchUserInterestedConcert()
            send(.concertSection(.checkShowBanner))
            
        case .onErrorToastDisappear:
            state.errorMessage = ""
            
        case .onToastDisappear:
            state.toastMessage = ""
            
        case ._fetchUserResult(let result):
            switch result {
            case .success(let user):
                state.userName = user.nickname
            case .failure(let error):
                state.errorMessage = getErrorMessage(from: error)
            }
            
        case .interestConcert(let intent):
            handleInterestConcertIntent(intent)
            
        case .concertSection(let intent):
            handleConcertSectionIntent(intent)
        }
    }
}

// MARK: - Interest Concert Intent Handlers

private extension HomeStore {
    func handleInterestConcertIntent(_ intent: HomeIntent.InterestConcertIntent) {
        switch intent {
        case .onDelete:
            executeDeleteInterestConcert()
        case .onRefresh:
            executeRefreshInterestConcert()
        case ._fetchUserInterestConcertResult(let result):
            handleFetchUserInterestConcertResult(result)
        case ._fetchScheduleListResult(let result):
            handleFetchScheduleListResult(result)
        case ._fetchMainSetlistResult(let result):
            handleFetchMainSetlistResult(result)
        case ._fetchSetlistSongListResult(let result):
            handleFetchSetlistSongListResult(result)
        case ._deleteInterestConcertResult(let result):
            handleDeleteInterestConcertResult(result)
        }
    }
    
    func executeDeleteInterestConcert() {
        performDeleteInterestConcert()
    }
    
    func executeRefreshInterestConcert() {
        if let concert = state.interestConcert.concert {
            performFetchScheduleList(concertID: concert.id)
            performFetchMainSetlist(concertID: concert.id)
        } else {
            performFetchUserInterestedConcert()
        }
    }
    
    func handleFetchUserInterestConcertResult(_ result: Result<Concert?, Error>) {
        switch result {
        case .success(let concert):
            state.interestConcert.concert = concert
            
            if let concert {
                performFetchScheduleList(concertID: concert.id)
                performFetchMainSetlist(concertID: concert.id)
            } else {
                state.interestConcert.scheduleList = []
                state.interestConcert.setlist = nil
                state.interestConcert.songList = []
            }
        case .failure(let error):
            state.interestConcert.concert = nil
            state.errorMessage = getErrorMessage(from: error)
        }
    }
    
    func handleFetchScheduleListResult(_ result: Result<[ConcertSchedule], Error>) {
        switch result {
        case .success(let schedules):
            state.interestConcert.scheduleList = schedules
        case .failure(let error):
            state.interestConcert.scheduleList = []
            state.errorMessage = getErrorMessage(from: error)
        }
    }
    
    func handleFetchMainSetlistResult(_ result: Result<Setlist, Error>) {
        switch result {
        case .success(let setlist):
            state.interestConcert.setlist = setlist
        case .failure(let error):
            state.interestConcert.setlist = nil
            state.interestConcert.songList = []
            state.errorMessage = getErrorMessage(from: error)
        }
    }
    
    func handleFetchSetlistSongListResult(_ result: Result<[SetlistSong], Error>) {
        switch result {
        case .success(let songs):
            state.interestConcert.songList = songs
        case .failure(let error):
            state.interestConcert.songList = []
            state.errorMessage = getErrorMessage(from: error)
        }
    }
    
    func handleDeleteInterestConcertResult(_ result: Result<Void, Error>) {
        switch result {
        case .success:
            state.interestConcert.concert = nil
            state.interestConcert.scheduleList = []
            state.interestConcert.setlist = nil
            state.interestConcert.songList = []
            state.toastMessage = "관심 공연을 삭제했어요"
        case .failure(let error):
            state.errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Concert Section Intent Handlers

private extension HomeStore {
    func handleConcertSectionIntent(_ intent: HomeIntent.ConcertSectionIntent) {
        switch intent {
        case .onRefreshSections:
            executeRefreshSections()
        case .checkShowBanner:
            performFetchUserPreferredGenreList()
        case ._fetchHomeSectionListResult(let result):
            handleFetchHomeSectionListResult(result)
        case ._fetchUserPreferredGenreListResult(let result):
            handleFetchUserPreferredGenreListResult(result)
        }
    }
    
    func executeRefreshSections() {
        state.sections.isLoading = true
        performFetchHomeSectionList()
        performFetchUserInterestedConcert()
    }
    
    func handleFetchHomeSectionListResult(_ result: Result<[ConcertSection], Error>) {
        state.sections.isLoading = false
        switch result {
        case .success(let sectionList):
            state.sections.sectionList = sectionList
        case .failure(let error):
            state.errorMessage = getErrorMessage(from: error)
        }
    }
    
    func handleFetchUserPreferredGenreListResult(_ result: Result<[PreferredGenre], Error>) {
        switch result {
        case .success(let genreList):
            state.sections.shouldShowPreferenceBanner = genreList.isEmpty
        case .failure:
            state.sections.shouldShowPreferenceBanner = false
        }
    }
}

// MARK: - Network Operations

private extension HomeStore {
    func performFetchUserInterestedConcert() {
        cancellables[.fetchInterestedConcert]?.cancel()
        cancellables[.fetchInterestedConcert] = Task {
            do {
                let result = try await userRepository.fetchInterestedConcert()
                send(.interestConcert(._fetchUserInterestConcertResult(.success(result))))
            } catch {
                send(.interestConcert(._fetchUserInterestConcertResult(.failure(error))))
            }
        }
    }
    
    func performFetchUser() {
        cancellables[.fetchUser]?.cancel()
        cancellables[.fetchUser] = Task {
            do {
                let result = try await userRepository.fetchUser()
                send(._fetchUserResult(.success(result)))
            } catch {
                send(._fetchUserResult(.failure(error)))
            }
        }
    }
    
    func performFetchScheduleList(concertID: Int) {
        cancellables[.fetchScheduleList]?.cancel()
        cancellables[.fetchScheduleList] = Task {
            do {
                let schedules = try await concertRepository.fetchConcertScheduleList(concertID: concertID)
                send(.interestConcert(._fetchScheduleListResult(.success(schedules))))
            } catch {
                send(.interestConcert(._fetchScheduleListResult(.failure(error))))
            }
        }
    }
    
    func performFetchMainSetlist(concertID: Int) {
        cancellables[.fetchMainSetlist]?.cancel()
        cancellables[.fetchMainSetlist] = Task {
            do {
                guard let setlist = try await concertRepository.fetchMainSetlist(concertID: concertID) else {
                    send(.interestConcert(._fetchMainSetlistResult(.failure(ConcertError.cancelled))))
                    return
                }
                let songList = try await setlistRepository.fetchSetlistSongs(setlistID: setlist.id)
                send(.interestConcert(._fetchMainSetlistResult(.success(setlist))))
                send(.interestConcert(._fetchSetlistSongListResult(.success(songList))))
            } catch ConcertError.invalidResponse {
                send(.interestConcert(._fetchMainSetlistResult(.failure(ConcertError.cancelled))))
            } catch {
                send(.interestConcert(._fetchMainSetlistResult(.failure(error))))
            }
        }
    }
    
    func performFetchSetlistSongList(setlistID: Int) {
        cancellables[.fetchSetlistSongList]?.cancel()
        cancellables[.fetchSetlistSongList] = Task {
            do {
                let songList = try await setlistRepository.fetchSetlistSongs(setlistID: setlistID)
                send(.interestConcert(._fetchSetlistSongListResult(.success(songList))))
            } catch {
                send(.interestConcert(._fetchSetlistSongListResult(.failure(error))))
            }
        }
    }
    
    func performDeleteInterestConcert() {
        Task {
            do {
                try await userRepository.deleteInterestedConcert()
                WidgetCenter.shared.reloadAllTimelines()
                send(.interestConcert(._deleteInterestConcertResult(.success(()))))
            } catch {
                send(.interestConcert(._deleteInterestConcertResult(.failure(error))))
            }
        }
    }
    
    func performFetchHomeSectionList() {
        cancellables[.refreshSections]?.cancel()
        cancellables[.refreshSections] = Task {
            do {
                let result = try await concertRepository.fetchHomeConcertSectionList()
                send(.concertSection(._fetchHomeSectionListResult(.success(result))))
            } catch {
                send(.concertSection(._fetchHomeSectionListResult(.failure(error))))
            }
        }
    }
    
    func performFetchUserPreferredGenreList() {
        cancellables[.fetchUserPreferredGenreList]?.cancel()
        cancellables[.fetchUserPreferredGenreList] = Task {
            do {
                let genreList = try await preferenceRepository.fetchUserPreferredGenreList()
                send(.concertSection(._fetchUserPreferredGenreListResult(.success(genreList))))
            } catch {
                send(.concertSection(._fetchUserPreferredGenreListResult(.failure(error))))
            }
        }
    }
}

// MARK: - Utilities

private extension HomeStore {
    func getErrorMessage(from error: Error) -> String {
        if error is CancellationError {
            return ""
        }
        
        if case let error as ConcertError = error, error == .cancelled {
            return ""
        }
        
        return error.localizedDescription
    }
}
