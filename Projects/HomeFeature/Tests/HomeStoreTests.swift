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
    
    @Test("초기 상태에서 userName은 빈 문자열이어야 한다")
    func testInitialUserNameState() {
        let sut = HomeStore()
        #expect(sut.state.userName == "")
    }
    
    @Test("초기 상태에서 interestConcert는 nil이어야 한다")
    func testInitialInterestConcertState() {
        let sut = HomeStore()
        #expect(sut.state.interestConcert.concert == nil)
    }
    
    @Test("초기 상태에서 scheduleList는 비어있어야 한다")
    func testInitialScheduleListState() {
        let sut = HomeStore()
        #expect(sut.state.interestConcert.scheduleList.isEmpty)
    }
    
    @Test("초기 상태에서 shouldShowPreferenceBanner는 false이어야 한다")
    func testInitialPreferenceBannerState() {
        let sut = HomeStore()
        #expect(sut.state.sections.shouldShowPreferenceBanner == false)
    }
    
    @Test("초기 상태에서 recommendedConcerts는 비어있어야 한다")
    func testInitialRecommendedConcertsState() {
        let sut = HomeStore()
        #expect(sut.state.sections.recommendedConcerts.isEmpty)
    }
    
    // MARK: - onAppear 테스트
    
    @Test("onAppear 시 사용자 정보가 로드되어야 한다")
    func testOnAppearLoadsUser() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestedConcertStub = nil
        
        let sut = HomeStore()
        
        // When
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(sut.state.userName == "홍길동")
    }
    
    @Test("onAppear 시 관심 공연이 있으면 스케줄과 셋리스트가 로드되어야 한다")
    func testOnAppearLoadsInterestConcertWithDetails() async throws {
        // Given
        let concert = makeMockConcert()
        container.userRepository.userStub = makeMockUser()
        container.userRepository.interestedConcertStub = concert
        container.concertRepository.scheduleListStub = [makeMockSchedule()]
        container.concertRepository.mainSetlistStub = makeMockSetlist()
        container.setlistRepository.setlistSongsStub = [makeMockSong()]
        
        let sut = HomeStore()
        
        // When
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 150_000_000)
        
        // Then
        #expect(sut.state.interestConcert.concert?.id == concert.id)
        #expect(!sut.state.interestConcert.scheduleList.isEmpty)
        #expect(sut.state.interestConcert.setlist != nil)
        #expect(!sut.state.interestConcert.songList.isEmpty)
    }
    
    @Test("onAppear 사용자 정보 로드 실패 시 에러 메시지가 설정되어야 한다")
    func testOnAppearUserLoadFailure() async throws {
        // Given
        container.userRepository.errorStub = .serverError
        
        let sut = HomeStore()
        
        // When
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(container.userRepository.fetchUserCallCount > 0)
        #expect(!sut.state.errorMessage.isEmpty)
    }
    
    // MARK: - 토스트 관리 테스트
    
    @Test("onErrorToastDisappear 시 에러 메시지가 초기화되어야 한다")
    func testOnErrorToastDisappear() async throws {
        // Given
        container.userRepository.errorStub = .serverError
        let sut = HomeStore()
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Precondition
        #expect(!sut.state.errorMessage.isEmpty)
        
        // When
        sut.send(.onErrorToastDisappear)
        
        // Then
        #expect(sut.state.errorMessage.isEmpty)
    }
    
    @Test("onToastDisappear 시 토스트 메시지가 초기화되어야 한다")
    func testOnToastDisappear() async throws {
        // Given
        container.userRepository.userStub = makeMockUser()
        container.userRepository.interestedConcertStub = makeMockConcert()
        
        let sut = HomeStore()
        sut.send(.interestConcert(.onDelete))
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Precondition
        #expect(!sut.state.toastMessage.isEmpty)
        
        // When
        sut.send(.onToastDisappear)
        
        // Then
        #expect(sut.state.toastMessage.isEmpty)
    }
    
    // MARK: - 관심 공연 삭제 테스트
    
    @Test("onDelete 성공 시 관심 공연이 삭제되고 토스트가 표시되어야 한다")
    func testOnDeleteSuccess() async throws {
        // Given
        container.userRepository.userStub = makeMockUser()
        container.userRepository.interestedConcertStub = makeMockConcert()
        
        let concert = makeMockConcert()
        let schedule = makeMockSchedule()
        let setlist = makeMockSetlist()
        let song = makeMockSong()
        
        let sut = HomeStore()
        sut.send(.interestConcert(._fetchUserInterestConcertResult(.success(concert))))
        sut.send(.interestConcert(._fetchScheduleListResult(.success([schedule]))))
        sut.send(.interestConcert(._fetchMainSetlistResult(.success(setlist))))
        sut.send(.interestConcert(._fetchSetlistSongListResult(.success([song]))))
        
        // Precondition
        #expect(sut.state.interestConcert.concert != nil)
        #expect(!sut.state.interestConcert.scheduleList.isEmpty)
        #expect(sut.state.interestConcert.setlist != nil)
        #expect(!sut.state.interestConcert.songList.isEmpty)
        
        // When
        sut.send(.interestConcert(.onDelete))
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(sut.state.interestConcert.concert == nil)
        #expect(sut.state.interestConcert.scheduleList.isEmpty)
        #expect(sut.state.interestConcert.setlist == nil)
        #expect(sut.state.interestConcert.songList.isEmpty)
        #expect(sut.state.toastMessage == "관심 공연을 삭제했어요")
    }
    
    @Test("onDelete 실패 시 에러 메시지가 설정되어야 한다")
    func testOnDeleteFailure() async throws {
        // Given
        container.userRepository.errorStub = .serverError
        
        let sut = HomeStore()
        
        // When
        sut.send(.interestConcert(.onDelete))
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(!sut.state.errorMessage.isEmpty)
    }
    
    // MARK: - 관심 공연 새로고침 테스트
    
    @Test("관심 공연이 있을 때 onRefreshInterestConcert 시 스케줄과 셋리스트가 새로고침되어야 한다")
    func testOnRefreshInterestConcertWithExistingConcert() async throws {
        // Given
        let concert = makeMockConcert()
        container.userRepository.userStub = makeMockUser()
        container.userRepository.interestedConcertStub = concert
        container.concertRepository.scheduleListStub = [makeMockSchedule()]
        container.concertRepository.mainSetlistStub = makeMockSetlist()
        container.setlistRepository.setlistSongsStub = [makeMockSong()]
        
        let sut = HomeStore()
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 150_000_000)
        
        // Reset call counts
        container.concertRepository.fetchConcertScheduleListCallCount = 0
        container.concertRepository.fetchMainSetlistCallCount = 0
        
        // When
        sut.send(.interestConcert(.onRefresh))
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(container.concertRepository.fetchConcertScheduleListCallCount > 0)
        #expect(container.concertRepository.fetchMainSetlistCallCount > 0)
    }
    
    @Test("관심 공연이 없을 때 onRefreshInterestConcert 시 관심 공연을 다시 로드해야 한다")
    func testOnRefreshInterestConcertWithNoConcert() async throws {
        // Given
        container.userRepository.userStub = makeMockUser()
        container.userRepository.interestedConcertStub = nil
        
        let sut = HomeStore()
        
        // Reset call count
        container.userRepository.fetchInterestedConcertCallCount = 0
        
        // When
        sut.send(.interestConcert(.onRefresh))
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(container.userRepository.fetchInterestedConcertCallCount > 0)
    }
    
    // MARK: - 섹션 새로고침 테스트
    
    @Test("onRefreshSections 시 isSectionsLoading이 true가 되어야 한다")
    func testOnRefreshSectionsLoading() async throws {
        // Given
        container.userRepository.userStub = makeMockUser()
        container.concertRepository.homeSectionListStub = [makeMockSection()]
        
        let sut = HomeStore()
        
        // When
        sut.send(.concertSection(.onRefreshSections))
        
        // Then - 즉시 체크
        #expect(sut.state.sections.isLoading == true)
    }
    
    @Test("섹션 로드 성공 시 sectionList가 업데이트되고 로딩이 false가 되어야 한다")
    func testOnRefreshSectionsSuccess() async throws {
        // Given
        container.userRepository.userStub = makeMockUser()
        container.concertRepository.homeSectionListStub = [makeMockSection()]
        
        let sut = HomeStore()
        try await Task.sleep(nanoseconds: 100_000_000)
        container.concertRepository.fetchHomeConcertSectionListCallCount = 0
        
        // When
        sut.send(.concertSection(.onRefreshSections))
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount > 0)
        #expect(!sut.state.sections.sectionList.isEmpty)
        #expect(sut.state.sections.isLoading == false)
    }
    
    // MARK: - Preference 배너 테스트
    
    @Test("선호 장르가 비어있으면 배너를 표시해야 한다")
    func testShowPreferenceBannerWhenGenreListEmpty() async throws {
        // Given
        container.userRepository.userStub = makeMockUser()
        container.preferenceRepository.preferredGenreListStub = []
        
        let sut = HomeStore()
        
        // When
        sut.send(.concertSection(.checkShowBanner))
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(sut.state.sections.shouldShowPreferenceBanner == true)
    }
    
    @Test("선호 장르가 있으면 배너를 표시하지 않아야 한다")
    func testHidePreferenceBannerWhenGenreListNotEmpty() async throws {
        // Given
        let mockGenre = PreferredGenre(id: 1, name: "팝", imageURL: nil)
        container.userRepository.userStub = makeMockUser()
        container.preferenceRepository.preferredGenreListStub = [mockGenre]
        
        let sut = HomeStore()
        
        // When
        sut.send(.concertSection(.checkShowBanner))
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(sut.state.sections.shouldShowPreferenceBanner == false)
    }
    
    @Test("선호 장르 로드 실패 시 배너를 표시하지 않아야 한다")
    func testHidePreferenceBannerWhenFetchFails() async throws {
        // Given
        container.userRepository.userStub = makeMockUser()
        container.preferenceRepository.errorStub = PreferenceError.invalidResponse
        
        let sut = HomeStore()
        
        // When
        sut.send(.concertSection(.checkShowBanner))
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(sut.state.sections.shouldShowPreferenceBanner == false)
    }
    
    @Test("onAppear 시 선호 배너 체크가 자동으로 수행되어야 한다")
    func testCheckShowBannerOnAppear() async throws {
        // Given
        container.userRepository.userStub = makeMockUser()
        container.userRepository.interestedConcertStub = nil
        container.preferenceRepository.preferredGenreListStub = []
        container.concertRepository.homeSectionListStub = []
        
        let sut = HomeStore()
        
        // Reset call count
        container.preferenceRepository.fetchUserPreferredGenreListCallCount = 0
        
        // When
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(container.preferenceRepository.fetchUserPreferredGenreListCallCount > 0)
        #expect(sut.state.sections.shouldShowPreferenceBanner == true)
    }
    
    // MARK: - 추천 콘서트 테스트
    
    @Test("선호 장르가 있을 때 추천 콘서트가 로드되어야 한다")
    func testFetchRecommendedConcertWhenGenreExists() async throws {
        // Given
        let mockGenre = PreferredGenre(id: 1, name: "팝", imageURL: nil)
        let mockRecommendedConcerts = [makeMockConcert(id: 1), makeMockConcert(id: 2)]
        
        container.userRepository.userStub = makeMockUser()
        container.preferenceRepository.preferredGenreListStub = [mockGenre]
        container.concertRepository.recommendedConcertListStub = mockRecommendedConcerts
        
        let sut = HomeStore()
        
        // When
        sut.send(.concertSection(.checkShowBanner))
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount > 0)
        #expect(!sut.state.sections.recommendedConcerts.isEmpty)
        #expect(sut.state.sections.recommendedConcerts.count == 2)
    }
    
    @Test("선호 장르가 없을 때 추천 콘서트가 로드되지 않아야 한다")
    func testFetchRecommendedConcertWhenGenreNotExists() async throws {
        // Given
        container.userRepository.userStub = makeMockUser()
        container.preferenceRepository.preferredGenreListStub = []
        container.concertRepository.recommendedConcertListStub = []
        
        let sut = HomeStore()
        
        // Reset call count
        container.concertRepository.fetchRecommendedConcertListCallCount = 0
        
        // When
        sut.send(.concertSection(.checkShowBanner))
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 0)
        #expect(sut.state.sections.recommendedConcerts.isEmpty)
    }
    
    @Test("추천 콘서트 로드 실패 시 에러가 설정되어야 한다")
    func testFetchRecommendedConcertFailure() async throws {
        // Given
        let mockGenre = PreferredGenre(id: 1, name: "팝", imageURL: nil)
        
        container.userRepository.userStub = makeMockUser()
        container.preferenceRepository.preferredGenreListStub = [mockGenre]
        container.concertRepository.errorStub = ConcertError.serverError
        
        let sut = HomeStore()
        
        // When
        sut.send(.concertSection(.checkShowBanner))
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(sut.state.sections.recommendedConcerts.isEmpty)
        #expect(!sut.state.errorMessage.isEmpty)
    }
    
    // MARK: - 연쇄 호출 테스트
    
    @Test("관심 공연이 nil로 변경될 때 스케줄, 셋리스트, 곡 목록이 비워져야 한다")
    func testInterestConcertNilClearsRelatedData() async throws {
        // Given
        let concert = makeMockConcert()
        container.userRepository.userStub = makeMockUser()
        container.userRepository.interestedConcertStub = concert
        container.concertRepository.scheduleListStub = [makeMockSchedule()]
        container.concertRepository.mainSetlistStub = makeMockSetlist()
        container.setlistRepository.setlistSongsStub = [makeMockSong()]
        
        let sut = HomeStore()
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 150_000_000)
        
        // Precondition
        #expect(!sut.state.interestConcert.scheduleList.isEmpty)
        
        // When - 관심 공연을 nil로 받음
        sut.send(.interestConcert(._fetchUserInterestConcertResult(.success(nil))))
        
        // Then
        #expect(sut.state.interestConcert.concert == nil)
        #expect(sut.state.interestConcert.scheduleList.isEmpty)
        #expect(sut.state.interestConcert.setlist == nil)
        #expect(sut.state.interestConcert.songList.isEmpty)
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
    
    func makeMockUser(nickname: String = "테스트유저") -> User {
        User(
            id: 1,
            interestConcertID: nil,
            provider: "APPLE",
            providerID: "12345",
            email: "test@test.com",
            nickname: nickname,
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
