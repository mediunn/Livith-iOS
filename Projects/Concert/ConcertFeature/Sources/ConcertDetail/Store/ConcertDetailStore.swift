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
    public var errorMessage: String = ""
    public var isLoading: Bool = false

    public init() {}
}

public enum ConcertDetailIntent {
    case onAppear(concertID: Int)
    case favoriteButtonTapped

    case _setConcert(Concert)
    case _setLoading(Bool)
    case _setErrorMessage(String)
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
        case ._setConcert(let concert):
            state.concert = concert
        case ._setLoading(let isLoading):
            state.isLoading = isLoading
        case ._setErrorMessage(let message):
            state.errorMessage = message
        }
    }
}

// MARK: - Private Methods

private extension ConcertDetailStore {
    func fetchConcertDetail(concertID: Int) {
        fetchTask?.cancel()

        fetchTask = Task { @MainActor in
            state.isLoading = true

            // TODO: Repository 연결 시 실제 API 호출로 교체
            // 현재는 Mock 데이터 사용
            guard await Task.wait(for: .milliseconds(300)) else { return }

            let mockConcert = Concert(
                id: concertID,
                title: "Gen Hoshino presents MAD Asia in Seoul",
                artist: "호시노 겐",
                status: .upcoming,
                daysLeft: 30,
                startDate: createDate(year: 2025, month: 9, day: 13),
                endDate: createDate(year: 2025, month: 9, day: 14),
                posterURL: URL(string: "https://example.com/poster.jpg")!,
                venue: "올림픽공원 올림픽홀",
                ticketSite: nil,
                ticketURL: nil,
                introduction: "호시노 겐의 n 년만의 내한!\nKoi 열풍으로 한국에서도 인기 아티스트",
                label: "많이 찾는 콘서트 1위"
            )

            state.concert = mockConcert
            state.isLoading = false
        }
    }

    func createDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
}
