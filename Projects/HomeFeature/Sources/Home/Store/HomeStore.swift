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
    case checkUnreadNotification
    case _fetchUserResult(Result<User, Error>)
    case _fetchUnreadNotificationCountResult(Result<Int, Error>)
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
        case onRefresh
        case _concertSectionDataResult(Result<HomeState.ConcertSectionState.Data, Error>)
    }
}

struct HomeState {
    enum Content {
        case concertSection
        case interestConcert
    }

    var currentContent: Content = .concertSection
    var user: User? = nil
    var toastMessage: String = ""
    var errorMessage: String = ""
    var hasNewNotice: Bool = false
    var interestConcert: InterestConcertState = .init()
    var concertSection: ConcertSectionState = .init()
    
    struct InterestConcertState {
        var isInitialLoad: Bool = true
        var concert: Concert? = nil
        var scheduleList: [ConcertSchedule] = []
        var setlist: Setlist? = nil
        var songList: [SetlistSong] = []
    }
    
    struct ConcertSectionState {
        typealias Data = (sections: [ConcertSection], recommended: [Concert]?)
        
        var sectionList: [ConcertSection] = []
        var isLoading: Bool = false
        var isInitialLoad: Bool = true
        var shouldShowPreferenceBanner: Bool = false
        var recommendedConcertList: [Concert] = []
        var errorMessage: String = ""
    }
}

@MainActor
final class HomeStore: ObservableObject {
    
    // MARK: - CancelID
    
    private enum CancelID {
        case fetchInterestedConcert
        case fetchScheduleList
        case fetchMainSetlist
        case fetchUser
        case refreshSections
        case fetchUnreadNotificationCount
    }
    
    @Published private(set) var state: HomeState = .init()
    
    @Injected private var userRepository: UserRepository
    @Injected private var notificationRepository: NotificationRepository
    @Injected private var concertRepository: ConcertRepository
    @Injected private var setlistRepository: SetlistRepository
    
    private var cancellables = [CancelID: Task<Void, Never>]()
    
    func send(_ intent: HomeIntent) {
        switch intent {
        case .onAppear:
            performFetchUser()
            performFetchUnreadNotificationCount()

        case .onErrorToastDisappear:
            state.errorMessage = ""

        case .onToastDisappear:
            state.toastMessage = ""

        case .checkUnreadNotification:
            performFetchUnreadNotificationCount()

        case ._fetchUserResult(let result):
            switch result {
            case .success(let user):
                let nextContent: HomeState.Content = user.interestConcertID == nil ? .concertSection : .interestConcert
                let didChangeContent = state.currentContent != nextContent

                state.user = user
                state.currentContent = nextContent
                executeInitialLoad(for: nextContent, forceReload: didChangeContent)
            case .failure(let error):
                state.errorMessage = getErrorMessage(from: error)
            }

        case ._fetchUnreadNotificationCountResult(let result):
            switch result {
            case .success(let count):
                state.hasNewNotice = count > 0
            case .failure:
                state.hasNewNotice = false
            }

        case .interestConcert(let intent):
            handleInterestConcertIntent(intent)

        case .concertSection(let intent):
            handleConcertSectionIntent(intent)
        }
    }
}

// MARK: - Intent Reducers

