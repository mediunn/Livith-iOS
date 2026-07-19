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
import LivithDesignSystem

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

    @Test("초기 상태에서 selectedHomeTab은 관심 콘서트여야 한다")
    func testInitialSelectedHomeTabIsInterestConcert() {
        let sut = HomeStore()
        #expect(sut.state.selectedHomeTab == .interestConcert)
    }

    @Test("homeTabSelected 시 selectedHomeTab이 변경되어야 한다")
    func testHomeTabSelectedUpdatesSelectedHomeTab() {
        // Given
        let sut = HomeStore()

        // When
        sut.send(.homeTabSelected(.calendar))

        // Then
        #expect(sut.state.selectedHomeTab == .calendar)
    }

    @Test("homeTabSelected는 초기 홈 데이터 로드를 다시 수행하지 않아야 한다")
    func testHomeTabSelectedDoesNotRefetchInitialHomeData() async throws {
        // Given
        let sut = HomeStore()

        // When
        sut.send(.homeTabSelected(.calendar))
        try await Task.sleep(nanoseconds: 50_000_000)

        // Then
        #expect(container.userRepository.fetchUserCallCount == 0)
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 0)
    }

    // MARK: - homeAppear / interestAppear 분리 테스트

    @Test("homeAppear는 관심 콘서트 목록과 홈 섹션을 조회하지 않아야 한다")
    func testHomeAppearDoesNotFetchInterestListOrSections() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.notificationRepository.unreadNotificationCountStub = 3

        let sut = HomeStore()

        // When
        sut.send(.homeAppear)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(container.userRepository.fetchUserCallCount == 1)
        #expect(container.notificationRepository.fetchUnreadNotificationCountCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 0)
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 0)
        #expect(sut.state.user?.nickname == "홍길동")
        #expect(sut.state.hasNewNotice)
        #expect(sut.state.interestConcertList.isEmpty)
        #expect(sut.state.concertSectionList.isEmpty)
    }

    @Test("interestAppear는 유저를 조회하지 않아야 한다")
    func testInterestAppearDoesNotFetchUser() async throws {
        // Given
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]

        let sut = HomeStore()

        // When
        sut.send(.interestAppear)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(container.userRepository.fetchUserCallCount == 0)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
        #expect(sut.state.interestConcertList.map(\.id) == [123])

        // homeAppear가 끝내 오지 않아도 대기 중인 추천 조회가 누수되지 않도록 정리한다.
        container.userRepository.userStub = makeMockUser()
        sut.send(.homeAppear)
        try await Task.sleep(nanoseconds: 100_000_000)
    }

    @Test("homeAppear와 interestAppear 동시 진행 시 유저 조회 완료 전에 홈 섹션 조회가 시작되어야 한다")
    func testOnAppearStartsHomeSectionFetchWithoutWaitingForUser() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.fetchUserDelay = 300_000_000
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.notificationRepository.unreadNotificationCountStub = 3
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]

        let sut = HomeStore()

        // When
        sut.send(.homeAppear)
        sut.send(.interestAppear)
        try await Task.sleep(nanoseconds: 50_000_000)

        // Then
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(sut.state.user == nil)
        #expect(sut.state.isSectionLoading)

        try await Task.sleep(nanoseconds: 350_000_000)

        #expect(sut.state.user?.nickname == "홍길동")
        #expect(sut.state.concertSectionList.count == 1)
        #expect(!sut.state.isSectionLoading)
    }

    @Test("homeAppear와 interestAppear가 함께 진행되면 유저·관심 콘서트 목록·알림 수·홈 섹션을 모두 조회해야 한다")
    func testOnAppearFetchesInitialHomeDataTogether() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.notificationRepository.unreadNotificationCountStub = 3
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        
        let sut = HomeStore()
        
        // When
        sut.send(.homeAppear)
        sut.send(.interestAppear)
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
        #expect(!sut.state.isSectionLoading)
    }

    @Test("동시 진행 시 추천 콘서트는 유저 조회가 끝난 뒤에만 조회되어야 한다")
    func testRecommendationsWaitForUserBeforeBeingFetched() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(hasPreferences: true)
        container.userRepository.fetchUserDelay = 200_000_000
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        container.concertRepository.recommendedConcertListStub = [makeMockConcert(id: 99)]

        let sut = HomeStore()

        // When
        sut.send(.homeAppear)
        sut.send(.interestAppear)
        try await Task.sleep(nanoseconds: 80_000_000)

        // Then: 섹션 조회는 끝났지만 유저 조회가 끝나지 않아 추천은 아직 조회되지 않는다.
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 0)
        #expect(sut.state.concertSectionList.isEmpty)

        try await Task.sleep(nanoseconds: 250_000_000)

        // Then: 유저 조회가 끝나면 추천을 조회하고 섹션과 함께 반영한다.
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 1)
        #expect(sut.state.concertSectionList.count == 1)
        #expect(sut.state.recommendedConcertList.map(\.id) == [99])
    }

    @Test("homeAppear 유저 조회 실패 후 다시 진행하면 홈 섹션을 로드해야 한다")
    func testOnAppearRetriesHomeSectionLoadAfterUserFailure() async throws {
        // Given
        container.userRepository.fetchUserErrorStub = .serverError
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        let sut = HomeStore()

        sut.send(.homeAppear)
        sut.send(.interestAppear)
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(!sut.state.errorMessage.isEmpty)
        #expect(sut.state.concertSectionList.isEmpty)

        container.userRepository.fetchUserErrorStub = nil
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.notificationRepository.unreadNotificationCountStub = 1

        // When
        sut.send(.homeAppear)
        sut.send(.interestAppear)
        try await Task.sleep(nanoseconds: 150_000_000)

        // Then
        #expect(sut.state.user?.nickname == "홍길동")
        #expect(sut.state.concertSectionList.count == 1)
        #expect(!sut.state.isSectionLoading)
    }

    @Test("섹션 로드 중 다시 interestAppear하면 섹션 파이프라인을 다시 수행해야 한다")
    func testOnAppearDuringSectionLoadRetriesSectionPipeline() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.notificationRepository.unreadNotificationCountStub = 1
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        container.concertRepository.fetchHomeConcertSectionListDelay = 300_000_000
        let sut = HomeStore()

        sut.send(.homeAppear)
        sut.send(.interestAppear)
        try await Task.sleep(nanoseconds: 50_000_000)
        #expect(sut.state.user?.nickname == "홍길동")
        #expect(sut.state.isSectionLoading)
        #expect(sut.state.concertSectionList.isEmpty)

        // When
        container.concertRepository.fetchHomeConcertSectionListDelay = 0
        sut.send(.homeAppear)
        sut.send(.interestAppear)
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then
        #expect(sut.state.concertSectionList.count == 1)
        #expect(!sut.state.isSectionLoading)
        #expect(!sut.state.needsInitialSectionLoad)
    }

    @Test("초기 로드 중 다시 진행하면 이전 Task를 취소하고 로드를 완료해야 한다")
    func testOnAppearCancelsInFlightLoadAndCompletesNewLoad() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.fetchUserDelay = 300_000_000
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        let sut = HomeStore()

        sut.send(.homeAppear)
        sut.send(.interestAppear)
        try await Task.sleep(nanoseconds: 30_000_000)
        #expect(sut.state.isSectionLoading)

        // When: 재요청으로 이전 Task 취소
        container.userRepository.fetchUserDelay = 0
        sut.send(.homeAppear)
        sut.send(.interestAppear)
        try await Task.sleep(nanoseconds: 150_000_000)

        // Then
        #expect(!sut.state.isSectionLoading)
        #expect(sut.state.concertSectionList.count == 1)
    }

    @Test("interestAppear 시 관심 콘서트 목록 조회 실패는 홈 초기 데이터 실패로 전파하지 않아야 한다")
    func testOnAppearInterestConcertListFailureDoesNotFailHomeInitialData() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.fetchInterestedConcertListErrorStub = .serverError
        container.notificationRepository.unreadNotificationCountStub = 3
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]

        let sut = HomeStore()

        // When
        sut.send(.homeAppear)
        sut.send(.interestAppear)
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

    @Test("homeAppear 시 알림 수 조회 실패는 홈 초기 데이터 실패로 전파하지 않아야 한다")
    func testOnAppearNotificationCountFailureDoesNotFailHomeInitialData() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.notificationRepository.errorStub = .serverError
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]

        let sut = HomeStore()

        // When
        sut.send(.homeAppear)
        sut.send(.interestAppear)
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

    @Test("homeAppear 유저 조회 실패만 홈 초기 데이터 실패로 전파하고 섹션 결과는 반영하지 않아야 한다")
    func testOnAppearUserFailureFailsHomeInitialData() async throws {
        // Given
        container.userRepository.fetchUserErrorStub = .serverError
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.notificationRepository.unreadNotificationCountStub = 3
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        container.concertRepository.fetchHomeConcertSectionListDelay = 200_000_000

        let sut = HomeStore()

        // When
        sut.send(.homeAppear)
        sut.send(.interestAppear)
        try await Task.sleep(nanoseconds: 300_000_000)

        // Then: 관심 목록은 유저 조회와 무관하게 반영되지만, 섹션은 유저 실패로 반영되지 않는다.
        #expect(container.userRepository.fetchUserCallCount == 1)
        #expect(sut.state.user == nil)
        #expect(sut.state.interestConcertList.map(\.id) == [123])
        #expect(!sut.state.hasNewNotice)
        #expect(!sut.state.errorMessage.isEmpty)
        #expect(sut.state.concertSectionList.isEmpty)
        #expect(!sut.state.isSectionLoading)
    }

    @Test("홈 섹션 조회가 유저 조회보다 먼저 끝나도 유저 조회가 실패하면 섹션 결과를 반영하지 않아야 한다")
    func testSectionResultIsDiscardedWhenUserFailsAfterSectionSucceeds() async throws {
        // Given: 섹션은 지연 없이 바로 성공하고, 유저 조회는 지연 후 실패한다.
        container.userRepository.fetchUserErrorStub = .serverError
        container.userRepository.fetchUserDelay = 150_000_000
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]

        let sut = HomeStore()

        // When
        sut.send(.homeAppear)
        sut.send(.interestAppear)
        try await Task.sleep(nanoseconds: 60_000_000)

        // Then: 섹션 조회는 이미 끝났지만 유저 조회 결과를 기다리는 중이다.
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(sut.state.concertSectionList.isEmpty)
        #expect(sut.state.isSectionLoading)

        try await Task.sleep(nanoseconds: 150_000_000)

        // Then: 유저 조회 실패가 도착하면 대기 중이던 섹션 결과를 반영하지 않는다.
        #expect(!sut.state.errorMessage.isEmpty)
        #expect(sut.state.concertSectionList.isEmpty)
        #expect(!sut.state.isSectionLoading)
    }

    // MARK: - InterestConcertResultSheet 테스트

    @Test("섹션 로드 CancellationError는 결과 시트 정책 조회 예약을 소진하지 않아야 한다")
    func testSectionLoadCancellationDoesNotConsumeInterestResultPolicyFetch() async throws {
        // Given: 초기 섹션 로드가 진행 중이라 정책 조회가 예약된 상태
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestConcertCleanupPolicyStub = .completed
        container.notificationRepository.unreadNotificationCountStub = 1
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        container.concertRepository.fetchHomeConcertSectionListDelay = 5_000_000_000

        let sut = HomeStore()
        sut.send(.homeAppear)
        sut.send(.interestAppear)
        try await Task.sleep(nanoseconds: 50_000_000)
        #expect(sut.state.isSectionLoading)
        #expect(container.userRepository.fetchInterestConcertCleanupPolicyCallCount == 0)

        // When: 취소된 섹션 Task가 failure를 보내고, 이어서 성공 결과가 도착한다
        sut.send(._sectionLoadResult(.failure(CancellationError())))
        sut.send(._sectionLoadResult(.success((
            sectionList: [makeMockSection(id: 1)],
            recommendedConcertList: []
        ))))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then: 취소 failure에 예약이 소진되지 않아 성공 로드 후 정책을 조회한다
        #expect(container.userRepository.fetchInterestConcertCleanupPolicyCallCount == 1)
        #expect(sut.state.shouldShowInterestResultSheet)
        #expect(sut.state.concertSectionList.count == 1)
    }

    @Test("homeAppear·interestAppear 시 관심 콘서트 결과 노출이 필요하면 시트를 띄우고 dismiss 전에는 mark하지 않아야 한다")
    func testOnAppearShowsInterestResultSheetWithoutMarkingUntilDismiss() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.userRepository.interestConcertCleanupPolicyStub = .completed
        container.notificationRepository.unreadNotificationCountStub = 3
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]

        let sut = HomeStore()

        // When
        sut.send(.homeAppear)
        sut.send(.interestAppear)
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then
        #expect(container.userRepository.fetchInterestConcertCleanupPolicyCallCount == 1)
        #expect(sut.state.shouldShowInterestResultSheet)
        #expect(sut.state.interestResultSheetContent == .stub)
        #expect(container.userRepository.markInterestConcertToastShownCallCount == 0)
    }

    @Test("관심 콘서트 정리 정책이 none이 아니면 stub 시트를 띄워야 한다")
    func testInterestConcertCleanupPolicyShowsStubSheetWhenNeeded() async throws {
        // Given
        let sut = HomeStore()

        // When & Then
        sut.send(._interestResultPolicyResult(.success(.canceled)))
        #expect(sut.state.shouldShowInterestResultSheet)
        #expect(sut.state.interestResultSheetContent == .stub)

        sut.send(.onInterestResultSheetDismiss)
        sut.send(._interestResultPolicyResult(.success(.completed)))
        #expect(sut.state.shouldShowInterestResultSheet)
        #expect(sut.state.interestResultSheetContent == .stub)

        sut.send(.onInterestResultSheetDismiss)
        sut.send(._interestResultPolicyResult(.success(.both)))
        #expect(sut.state.shouldShowInterestResultSheet)
        #expect(sut.state.interestResultSheetContent == .stub)
    }

    @Test("homeAppear·interestAppear 시 관심 콘서트 결과 노출이 필요하지 않으면 시트를 띄우지 않아야 한다")
    func testOnAppearSkipsInterestResultSheetWhenNotNeeded() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestConcertCleanupPolicyStub = .none
        container.notificationRepository.unreadNotificationCountStub = 3
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]

        let sut = HomeStore()

        // When
        sut.send(.homeAppear)
        sut.send(.interestAppear)
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then
        #expect(container.userRepository.fetchInterestConcertCleanupPolicyCallCount == 1)
        #expect(!sut.state.shouldShowInterestResultSheet)
        #expect(sut.state.interestResultSheetContent == nil)
        #expect(container.userRepository.markInterestConcertToastShownCallCount == 0)
    }

    @Test("홈 섹션 데이터 반영 전에는 관심 콘서트 결과 정책을 조회하지 않아야 한다")
    func testInterestResultPolicyIsFetchedAfterHomeSectionDataIsLoaded() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.userRepository.interestConcertCleanupPolicyStub = .completed
        container.notificationRepository.unreadNotificationCountStub = 3
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        container.concertRepository.fetchHomeConcertSectionListDelay = 300_000_000

        let sut = HomeStore()

        // When
        sut.send(.homeAppear)
        sut.send(.interestAppear)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(sut.state.concertSectionList.isEmpty)
        #expect(container.userRepository.fetchInterestConcertCleanupPolicyCallCount == 0)
        #expect(!sut.state.shouldShowInterestResultSheet)
        #expect(container.userRepository.markInterestConcertToastShownCallCount == 0)

        try await Task.sleep(nanoseconds: 300_000_000)

        #expect(sut.state.concertSectionList.count == 1)
        #expect(container.userRepository.fetchInterestConcertCleanupPolicyCallCount == 1)
        #expect(sut.state.shouldShowInterestResultSheet)
        #expect(sut.state.interestResultSheetContent == .stub)
        #expect(container.userRepository.markInterestConcertToastShownCallCount == 0)
    }

    @Test("홈 섹션 데이터 조회가 실패하면 관심 콘서트 결과 정책을 조회하지 않아야 한다")
    func testInterestResultPolicyIsNotFetchedWhenHomeSectionDataFails() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.userRepository.interestConcertCleanupPolicyStub = .completed
        container.notificationRepository.unreadNotificationCountStub = 3
        container.concertRepository.errorStub = .serverError

        let sut = HomeStore()

        // When
        sut.send(.homeAppear)
        sut.send(.interestAppear)
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then
        #expect(!sut.state.errorMessage.isEmpty)
        #expect(container.userRepository.fetchInterestConcertCleanupPolicyCallCount == 0)
        #expect(!sut.state.shouldShowInterestResultSheet)
        #expect(container.userRepository.markInterestConcertToastShownCallCount == 0)
    }

    @Test("관심 콘서트 결과 정책 조회 실패는 홈 초기 로딩과 오류 메시지로 전파하지 않아야 한다")
    func testInterestResultPolicyFetchFailureDoesNotFailInitialHomeData() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.fetchInterestConcertToastErrorStub = .serverError
        container.notificationRepository.unreadNotificationCountStub = 3
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]

        let sut = HomeStore()

        // When
        sut.send(.homeAppear)
        sut.send(.interestAppear)
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then
        #expect(sut.state.user?.nickname == "홍길동")
        #expect(sut.state.errorMessage.isEmpty)
        #expect(!sut.state.shouldShowInterestResultSheet)
        #expect(container.userRepository.markInterestConcertToastShownCallCount == 0)
    }

    @Test("오류 메시지가 있으면 관심 콘서트 결과 시트를 폐기하고 mark하지 않아야 한다")
    func testInterestResultSheetIsDiscardedWhenErrorMessageExists() async throws {
        // Given
        let sut = HomeStore()
        sut.send(._fetchUserResult(.failure(UserError.serverError)))
        #expect(!sut.state.errorMessage.isEmpty)

        // When
        sut.send(._interestResultPolicyResult(.success(.completed)))

        // Then
        #expect(!sut.state.shouldShowInterestResultSheet)
        #expect(sut.state.interestResultSheetContent == nil)
        #expect(container.userRepository.markInterestConcertToastShownCallCount == 0)
    }

    @Test("오류가 발생하면 대기 중인 관심 콘서트 결과 시트를 닫아야 한다")
    func testErrorClearsPendingInterestResultSheet() async throws {
        // Given
        let sut = HomeStore()
        sut.send(._interestResultPolicyResult(.success(.completed)))
        #expect(sut.state.shouldShowInterestResultSheet)

        // When
        sut.send(._interestListResult(.failure(UserError.serverError)))

        // Then
        #expect(!sut.state.errorMessage.isEmpty)
        #expect(!sut.state.shouldShowInterestResultSheet)
        #expect(sut.state.interestResultSheetContent == nil)
    }

    @Test("관심 콘서트 결과 시트 dismiss 시 mark를 호출하고 시트는 닫혀야 한다")
    func testInterestResultSheetDismissMarksShownAndClosesSheet() async throws {
        // Given
        let sut = HomeStore()
        sut.send(._interestResultPolicyResult(.success(.completed)))
        #expect(sut.state.shouldShowInterestResultSheet)

        // When
        sut.send(.onInterestResultSheetDismiss)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(!sut.state.shouldShowInterestResultSheet)
        #expect(sut.state.interestResultSheetContent == nil)
        #expect(container.userRepository.markInterestConcertToastShownCallCount == 1)
    }

    @Test("관심 콘서트 결과 mark 실패는 오류 메시지로 노출하지 않아야 한다")
    func testInterestResultSheetMarkFailureDoesNotSetErrorMessage() async throws {
        // Given
        container.userRepository.markInterestConcertToastShownErrorStub = .serverError
        let sut = HomeStore()
        sut.send(._interestResultPolicyResult(.success(.completed)))

        // When
        sut.send(.onInterestResultSheetDismiss)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(sut.state.errorMessage.isEmpty)
        #expect(container.userRepository.markInterestConcertToastShownCallCount == 1)
    }

    @Test("이미 닫힌 관심 콘서트 결과 시트를 다시 dismiss해도 mark를 중복 호출하지 않아야 한다")
    func testInterestResultSheetDismissIsIdempotent() async throws {
        // Given
        let sut = HomeStore()
        sut.send(._interestResultPolicyResult(.success(.completed)))
        sut.send(.onInterestResultSheetDismiss)
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(container.userRepository.markInterestConcertToastShownCallCount == 1)

        // When
        sut.send(.onInterestResultSheetDismiss)
        try await Task.sleep(nanoseconds: 50_000_000)

        // Then
        #expect(container.userRepository.markInterestConcertToastShownCallCount == 1)
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

        sut.send(._interestListResult(.success(makeInterestConcertList(concertIDList: [123]))))
        sut.send(._interestListResult(.failure(UserError.serverError)))

        #expect(sut.state.interestConcertList.map(\.id) == [123])
        #expect(!sut.state.errorMessage.isEmpty)
    }

    @Test("관심 콘서트 정렬을 선택하면 홈 섹션 조회 조건으로 목록을 다시 조회해야 한다")
    func testInterestConcertSortSelectedRefetchesInterestConcertList() async throws {
        // Given
        let sut = HomeStore()
        sut.send(._interestListResult(.success(makeInterestConcertList(concertIDList: [123]))))
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
        sut.send(._interestListResult(.success(makeInterestConcertList(concertIDList: [123]))))
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

        sut.send(._interestListResult(.success(makeInterestConcertList(concertIDList: [123]))))
        try await Task.sleep(nanoseconds: 100_000_000)

        sut.send(._interestListResult(.success([])))
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
