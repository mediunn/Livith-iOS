//
//  InterestConcertSettingStore.swift
//  HomeFeature
//
//  Created by 김진웅 on 4/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Observation

import Domain

// MARK: - State

struct InterestConcertSettingState {
    let mode: InterestConcertSettingMode
    var concertList: [Concert]
    var filteredConcertList: [Concert]
    var searchText: String
    var isSearchFocused: Bool
    var initialUserInterestConcertIDList: [Int]
    var selectedConcertIDList: [Int]

    var selectedConcertCount: Int {
        selectedConcertIDList.count
    }

    var selectedConcertList: [Concert] {
        let concertByID = Dictionary(uniqueKeysWithValues: concertList.map { ($0.id, $0) })
        return selectedConcertIDList.compactMap { concertByID[$0] }
    }

    var isCTAEnabled: Bool {
        switch mode {
        case .initialSetup:
            return !selectedConcertIDList.isEmpty
        case .update:
            return Set(selectedConcertIDList) != Set(initialUserInterestConcertIDList)
        }
    }
}

enum InterestConcertSettingMode {
    case initialSetup
    case update

    var navigationTitle: String {
        switch self {
        case .initialSetup:
            return "공연 설정"
        case .update:
            return "공연 변경"
        }
    }

    var ctaTitle: String {
        switch self {
        case .initialSetup:
            return "설정하기"
        case .update:
            return "변경하기"
        }
    }
}

// MARK: - Intent

enum InterestConcertSettingIntent {
    case updateSearchText(String)
    case clearSearchText
    case setSearchFocused(Bool)
    case toggleConcertSelection(Int)
    case removeSelectedConcert(Int)
}

// MARK: - Store

@Observable
final class InterestConcertSettingStore {

    // MARK: - Property

    private(set) var state: InterestConcertSettingState

    // MARK: - Initializer

    init(
        mode: InterestConcertSettingMode,
        userInterestConcertList: [Concert] = []
    ) {
        // TODO: update 모드 실제 연동 시 외부 userInterestConcertList의 활용 범위를 확장한다.
        let initialUserInterestConcertIDList = userInterestConcertList.map(\.id)
        let concertList = Self.mockConcertList

        self.state = InterestConcertSettingState(
            mode: mode,
            concertList: concertList,
            filteredConcertList: concertList,
            searchText: "",
            isSearchFocused: false,
            initialUserInterestConcertIDList: initialUserInterestConcertIDList,
            selectedConcertIDList: initialUserInterestConcertIDList
        )
    }

    // MARK: - Public Interface

    func send(_ intent: InterestConcertSettingIntent) {
        switch intent {
        case .updateSearchText(let text):
            let trimmedText = trimmedSearchText(from: text)

            state.searchText = trimmedText
            state.filteredConcertList = filteredConcertList(
                from: state.concertList,
                searchText: trimmedText
            )
        case .clearSearchText:
            state.searchText = ""
            state.filteredConcertList = state.concertList
            state.isSearchFocused = true
        case .setSearchFocused(let isFocused):
            state.isSearchFocused = isFocused
        case .toggleConcertSelection(let concertID):
            state.selectedConcertIDList = toggledConcertIDList(
                from: state.selectedConcertIDList,
                concertID: concertID
            )
        case .removeSelectedConcert(let concertID):
            state.selectedConcertIDList = removedConcertIDList(
                from: state.selectedConcertIDList,
                concertID: concertID
            )
        }
    }
}

// MARK: - Helpers

private extension InterestConcertSettingStore {
    func trimmedSearchText(from text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func filteredConcertList(from concertList: [Concert], searchText: String) -> [Concert] {
        guard !searchText.isEmpty else { return concertList }

        return concertList.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    func toggledConcertIDList(from selectedConcertIDList: [Int], concertID: Int) -> [Int] {
        guard !selectedConcertIDList.contains(concertID) else {
            return selectedConcertIDList.filter { $0 != concertID }
        }

        return selectedConcertIDList + [concertID]
    }

    func removedConcertIDList(from selectedConcertIDList: [Int], concertID: Int) -> [Int] {
        selectedConcertIDList.filter { $0 != concertID }
    }
}

private extension InterestConcertSettingStore {
    static let mockPosterURL = URL(string: "https://fastly.picsum.photos/id/1023/216/316.jpg?hmac=Wunm3hRG7WiE7puCI0_-RyR4Do-XrvPTOd02kuc1ktw")!

    static var mockConcertList: [Concert] {
        [
            makeConcert(id: 1, title: "IU 2026 TOUR H.E.R.", artist: "IU", daysLeft: 1),
            makeConcert(id: 2, title: "World Tour [ LIVE FULL EXPERIENCE ]", artist: "Coldplay", daysLeft: 3),
            makeConcert(id: 3, title: "NCT DREAM THE FUTURE", artist: "NCT DREAM", daysLeft: 5),
            makeConcert(id: 4, title: "Kendrick Lamar Live in Seoul", artist: "Kendrick Lamar", daysLeft: 7),
            makeConcert(id: 5, title: "Oasis Reunion Tour", artist: "Oasis", daysLeft: 10),
            makeConcert(id: 6, title: "Day6 Special Concert", artist: "DAY6", daysLeft: 14),
            makeConcert(id: 7, title: "Bruno Mars Live at Seoul", artist: "Bruno Mars", daysLeft: 16),
            makeConcert(id: 8, title: "Post Malone Big Ass Stadium", artist: "Post Malone", daysLeft: 19),
            makeConcert(id: 9, title: "SEVENTEEN RIGHT HERE", artist: "SEVENTEEN", daysLeft: 21),
            makeConcert(id: 10, title: "Taylor Swift Eras Encore", artist: "Taylor Swift", daysLeft: 24),
            makeConcert(id: 11, title: "The 1975 Live in Korea", artist: "The 1975", daysLeft: 27),
            makeConcert(id: 12, title: "Zion.T Midnight Groove", artist: "Zion.T", daysLeft: 30),
            makeConcert(id: 13, title: "NewJeans Supernatural Stage", artist: "NewJeans", daysLeft: 33),
            makeConcert(id: 14, title: "Crush Summer Night Show", artist: "Crush", daysLeft: 36),
            makeConcert(id: 15, title: "Silica Gel Planet Tour", artist: "Silica Gel", daysLeft: 40)
        ]
    }

    static func makeConcert(id: Int, title: String, artist: String, daysLeft: Int) -> Concert {
        Concert(
            id: id,
            title: title,
            artist: artist,
            status: .upcoming,
            daysLeft: daysLeft,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86_400),
            posterURL: mockPosterURL,
            venue: "KSPO DOME",
            ticketSite: "인터파크",
            ticketURL: URL(string: "https://example.com/ticket-\(id)"),
            introduction: "Draft 관심 콘서트 데이터",
            label: nil
        )
    }
}
