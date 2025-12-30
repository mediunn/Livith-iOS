//
//  InterestConcertSearchStore.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import HomeDomain
import DIContainer
import LivithConcurrency

enum InterestConcertSearchIntent {
    case updateText(String)
    case onSearch
    case selectConcert(Int)
    case onSubmit
    case onToastDisappear
    case _fetchConcertListResult(Result<[Concert], Error>)
    case _fetchRecommendKeywordListResult(Result<[String], Error>)
    case _fetchSearchListResult(Result<[Concert], Error>)
}

struct InterestConcertSearchState {
    var concertList: [Concert] = []
    var searchText: String = ""
    var recommendKeywordList: [String] = []
    var searchList: [Concert] = []
    var selectedConcertID: Int?
    var errorMessage: String = ""
}

final class InterestConcertSearchStore: ObservableObject {
    @Published private(set) var state = InterestConcertSearchState()

    @Injected private var repository: HomeRepository

    private var searchTask: Task<Void, Never>?
    
    init() {
        performFetchConcertList()
    }
    
    @MainActor
    func send(_ intent: InterestConcertSearchIntent) {
        switch intent {
        case .updateText(let text):
            state.searchList.removeAll()
            state.searchText = text

            if text.isEmpty {
                state.recommendKeywordList.removeAll()
                searchTask?.cancel()
            } else {
                performFetchRecommendKeywordList()
            }

        case .onSearch:
            performFetchSearchList(for: state.searchText)

        case .selectConcert(let concertID):
            state.selectedConcertID = state.selectedConcertID == concertID ? nil : concertID

        case .onSubmit:
            break
        
        case .onToastDisappear:
            state.errorMessage = ""
            
        case ._fetchConcertListResult(let result):
            switch result {
            case .success(let concertList):
                state.concertList = concertList
            case .failure:
                state.concertList = []
            }

        case ._fetchRecommendKeywordListResult(let result):
            switch result {
            case .success(let keywordList):
                state.recommendKeywordList = keywordList
                print("Fetched recommend keywords: \(keywordList)")
            case .failure:
                state.recommendKeywordList = []
            }

        case ._fetchSearchListResult(let result):
            switch result {
            case .success(let searchList):
                state.searchList = searchList
            case .failure:
                state.searchList = []
            }
        }
    }
}

// MARK: - Helpers

private extension InterestConcertSearchStore {
    func performFetchConcertList() {
        Task {
            do {
                let concertList = createConcertListMockData()
                await send(._fetchConcertListResult(.success(concertList)))
            } catch {
                await send(._fetchConcertListResult(.failure(error)))
            }
        }
    }

    func performFetchRecommendKeywordList() {
        guard !state.searchText.isEmpty else { return }
        
        searchTask?.cancel()
        searchTask = Task {
            guard await Task.wait(for: .milliseconds(400)) else { return }

            do {
                let allKeywords = ["아이유", "아이즈원", "아이브", "뉴진스", "BTS", "블랙핑크", "세븐틴", "트와이스"]
                let filteredKeywords = allKeywords.filter { $0.localizedCaseInsensitiveContains(state.searchText) }
                await send(._fetchRecommendKeywordListResult(.success(filteredKeywords)))
            } catch {
                await send(._fetchRecommendKeywordListResult(.failure(error)))
            }
        }
    }

    func performFetchSearchList(for keyword: String) {
        Task {
            do {
                let searchList = createSearchResultMockData().filter {
                    $0.title.localizedCaseInsensitiveContains(keyword) ||
                    $0.artist.localizedCaseInsensitiveContains(keyword)
                }
                await send(._fetchSearchListResult(.success(searchList)))
            } catch {
                await send(._fetchSearchListResult(.failure(error)))
            }
        }
    }

