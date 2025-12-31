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

public struct ConcertState {
    public var concertID: Int = 0
    public var artist: Artist?
    public var concert: Concert?
    public var communityCount: Int = 0
    public var isLoading: Bool = false
    public var errorMessage: String = ""
    public var successMessage: String = ""
    public var formattedDateRange: String = ""
    public var fanCultures: [ConcertCulture] = []
    public var selectedTab: ConcertTab = .artistDetail

    public init() {}
}

public enum ConcertIntent {
    case favoriteButtonTapped
    case tabSelected(ConcertTab)
    case onAppear(concertID: Int)
    case onToastDisappear

    case _setError(String)
    case _setSuccess(String)
    case _setLoading(Bool)
    case _setArtist(Artist)
    case _setFanCultures([ConcertCulture])
    case _setConcert(Concert, formattedDateRange: String)
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
        case .favoriteButtonTapped:
            setInterestConcert()
        case .tabSelected(let tab):
            state.selectedTab = tab
        case .onToastDisappear:
            state.errorMessage = ""
            state.successMessage = ""
        case ._setConcert(let concert, let formattedDateRange):
            state.concert = concert
            state.formattedDateRange = formattedDateRange
        case ._setArtist(let artist):
            state.artist = artist
        case ._setFanCultures(let fanCultures):
            state.fanCultures = fanCultures
        case ._setLoading(let isLoading):
            state.isLoading = isLoading
        case ._setError(let message):
            state.errorMessage = message
        case ._setSuccess(let message):
            state.successMessage = message
        }
    }
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
                send(._setError(error.localizedDescription))
            }

            send(._setLoading(false))
        }
    }

    func formatDateRange(from concert: Concert) -> String {
        let calendar = Calendar.current
        let startYear = calendar.component(.year, from: concert.startDate)
        let endYear = calendar.component(.year, from: concert.endDate)

        let fullFormatter = DateFormatter()
        fullFormatter.dateFormat = "yyyy.MM.dd"

        let startDateString = fullFormatter.string(from: concert.startDate)
        let endDateString = fullFormatter.string(from: concert.endDate)

        if startDateString == endDateString {
            return startDateString
        } else if startYear == endYear {
            let shortFormatter = DateFormatter()
            shortFormatter.dateFormat = "MM.dd"
            let endShortString = shortFormatter.string(from: concert.endDate)
            return "\(startDateString)~\(endShortString)"
        } else {
            return "\(startDateString)~\(endDateString)"
        }
    }

    func setInterestConcert() {
        Task { @MainActor in
            do {
                try await repository.setInterestConcert(concertID: state.concertID)
                send(._setSuccess("관심 공연을 변경했어요"))
            } catch {
                send(._setError(error.localizedDescription))
            }
        }
    }
}
