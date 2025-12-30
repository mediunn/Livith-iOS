//
//  ConcertDetailStore.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import ConcertDomain
import DIContainer
import LivithConcurrency

public struct ConcertDetailState {
    public var concert: Concert?
    public var formattedDateRange: String = ""
    public var errorMessage: String = ""
    public var isLoading: Bool = false

    public init() {}
}

public enum ConcertDetailIntent {
    case onAppear(concertID: Int)
    case favoriteButtonTapped

    case _setConcert(Concert, formattedDateRange: String)
    case _setLoading(Bool)
}

public final class ConcertDetailStore: ObservableObject {

    // MARK: - Property

    private var fetchTask: Task<Void, Never>?
    @Published private(set) var state = ConcertDetailState()

    // MARK: - Initializer

    public init() {}

    // TODO: Repository 연결 시 주석 해제
    // @Injected private var repository: ConcertRepository

    // MARK: - Intent Handler

    @MainActor
    public func send(_ intent: ConcertDetailIntent) {
        switch intent {
        case .onAppear(let concertID):
            fetchConcertDetail(concertID: concertID)
        case .favoriteButtonTapped:
            // TODO: 관심 콘서트 설정 기능 구현
            break
        case ._setConcert(let concert, let formattedDateRange):
            state.concert = concert
            state.formattedDateRange = formattedDateRange
        case ._setLoading(let isLoading):
            state.isLoading = isLoading
        }
    }
}

// MARK: - Private Methods

private extension ConcertDetailStore {
    func fetchConcertDetail(concertID: Int) {
        fetchTask?.cancel()

        fetchTask = Task { @MainActor in
            send(._setLoading(true))

            // TODO: Repository 연결 시 실제 API 호출로 교체
            // 현재는 Mock 데이터 사용
            guard await Task.wait(for: .milliseconds(300)) else { return }

            let mockConcert = Concert(
                id: concertID,
                title: "Gen Hoshino presents MAD Asia in Seoul",
                artist: "호시노 겐",
                status: .upcoming,
                daysLeft: 30,
                startDate: Date(),
                endDate: Date(),
                posterURL: URL(string: "https://example.com/poster.jpg")!,
                venue: "올림픽공원 올림픽홀",
                ticketSite: nil,
                ticketURL: nil,
                introduction: "호시노 겐의 n 년만의 내한!\nKoi 열풍으로 한국에서도 인기 아티스트",
                label: "많이 찾는 콘서트 1위"
            )

            send(._setConcert(mockConcert, formattedDateRange: formatDateRange(from: mockConcert)))
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

}