    func createConcertListMockData() -> [Concert] {
        [
            Concert(
                id: 101,
                title: "NCT DREAM THE DREAM SHOW 3",
                artist: "엔시티 드림",
                status: .upcoming,
                daysLeft: 25,
                startDate: "2026.01.24",
                endDate: "2026.01.26",
                posterURL: URL(string: "https://picsum.photos/id/100/200/300")!,
                venue: "고척스카이돔",
                ticketSite: "YES24",
                ticketURL: URL(string: "https://ticket.yes24.com"),
                introduction: "엔시티 드림 세번째 단독 투어",
                label: "HOT"
            ),
            Concert(
                id: 102,
                title: "TWICE 5TH WORLD TOUR 'READY TO BE'",
                artist: "트와이스",
                status: .ongoing,
                daysLeft: 0,
                startDate: "2025.12.28",
                endDate: "2026.01.05",
                posterURL: URL(string: "https://picsum.photos/id/101/200/300")!,
                venue: "KSPO DOME",
                ticketSite: "인터파크 티켓",
                ticketURL: URL(string: "https://tickets.interpark.com"),
                introduction: "트와이스 5번째 월드투어 서울 공연",
                label: "SOLD OUT"
            ),
            Concert(
                id: 103,
                title: "Red Velvet 'R to V' CONCERT",
                artist: "레드벨벳",
                status: .upcoming,
                daysLeft: 40,
                startDate: "2026.02.08",
                endDate: "2026.02.09",
                posterURL: URL(string: "https://picsum.photos/id/102/200/300")!,
                venue: "잠실실내체육관",
                ticketSite: "멜론티켓",
                ticketURL: URL(string: "https://ticket.melon.com"),
                introduction: "레드벨벳 단독 콘서트",
                label: nil
            ),
            Concert(
                id: 104,
                title: "Stray Kids 'DominATE' WORLD TOUR",
                artist: "스트레이키즈",
                status: .upcoming,
                daysLeft: 35,
                startDate: "2026.02.03",
                endDate: "2026.02.05",
                posterURL: URL(string: "https://picsum.photos/id/103/200/300")!,
                venue: "고척스카이돔",
                ticketSite: "YES24",
                ticketURL: URL(string: "https://ticket.yes24.com"),
                introduction: "스트레이키즈 월드투어 서울 공연",
                label: "HOT"
            ),
            Concert(
                id: 105,
                title: "LE SSERAFIM 'FLAME RISES' TOUR",
                artist: "르세라핌",
                status: .upcoming,
                daysLeft: 50,
                startDate: "2026.02.18",
                endDate: "2026.02.20",
                posterURL: URL(string: "https://picsum.photos/id/104/200/300")!,
                venue: "KSPO DOME",
                ticketSite: "인터파크 티켓",
                ticketURL: URL(string: "https://tickets.interpark.com"),
                introduction: "르세라핌 첫 단독 투어",
                label: "NEW"
            ),
            Concert(
                id: 106,
                title: "(G)I-DLE 'I am FREE-TY' CONCERT",
                artist: "(여자)아이들",
                status: .completed,
                daysLeft: 0,
                startDate: "2025.11.15",
                endDate: "2025.12.15",
                posterURL: URL(string: "https://picsum.photos/id/105/200/300")!,
                venue: "올림픽공원 올림픽홀",
                ticketSite: "YES24",
                ticketURL: URL(string: "https://ticket.yes24.com"),
                introduction: "(여자)아이들 전국투어",
                label: nil
            ),
            Concert(
                id: 107,
                title: "NMIXX 'MIXXTOPIA' SHOWCASE",
                artist: "엔믹스",
                status: .upcoming,
                daysLeft: 18,
                startDate: "2026.01.17",
                endDate: "2026.01.18",
                posterURL: URL(string: "https://picsum.photos/id/106/200/300")!,
                venue: "잠실실내체육관",
                ticketSite: "멜론티켓",
                ticketURL: URL(string: "https://ticket.melon.com"),
                introduction: "엔믹스 단독 쇼케이스",
                label: "NEW"
            ),
            Concert(
                id: 108,
                title: "ITZY 2ND WORLD TOUR 'BORN TO BE'",
                artist: "있지",
                status: .upcoming,
                daysLeft: 12,
                startDate: "2026.01.11",
                endDate: "2026.01.12",
                posterURL: URL(string: "https://picsum.photos/id/107/200/300")!,
                venue: "KSPO DOME",
                ticketSite: "인터파크 티켓",
                ticketURL: URL(string: "https://tickets.interpark.com"),
                introduction: "있지 두번째 월드투어",
                label: "HOT"
            ),
            Concert(
                id: 109,
                title: "태연 'The ODD OF LOVE' CONCERT",
                artist: "태연",
                status: .upcoming,
                daysLeft: 55,
                startDate: "2026.02.23",
                endDate: "2026.02.25",
                posterURL: URL(string: "https://picsum.photos/id/108/200/300")!,
                venue: "올림픽공원 올림픽홀",
                ticketSite: "YES24",
                ticketURL: URL(string: "https://ticket.yes24.com"),
                introduction: "태연 단독 콘서트",
                label: nil
            ),
            Concert(
                id: 110,
                title: "EXO 'EXO PLANET' ENCORE",
                artist: "엑소",
                status: .upcoming,
                daysLeft: 70,
                startDate: "2026.03.10",
                endDate: "2026.03.12",
                posterURL: URL(string: "https://picsum.photos/id/109/200/300")!,
                venue: "고척스카이돔",
                ticketSite: "인터파크 티켓",
                ticketURL: URL(string: "https://tickets.interpark.com"),
                introduction: "엑소 앵콜 콘서트",
                label: "SOLD OUT"
            )
        ]
    }
    
