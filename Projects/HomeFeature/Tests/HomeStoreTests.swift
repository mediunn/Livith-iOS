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

    // MARK: - onAppear 테스트

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

    // MARK: - Route 결정 테스트

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

    // MARK: - ConcertSection 상태 테스트

    @Test("concertSection onAppear 시 섹션/추천 데이터가 로드되어야 한다")
    func testConcertSectionOnAppearLoadsSectionsAndRecommendations() async throws {
        // Given
        let sut = HomeStore()
        let section = makeMockSection(id: 1)
        let recommended = [makeMockConcert(id: 10), makeMockConcert(id: 11)]
        let user = makeMockUser(hasPreferences: true)

        container.concertRepository.homeSectionListStub = [section]
        container.concertRepository.recommendedConcertListStub = recommended
        sut.send(._fetchUserResult(.success(user)))

        // When
        sut.send(.concertSection(.onAppear))

        // Then (immediate)
        #expect(sut.state.sections.isLoading)
        #expect(!sut.state.sections.isInitialLoad)

        // Then (after async)
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 1)
        #expect(sut.state.sections.sectionList.count == 1)
        #expect(sut.state.sections.sectionList.first?.id == section.id)
        #expect(sut.state.sections.recommendedConcertList.count == 2)
        #expect(!sut.state.sections.shouldShowPreferenceBanner)
        #expect(!sut.state.sections.isLoading)
    }

    @Test("concertSection onAppear 시 hasPreferences가 false면 추천을 조회하지 않고 배너를 표시해야 한다")
    func testConcertSectionOnAppearShowsPreferenceBannerWhenUserHasNoPreferences() async throws {
        // Given
        let sut = HomeStore()
        let section = makeMockSection(id: 2)
        let user = makeMockUser(hasPreferences: false)

        container.concertRepository.homeSectionListStub = [section]
        sut.send(._fetchUserResult(.success(user)))

        // When
        sut.send(.concertSection(.onAppear))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 0)
        #expect(sut.state.sections.sectionList.count == 1)
        #expect(sut.state.sections.shouldShowPreferenceBanner)
        #expect(sut.state.sections.recommendedConcertList.isEmpty)
    }

    // MARK: - InterestConcert 상태 테스트

    @Test("interestConcert onAppear 시 관심 공연과 상세 데이터를 로드해야 한다")
    func testInterestConcertOnAppearLoadsConcertAndDetailState() async throws {
        // Given
        let sut = HomeStore()
        let concert = makeMockConcert(id: 100)
        let schedule = makeMockSchedule(id: 200)
        let setlist = makeMockSetlist(id: 300)
        let songs = [makeMockSong(id: 400, orderIndex: 1), makeMockSong(id: 401, orderIndex: 2)]

        container.userRepository.interestedConcertStub = concert
        container.concertRepository.scheduleListStub = [schedule]
        container.concertRepository.mainSetlistStub = setlist
        container.setlistRepository.setlistSongsStub = songs

        // When
        sut.send(.interestConcert(.onAppear))
        try await Task.sleep(nanoseconds: 150_000_000)

        // Then
        #expect(container.userRepository.fetchInterestedConcertCallCount == 1)
        #expect(container.concertRepository.fetchConcertScheduleListCallCount == 1)
        #expect(container.concertRepository.fetchMainSetlistCallCount == 1)
        #expect(container.setlistRepository.fetchSetlistSongsCallCount == 1)
        #expect(sut.state.interestConcert.concert?.id == concert.id)
        #expect(sut.state.interestConcert.scheduleList.count == 1)
        #expect(sut.state.interestConcert.scheduleList.first?.id == schedule.id)
        #expect(sut.state.interestConcert.setlist?.id == setlist.id)
        #expect(sut.state.interestConcert.songList.count == 2)
    }

    @Test("interestConcert onRefresh 시 현재 concert가 없으면 관심 공연을 다시 조회해야 한다")
    func testInterestConcertOnRefreshWithoutConcertFetchesInterestedConcert() async throws {
        // Given
        let sut = HomeStore()
        container.userRepository.interestedConcertStub = nil

        // When
        sut.send(.interestConcert(.onRefresh))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(container.userRepository.fetchInterestedConcertCallCount == 1)
    }

    @Test("관심 공연 조회 결과가 nil이면 상세 상태를 초기화해야 한다")
    func testFetchUserInterestConcertResultNilClearsDetailState() {
        // Given
        let sut = HomeStore()
        sut.send(.interestConcert(._fetchScheduleListResult(.success([makeMockSchedule(id: 1)]))))
        sut.send(.interestConcert(._fetchMainSetlistResult(.success(makeMockSetlist(id: 2)))))
        sut.send(.interestConcert(._fetchSetlistSongListResult(.success([makeMockSong(id: 3)]))))

        // When
        sut.send(.interestConcert(._fetchUserInterestConcertResult(.success(nil))))

        // Then
        #expect(sut.state.interestConcert.concert == nil)
        #expect(sut.state.interestConcert.scheduleList.isEmpty)
        #expect(sut.state.interestConcert.setlist == nil)
        #expect(sut.state.interestConcert.songList.isEmpty)
    }

    @Test("관심 공연 삭제 성공 결과를 받으면 상태를 비우고 토스트를 표시해야 한다")
    func testDeleteInterestConcertResultSuccessClearsStateAndShowsToast() {
        // Given
        let sut = HomeStore()
        sut.send(.interestConcert(._fetchScheduleListResult(.success([makeMockSchedule(id: 10)]))))
        sut.send(.interestConcert(._fetchMainSetlistResult(.success(makeMockSetlist(id: 11)))))
        sut.send(.interestConcert(._fetchSetlistSongListResult(.success([makeMockSong(id: 12)]))))

        // When
        sut.send(.interestConcert(._deleteInterestConcertResult(.success(()))))

        // Then
        #expect(sut.state.interestConcert.concert == nil)
        #expect(sut.state.interestConcert.scheduleList.isEmpty)
        #expect(sut.state.interestConcert.setlist == nil)
        #expect(sut.state.interestConcert.songList.isEmpty)
        #expect(sut.state.toastMessage == "관심 공연을 삭제했어요")
    }

    // MARK: - Toast 상태 테스트

    @Test("onToastDisappear 호출 시 toastMessage는 비워져야 한다")
    func testOnToastDisappearClearsToastMessage() {
        // Given
        let sut = HomeStore()
        sut.send(.interestConcert(._deleteInterestConcertResult(.success(()))))
        #expect(!sut.state.toastMessage.isEmpty)

        // When
        sut.send(.onToastDisappear)

        // Then
        #expect(sut.state.toastMessage.isEmpty)
    }

    @Test("onErrorToastDisappear 호출 시 errorMessage는 비워져야 한다")
    func testOnErrorToastDisappearClearsErrorMessage() {
        // Given
        let sut = HomeStore()
        sut.send(._fetchUserResult(.failure(UserError.serverError)))
        #expect(!sut.state.errorMessage.isEmpty)

        // When
        sut.send(.onErrorToastDisappear)

        // Then
        #expect(sut.state.errorMessage.isEmpty)
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
