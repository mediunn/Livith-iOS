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

    @Test("onAppear 시 유저/알림 조회 후 route에 필요한 데이터를 이어서 로드해야 한다")
    func testOnAppearFetchesUserAndUnreadNotificationCount() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.notificationRepository.unreadNotificationCountStub = 3
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        
        let sut = HomeStore()
        
        // When
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 150_000_000)
        
        // Then
        #expect(container.userRepository.fetchUserCallCount == 1)
        #expect(container.notificationRepository.fetchUnreadNotificationCountCallCount == 1)
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 0)
        #expect(sut.state.user?.nickname == "홍길동")
        #expect(sut.state.hasNewNotice)
        #expect(sut.state.currentContent == .concertSection)
        #expect(sut.state.concertSection.sectionList.count == 1)
    }

    // MARK: - Route 결정 테스트

    @Test("유저 조회 결과에서 interestedConcertID가 nil이면 concertSection 콘텐츠를 설정하고 데이터를 로드해야 한다")
    func testUserResultWithNilInterestConcertIDSetsConcertSectionContent() async throws {
        let sut = HomeStore()
        let user = makeMockUser(hasPreferences: true, interestConcertID: nil)
        let section = makeMockSection(id: 5)
        let recommended = [makeMockConcert(id: 21)]

        container.concertRepository.homeSectionListStub = [section]
        container.concertRepository.recommendedConcertListStub = recommended

        sut.send(._fetchUserResult(.success(user)))
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.state.currentContent == .concertSection)
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 1)
        #expect(sut.state.concertSection.sectionList.first?.id == section.id)
        #expect(sut.state.concertSection.recommendedConcertList.first?.id == recommended.first?.id)
    }

    @Test("같은 홈 콘텐츠의 유저 조회 결과가 다시 들어와도 초기 로딩은 한 번만 수행되어야 한다")
    func testUserResultDoesNotResetInitialLoadForSameContent() async throws {
        let sut = HomeStore()
        let user = makeMockUser(hasPreferences: true, interestConcertID: nil)

        container.concertRepository.homeSectionListStub = [makeMockSection(id: 10)]
        container.concertRepository.recommendedConcertListStub = [makeMockConcert(id: 100)]

        sut.send(._fetchUserResult(.success(user)))
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.send(._fetchUserResult(.success(user)))
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 1)
    }

    @Test("유저 조회 결과로 홈 콘텐츠가 바뀌면 해당 콘텐츠 데이터를 다시 로드해야 한다")
    func testUserResultReloadsWhenContentChanges() async throws {
        let sut = HomeStore()
        let concertSectionUser = makeMockUser(hasPreferences: true, interestConcertID: nil)
        let interestConcertUser = makeMockUser(interestConcertID: 123)
        let concert = makeMockConcert(id: 100)
        let schedule = makeMockSchedule(id: 200)
        let setlist = makeMockSetlist(id: 300)
        let songs = [makeMockSong(id: 400, orderIndex: 1)]

        container.concertRepository.homeSectionListStub = [makeMockSection(id: 10)]
        container.concertRepository.recommendedConcertListStub = [makeMockConcert(id: 100)]
        container.userRepository.interestedConcertStub = concert
        container.concertRepository.scheduleListStub = [schedule]
        container.concertRepository.mainSetlistStub = setlist
        container.setlistRepository.setlistSongsStub = songs

        sut.send(._fetchUserResult(.success(concertSectionUser)))
        try await Task.sleep(nanoseconds: 100_000_000)

        sut.send(._fetchUserResult(.success(interestConcertUser)))
        try await Task.sleep(nanoseconds: 150_000_000)

        sut.send(._fetchUserResult(.success(concertSectionUser)))
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 2)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 2)
        #expect(container.userRepository.fetchInterestedConcertCallCount == 1)
        #expect(sut.state.currentContent == .concertSection)
    }

    @Test("유저 조회 결과에서 interestedConcertID가 있으면 interestConcert 콘텐츠를 설정하고 데이터를 로드해야 한다")
    func testUserResultWithInterestConcertIDSetsInterestConcertContent() async throws {
        let sut = HomeStore()
        let user = makeMockUser(interestConcertID: 123)
        let concert = makeMockConcert(id: 100)
        let schedule = makeMockSchedule(id: 200)
        let setlist = makeMockSetlist(id: 300)
        let songs = [makeMockSong(id: 400, orderIndex: 1), makeMockSong(id: 401, orderIndex: 2)]

        container.userRepository.interestedConcertStub = concert
        container.concertRepository.scheduleListStub = [schedule]
        container.concertRepository.mainSetlistStub = setlist
        container.setlistRepository.setlistSongsStub = songs

        sut.send(._fetchUserResult(.success(user)))
        try await Task.sleep(nanoseconds: 150_000_000)

        #expect(sut.state.currentContent == .interestConcert)
        #expect(container.userRepository.fetchInterestedConcertCallCount == 1)
        #expect(container.concertRepository.fetchConcertScheduleListCallCount == 1)
        #expect(container.concertRepository.fetchMainSetlistCallCount == 1)
        #expect(container.setlistRepository.fetchSetlistSongsCallCount == 1)
        #expect(sut.state.interestConcert.concert?.id == concert.id)
    }

    // MARK: - ConcertSection 상태 테스트

    @Test("concertSection 콘텐츠가 결정되고 hasPreferences가 false면 추천 없이 배너를 표시해야 한다")
    func testConcertSectionContentShowsPreferenceBannerWhenUserHasNoPreferences() async throws {
        // Given
        let sut = HomeStore()
        let section = makeMockSection(id: 2)
        let user = makeMockUser(hasPreferences: false)

        container.concertRepository.homeSectionListStub = [section]

        // When
        sut.send(._fetchUserResult(.success(user)))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 0)
        #expect(sut.state.concertSection.sectionList.count == 1)
        #expect(sut.state.concertSection.shouldShowPreferenceBanner)
        #expect(sut.state.concertSection.recommendedConcertList.isEmpty)
    }

    // MARK: - InterestConcert 상태 테스트

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