    func createSearchResultMockData() -> [Concert] {
        [
            Concert(
                id: 1,
                title: "아이유 단독 콘서트 'The Golden Hour : 오렌지 태양 아래'",
                artist: "아이유",
                status: .upcoming,
                daysLeft: 15,
                startDate: "2026.01.14",
                endDate: "2026.02.16",
                posterURL: URL(string: "https://picsum.photos/id/10/200/300")!,
                venue: "고척스카이돔",
                ticketSite: "인터파크 티켓",
                ticketURL: URL(string: "https://tickets.interpark.com"),
                introduction: "아이유의 2026년 전국 투어 콘서트",
                label: "HOT"
            ),
            Concert(
                id: 2,
                title: "BTS WORLD TOUR 'YET TO COME'",
                artist: "방탄소년단",
                status: .ongoing,
                daysLeft: 0,
                startDate: "2025.12.25",
                endDate: "2026.01.10",
                posterURL: URL(string: "https://picsum.photos/id/20/200/300")!,
                venue: "잠실종합운동장",
                ticketSite: "위버스",
                ticketURL: URL(string: "https://www.weverse.io"),
                introduction: "방탄소년단 완전체 월드투어",
                label: "SOLD OUT"
            ),
            Concert(
                id: 3,
                title: "블랙핑크 앵콜 콘서트 'BORN PINK'",
                artist: "블랙핑크",
                status: .upcoming,
                daysLeft: 45,
                startDate: "2026.02.13",
                endDate: "2026.02.14",
                posterURL: URL(string: "https://picsum.photos/id/30/200/300")!,
                venue: "KSPO DOME",
                ticketSite: "YES24",
                ticketURL: URL(string: "https://ticket.yes24.com"),
                introduction: "블랙핑크 한국 앵콜 공연",
                label: nil
            ),
            Concert(
                id: 4,
                title: "세븐틴 'FOLLOW' AGAIN TOUR",
                artist: "세븐틴",
                status: .upcoming,
                daysLeft: 30,
                startDate: "2026.01.29",
                endDate: "2026.02.02",
                posterURL: URL(string: "https://picsum.photos/id/40/200/300")!,
                venue: "고척스카이돔",
                ticketSite: "YES24",
                ticketURL: URL(string: "https://ticket.yes24.com"),
                introduction: "세븐틴 정규 앨범 발매 기념 콘서트",
                label: "HOT"
            ),
            Concert(
                id: 5,
                title: "NewJeans 1st Concert 'Bunnies'",
                artist: "뉴진스",
                status: .upcoming,
                daysLeft: 60,
                startDate: "2026.02.28",
                endDate: "2026.03.02",
                posterURL: URL(string: "https://picsum.photos/id/50/200/300")!,
                venue: "KSPO DOME",
                ticketSite: "인터파크 티켓",
                ticketURL: URL(string: "https://tickets.interpark.com"),
                introduction: "뉴진스 첫 단독 콘서트",
                label: "NEW"
            ),
            Concert(
                id: 6,
                title: "임영웅 전국투어 '아임히어로'",
                artist: "임영웅",
                status: .completed,
                daysLeft: 0,
                startDate: "2025.11.01",
                endDate: "2025.12.20",
                posterURL: URL(string: "https://picsum.photos/id/60/200/300")!,
                venue: "서울 올림픽공원",
                ticketSite: "멜론티켓",
                ticketURL: URL(string: "https://ticket.melon.com"),
                introduction: "임영웅 전국투어 콘서트",
                label: nil
            ),
            Concert(
                id: 7,
                title: "에스파 'MY WORLD' TOUR",
                artist: "에스파",
                status: .upcoming,
                daysLeft: 20,
                startDate: "2026.01.19",
                endDate: "2026.01.20",
                posterURL: URL(string: "https://picsum.photos/id/70/200/300")!,
                venue: "잠실실내체육관",
                ticketSite: "YES24",
                ticketURL: URL(string: "https://ticket.yes24.com"),
                introduction: "에스파 월드 투어 서울 공연",
                label: "HOT"
            ),
            Concert(
                id: 8,
                title: "자이언티 단독 콘서트",
                artist: "자이언티",
                status: .upcoming,
                daysLeft: 7,
                startDate: "2026.01.06",
                endDate: "2026.01.07",
                posterURL: URL(string: "https://picsum.photos/id/80/200/300")!,
                venue: "올림픽공원 올림픽홀",
                ticketSite: "멜론티켓",
                ticketURL: URL(string: "https://ticket.melon.com"),
                introduction: "자이언티의 감성 R&B 콘서트",
                label: nil
            ),
            Concert(
                id: 9,
                title: "아이브 1st WORLD TOUR 'SHOW WHAT I HAVE'",
                artist: "아이브",
                status: .upcoming,
                daysLeft: 90,
                startDate: "2026.03.30",
                endDate: "2026.03.31",
                posterURL: URL(string: "https://picsum.photos/id/90/200/300")!,
                venue: "KSPO DOME",
                ticketSite: "인터파크 티켓",
                ticketURL: URL(string: "https://tickets.interpark.com"),
                introduction: "아이브 첫 월드투어",
                label: "NEW"
            )
        ]
    }
}