private extension HomeStore {
    func handleInterestConcertIntent(_ intent: HomeIntent.InterestConcertIntent) {
        switch intent {
        case .onDelete:
            performDeleteInterestConcert()

        case .onRefresh:
            if let concert = state.interestConcert.concert {
                performFetchScheduleList(concertID: concert.id)
                performFetchMainSetlist(concertID: concert.id)
            } else {
                performFetchUserInterestedConcert()
            }

        case ._fetchUserInterestConcertResult(let result):
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

        case ._fetchScheduleListResult(let result):
            switch result {
            case .success(let schedules):
                state.interestConcert.scheduleList = schedules
            case .failure(let error):
                state.interestConcert.scheduleList = []
                state.errorMessage = getErrorMessage(from: error)
            }

        case ._fetchMainSetlistResult(let result):
            switch result {
            case .success(let setlist):
                state.interestConcert.setlist = setlist
            case .failure(let error):
                state.interestConcert.setlist = nil
                state.interestConcert.songList = []
                state.errorMessage = getErrorMessage(from: error)
            }

        case ._fetchSetlistSongListResult(let result):
            switch result {
            case .success(let songs):
                state.interestConcert.songList = songs
            case .failure(let error):
                state.interestConcert.songList = []
                state.errorMessage = getErrorMessage(from: error)
            }

        case ._deleteInterestConcertResult(let result):
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
}

private extension HomeStore {
    func handleConcertSectionIntent(_ intent: HomeIntent.ConcertSectionIntent) {
        switch intent {
        case .onRefresh:
            performFetchConcertSectionData()

        case ._concertSectionDataResult(let result):
            state.concertSection.isLoading = false

            switch result {
            case .success(let data):
                state.concertSection.sectionList = data.sections
                state.concertSection.shouldShowPreferenceBanner = !(state.user?.hasPreferences ?? false)
                state.concertSection.recommendedConcertList = data.recommended ?? []
                state.concertSection.errorMessage = ""
            case .failure(let error):
                state.concertSection.errorMessage = getErrorMessage(from: error)
            }
        }
    }
}

// MARK: - Initial Load Control

private extension HomeStore {
    func executeInitialConcertSectionLoadIfNeeded(forceReload: Bool) {
        guard state.user != nil else { return }
        
        if state.concertSection.isInitialLoad {
            state.concertSection.isLoading = true
            state.concertSection.isInitialLoad = false
            performFetchConcertSectionData()
            return
        }

        guard forceReload else { return }

        performFetchConcertSectionData()
    }

    func executeInitialInterestConcertLoadIfNeeded(forceReload: Bool) {
        guard state.user != nil else { return }

        if state.interestConcert.isInitialLoad {
            state.interestConcert.isInitialLoad = false
            performFetchUserInterestedConcert()
            return
        }

        guard forceReload else { return }

        performFetchUserInterestedConcert()
    }
}

// MARK: - Effects

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

    func performFetchUnreadNotificationCount() {
        cancellables[.fetchUnreadNotificationCount]?.cancel()
        cancellables[.fetchUnreadNotificationCount] = Task {
            do {
                let count = try await notificationRepository.fetchUnreadNotificationCount()
                send(._fetchUnreadNotificationCountResult(.success(count)))
            } catch {
                send(._fetchUnreadNotificationCountResult(.failure(error)))
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
    
    func performDeleteInterestConcert() {
        Task {
            do {
                try await userRepository.deleteInterestedConcert()
                WidgetCenter.shared.reloadAllTimelines()
                performFetchUser()
                send(.interestConcert(._deleteInterestConcertResult(.success(()))))
            } catch {
                send(.interestConcert(._deleteInterestConcertResult(.failure(error))))
            }
        }
    }
    
    func performFetchConcertSectionData() {
        cancellables[.refreshSections]?.cancel()
        cancellables[.refreshSections] = Task {
            do {
                async let sections = concertRepository.fetchHomeConcertSectionList()
                async let recommendations = fetchRecommendationsIfNeeded()
                
                let resolvedSections = try await sections
                let resolvedRecommendations = await recommendations
                let data = (
                    sections: resolvedSections,
                    recommended: resolvedRecommendations
                )
                send(.concertSection(._concertSectionDataResult(.success(data))))
            } catch {
                send(.concertSection(._concertSectionDataResult(.failure(error))))
            }
        }
    }
}

// MARK: - Route Load Strategy

private extension HomeStore {
    func executeInitialLoad(for content: HomeState.Content, forceReload: Bool) {
        switch content {
        case .concertSection:
            executeInitialConcertSectionLoadIfNeeded(forceReload: forceReload)
        case .interestConcert:
            executeInitialInterestConcertLoadIfNeeded(forceReload: forceReload)
        }
    }
}

// MARK: - Utilities

private extension HomeStore {
    func fetchRecommendationsIfNeeded() async -> [Concert]? {
        guard let hasPreferences = state.user?.hasPreferences else { return nil }
        if hasPreferences {
            do {
                return try await concertRepository.fetchRecommendedConcertList()
            } catch {
                return []
            }
        }
        
        return nil
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
}
