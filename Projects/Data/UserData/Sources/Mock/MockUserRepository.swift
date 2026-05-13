//
//  MockUserRepository.swift
//  UserData
//
//  Created by Youjin Lee on 2/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

#if DEBUG
public struct MockUserRepository: UserRepository {
    public init() {}

    public func updateNickname(_ nickname: String) async throws(UserError) {}

    public func fetchUser() async throws(UserError) -> User {
        User(
            id: 1,
            provider: "kakao",
            providerID: "12345",
            email: "test@test.com",
            nickname: "테스트유저",
            hasPreferences: false,
            authority: UserAuthority(deviceNotification: true, marketingConsent: true)
        )
    }

    @discardableResult
    public func refreshUser() async throws(UserError) -> User {
        try await fetchUser()
    }

    public func fetchInterestedConcertList(filter: InterestConcertListFilter) async throws(UserError) -> ListResult<InterestConcert> {
        let sortedConcertList = Self.interestConcertList.sorted { lhs, rhs in
            switch filter.sort ?? .concert {
            case .concert:
                return (lhs.concert.startDate ?? .distantFuture) < (rhs.concert.startDate ?? .distantFuture)
            case .ticketing:
                return Self.ticketingDate(from: lhs.ticketingSchedule) < Self.ticketingDate(from: rhs.ticketingSchedule)
            }
        }
        let interestConcertList = filter.limit.map { Array(sortedConcertList.prefix(max($0, 0))) } ?? sortedConcertList
        return ListResult(
            items: interestConcertList,
            nextToken: nil
        )
    }

    public func checkInterestedConcert(id: Int) async throws(UserError) -> Bool {
        Self.interestConcertList.contains(where: { $0.concert.id == id })
    }

    @discardableResult
    public func updateInterestedConcert(_ concertID: Int) async throws(UserError) -> Concert {
        throw UserError.unknown
    }

    @discardableResult
    public func updateInterestedConcertList(_ concertIDList: [Int]) async throws(UserError) -> [Concert] {
        []
    }

    public func deleteInterestedConcert() async throws(UserError) {}

    public func fetchInterestConcertCleanupPolicy() async throws(UserError) -> InterestConcertCleanupPolicy {
        .none
    }

    public func markInterestConcertToastShown() async throws(UserError) {}
}

private extension MockUserRepository {
    static let interestConcertList: [InterestConcert] = [
        InterestConcert(
            concert: Concert(
                id: 101,
                title: "ONE OK ROCK 내한공연",
                artist: "ONE OK ROCK",
                status: .upcoming,
                daysLeft: 20,
                startDate: Date(timeIntervalSince1970: 1_783_584_000),
                endDate: Date(timeIntervalSince1970: 1_783_670_400),
                posterURL: URL(string: "https://kopis.or.kr/upload/pfmPoster/PF_PF278958_251113_113650.jpg"),
                venue: "잠실 실내체육관",
                ticketSite: "인터파크 티켓",
                ticketURL: URL(string: "https://ticket.example.com/one-ok-rock"),
                introduction: "ONE OK ROCK의 에너지 넘치는 내한공연",
                label: "월드투어"
            ),
            ticketingSchedule: InterestConcertTicketingSchedule(
                preSaleDate: Date(timeIntervalSince1970: 1_779_955_200),
                generalSaleDate: Date(timeIntervalSince1970: 1_780_214_400)
            )
        ),
        InterestConcert(
            concert: Concert(
                id: 102,
                title: "Taylor Swift | The Eras Tour",
                artist: "Taylor Swift",
                status: .upcoming,
                daysLeft: 54,
                startDate: Date(timeIntervalSince1970: 1_786_780_800),
                endDate: Date(timeIntervalSince1970: 1_786_867_200),
                posterURL: URL(string: "https://images.unsplash.com/photo-1501386761578-eac5c94b800a"),
                venue: "고척스카이돔",
                ticketSite: "Ticketmaster",
                ticketURL: URL(string: "https://ticket.example.com/taylor-swift"),
                introduction: "Taylor Swift의 첫 내한공연",
                label: "첫 내한"
            ),
            ticketingSchedule: InterestConcertTicketingSchedule(
                preSaleDate: nil,
                generalSaleDate: Date(timeIntervalSince1970: 1_777_363_200)
            )
        ),
        InterestConcert(
            concert: Concert(
                id: 103,
                title: "LANY Live in Seoul",
                artist: "LANY",
                status: .upcoming,
                daysLeft: 12,
                startDate: Date(timeIntervalSince1970: 1_782_201_600),
                endDate: Date(timeIntervalSince1970: 1_782_201_600),
                posterURL: URL(string: "https://images.unsplash.com/photo-1492684223066-81342ee5ff30"),
                venue: "올림픽공원 올림픽홀",
                ticketSite: "YES24 티켓",
                ticketURL: URL(string: "https://ticket.example.com/lany"),
                introduction: "LANY의 감성적인 서울 공연",
                label: nil
            ),
            ticketingSchedule: InterestConcertTicketingSchedule(
                preSaleDate: Date(timeIntervalSince1970: 1_781_164_800),
                generalSaleDate: Date(timeIntervalSince1970: 1_781_424_000)
            )
        ),
        InterestConcert(
            concert: Concert(
                id: 104,
                title: nil,
                artist: "Billie Eilish",
                status: .upcoming,
                daysLeft: nil,
                startDate: Date(timeIntervalSince1970: 1_790_064_000),
                endDate: Date(timeIntervalSince1970: 1_790_150_400),
                posterURL: nil,
                venue: nil,
                ticketSite: nil,
                ticketURL: nil,
                introduction: "Billie Eilish 내한 예정",
                label: "Coming Soon"
            ),
            ticketingSchedule: InterestConcertTicketingSchedule(
                preSaleDate: nil,
                generalSaleDate: nil
            )
        ),
        InterestConcert(
            concert: Concert(
                id: 105,
                title: "Coldplay Music of the Spheres",
                artist: "Coldplay",
                status: .upcoming,
                daysLeft: 5,
                startDate: Date(timeIntervalSince1970: 1_781_596_800),
                endDate: Date(timeIntervalSince1970: 1_781_683_200),
                posterURL: URL(string: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819"),
                venue: "상암월드컵경기장",
                ticketSite: "NOL 티켓",
                ticketURL: URL(string: "https://ticket.example.com/coldplay"),
                introduction: "Coldplay 스타디움 투어",
                label: "Stadium Live"
            ),
            ticketingSchedule: InterestConcertTicketingSchedule(
                preSaleDate: Date(timeIntervalSince1970: 1_780_732_800),
                generalSaleDate: Date(timeIntervalSince1970: 1_780_992_000)
            )
        )
    ]

    static func ticketingDate(from schedule: InterestConcertTicketingSchedule) -> Date {
        [schedule.preSaleDate, schedule.generalSaleDate]
            .compactMap { $0 }
            .min() ?? .distantFuture
    }
}
#endif
