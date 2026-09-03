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
    
    @Test("초기 상태에서 관심 유저는 nil이어야 한다")
    func testInitialUserState() {
        let sut = HomeStore()
        #expect(sut.state.interest.user == nil)
    }

    @Test("초기 상태에서 관심 콘서트 정렬은 예매일이어야 한다")
    func testInitialInterestConcertSortIsTicketing() {
        let sut = HomeStore()
        #expect(sut.state.interest.interestConcertSort == .ticketing)
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

    @Test("scope는 child state를 투영하고 send를 셸 Intent로 감싸야 한다")
    func testScopeProjectsChildStateAndWrapsIntent() {
        let sut = HomeStore()

        let scope = sut.scope(\.interest, intent: HomeIntent.interest)
        #expect(scope.state.interestConcertSort == .ticketing)

        scope.send(.interestConcertSortSelected(.concert))
        #expect(sut.state.interest.interestConcertSort == .concert)
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

    // MARK: - homeAppear / interest(.onAppear) 분리 테스트

    @Test("homeAppear는 알림 수만 조회하고 유저·관심목록·섹션을 조회하지 않아야 한다")
    func testHomeAppearFetchesOnlyUnreadCount() async throws {
        // Given
        container.notificationRepository.unreadNotificationCountStub = 3

        let sut = HomeStore()

        // When
        sut.send(.homeAppear)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(container.userRepository.fetchUserCallCount == 0)
        #expect(container.notificationRepository.fetchUnreadNotificationCountCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 0)
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 0)
        #expect(sut.state.interest.user == nil)
        #expect(sut.state.hasNewNotice)
        #expect(sut.state.interest.interestConcertList.isEmpty)
        #expect(sut.state.interest.concertSectionList.isEmpty)
    }

    @Test("interest onAppear는 유저를 조회해야 한다")
    func testInterestAppearFetchesUser() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]

        let sut = HomeStore()

        // When
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 150_000_000)

        // Then
        #expect(container.userRepository.fetchUserCallCount == 1)
        #expect(sut.state.interest.user?.nickname == "홍길동")
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
        #expect(sut.state.interest.interestConcertList.map(\.id) == [123])
        #expect(sut.state.interest.concertSectionList.count == 1)
    }

    @Test("interest onAppear는 유저 조회 완료 전에 홈 섹션 조회를 시작해야 한다")
    func testOnAppearStartsSectionFetchWithoutWaitingForUser() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.fetchUserDelay = 300_000_000
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]

        let sut = HomeStore()

        // When
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 50_000_000)

        // Then
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(sut.state.interest.user == nil)
        #expect(sut.state.interest.isSectionLoading)

        try await Task.sleep(nanoseconds: 350_000_000)

        #expect(sut.state.interest.user?.nickname == "홍길동")
        #expect(sut.state.interest.concertSectionList.count == 1)
        #expect(!sut.state.interest.isSectionLoading)
    }

    @Test("homeAppear는 알림 수를, interest onAppear는 유저·관심목록·홈 섹션을 조회해야 한다")
    func testOnAppearFetchesInitialHomeDataTogether() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.notificationRepository.unreadNotificationCountStub = 3
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        
        let sut = HomeStore()
        
        // When
        sut.send(.homeAppear)
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 150_000_000)
        
        // Then
        #expect(container.userRepository.fetchUserCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListFilter?.sort == .ticketing)
        #expect(container.userRepository.fetchInterestedConcertListFilter?.limit == 5)
        #expect(container.notificationRepository.fetchUnreadNotificationCountCallCount == 1)
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 0)
        #expect(sut.state.interest.user?.nickname == "홍길동")
        #expect(sut.state.interest.interestConcertList.map(\.id) == [123])
        #expect(sut.state.hasNewNotice)
        #expect(sut.state.interest.concertSectionList.count == 1)
        #expect(!sut.state.interest.isSectionLoading)
    }

    @Test("onAppear 시 추천 콘서트는 유저 조회가 끝난 뒤에만 조회되어야 한다")
    func testRecommendationsWaitForUserBeforeBeingFetched() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(hasPreferences: true)
        container.userRepository.fetchUserDelay = 200_000_000
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        container.concertRepository.recommendedConcertListStub = [makeMockConcert(id: 99)]

        let sut = HomeStore()

        // When
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 80_000_000)

        // Then: 섹션 조회는 끝났지만 유저 조회가 끝나지 않아 추천은 아직 조회되지 않는다.
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 0)
        #expect(sut.state.interest.concertSectionList.isEmpty)

        try await Task.sleep(nanoseconds: 250_000_000)

        // Then: 유저 조회가 끝나면 추천을 조회하고 섹션과 함께 반영한다.
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 1)
        #expect(sut.state.interest.concertSectionList.count == 1)
        #expect(sut.state.interest.recommendedConcertList.map(\.id) == [99])
    }

    @Test("유저 조회 실패 후 onRefresh하면 유저를 다시 조회하고 홈 섹션을 로드해야 한다")
    func testOnRefreshRecoversHomeSectionLoadAfterUserFailure() async throws {
        // Given
        container.userRepository.fetchUserErrorStub = .serverError
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        let sut = HomeStore()

        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(!sut.state.interest.errorMessage.isEmpty)
        #expect(sut.state.interest.concertSectionList.isEmpty)

        container.userRepository.fetchUserErrorStub = nil
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")

        // When: 자동 재시도는 없고 수동 새로고침으로만 복구한다.
        sut.send(.interest(.onRefresh))
        try await Task.sleep(nanoseconds: 150_000_000)

        // Then
        #expect(container.userRepository.fetchUserCallCount == 2)
        #expect(sut.state.interest.user?.nickname == "홍길동")
        #expect(sut.state.interest.concertSectionList.count == 1)
        #expect(!sut.state.interest.isSectionLoading)
    }

    @Test("섹션 로드 중 다시 interest onAppear하면 섹션 파이프라인을 다시 수행해야 한다")
    func testOnAppearDuringSectionLoadRetriesSectionPipeline() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.notificationRepository.unreadNotificationCountStub = 1
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        container.concertRepository.fetchHomeConcertSectionListDelay = 300_000_000
        let sut = HomeStore()

        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 50_000_000)
        #expect(sut.state.interest.user?.nickname == "홍길동")
        #expect(sut.state.interest.isSectionLoading)
        #expect(sut.state.interest.concertSectionList.isEmpty)

        // When
        container.concertRepository.fetchHomeConcertSectionListDelay = 0
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then
        #expect(sut.state.interest.concertSectionList.count == 1)
        #expect(!sut.state.interest.isSectionLoading)
        #expect(!sut.state.interest.needsInitialSectionLoad)
    }

    @Test("초기 로드 중 다시 진행하면 이전 Task를 취소하고 로드를 완료해야 한다")
    func testOnAppearCancelsInFlightLoadAndCompletesNewLoad() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.fetchUserDelay = 300_000_000
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        let sut = HomeStore()

        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 30_000_000)
        #expect(sut.state.interest.isSectionLoading)

        // When: 재요청으로 이전 Task 취소
        container.userRepository.fetchUserDelay = 0
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 150_000_000)

        // Then
        #expect(!sut.state.interest.isSectionLoading)
        #expect(sut.state.interest.concertSectionList.count == 1)
    }

    @Test("interest onAppear 시 관심 콘서트 목록 조회 실패는 홈 초기 데이터 실패로 전파하지 않아야 한다")
    func testOnAppearInterestConcertListFailureDoesNotFailHomeInitialData() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.fetchInterestedConcertListErrorStub = .serverError
        container.notificationRepository.unreadNotificationCountStub = 3
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]

        let sut = HomeStore()

        // When
        sut.send(.homeAppear)
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 150_000_000)

        // Then
        #expect(container.userRepository.fetchUserCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
        #expect(sut.state.interest.user?.nickname == "홍길동")
        #expect(sut.state.interest.interestConcertList.isEmpty)
        #expect(sut.state.hasNewNotice)
        #expect(sut.state.interest.isInterestListLoadFailed)
        #expect(sut.state.interest.errorMessage.isEmpty)
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
    }

    @Test("관심 목록 로드 실패 후 interest onAppear는 재조회 로딩을 켜고 목록을 다시 조회해야 한다")
    func testInterestAppearAfterLoadFailedStartsRetryLoadingAndRefetches() async throws {
        // Given
        let sut = HomeStore()
        sut.send(.interest(._interestListResult(.failure(UserError.serverError))))
        #expect(sut.state.interest.isInterestListLoadFailed)
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])

        // When
        sut.send(.interest(.onAppear))

        // Then
        #expect(sut.state.interest.isInterestListRetryLoading)

        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
        #expect(!sut.state.interest.isInterestListLoadFailed)
        #expect(!sut.state.interest.isInterestListRetryLoading)
        #expect(sut.state.interest.interestConcertList.map(\.id) == [123])
    }

    @Test("onRefresh는 홈 섹션과 관심 콘서트 목록을 함께 다시 조회해야 한다")
    func testOnRefreshRefetchesSectionsAndInterestList() async throws {
        // Given
        let sut = HomeStore()
        sut.send(.interest(._interestListResult(.failure(UserError.serverError))))
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        container.userRepository.userStub = makeMockUser(hasPreferences: false)

        // When
        sut.send(.interest(.onRefresh))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
        #expect(!sut.state.interest.isInterestListLoadFailed)
        #expect(!sut.state.interest.isInterestListRetryLoading)
        #expect(sut.state.interest.interestConcertList.map(\.id) == [123])
    }

    @Test("onRefresh wait 취소 시 fetch 결과를 state에 반영하지 않아야 한다")
    func onRefresh_wait_취소_시_fetch_결과를_state에_반영하지_않아야_한다() async throws {
        // Given
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 99)]
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [456])
        container.concertRepository.fetchHomeConcertSectionListDelay = 300_000_000
        container.userRepository.fetchInterestedConcertListDelayQueue = [300_000_000]
        let sut = HomeStore()

        // When
        let waitTask = Task { await sut.send(.interest(.onRefresh)).wait() }
        try await Task.sleep(nanoseconds: 30_000_000)
        waitTask.cancel()
        try await Task.sleep(nanoseconds: 400_000_000)

        // Then
        #expect(sut.state.interest.concertSectionList.isEmpty)
        #expect(sut.state.interest.interestConcertList.isEmpty)
    }

    @Test("onRefresh wait는 섹션·관심 목록 fetch 완료까지 대기해야 한다")
    func onRefresh_wait는_섹션_관심_목록_fetch_완료까지_대기해야_한다() async throws {
        // Given
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.concertRepository.fetchHomeConcertSectionListDelay = 100_000_000
        container.userRepository.fetchInterestedConcertListDelayQueue = [100_000_000]
        let sut = HomeStore()

        // When
        await sut.send(.interest(.onRefresh)).wait()

        // Then
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
        #expect(sut.state.interest.concertSectionList.map(\.id) == [1])
        #expect(sut.state.interest.interestConcertList.map(\.id) == [123])
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
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 150_000_000)

        // Then
        #expect(container.userRepository.fetchUserCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
        #expect(container.notificationRepository.fetchUnreadNotificationCountCallCount == 1)
        #expect(sut.state.interest.user?.nickname == "홍길동")
        #expect(sut.state.interest.interestConcertList.map(\.id) == [123])
        #expect(!sut.state.hasNewNotice)
        #expect(sut.state.interest.errorMessage.isEmpty)
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
    }

    @Test("interest onAppear 유저 조회 실패만 홈 초기 데이터 실패로 전파하고 섹션 결과는 반영하지 않아야 한다")
    func testOnAppearUserFailureFailsHomeInitialData() async throws {
        // Given
        container.userRepository.fetchUserErrorStub = .serverError
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        container.concertRepository.fetchHomeConcertSectionListDelay = 200_000_000

        let sut = HomeStore()

        // When
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 300_000_000)

        // Then: 관심 목록은 유저 조회와 무관하게 반영되지만, 섹션은 유저 실패로 반영되지 않는다.
        #expect(container.userRepository.fetchUserCallCount == 1)
        #expect(sut.state.interest.user == nil)
        #expect(sut.state.interest.interestConcertList.map(\.id) == [123])
        #expect(!sut.state.hasNewNotice)
        #expect(!sut.state.interest.errorMessage.isEmpty)
        #expect(sut.state.interest.concertSectionList.isEmpty)
        #expect(!sut.state.interest.isSectionLoading)
    }

    @Test("홈 섹션 조회가 유저 조회보다 먼저 끝나도 유저 조회가 실패하면 섹션 결과를 반영하지 않아야 한다")
    func testSectionResultIsDiscardedWhenUserFailsAfterSectionSucceeds() async throws {
        // Given: 섹션은 지연 없이 바로 성공하고, 유저 조회는 지연 후 실패한다.
        container.userRepository.fetchUserErrorStub = .serverError
        container.userRepository.fetchUserDelay = 150_000_000
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]

        let sut = HomeStore()

        // When
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 60_000_000)

        // Then: 섹션 조회는 이미 끝났지만 유저 조회 결과를 기다리는 중이다.
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(sut.state.interest.concertSectionList.isEmpty)
        #expect(sut.state.interest.isSectionLoading)

        try await Task.sleep(nanoseconds: 150_000_000)

        // Then: 유저 조회 실패가 도착하면 대기 중이던 섹션 결과를 반영하지 않는다.
        #expect(!sut.state.interest.errorMessage.isEmpty)
        #expect(sut.state.interest.concertSectionList.isEmpty)
        #expect(!sut.state.interest.isSectionLoading)
    }

    @Test("재진입 시 이전 추천 Task 결과는 섹션에 반영되지 않아야 한다")
    func testReappearCancelsStaleRecommendationTask() async throws {
        // Given: 첫 진입은 추천이 느리게 끝나도록 둔다.
        container.userRepository.userStub = makeMockUser(nickname: "홍길동", hasPreferences: true)
        container.notificationRepository.unreadNotificationCountStub = 0
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        container.concertRepository.recommendedConcertListStub = [makeMockConcert(id: 99)]
        container.concertRepository.fetchRecommendedConcertListDelay = 400_000_000

        let sut = HomeStore()
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 100_000_000)

        // When: 추천이 끝나기 전에 새 스텁으로 다시 진입한다. 새 추천은 즉시 끝난다.
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 2)]
        container.concertRepository.recommendedConcertListStub = [makeMockConcert(id: 100)]
        container.concertRepository.fetchRecommendedConcertListDelay = 0
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 600_000_000)

        // Then: 늦게 끝난 이전 추천 결과가 새 섹션을 덮지 않아야 한다.
        #expect(sut.state.interest.concertSectionList.map(\.id) == [2])
        #expect(sut.state.interest.recommendedConcertList.map(\.id) == [100])
    }

    @Test("interest onAppear 단독으로 유저·관심목록·섹션을 모두 조회해야 한다")
    func testOnAppearAloneFetchesUserInterestListAndSections() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동", hasPreferences: true)
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        container.concertRepository.recommendedConcertListStub = [makeMockConcert(id: 99)]

        let sut = HomeStore()

        // When
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then: 셸 homeAppear 없이 관심 탭만으로 유저까지 조회된다.
        #expect(container.userRepository.fetchUserCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 1)
        #expect(sut.state.interest.user?.nickname == "홍길동")
        #expect(sut.state.interest.concertSectionList.count == 1)
        #expect(sut.state.interest.recommendedConcertList.map(\.id) == [99])
    }

    @Test("유저 조회 실패 시 섹션 결과를 폐기하고 다음 onAppear에 재조회하지 않아야 한다")
    func testUserFailureDiscardsSectionsAndDoesNotRefetchOnNextAppear() async throws {
        // Given: 유저 조회는 실패하고 섹션은 성공한다.
        container.userRepository.fetchUserErrorStub = .serverError
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 7)]
        container.concertRepository.fetchHomeConcertSectionListDelay = 100_000_000

        let sut = HomeStore()
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 300_000_000)

        // Then: 섹션 결과를 폐기하고 에러를 남긴다.
        #expect(container.userRepository.fetchUserCallCount == 1)
        #expect(sut.state.interest.user == nil)
        #expect(sut.state.interest.concertSectionList.isEmpty)
        #expect(!sut.state.interest.errorMessage.isEmpty)

        // When: 다시 진입해도 유저를 재조회하지 않는다(수동 새로고침으로만 복구).
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 300_000_000)

        // Then
        #expect(container.userRepository.fetchUserCallCount == 1)
        #expect(sut.state.interest.user == nil)
        #expect(sut.state.interest.concertSectionList.isEmpty)
    }

    @Test("user 미보유 시 onRefresh는 user 조회부터 시작해야 한다")
    func testOnRefreshWithoutUserFetchesUserFirst() async throws {
        // Given: user를 모르는 상태
        container.userRepository.userStub = makeMockUser(nickname: "홍길동", hasPreferences: false)
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 5)]
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])

        let sut = HomeStore()
        #expect(sut.state.interest.user == nil)

        // When
        sut.send(.interest(.onRefresh))
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then: 새로고침이 user 조회를 시작해 복구한다.
        #expect(container.userRepository.fetchUserCallCount == 1)
        #expect(sut.state.interest.user?.nickname == "홍길동")
    }

    // MARK: - InterestConcertResultSheet 테스트

    @Test("섹션 로드 CancellationError는 결과 시트 조회 예약을 소진하지 않아야 한다")
    func testSectionLoadCancellationDoesNotConsumeInterestResultAlertFetch() async throws {
        // Given: 초기 섹션 로드가 진행 중이라 entry-alerts 조회가 예약된 상태
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestConcertEntryAlertListStub = makeInterestConcertEntryAlertList()
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        container.concertRepository.fetchHomeConcertSectionListDelay = 5_000_000_000

        let sut = HomeStore()
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 50_000_000)
        #expect(sut.state.interest.isSectionLoading)
        #expect(container.userRepository.fetchInterestConcertEntryAlertsCallCount == 0)

        // When: 취소된 섹션 Task가 failure를 보내고, 이어서 성공 결과가 도착한다
        sut.send(.interest(._sectionLoadResult(.failure(CancellationError()))))
        sut.send(.interest(._sectionLoadResult(.success((
            sectionList: [makeMockSection(id: 1)],
            recommendedConcertList: []
        )))))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then: 취소 failure에 예약이 소진되지 않아 성공 로드 후 entry-alerts를 조회한다
        #expect(container.userRepository.fetchInterestConcertEntryAlertsCallCount == 1)
        #expect(sut.state.interest.shouldShowInterestResultSheet)
        #expect(sut.state.interest.concertSectionList.count == 1)
    }

    @Test("interest onAppear 시 entry-alerts가 있으면 시트를 띄워야 한다")
    func testOnAppearShowsInterestResultSheetWhenAlertsExist() async throws {
        // Given
        let alertList = makeInterestConcertEntryAlertList()
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.userRepository.interestConcertEntryAlertListStub = alertList
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]

        let sut = HomeStore()

        // When
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then
        #expect(container.userRepository.fetchInterestConcertEntryAlertsCallCount == 1)
        #expect(sut.state.interest.shouldShowInterestResultSheet)
        #expect(sut.state.interest.interestResultAlertList == alertList)
    }

    @Test("entry-alerts 결과가 비어 있지 않으면 시트를 띄워야 한다")
    func testInterestResultAlertListShowsSheetWhenNonEmpty() async throws {
        // Given
        let sut = HomeStore()
        let alertList = makeInterestConcertEntryAlertList()

        // When & Then
        sut.send(.interest(._interestResultAlertListResult(.success(alertList))))
        #expect(sut.state.interest.shouldShowInterestResultSheet)
        #expect(sut.state.interest.interestResultAlertList == alertList)
    }

    @Test("interest onAppear 시 entry-alerts가 비어 있으면 시트를 띄우지 않아야 한다")
    func testOnAppearSkipsInterestResultSheetWhenAlertsAreEmpty() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestConcertEntryAlertListStub = []
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]

        let sut = HomeStore()

        // When
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then
        #expect(container.userRepository.fetchInterestConcertEntryAlertsCallCount == 1)
        #expect(!sut.state.interest.shouldShowInterestResultSheet)
        #expect(sut.state.interest.interestResultAlertList.isEmpty)
    }

    @Test("홈 섹션 데이터 반영 전에는 entry-alerts를 조회하지 않아야 한다")
    func testInterestResultAlertsAreFetchedAfterHomeSectionDataIsLoaded() async throws {
        // Given
        let alertList = makeInterestConcertEntryAlertList()
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.userRepository.interestConcertEntryAlertListStub = alertList
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]
        container.concertRepository.fetchHomeConcertSectionListDelay = 300_000_000

        let sut = HomeStore()

        // When
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(sut.state.interest.concertSectionList.isEmpty)
        #expect(container.userRepository.fetchInterestConcertEntryAlertsCallCount == 0)
        #expect(!sut.state.interest.shouldShowInterestResultSheet)

        try await Task.sleep(nanoseconds: 300_000_000)

        #expect(sut.state.interest.concertSectionList.count == 1)
        #expect(container.userRepository.fetchInterestConcertEntryAlertsCallCount == 1)
        #expect(sut.state.interest.shouldShowInterestResultSheet)
        #expect(sut.state.interest.interestResultAlertList == alertList)
    }

    @Test("홈 섹션 데이터 조회가 실패하면 entry-alerts를 조회하지 않아야 한다")
    func testInterestResultAlertsAreNotFetchedWhenHomeSectionDataFails() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [123])
        container.userRepository.interestConcertEntryAlertListStub = makeInterestConcertEntryAlertList()
        container.concertRepository.errorStub = .serverError

        let sut = HomeStore()

        // When
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then
        #expect(!sut.state.interest.errorMessage.isEmpty)
        #expect(container.userRepository.fetchInterestConcertEntryAlertsCallCount == 0)
        #expect(!sut.state.interest.shouldShowInterestResultSheet)
    }

    @Test("entry-alerts 조회 실패는 홈 초기 로딩과 오류 메시지로 전파하지 않아야 한다")
    func testInterestResultAlertFetchFailureDoesNotFailInitialHomeData() async throws {
        // Given
        container.userRepository.userStub = makeMockUser(nickname: "홍길동")
        container.userRepository.fetchInterestConcertEntryAlertsErrorStub = .serverError
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 1)]

        let sut = HomeStore()

        // When
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then
        #expect(sut.state.interest.user?.nickname == "홍길동")
        #expect(sut.state.interest.errorMessage.isEmpty)
        #expect(!sut.state.interest.shouldShowInterestResultSheet)
    }

    @Test("오류 메시지가 있으면 관심 콘서트 결과 시트를 폐기해야 한다")
    func testInterestResultSheetIsDiscardedWhenErrorMessageExists() async throws {
        // Given
        let sut = HomeStore()
        sut.send(.interest(._userResult(.failure(UserError.serverError))))
        #expect(!sut.state.interest.errorMessage.isEmpty)

        // When
        sut.send(.interest(._interestResultAlertListResult(.success(makeInterestConcertEntryAlertList()))))

        // Then
        #expect(!sut.state.interest.shouldShowInterestResultSheet)
        #expect(sut.state.interest.interestResultAlertList.isEmpty)
    }

    @Test("오류가 발생하면 대기 중인 관심 콘서트 결과 시트를 닫아야 한다")
    func testErrorClearsPendingInterestResultSheet() async throws {
        // Given
        let sut = HomeStore()
        sut.send(.interest(._interestResultAlertListResult(.success(makeInterestConcertEntryAlertList()))))
        #expect(sut.state.interest.shouldShowInterestResultSheet)

        // When
        sut.send(.interest(._interestListResult(.failure(UserError.serverError))))

        // Then
        #expect(sut.state.interest.isInterestListLoadFailed)
        #expect(sut.state.interest.errorMessage.isEmpty)
        #expect(!sut.state.interest.shouldShowInterestResultSheet)
        #expect(sut.state.interest.interestResultAlertList.isEmpty)
    }

    @Test("관심 목록 로드 실패 상태에서는 관심 콘서트 결과 시트를 띄우지 않아야 한다")
    func testInterestResultSheetIsBlockedWhenInterestListLoadFailed() {
        // Given
        let sut = HomeStore()
        sut.send(.interest(._interestListResult(.failure(UserError.serverError))))
        #expect(sut.state.interest.isInterestListLoadFailed)

        // When
        sut.send(.interest(._interestResultAlertListResult(.success(makeInterestConcertEntryAlertList()))))

        // Then
        #expect(!sut.state.interest.shouldShowInterestResultSheet)
        #expect(sut.state.interest.interestResultAlertList.isEmpty)
    }

    @Test("관심 콘서트 결과 시트 dismiss 시 시트만 닫혀야 한다")
    func testInterestResultSheetDismissClosesSheet() async throws {
        // Given
        let sut = HomeStore()
        sut.send(.interest(._interestResultAlertListResult(.success(makeInterestConcertEntryAlertList()))))
        #expect(sut.state.interest.shouldShowInterestResultSheet)

        // When
        sut.send(.interest(.onInterestResultSheetDismiss))

        // Then
        #expect(!sut.state.interest.shouldShowInterestResultSheet)
        #expect(sut.state.interest.interestResultAlertList.isEmpty)
    }

    @Test("이미 닫힌 관심 콘서트 결과 시트를 다시 dismiss해도 상태가 유지되어야 한다")
    func testInterestResultSheetDismissIsIdempotent() async throws {
        // Given
        let sut = HomeStore()
        sut.send(.interest(._interestResultAlertListResult(.success(makeInterestConcertEntryAlertList()))))
        sut.send(.interest(.onInterestResultSheetDismiss))
        #expect(!sut.state.interest.shouldShowInterestResultSheet)

        // When
        sut.send(.interest(.onInterestResultSheetDismiss))

        // Then
        #expect(!sut.state.interest.shouldShowInterestResultSheet)
        #expect(sut.state.interest.interestResultAlertList.isEmpty)
    }

    // MARK: - Home Layout Load 테스트

    @Test("userResult는 관심 상태에 저장하고 관심 목록·섹션을 조회하지 않아야 한다")
    func testUserResultStoresUserWithoutFetchingInterestListOrSections() async throws {
        let sut = HomeStore()
        let user = makeMockUser(hasPreferences: true)

        sut.send(.interest(._userResult(.success(user))))
        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(sut.state.interest.user?.nickname == user.nickname)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 0)
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 0)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 0)
        #expect(sut.state.interest.concertSectionList.isEmpty)
    }

    @Test("유저 조회 결과가 있어도 기존 관심 콘서트 상세 API를 호출하지 않아야 한다")
    func testUserResultDoesNotFetchLegacyInterestConcertDetail() async throws {
        let sut = HomeStore()
        let user = makeMockUser(hasPreferences: true)
        let section = makeMockSection(id: 6)
        let recommended = [makeMockConcert(id: 22)]

        container.concertRepository.homeSectionListStub = [section]
        container.concertRepository.recommendedConcertListStub = recommended
        container.userRepository.userStub = user

        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 1)
        #expect(container.concertRepository.fetchConcertScheduleListCallCount == 0)
        #expect(container.concertRepository.fetchMainSetlistCallCount == 0)
        #expect(container.setlistRepository.fetchSetlistSongsCallCount == 0)
        #expect(sut.state.interest.concertSectionList.first?.id == section.id)
        #expect(sut.state.interest.recommendedConcertList.first?.id == recommended.first?.id)
    }

    @Test("관심 콘서트 목록이 비어 있는 조회 실패 시 isInterestListLoadFailed를 설정하고 errorMessage는 비워야 한다")
    func testEmptyInterestConcertListFailureSetsLoadFailedWithoutErrorMessage() {
        // Given
        let sut = HomeStore()

        // When
        sut.send(.interest(._interestListResult(.failure(UserError.serverError))))

        // Then
        #expect(sut.state.interest.interestConcertList.isEmpty)
        #expect(sut.state.interest.isInterestListLoadFailed)
        #expect(sut.state.interest.errorMessage.isEmpty)
    }

    @Test("관심 콘서트 목록 조회 실패 결과가 들어오면 기존 관심 콘서트 목록을 유지하고 errorMessage를 설정해야 한다")
    func testInterestConcertListFailureKeepsInterestConcertListAndSetsErrorMessage() {
        let sut = HomeStore()

        sut.send(.interest(._interestListResult(.success(makeInterestConcertList(concertIDList: [123])))))
        sut.send(.interest(._interestListResult(.failure(UserError.serverError))))

        #expect(sut.state.interest.interestConcertList.map(\.id) == [123])
        #expect(!sut.state.interest.isInterestListLoadFailed)
        #expect(!sut.state.interest.errorMessage.isEmpty)
    }

    @Test("관심 콘서트 목록 조회 성공 시 isInterestListLoadFailed를 해제해야 한다")
    func testInterestConcertListSuccessClearsLoadFailed() {
        // Given
        let sut = HomeStore()
        sut.send(.interest(._interestListResult(.failure(UserError.serverError))))
        #expect(sut.state.interest.isInterestListLoadFailed)

        // When
        sut.send(.interest(._interestListResult(.success(makeInterestConcertList(concertIDList: [123])))))

        // Then
        #expect(!sut.state.interest.isInterestListLoadFailed)
        #expect(sut.state.interest.interestConcertList.map(\.id) == [123])
    }

    @Test("관심 콘서트 정렬을 선택하면 홈 섹션 조회 조건으로 목록을 다시 조회해야 한다")
    func testInterestConcertSortSelectedRefetchesInterestConcertList() async throws {
        // Given
        let sut = HomeStore()
        sut.send(.interest(._interestListResult(.success(makeInterestConcertList(concertIDList: [123])))))
        container.userRepository.interestConcertListStub = makeInterestConcertList(concertIDList: [456])

        // When
        sut.send(.interest(.interestConcertSortSelected(.concert)))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(sut.state.interest.interestConcertSort == .concert)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListFilter?.sort == .concert)
        #expect(container.userRepository.fetchInterestedConcertListFilter?.limit == 5)
        #expect(sut.state.interest.interestConcertList.map(\.id) == [456])
        #expect(sut.state.interest.errorMessage.isEmpty)
    }

    @Test("관심 콘서트 정렬 조회가 실패하면 기존 목록을 유지하고 errorMessage를 설정해야 한다")
    func testInterestConcertSortFetchFailureKeepsExistingListAndSetsErrorMessage() async throws {
        // Given
        let sut = HomeStore()
        sut.send(.interest(._interestListResult(.success(makeInterestConcertList(concertIDList: [123])))))
        container.userRepository.fetchInterestedConcertListErrorStub = .serverError

        // When
        sut.send(.interest(.interestConcertSortSelected(.concert)))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(sut.state.interest.interestConcertSort == .concert)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListFilter?.sort == .concert)
        #expect(container.userRepository.fetchInterestedConcertListFilter?.limit == 5)
        #expect(sut.state.interest.interestConcertList.map(\.id) == [123])
        #expect(!sut.state.interest.errorMessage.isEmpty)
    }

    @Test("같은 관심 콘서트 정렬을 다시 선택하면 목록을 다시 조회하지 않아야 한다")
    func testSameInterestConcertSortSelectedDoesNotRefetchInterestConcertList() async throws {
        // Given
        let sut = HomeStore()

        // When
        sut.send(.interest(.interestConcertSortSelected(.ticketing)))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(sut.state.interest.interestConcertSort == .ticketing)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 0)
    }

    @Test("유저 조회가 끝나고 다시 진입해도 홈 콘서트 섹션 초기 로딩은 한 번만 수행되어야 한다")
    func testUserResultDoesNotResetHomeConcertSectionInitialLoad() async throws {
        let sut = HomeStore()
        let user = makeMockUser(hasPreferences: true)

        container.userRepository.userStub = user
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 10)]
        container.concertRepository.recommendedConcertListStub = [makeMockConcert(id: 100)]

        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(container.userRepository.fetchUserCallCount == 1)
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 1)
    }

    @Test("관심 콘서트 목록 조회 결과가 바뀌어도 홈 콘서트 섹션 초기 로딩은 한 번만 수행되어야 한다")
    func testInterestConcertListResultChangeDoesNotResetHomeConcertSectionInitialLoad() async throws {
        let sut = HomeStore()
        let user = makeMockUser(hasPreferences: true)

        container.concertRepository.homeSectionListStub = [makeMockSection(id: 10)]
        container.concertRepository.recommendedConcertListStub = [makeMockConcert(id: 100)]
        container.userRepository.userStub = user

        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 100_000_000)

        sut.send(.interest(._interestListResult(.success(makeInterestConcertList(concertIDList: [123])))))
        try await Task.sleep(nanoseconds: 100_000_000)

        sut.send(.interest(._interestListResult(.success([]))))
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
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
        container.userRepository.userStub = user

        // When
        sut.send(.interest(.onAppear))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(container.concertRepository.fetchRecommendedConcertListCallCount == 0)
        #expect(sut.state.interest.concertSectionList.count == 1)
        #expect(sut.state.interest.shouldShowPreferenceBanner)
        #expect(sut.state.interest.recommendedConcertList.isEmpty)
    }

    @Test("concertSection onRefresh 시 홈 콘서트 섹션 데이터를 다시 로드해야 한다")
    func testConcertSectionOnRefreshReloadsHomeConcertSection() async throws {
        // Given
        let sut = HomeStore()
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 20)]

        // When
        sut.send(.interest(.onRefresh))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(container.concertRepository.fetchHomeConcertSectionListCallCount == 1)
        #expect(sut.state.interest.concertSectionList.first?.id == 20)
    }

    @Test("concertSection 데이터 로드 실패 시 errorMessage를 설정해야 한다")
    func testConcertSectionLoadFailureSetsErrorMessage() async throws {
        // Given
        let sut = HomeStore()
        container.concertRepository.errorStub = .serverError

        // When
        sut.send(.interest(.onRefresh))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(!sut.state.interest.errorMessage.isEmpty)
    }

    @Test("concertSection 데이터 로드 실패 후 성공 시 errorMessage를 비워야 한다")
    func testConcertSectionLoadSuccessClearsPreviousErrorMessage() async throws {
        // Given
        let sut = HomeStore()
        container.concertRepository.errorStub = .serverError

        sut.send(.interest(.onRefresh))
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(!sut.state.interest.errorMessage.isEmpty)

        container.concertRepository.errorStub = nil
        container.concertRepository.homeSectionListStub = [makeMockSection(id: 30)]

        // When
        sut.send(.interest(.onRefresh))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(sut.state.interest.errorMessage.isEmpty)
        #expect(sut.state.interest.concertSectionList.first?.id == 30)
    }

    @Test("onErrorToastDisappear 호출 시 errorMessage는 비워져야 한다")
    func testOnErrorToastDisappearClearsErrorMessage() {
        // Given
        let sut = HomeStore()
        sut.send(.interest(._userResult(.failure(UserError.serverError))))
        #expect(!sut.state.interest.errorMessage.isEmpty)

        // When
        sut.send(.interest(.onErrorToastDisappear))

        // Then
        #expect(sut.state.interest.errorMessage.isEmpty)
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

    func makeInterestConcertEntryAlertList() -> [InterestConcertEntryAlert] {
        [
            InterestConcertEntryAlert(
                kind: .autoRemovedCompleted,
                title: "자동 정리된 공연 1",
                content: "원 오크 록 내한 공연이 자동 정리 됐어요",
                concertID: nil
            ),
            InterestConcertEntryAlert(
                kind: .requestRegistered,
                title: "natori 콘서트",
                content: "나의 관심 콘서트에 추가됐어요",
                concertID: 55
            )
        ]
    }
}
