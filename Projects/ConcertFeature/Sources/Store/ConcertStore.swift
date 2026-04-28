//
//  ConcertStore.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation
import DIContainer
import Domain
import LivithDesignSystem
import LivithFoundation

public typealias ConcertTab = SegmentedTabBarType.DetailTab

public enum ConcertInfoSection: String {
    case schedule
    case concertInfo
    case merchandise
}

public enum InterestSettingStatus: Equatable {
    case idle
    case inProgress
    case success(String)
    case failure(String)

    var message: String {
        switch self {
        case .success(let message), .failure(let message):
            return message
        default:
            return ""
        }
    }
}

public struct ConcertState {
    public var artist: Artist?
    public var concert: Concert?
    public var concertID: Int = 0
    public var fetchError: String?
    public var isLoading: Bool = false
    public var formattedDateRange: String = ""
    public var schedules: [ConcertSchedule] = []
    public var fanCultures: [ConcertCulture] = []
    public var concertInfoList: [ConcertInfo] = []
    public var selectedTab: ConcertTab = .artistDetail
    public var initialSection: ConcertInfoSection?
    public var merchandiseList: [ConcertMerchandise] = []
    public var setlistList: [Setlist] = []
    public var interestStatus: InterestSettingStatus = .idle
    public var showTicketReturnBanner: Bool = false
    public var isCurrentConcertInterested: Bool = false

    public init() {}
}

public enum ConcertIntent {
    case interestButtonTapped
    case tabSelected(ConcertTab)
    case sectionSelected(ConcertInfoSection?)
    case onAppear(concertID: Int)
    case onToastDisappear
    case onFetchErrorDismiss
    case onTicketSiteReturn
    case onTicketBannerDismiss

    case _setLoading(Bool)
    case _setArtist(Artist)
    case _setFanCultures([ConcertCulture])
    case _setSchedules([ConcertSchedule])
    case _setConcertInfoList([ConcertInfo])
    case _setMerchandiseList([ConcertMerchandise])
    case _setSetlistList([Setlist])
    case _setConcert(Concert, formattedDateRange: String)
    case _setInterestStatus(InterestSettingStatus)
    case _setFetchError(String?)
    case _setIsCurrentConcertInterested(Bool)
}

public final class ConcertStore: ObservableObject {

    // MARK: - Property

    private var fetchTask: Task<Void, Never>?
    @Published private(set) var state = ConcertState()

    @Injected private var repository: ConcertRepository
    @Injected private var userRepository: UserRepository

    // MARK: - Initializer

    public init() {}

    // MARK: - Intent Handler

    @MainActor
    public func send(_ intent: ConcertIntent) {
        switch intent {
        case .onAppear(let concertID):
            state.concertID = concertID
            fetchConcertData(concertID: concertID)
        case .interestButtonTapped:
            setInterestConcert()
        case .tabSelected(let tab):
            state.selectedTab = tab
        case .sectionSelected(let section):
            state.initialSection = section
        case .onToastDisappear:
            state.interestStatus = .idle
        case .onFetchErrorDismiss:
            state.fetchError = nil
        case .onTicketSiteReturn:
            state.showTicketReturnBanner = true
        case .onTicketBannerDismiss:
            state.showTicketReturnBanner = false
        case ._setConcert(let concert, let formattedDateRange):
            state.concert = concert
            state.formattedDateRange = formattedDateRange
        case ._setArtist(let artist):
            state.artist = artist
        case ._setFanCultures(let fanCultures):
            state.fanCultures = fanCultures
        case ._setSchedules(let schedules):
            state.schedules = schedules
        case ._setConcertInfoList(let concertInfoList):
            state.concertInfoList = concertInfoList
        case ._setMerchandiseList(let merchandiseList):
            state.merchandiseList = merchandiseList
        case ._setSetlistList(let setlistList):
            state.setlistList = setlistList
        case ._setLoading(let isLoading):
            state.isLoading = isLoading
        case ._setInterestStatus(let status):
            state.interestStatus = status
        case ._setFetchError(let error):
            state.fetchError = error
        case ._setIsCurrentConcertInterested(let isInterested):
            state.isCurrentConcertInterested = isInterested
        }
    }
}


// MARK: - Private Methods

private extension ConcertStore {
    func fetchConcertData(concertID: Int) {
        fetchTask?.cancel()

        let repo = repository
        let userRepo = userRepository

        fetchTask = Task { @MainActor in
            send(._setLoading(true))

            do {
                async let interestedConcertResult = userRepo.fetchInterestedConcert()
                async let concertResult = repo.fetchConcert(concertID: concertID)
                async let artistResult = repo.fetchConcertArtistInfo(concertID: concertID)
                async let cultureResult = repo.fetchConcertCultureList(concertID: concertID)
                async let scheduleResult = repo.fetchConcertScheduleList(concertID: concertID)
                async let concertInfoResult = repo.fetchConcertInfoList(concertID: concertID)
                async let merchandiseResult = repo.fetchConcertMerchandiseList(concertID: concertID)
                async let setlistResult = repo.fetchConcertSetlistList(concertID: concertID)

                let (concert, artist, cultures, schedules, concertInfoList, merchandiseList, setlistList) = try await (
                    concertResult,
                    artistResult,
                    cultureResult,
                    scheduleResult,
                    concertInfoResult,
                    merchandiseResult,
                    setlistResult
                )

                let interestedConcert = try? await interestedConcertResult
                send(._setIsCurrentConcertInterested(interestedConcert?.id == concertID))

                guard await Task.wait() else { return }

                send(._setConcert(concert, formattedDateRange: formatDateRange(from: concert)))
                send(._setArtist(artist))
                send(._setFanCultures(cultures))
                send(._setSchedules(schedules))
                send(._setConcertInfoList(concertInfoList))
                send(._setMerchandiseList(merchandiseList))
                send(._setSetlistList(setlistList))
            } catch let error as ConcertError {
                guard !Task.isCancelled else { return }
                let message = error == .noConnection
                    ? "네트워크 연결이 없습니다.\n연결 상태를 확인해주세요."
                    : "데이터를 불러오는데 실패했어요"
                send(._setFetchError(message))
            } catch {
                guard !Task.isCancelled else { return }
                send(._setFetchError("데이터를 불러오는데 실패했어요"))
            }

            send(._setLoading(false))
        }
    }

    func formatDateRange(from concert: Concert) -> String {
        DateFormatter.formatDateRange(from: concert.startDate, to: concert.endDate)
    }

    func setInterestConcert() {
        guard state.interestStatus != .inProgress else { return }

        Task { @MainActor in
            send(._setInterestStatus(.inProgress))

            do {
                try await userRepository.updateInterestedConcert(state.concertID)
                send(._setInterestStatus(.success("관심 공연을 변경했어요")))
                send(._setIsCurrentConcertInterested(true))
            } catch {
                send(._setInterestStatus(.failure(error.localizedDescription)))
            }
        }
    }
}
