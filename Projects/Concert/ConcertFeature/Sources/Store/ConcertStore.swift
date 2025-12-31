//
//  ConcertStore.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import ConcertDomain
import DIContainer
import LivithConcurrency

public enum ConcertTab: Int, CaseIterable {
    case artistDetail
    case concertInfo
    case setlist
    case community

    var title: String {
        switch self {
        case .artistDetail: return "아티스트 상세"
        case .concertInfo: return "콘서트 상세"
        case .setlist: return "셋리스트"
        case .community: return "소통·댓글"
        }
    }
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
    public var communityCount: Int = 0
    public var formattedDateRange: String = ""
    public var schedules: [ConcertSchedule] = []
    public var fanCultures: [ConcertCulture] = []
    public var concertInfoList: [ConcertInfo] = []
    public var selectedTab: ConcertTab = .artistDetail
    public var merchandiseList: [ConcertMerchandise] = []
    public var interestStatus: InterestSettingStatus = .idle

    public init() {}
}

public enum ConcertIntent {
    case interestButtonTapped
    case tabSelected(ConcertTab)
    case onAppear(concertID: Int)
    case onToastDisappear
    case onFetchErrorDismiss

    case _setLoading(Bool)
    case _setArtist(Artist)
    case _setFanCultures([ConcertCulture])
    case _setConcert(Concert, formattedDateRange: String)
    case _setInterestStatus(InterestSettingStatus)
    case _setFetchError(String?)
}

public final class ConcertStore: ObservableObject {

    // MARK: - Property

    private var fetchTask: Task<Void, Never>?
    @Published private(set) var state = ConcertState()

    @Injected private var repository: ConcertRepository

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
        case .onToastDisappear:
            state.interestStatus = .idle
        case .onFetchErrorDismiss:
            state.fetchError = nil
        case ._setConcert(let concert, let formattedDateRange):
            state.concert = concert
            state.formattedDateRange = formattedDateRange
        case ._setArtist(let artist):
            state.artist = artist
        case ._setFanCultures(let fanCultures):
            state.fanCultures = fanCultures
        case ._setLoading(let isLoading):
            state.isLoading = isLoading
        case ._setInterestStatus(let status):
            state.interestStatus = status
        case ._setFetchError(let error):
            state.fetchError = error
        }
    }
}

// MARK: - Date Formatter

private extension ConcertStore {
    static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()

    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        return formatter
    }()
}

// MARK: - Private Methods

private extension ConcertStore {
    func fetchConcertData(concertID: Int) {
        fetchTask?.cancel()

        fetchTask = Task { @MainActor in
            send(._setLoading(true))

            do {
                async let concertResult = repository.fetchConcertInfo(concertID: concertID)
                async let artistResult = repository.fetchConcertArtistInfo(concertID: concertID)
                async let cultureResult = repository.fetchConcertCultureList(concertID: concertID)

                let (concert, artist, cultures) = try await (concertResult, artistResult, cultureResult)

                guard await Task.wait() else { return }

                send(._setConcert(concert, formattedDateRange: formatDateRange(from: concert)))
                send(._setArtist(artist))
                send(._setFanCultures(cultures))
            } catch {
                guard !Task.isCancelled else { return }
                send(._setFetchError("데이터를 불러오는데 실패했어요"))
            }

            send(._setLoading(false))
        }
    }

    func formatDateRange(from concert: Concert) -> String {
        let calendar = Calendar.current
        let startYear = calendar.component(.year, from: concert.startDate)
        let endYear = calendar.component(.year, from: concert.endDate)

        let startDateString = Self.fullDateFormatter.string(from: concert.startDate)
        let endDateString = Self.fullDateFormatter.string(from: concert.endDate)

        if startDateString == endDateString {
            return startDateString
        } else if startYear == endYear {
            let endShortString = Self.shortDateFormatter.string(from: concert.endDate)
            return "\(startDateString)~\(endShortString)"
        } else {
            return "\(startDateString)~\(endDateString)"
        }
    }

    func setInterestConcert() {
        guard state.interestStatus != .inProgress else { return }

        Task { @MainActor in
            send(._setInterestStatus(.inProgress))

            do {
                try await repository.setInterestConcert(concertID: state.concertID)
                send(._setInterestStatus(.success("관심 공연을 변경했어요")))
            } catch {
                send(._setInterestStatus(.failure(error.localizedDescription)))
            }
        }
    }
}
