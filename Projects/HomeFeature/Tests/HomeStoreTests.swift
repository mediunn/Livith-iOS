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
        #expect(sut.state.interestConcert == nil)
    }
    
    @Test("초기 상태에서 scheduleList는 비어있어야 한다")
    func testInitialScheduleListState() {
        let sut = HomeStore()
        #expect(sut.state.scheduleList.isEmpty)
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
        #expect(sut.state.interestConcert?.id == concert.id)
        #expect(!sut.state.scheduleList.isEmpty)
        #expect(sut.state.setlist != nil)
        #expect(!sut.state.songList.isEmpty)
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
        sut.send(.onDelete)
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
        
        let sut = HomeStore()
        
        // When
        sut.send(.onDelete)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(sut.state.interestConcert == nil)
        #expect(sut.state.scheduleList.isEmpty)
        #expect(sut.state.setlist == nil)
        #expect(sut.state.songList.isEmpty)
        #expect(sut.state.toastMessage == "관심 공연을 삭제했어요")
    }
    
    @Test("onDelete 실패 시 에러 메시지가 설정되어야 한다")
    func testOnDeleteFailure() async throws {
        // Given
        container.userRepository.errorStub = .serverError
        
        let sut = HomeStore()
        
        // When
        sut.send(.onDelete)
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
        sut.send(.onRefreshInterestConcert)
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
        sut.send(.onRefreshInterestConcert)
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
        sut.send(.onRefreshSections)
        
        // Then - 즉시 체크
        #expect(sut.state.isSectionsLoading == true)
    }
    
    @Test("섹션 로드 성공 시 sectionList가 업데이트되고 로딩이 false가 되어야 한다")
    func testOnRefreshSectionsSuccess() async throws {
        // Given
        container.userRepository.userStub = makeMockUser()
        container.concertRepository.homeSectionListStub = [makeMockSection()]
        
        let sut = HomeStore()
        
        // When
        sut.send(.onRefreshSections)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(!sut.state.sectionList.isEmpty)
        #expect(sut.state.isSectionsLoading == false)
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
        #expect(!sut.state.scheduleList.isEmpty)
        
        // When - 관심 공연을 nil로 받음
        sut.send(._fetchUserInterestConcertResult(.success(nil)))
        
        // Then
        #expect(sut.state.interestConcert == nil)
        #expect(sut.state.scheduleList.isEmpty)
        #expect(sut.state.setlist == nil)
        #expect(sut.state.songList.isEmpty)
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
