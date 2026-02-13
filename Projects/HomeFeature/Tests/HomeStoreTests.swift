//
//  HomeStoreTests.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 2/5/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Testing
import Foundation

@testable import HomeFeature
import Domain
import DIContainer

@MainActor
struct HomeStoreTests {
    
    let container: MockDIContainer
    
    init() {
        self.container = MockDIContainer()
        self.container.registerDependencies()
    }
    
    // MARK: - 초기 상태 테스트
    
    @Test("초기 상태에서 user는 nil이어야 한다")
    func testInitialUserState() {
        let sut = HomeStore()
        #expect(sut.state.user == nil)
    }
    
    @Test("onAppear 시 유저 정보와 읽지 않은 알림 수를 조회해야 한다")
    func testOnAppearFetchesUserAndUnreadNotificationCount() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.notificationRepository.unreadNotificationCountStub = 3
        
        let sut = HomeStore()
        
        // When
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(container.userRepository.fetchUserCallCount == 1)
        #expect(container.notificationRepository.fetchUnreadNotificationCountCallCount == 1)
        #expect(sut.state.user?.nickname == "홍길동")
        #expect(sut.state.hasNewNotice)
    }

    @Test("유저 조회 결과에서 interestedConcertID가 nil이면 route는 concertSection이어야 한다")
    func testUserResultWithNilInterestConcertIDSetsConcertSectionRoute() {
        let sut = HomeStore()
        let user = makeMockUser(interestConcertID: nil)

        sut.send(._fetchUserResult(.success(user)))

        #expect(sut.state.route == .concertSection)
    }

    @Test("유저 조회 결과에서 interestedConcertID가 있으면 route는 interestedConcert여야 한다")
    func testUserResultWithInterestConcertIDSetsInterestedConcertRoute() {
        let sut = HomeStore()
        let user = makeMockUser(interestConcertID: 123)

        sut.send(._fetchUserResult(.success(user)))

        #expect(sut.state.route == .interestedConcert)
    }
}

// MARK: - Helpers

private extension HomeStoreTests {
    func makeMockConcert(id: Int = 1) -> Concert {
        Concert(
            id: id,
            title: "테스트 콘서트",
            artist: "테스트 아티스트",
            status: .upcoming,
            daysLeft: 10,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400),
            posterURL: URL(string: "https://example.com/poster.jpg")!,
            venue: "테스트 공연장",
            ticketSite: "인터파크",
            ticketURL: URL(string: "https://ticket.example.com"),
            introduction: "테스트 소개",
            label: nil
        )
    }
    
    func makeMockUser(
        nickname: String = "테스트유저",
        hasPreferences: Bool = false,
        interestConcertID: Int? = nil
    ) -> User {
        User(
            id: 1,
            interestConcertID: interestConcertID,
            provider: "APPLE",
            providerID: "12345",
            email: "test@test.com",
            nickname: nickname,
            hasPreferences: hasPreferences,
            authority: UserAuthority(
                deviceNotification: true,
                marketingConsent: false
            )
        )
    }
    
    func makeMockSetlist(id: Int = 1) -> Setlist {
        Setlist(
            id: id,
            title: "테스트 셋리스트",
            imageURL: nil,
            type: .expected,
            status: nil,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400),
            venue: "테스트 공연장",
            artist: "테스트 아티스트"
        )
    }
    
    func makeMockSchedule(id: Int = 1) -> ConcertSchedule {
        ConcertSchedule(
            id: id,
            category: "티켓팅",
            scheduledAt: Date(),
            type: .ticketing
        )
    }
    
    func makeMockSong(id: Int = 1, orderIndex: Int = 1) -> SetlistSong {
        SetlistSong(
            id: id,
            title: "테스트 곡 \(orderIndex)",
            artist: "테스트 아티스트",
            orderIndex: orderIndex
        )
    }
    
    func makeMockSection(id: Int = 1) -> ConcertSection {
        ConcertSection(
            id: id,
            title: "인기 공연",
            concerts: [makeMockConcert()]
        )
    }
}
