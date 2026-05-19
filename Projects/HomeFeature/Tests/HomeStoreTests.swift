//
//  HomeStoreTests.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 2/5/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

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

    @Test("초기 상태에서 관심 콘서트 정렬은 예매일이어야 한다")
    func testInitialInterestConcertSortIsTicketing() {
        let sut = HomeStore()
        #expect(sut.state.interestConcertSort == .ticketing)
    }

    // MARK: - onAppear 테스트

    @Test("onAppear 시 유저와 관심 콘서트 목록과 알림 수를 함께 조회한 뒤 홈 콘서트 섹션 데이터를 로드해야 한다")
    func testOnAppearFetchesInitialHomeDataTogether() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.notificationRepository.unreadNotificationCountStub = 3
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        
        let sut = HomeStore()
        
        // When
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 150_000_000)
        
        // Then
        #expect(container.userRepository.fetchUserCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListFilter?.sort == .ticketing)
        #expect(container.userRepository.fetchInterestedConcertListFilter?.limit == 5)
        #expect(container.notificationRepository.fetchUnreadNotificationCountCallCount == 1)
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 0)
        #expect(sut.state.user?.nickname == "홍길동")
        #expect(sut.state.interestConcertList.map(\.id) == [123])
        #expect(sut.state.hasNewNotice)
        #expect(sut.state.concertSectionList.count == 1)
    }

    @Test("onAppear 시 관심 콘서트 목록 조회 실패는 홈 초기 데이터 실패로 전파하지 않아야 한다")
    func testOnAppearInterestConcertListFailureDoesNotFailHomeInitialData() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.fetchInterestedConcertListErrorStub = .serverError
        container.notificationRepository.unreadNotificationCountStub = 3
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]

        let sut = HomeStore()

        // When
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 150_000_000)

        // Then
        #expect(container.userRepository.fetchUserCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
        #expect(sut.state.user?.nickname == "홍길동")
        #expect(sut.state.interestConcertList.isEmpty)
        #expect(sut.state.hasNewNotice)
        #expect(sut.state.errorMessage.isEmpty)
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
    }

    @Test("onAppear 시 알림 수 조회 실패는 홈 초기 데이터 실패로 전파하지 않아야 한다")
    func testOnAppearNotificationCountFailureDoesNotFailHomeInitialData() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.notificationRepository.errorStub = .serverError
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]

        let sut = HomeStore()

        // When
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 150_000_000)

        // Then
        #expect(container.userRepository.fetchUserCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
        #expect(container.notificationRepository.fetchUnreadNotificationCountCallCount == 1)
        #expect(sut.state.user?.nickname == "홍길동")
        #expect(sut.state.interestConcertList.map(\.id) == [123])
        #expect(!sut.state.hasNewNotice)
        #expect(sut.state.errorMessage.isEmpty)
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
    }

    @Test("onAppear 시 유저 조회 실패만 홈 초기 데이터 실패로 전파해야 한다")
    func testOnAppearUserFailureFailsHomeInitialData() async throws {
        // Given
        container.userRepository.fetchUserErrorStub = .serverError
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.notificationRepository.unreadNotificationCountStub = 3

        let sut = HomeStore()

        // When
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 150_000_000)

        // Then
        #expect(container.userRepository.fetchUserCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
        #expect(container.notificationRepository.fetchUnreadNotificationCountCallCount == 1)
        #expect(sut.state.user == nil)
        #expect(sut.state.interestConcertList.isEmpty)
        #expect(!sut.state.hasNewNotice)
        #expect(!sut.state.errorMessage.isEmpty)
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 0)
    }

    // MARK: - InterestConcertToast 테스트

    @Test("onAppear 시 관심 콘서트 토스트 노출이 필요하면 성공 메시지를 설정하고 노출 처리해야 한다")
    func testOnAppearShowsInterestConcertToastAndMarksShownWhenNeeded() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.userRepository.interestConcertCleanupPolicyStub = .completed
        container.notificationRepository.unreadNotificationCountStub = 3
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]

        let sut = HomeStore()

        // When
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then
        #expect(container.userRepository.fetchInterestConcertCleanupPolicyCallCount == 1)
        #expect(sut.state.interestConcertToastMessage == "종료된 공연이 자동 정리됐어요")
        #expect(container.userRepository.markInterestConcertToastShownCallCount == 1)
    }

    @Test("관심 콘서트 정리 정책별 성공 메시지를 설정해야 한다")
    func testInterestConcertCleanupPolicySetsMessage() async throws {
        // Given
        let sut = HomeStore()

        // When & Then
        sut.send(._fetchInterestConcertToastResult(.success(.canceled)))
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(sut.state.interestConcertToastMessage == "취소된 공연이 자동 정리됐어요")

        sut.send(.onInterestConcertToastDisappear)
        sut.send(._fetchInterestConcertToastResult(.success(.completed)))
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(sut.state.interestConcertToastMessage == "종료된 공연이 자동 정리됐어요")

        sut.send(.onInterestConcertToastDisappear)
        sut.send(._fetchInterestConcertToastResult(.success(.both)))
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(sut.state.interestConcertToastMessage == "취소·종료된 공연이 자동 정리됐어요")
    }

    @Test("onAppear 시 관심 콘서트 토스트 노출이 필요하지 않으면 성공 메시지와 노출 처리를 생략해야 한다")
    func testOnAppearSkipsInterestConcertToastWhenNotNeeded() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestConcertCleanupPolicyStub = .none
        container.notificationRepository.unreadNotificationCountStub = 3
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]

        let sut = HomeStore()

        // When
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then
        #expect(container.userRepository.fetchInterestConcertCleanupPolicyCallCount == 1)
        #expect(sut.state.interestConcertToastMessage.isEmpty)
        #expect(container.userRepository.markInterestConcertToastShownCallCount == 0)
    }

    @Test("홈 섹션 데이터 반영 전에는 관심 콘서트 토스트를 조회하지 않아야 한다")
    func testInterestConcertToastIsFetchedAfterHomeSectionDataIsLoaded() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.userRepository.interestConcertCleanupPolicyStub = .completed
        container.notificationRepository.unreadNotificationCountStub = 3
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        container.concertRepository.fetchHomeConcertSectionListDelay = 300_000_000

        let sut = HomeStore()

        // When
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(sut.state.concertSectionList.isEmpty)
        #expect(container.userRepository.fetchInterestConcertCleanupPolicyCallCount == 0)
        #expect(sut.state.interestConcertToastMessage.isEmpty)
        #expect(container.userRepository.markInterestConcertToastShownCallCount == 0)

        try await Task.sleep(nanoseconds: 300_000_000)

        #expect(sut.state.concertSectionList.count == 1)
        #expect(container.userRepository.fetchInterestConcertCleanupPolicyCallCount == 1)
        #expect(sut.state.interestConcertToastMessage == "종료된 공연이 자동 정리됐어요")
        #expect(container.userRepository.markInterestConcertToastShownCallCount == 1)
    }

    @Test("홈 섹션 데이터 조회가 실패하면 관심 콘서트 토스트를 조회하지 않아야 한다")
    func testInterestConcertToastIsNotFetchedWhenHomeSectionDataFails() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.userRepository.interestConcertCleanupPolicyStub = .completed
        container.notificationRepository.unreadNotificationCountStub = 3
        container.concertRepository.errorStub = .serverError

        let sut = HomeStore()

        // When
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then
        #expect(!sut.state.errorMessage.isEmpty)
        #expect(container.userRepository.fetchInterestConcertCleanupPolicyCallCount == 0)
        #expect(sut.state.interestConcertToastMessage.isEmpty)
        #expect(container.userRepository.markInterestConcertToastShownCallCount == 0)
    }

    @Test("관심 콘서트 토스트 조회 실패는 홈 초기 로딩과 오류 메시지로 전파하지 않아야 한다")
    func testInterestConcertToastFetchFailureDoesNotFailInitialHomeData() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.fetchInterestConcertToastErrorStub = .serverError
        container.notificationRepository.unreadNotificationCountStub = 3
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]

        let sut = HomeStore()

        // When
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then
        #expect(sut.state.user?.nickname == "홍길동")
        #expect(sut.state.errorMessage.isEmpty)
        #expect(sut.state.interestConcertToastMessage.isEmpty)
        #expect(container.userRepository.markInterestConcertToastShownCallCount == 0)
    }

    @Test("오류 메시지가 있으면 관심 콘서트 성공 토스트를 폐기하고 노출 처리하지 않아야 한다")
    func testInterestConcertToastResultIsDiscardedWhenErrorMessageExists() async throws {
        // Given
        let sut = HomeStore()
        sut.send(._fetchUserResult(.failure(UserError.serverError)))
        #expect(!sut.state.errorMessage.isEmpty)

        // When
        sut.send(._fetchInterestConcertToastResult(.success(.completed)))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(sut.state.interestConcertToastMessage.isEmpty)
        #expect(container.userRepository.markInterestConcertToastShownCallCount == 0)
    }

    @Test("오류가 발생하면 대기 중인 관심 콘서트 성공 토스트를 비워야 한다")
    func testErrorClearsPendingInterestConcertToastMessage() async throws {
        // Given
        let sut = HomeStore()
        sut.send(._fetchInterestConcertToastResult(.success(.completed)))
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(!sut.state.interestConcertToastMessage.isEmpty)

        // When
        sut.send(._fetchInterestConcertListResult(.failure(UserError.serverError)))

        // Then
        #expect(!sut.state.errorMessage.isEmpty)
        #expect(sut.state.interestConcertToastMessage.isEmpty)
    }

    @Test("관심 콘서트 토스트 노출 처리 실패는 오류 메시지로 노출하지 않아야 한다")
    func testInterestConcertToastMarkFailureDoesNotSetErrorMessage() async throws {
        // Given
        container.userRepository.markInterestConcertToastShownErrorStub = .serverError
        let sut = HomeStore()

        // When
        sut.send(._fetchInterestConcertToastResult(.success(.completed)))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(sut.state.interestConcertToastMessage == "종료된 공연이 자동 정리됐어요")
        #expect(sut.state.errorMessage.isEmpty)
        #expect(container.userRepository.markInterestConcertToastShownCallCount == 1)
    }

    @Test("관심 콘서트 성공 토스트 dismiss 호출 시 메시지는 비워져야 한다")
    func testOnInterestConcertToastDisappearClearsMessage() async throws {
        // Given
        let sut = HomeStore()
        sut.send(._fetchInterestConcertToastResult(.success(.completed)))
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(!sut.state.interestConcertToastMessage.isEmpty)

        // When
        sut.send(.onInterestConcertToastDisappear)

        // Then
        #expect(sut.state.interestConcertToastMessage.isEmpty)
    }

    // MARK: - Home Layout Load 테스트

    @Test("유저 조회 결과가 들어오면 관심 콘서트를 다시 조회하지 않고 홈 콘서트 섹션 데이터를 로드해야 한다")
    func testUserResultLoadsHomeConcertSectionWithoutFetchingInterestConcertList() async throws {
        let sut = HomeStore()
        let user = makeMockUser(hasPreferences: true)
        let section = makeMockSection(id: 5)
        let recommended = [makeMockConcert(id: 21)]

        container.concertRepository.homeSectionListStub = [section]
        container.concertRepository.recommendedConcertListStub = recommended

        sut.send(._fetchUserResult(.success(user)))
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(container.userRepository.fetchInterestedConcertListCallCount == 0)
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 1)
        #expect(sut.state.concertSectionList.first?.id == section.id)
        #expect(sut.state.recommendedConcertList.first?.id == recommended.first?.id)
    }

    @Test("유저 조회 결과가 있어도 기존 관심 콘서트 상세 API를 호출하지 않아야 한다")
    func testUserResultDoesNotFetchLegacyInterestConcertDetail() async throws {
        let sut = HomeStore()
        let user = makeMockUser(hasPreferences: true)
        let section = makeMockSection(id: 6)
        let recommended = [makeMockConcert(id: 22)]

        container.concertRepository.homeSectionListStub = [section]
        container.concertRepository.recommendedConcertListStub = recommended

        sut.send(._fetchUserResult(.success(user)))
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 0)
        #expect(container.concertRepository.fetchConcertScheduleListCallCount == 0)
        #expect(container.concertRepository.fetchMainSetlistCallCount == 0)
        #expect(container.setlistRepository.fetchSetlistSongsCallCount == 0)
        #expect(sut.state.concertSectionList.first?.id == section.id)
        #expect(sut.state.recommendedConcertList.first?.id == recommended.first?.id)
    }

    @Test("관심 콘서트 목록 조회 실패 결과가 들어오면 기존 관심 콘서트 목록을 유지하고 errorMessage를 설정해야 한다")
    func testInterestConcertListFailureKeepsInterestConcertListAndSetsErrorMessage() {
        let sut = HomeStore()

        sut.send(._fetchInterestConcertListResult(.success(makeInterestConcertList(concertIDList: [123]))))
        sut.send(._fetchInterestConcertListResult(.failure(UserError.serverError)))

        #expect(sut.state.interestConcertList.map(\.id) == [123])
        #expect(!sut.state.errorMessage.isEmpty)
    }

    @Test("관심 콘서트 정렬을 선택하면 홈 섹션 조회 조건으로 목록을 다시 조회해야 한다")
    func testInterestConcertSortSelectedRefetchesInterestConcertList() async throws {
        // Given
        let sut = HomeStore()
        sut.send(._fetchInterestConcertListResult(.success(makeInterestConcertList(concertIDList: [123]))))
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [456])

        // When
        sut.send(.interestConcertSortSelected(.concert))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(sut.state.interestConcertSort == .concert)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListFilter?.sort == .concert)
        #expect(container.userRepository.fetchInterestedConcertListFilter?.limit == 5)
        #expect(sut.state.interestConcertList.map(\.id) == [456])
        #expect(sut.state.errorMessage.isEmpty)
    }

    @Test("관심 콘서트 정렬 조회가 실패하면 기존 목록을 유지하고 errorMessage를 설정해야 한다")
    func testInterestConcertSortFetchFailureKeepsExistingListAndSetsErrorMessage() async throws {
        // Given
        let sut = HomeStore()
        sut.send(._fetchInterestConcertListResult(.success(makeInterestConcertList(concertIDList: [123]))))
        container.userRepository.fetchInterestedConcertListErrorStub = .serverError

        // When
        sut.send(.interestConcertSortSelected(.concert))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(sut.state.interestConcertSort == .concert)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListFilter?.sort == .concert)
        #expect(container.userRepository.fetchInterestedConcertListFilter?.limit == 5)
        #expect(sut.state.interestConcertList.map(\.id) == [123])
        #expect(!sut.state.errorMessage.isEmpty)
    }

    @Test("같은 관심 콘서트 정렬을 다시 선택하면 목록을 다시 조회하지 않아야 한다")
    func testSameInterestConcertSortSelectedDoesNotRefetchInterestConcertList() async throws {
        // Given
        let sut = HomeStore()

        // When
        sut.send(.interestConcertSortSelected(.ticketing))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(sut.state.interestConcertSort == .ticketing)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 0)
    }

    @Test("유저 조회 결과가 다시 들어와도 홈 콘서트 섹션 초기 로딩은 한 번만 수행되어야 한다")
    func testUserResultDoesNotResetHomeConcertSectionInitialLoad() async throws {
        let sut = HomeStore()
        let user = makeMockUser(hasPreferences: true)

        container.concertRepository.homeSectionListStub = [makeMockSection(id: 10)]
        container.concertRepository.recommendedConcertListStub = [makeMockConcert(id: 100)]

        sut.send(._fetchUserResult(.success(user)))
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.send(._fetchUserResult(.success(user)))
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 0)
    }

    @Test("관심 콘서트 목록 조회 결과가 바뀌어도 홈 콘서트 섹션 초기 로딩은 한 번만 수행되어야 한다")
    func testInterestConcertListResultChangeDoesNotResetHomeConcertSectionInitialLoad() async throws {
        let sut = HomeStore()
        let user = makeMockUser(hasPreferences: true)

        container.concertRepository.homeSectionListStub = [makeMockSection(id: 10)]
        container.concertRepository.recommendedConcertListStub = [makeMockConcert(id: 100)]

        sut.send(._fetchUserResult(.success(user)))
        try await Task.sleep(nanoseconds: 100_000_000)

        sut.send(._fetchInterestConcertListResult(.success(makeInterestConcertList(concertIDList: [123]))))
        try await Task.sleep(nanoseconds: 100_000_000)

        sut.send(._fetchInterestConcertListResult(.success([])))
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 0)
        #expect(container.concertRepository.fetchConcertScheduleListCallCount == 0)
        #expect(container.concertRepository.fetchMainSetlistCallCount == 0)
        #expect(container.setlistRepository.fetchSetlistSongsCallCount == 0)
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
        #expect(sut.state.concertSectionList.count == 1)
        #expect(sut.state.shouldShowPreferenceBanner)
        #expect(sut.state.recommendedConcertList.isEmpty)
    }

    @Test("concertSection onRefresh 시 홈 콘서트 섹션 데이터를 다시 로드해야 한다")
    func testConcertSectionOnRefreshReloadsHomeConcertSection() async throws {
        // Given
        let sut = HomeStore()
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 20)]

        // When
        sut.send(.onRefresh)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(sut.state.concertSectionList.first?.id == 20)
    }

    @Test("concertSection 데이터 로드 실패 시 errorMessage를 설정해야 한다")
    func testConcertSectionLoadFailureSetsErrorMessage() async throws {
        // Given
        let sut = HomeStore()
        container.concertRepository.errorStub = .serverError

        // When
        sut.send(.onRefresh)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(!sut.state.errorMessage.isEmpty)
    }

    @Test("concertSection 데이터 로드 실패 후 성공 시 errorMessage를 비워야 한다")
    func testConcertSectionLoadSuccessClearsPreviousErrorMessage() async throws {
        // Given
        let sut = HomeStore()
        container.concertRepository.errorStub = .serverError

        sut.send(.onRefresh)
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(!sut.state.errorMessage.isEmpty)

        container.concertRepository.errorStub = nil
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 30)]

        // When
        sut.send(.onRefresh)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(sut.state.errorMessage.isEmpty)
        #expect(sut.state.concertSectionList.first?.id == 30)
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
        hasPreferences: Bool = false
    ) -> User {
        User(
            id: 1,
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
    
    func makeMockSection(id: Int = 1) -> ConcertSection {
        ConcertSection(
            id: id,
            title: "인기 공연",
            concerts: [makeMockConcert()]
        )
    }

    func makeInterestConcertList(concertIDList: [Int]) -> [InterestConcert] {
        concertIDList.map { concertID in
            InterestConcert(
                concert: makeMockConcert(id: concertID),
                ticketingSchedule: InterestConcertTicketingSchedule(preSaleDate: nil, generalSaleDate: nil)
            )
        }
    }
}
