//
//  InterestConcertSettingStoreTests.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 5/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import HomeFeature
import DIContainer
import Domain

@MainActor
struct InterestConcertSettingStoreTests {

    // MARK: - Properties

    let container: MockDIContainer

    // MARK: - Initializer

    init() {
        self.container = MockDIContainer()
        self.container.registerDependencies()
    }

    // MARK: - Tests

    @Test("초기화 시 콘서트 첫 페이지를 조회하고 목록을 설정해야 한다")
    func 초기화_시_콘서트_첫_페이지를_조회하고_목록을_설정해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: TestNextToken()))
        ]

        // When
        let sut = InterestConcertSettingStore(mode: .initialSetup)
        try await waitForAsyncTask()

        // Then
        #expect(container.concertRepository.fetchAllConcertListCallCount == 1)
        #expect(container.concertRepository.fetchAllConcertListNextTokenList.isEmpty == false)
        if let nextToken = container.concertRepository.fetchAllConcertListNextTokenList.first,
           nextToken != nil {
            Issue.record("첫 페이지 조회는 nextToken 없이 호출해야 한다")
        }
        #expect(container.concertRepository.fetchAllConcertListSizeList.first == 12)
        #expect(sut.state.displayedConcertList.map(\.id) == [1, 2])
        #expect(sut.state.hasMoreConcertList)
        #expect(!sut.state.isInitialLoading)
    }

    @Test("다음 페이지 조회 시 nextToken을 그대로 넘기고 목록 뒤에 추가해야 한다")
    func 다음_페이지_조회_시_nextToken을_그대로_넘기고_목록_뒤에_추가해야_한다() async throws {
        // Given
        let nextToken = TestNextToken()
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: nextToken)),
            .success(ListResult(items: makeConcertList([3]), nextToken: nil))
        ]
        let sut = InterestConcertSettingStore(mode: .initialSetup)
        try await waitForAsyncTask()

        // When
        sut.send(.loadNextPage)
        try await waitForAsyncTask()

        // Then
        #expect(container.concertRepository.fetchAllConcertListCallCount == 2)
        #expect(container.concertRepository.fetchAllConcertListNextTokenList.dropFirst().first != nil)
        #expect(sut.state.displayedConcertList.map(\.id) == [1, 2, 3])
        #expect(!sut.state.hasMoreConcertList)
        #expect(!sut.state.isLoadingMore)
    }

    @Test("update 모드는 저장된 관심 콘서트를 조회해 초기 선택값으로 사용해야 한다")
    func update_모드는_저장된_관심_콘서트를_조회해_초기_선택값으로_사용해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: nil))
        ]
        container.userRepository.interestConcertListResultQueue = [
            .success(ListResult(items: makeInterestConcertList([2, 4]), nextToken: nil))
        ]

        // When
        let sut = InterestConcertSettingStore(mode: .update)
        try await waitForAsyncTask()

        // Then
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListFilter?.sort == nil)
        #expect(container.userRepository.fetchInterestedConcertListFilter?.limit == 20)
        #expect(container.userRepository.fetchInterestedConcertListFilter?.nextToken == nil)
        #expect(sut.state.selectedConcertIDList == [2, 4])
        #expect(sut.state.selectedConcertList.map(\.id) == [2, 4])
        #expect(!sut.state.isCTAEnabled)
        #expect(!sut.state.hasUnsavedChanges)
    }

    @Test("update 모드는 저장된 관심 콘서트 다음 token이 없을 때까지 조회해 초기 선택값으로 사용해야 한다")
    func update_모드는_저장된_관심_콘서트를_마지막_페이지까지_조회해_초기_선택값으로_사용해야_한다() async throws {
        // Given
        let nextToken = InitialSelectionNextToken(id: 2)
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: nil))
        ]
        container.userRepository.interestConcertListResultQueue = [
            .success(ListResult(items: makeInterestConcertList([2, 4]), nextToken: nextToken)),
            .success(ListResult(items: makeInterestConcertList([5]), nextToken: nil))
        ]

        // When
        let sut = InterestConcertSettingStore(mode: .update)
        try await waitForAsyncTask()

        // Then
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 2)
        let filterList = container.userRepository.fetchInterestedConcertListFilterList
        #expect(filterList.map(\.sort) == [nil, nil])
        #expect(filterList.map(\.limit) == [20, 20])
        #expect(filterList.first?.nextToken == nil)
        #expect(filterList.dropFirst().first?.nextToken as? InitialSelectionNextToken == nextToken)
        #expect(sut.state.selectedConcertIDList == [2, 4, 5])
        #expect(sut.state.selectedConcertList.map(\.id) == [2, 4, 5])
        #expect(!sut.state.isInitialLoading)
        #expect(!sut.state.isCTAEnabled)
        #expect(!sut.state.hasUnsavedChanges)
    }

    @Test("update 모드는 관심 콘서트 전체 조회가 끝날 때까지 초기 로딩 상태를 유지해야 한다")
    func update_모드는_관심_콘서트_전체_조회가_끝날_때까지_초기_로딩_상태를_유지해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: nil))
        ]
        container.userRepository.fetchInterestedConcertListDelayQueue = [300_000_000]
        container.userRepository.interestConcertListResultQueue = [
            .success(ListResult(items: makeInterestConcertList([2]), nextToken: nil))
        ]

        // When
        let sut = InterestConcertSettingStore(mode: .update)
        try await waitForAsyncTask()

        // Then
        #expect(sut.state.isInitialLoading)

        // When
        try await Task.sleep(nanoseconds: 300_000_000)

        // Then
        #expect(!sut.state.isInitialLoading)
        #expect(sut.state.selectedConcertIDList == [2])
    }

    @Test("update 모드는 초기 로딩 중 선택 변경과 제출을 무시해야 한다")
    func update_모드는_초기_로딩_중_선택_변경과_제출을_무시해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: nil))
        ]
        container.userRepository.fetchInterestedConcertListDelayQueue = [300_000_000]
        container.userRepository.interestConcertListResultQueue = [
            .success(ListResult(items: makeInterestConcertList([2]), nextToken: nil))
        ]
        let sut = InterestConcertSettingStore(mode: .update)
        try await waitForAsyncTask()

        // When
        sut.send(.toggleConcertSelection(1))
        sut.send(.submit)

        // Then
        #expect(sut.state.selectedConcertIDList.isEmpty)
        #expect(!sut.state.isCTAEnabled)
        #expect(container.userRepository.updateInterestedConcertListCallCount == 0)

        // Cleanup
        try await Task.sleep(nanoseconds: 300_000_000)
    }

    @Test("update 모드는 관심 콘서트 다음 페이지 조회 실패 시 부분 선택값을 반영하지 않아야 한다")
    func update_모드는_관심_콘서트_다음_페이지_조회_실패_시_부분_선택값을_반영하지_않아야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: nil))
        ]
        container.userRepository.interestConcertListResultQueue = [
            .success(ListResult(items: makeInterestConcertList([2]), nextToken: InitialSelectionNextToken(id: 2))),
            .failure(.serverError)
        ]

        // When
        let sut = InterestConcertSettingStore(mode: .update)
        try await waitForAsyncTask()

        // Then
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 2)
        #expect(sut.state.selectedConcertIDList.isEmpty)
        #expect(sut.state.selectedConcertList.isEmpty)
        #expect(!sut.state.isInitialLoading)
        #expect(!sut.state.errorMessage.isEmpty)
    }

    @Test("initialSetup 모드는 선택 변경에 따라 CTA 활성화 상태를 갱신해야 한다")
    func initialSetup_모드는_선택_변경에_따라_CTA_활성화_상태를_갱신해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: nil))
        ]
        let sut = InterestConcertSettingStore(mode: .initialSetup)
        try await waitForAsyncTask()

        #expect(!sut.state.hasUnsavedChanges)

        // When
        sut.send(.toggleConcertSelection(1))

        // Then
        #expect(sut.state.selectedConcertIDList == [1])
        #expect(sut.state.selectedConcertList.map(\.id) == [1])
        #expect(sut.state.isCTAEnabled)
        #expect(sut.state.hasUnsavedChanges)

        // When
        sut.send(.toggleConcertSelection(1))

        // Then
        #expect(sut.state.selectedConcertIDList.isEmpty)
        #expect(sut.state.selectedConcertList.isEmpty)
        #expect(!sut.state.isCTAEnabled)
        #expect(!sut.state.hasUnsavedChanges)
    }

    @Test("update 모드는 초기 선택과 달라질 때만 CTA를 활성화해야 한다")
    func update_모드는_초기_선택과_달라질_때만_CTA를_활성화해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: nil))
        ]
        container.userRepository.interestConcertListResultQueue = [
            .success(ListResult(items: makeInterestConcertList([1, 2]), nextToken: nil))
        ]
        let sut = InterestConcertSettingStore(mode: .update)
        try await waitForAsyncTask()

        // When
        sut.send(.toggleConcertSelection(2))

        // Then
        #expect(sut.state.selectedConcertIDList == [1])
        #expect(sut.state.isCTAEnabled)
        #expect(sut.state.hasUnsavedChanges)

        // When
        sut.send(.toggleConcertSelection(2))

        // Then
        #expect(Set(sut.state.selectedConcertIDList) == Set([1, 2]))
        #expect(!sut.state.isCTAEnabled)
        #expect(!sut.state.hasUnsavedChanges)
    }

    @Test("검색어 입력은 원문을 저장하고 초기화는 기본 목록과 포커스 상태를 갱신해야 한다")
    func 검색어_입력은_원문을_저장하고_초기화는_기본_목록과_포커스_상태를_갱신해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: nil))
        ]
        let sut = InterestConcertSettingStore(mode: .initialSetup)
        try await waitForAsyncTask()

        // When
        sut.send(.updateSearchText("  freedom  "))

        // Then
        #expect(sut.state.searchText == "  freedom  ")

        // When
        sut.send(.clearSearchText)

        // Then
        #expect(sut.state.searchText.isEmpty)
        #expect(sut.state.displayedConcertList.map(\.id) == [1, 2])
        #expect(sut.state.isSearchFocused)
    }

    @Test("검색어 입력 후 debounce 전에는 검색 API를 호출하지 않아야 한다")
    func 검색어_입력_후_debounce_전에는_검색_API를_호출하지_않아야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: nil))
        ]
        container.searchRepository.searchResultStub = SearchResult(
            concerts: makeConcertList([3]),
            cursor: nil,
            totalCount: 1
        )
        let sut = InterestConcertSettingStore(mode: .initialSetup)
        try await waitForAsyncTask()

        // When
        sut.send(.updateSearchText("  freedom  "))
        try await waitForAsyncTask()

        // Then
        #expect(container.searchRepository.fetchFilterSearchResultCallCount == 0)
        #expect(sut.state.searchText == "  freedom  ")

        // Cleanup
        sut.send(.clearSearchText)
    }

    @Test("검색어 입력 후 debounce가 지나면 고정 status로 검색 API를 호출하고 결과를 표시해야 한다")
    func 검색어_입력_후_debounce가_지나면_고정_status로_검색_API를_호출하고_결과를_표시해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: nil))
        ]
        container.searchRepository.searchResultStub = SearchResult(
            concerts: makeConcertList([3]),
            cursor: 3,
            totalCount: 1
        )
        let sut = InterestConcertSettingStore(mode: .initialSetup)
        try await waitForAsyncTask()

        // When
        sut.send(.updateSearchText("  freedom  "))
        try await waitForDebounceTask()

        // Then
        #expect(container.searchRepository.fetchFilterSearchResultCallCount == 1)
        #expect(container.searchRepository.fetchFilterSearchResultGenreList.first == [])
        #expect(container.searchRepository.fetchFilterSearchResultSortList.isEmpty == false)
        if let sort = container.searchRepository.fetchFilterSearchResultSortList.first,
           sort != nil {
            Issue.record("검색 API는 sort 없이 호출해야 한다")
        }
        #expect(container.searchRepository.fetchFilterSearchResultStatusList.first == [.ongoing, .upcoming])
        #expect(container.searchRepository.fetchFilterSearchResultKeywordList.first == "freedom")
        #expect(container.searchRepository.fetchFilterSearchResultCursorList.isEmpty == false)
        if let cursor = container.searchRepository.fetchFilterSearchResultCursorList.first,
           cursor != nil {
            Issue.record("검색 첫 요청은 cursor 없이 호출해야 한다")
        }
        #expect(container.searchRepository.fetchFilterSearchResultSizeList.first == 12)
        #expect(sut.state.displayedConcertList.map(\.id) == [3])
    }

    @Test("검색 첫 요청 중에는 로딩 상태를 표시해야 한다")
    func 검색_첫_요청_중에는_로딩_상태를_표시해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: nil))
        ]
        container.searchRepository.fetchFilterSearchResultDelayQueue = [300_000_000]
        container.searchRepository.searchResultStub = SearchResult(
            concerts: makeConcertList([3]),
            cursor: nil,
            totalCount: 1
        )
        let sut = InterestConcertSettingStore(mode: .initialSetup)
        try await waitForAsyncTask()

        // When
        sut.send(.updateSearchText("freedom"))
        try await waitForDebounceTask()

        // Then
        #expect(sut.state.isSearchLoading)

        // When
        try await waitForDebounceTask()

        // Then
        #expect(!sut.state.isSearchLoading)
        #expect(sut.state.displayedConcertList.map(\.id) == [3])
    }

    @Test("검색 실패 시 표시 목록을 비우고 errorMessage를 설정해야 한다")
    func 검색_실패_시_표시_목록을_비우고_errorMessage를_설정해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: nil))
        ]
        container.searchRepository.searchResultQueue = [
            .failure(.serverError)
        ]
        let sut = InterestConcertSettingStore(mode: .initialSetup)
        try await waitForAsyncTask()

        // When
        sut.send(.updateSearchText("freedom"))
        try await waitForDebounceTask()

        // Then
        #expect(sut.state.displayedConcertList.isEmpty)
        #expect(!sut.state.hasMoreConcertList)
        #expect(!sut.state.isSearchLoading)
        #expect(!sut.state.errorMessage.isEmpty)
    }

    @Test("검색 다음 페이지 조회 시 search cursor를 넘기고 목록 뒤에 추가해야 한다")
    func 검색_다음_페이지_조회_시_search_cursor를_넘기고_목록_뒤에_추가해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: TestNextToken()))
        ]
        container.searchRepository.searchResultQueue = [
            .success(SearchResult(concerts: makeConcertList([3]), cursor: 3, totalCount: 2)),
            .success(SearchResult(concerts: makeConcertList([4]), cursor: nil, totalCount: 2))
        ]
        let sut = InterestConcertSettingStore(mode: .initialSetup)
        try await waitForAsyncTask()
        sut.send(.updateSearchText("freedom"))
        try await waitForDebounceTask()

        // When
        sut.send(.loadNextPage)
        try await waitForAsyncTask()

        // Then
        #expect(container.concertRepository.fetchAllConcertListCallCount == 1)
        #expect(container.searchRepository.fetchFilterSearchResultCallCount == 2)
        #expect(container.searchRepository.fetchFilterSearchResultCursorList == [nil, 3])
        #expect(sut.state.displayedConcertList.map(\.id) == [3, 4])
        #expect(!sut.state.hasMoreConcertList)
        #expect(!sut.state.isLoadingMore)
    }

    @Test("검색어를 비우면 검색 API를 추가 호출하지 않고 기본 목록으로 복귀해야 한다")
    func 검색어를_비우면_검색_API를_추가_호출하지_않고_기본_목록으로_복귀해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: nil))
        ]
        container.searchRepository.searchResultStub = SearchResult(
            concerts: makeConcertList([3]),
            cursor: nil,
            totalCount: 1
        )
        let sut = InterestConcertSettingStore(mode: .initialSetup)
        try await waitForAsyncTask()
        sut.send(.updateSearchText("freedom"))
        try await waitForDebounceTask()

        // When
        sut.send(.clearSearchText)
        try await waitForAsyncTask()

        // Then
        #expect(container.searchRepository.fetchFilterSearchResultCallCount == 1)
        #expect(sut.state.searchText.isEmpty)
        #expect(sut.state.displayedConcertList.map(\.id) == [1, 2])
        #expect(sut.state.isSearchFocused)
    }

    @Test("첫 페이지 조회 실패 시 목록을 비우고 errorMessage를 설정해야 한다")
    func 첫_페이지_조회_실패_시_목록을_비우고_errorMessage를_설정해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .failure(.serverError)
        ]

        // When
        let sut = InterestConcertSettingStore(mode: .initialSetup)
        try await waitForAsyncTask()

        // Then
        #expect(sut.state.displayedConcertList.isEmpty)
        #expect(!sut.state.hasMoreConcertList)
        #expect(!sut.state.isInitialLoading)
        #expect(!sut.state.errorMessage.isEmpty)
    }

    @Test("다음 페이지 조회 실패 시 기존 목록을 유지하고 로딩을 종료해야 한다")
    func 다음_페이지_조회_실패_시_기존_목록을_유지하고_로딩을_종료해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: TestNextToken())),
            .failure(.serverError)
        ]
        let sut = InterestConcertSettingStore(mode: .initialSetup)
        try await waitForAsyncTask()

        // When
        sut.send(.loadNextPage)
        try await waitForAsyncTask()

        // Then
        #expect(sut.state.displayedConcertList.map(\.id) == [1, 2])
        #expect(!sut.state.isLoadingMore)
        #expect(!sut.state.errorMessage.isEmpty)
    }

    @Test("설정 제출 성공 시 선택한 콘서트 ID 목록으로 API를 호출하고 설정 성공 문구를 설정해야 한다")
    func 설정_제출_성공_시_선택한_콘서트_ID_목록으로_API를_호출하고_설정_성공_문구를_설정해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: nil))
        ]
        container.userRepository.updatedConcertListStub = makeConcertList([1, 2])
        let sut = InterestConcertSettingStore(mode: .initialSetup)
        try await waitForAsyncTask()
        sut.send(.toggleConcertSelection(1))
        sut.send(.toggleConcertSelection(2))

        // When
        sut.send(.submit)
        try await waitForAsyncTask()

        // Then
        #expect(container.userRepository.updateInterestedConcertListCallCount == 1)
        #expect(container.userRepository.updateInterestedConcertIDList == [1, 2])
        #expect(sut.state.successMessage == "소식을 받을 공연이 설정되었어요")
        #expect(!sut.state.isSubmitting)
        #expect(!sut.state.hasUnsavedChanges)
    }

    @Test("변경 제출 성공 시 선택한 콘서트 ID 목록으로 API를 호출하고 변경 성공 문구를 설정해야 한다")
    func 변경_제출_성공_시_선택한_콘서트_ID_목록으로_API를_호출하고_변경_성공_문구를_설정해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: nil))
        ]
        container.userRepository.interestConcertListResultQueue = [
            .success(ListResult(items: makeInterestConcertList([1]), nextToken: nil))
        ]
        container.userRepository.updatedConcertListStub = makeConcertList([1, 2])
        let sut = InterestConcertSettingStore(mode: .update)
        try await waitForAsyncTask()
        sut.send(.toggleConcertSelection(2))

        // When
        sut.send(.submit)
        try await waitForAsyncTask()

        // Then
        #expect(container.userRepository.updateInterestedConcertListCallCount == 1)
        #expect(container.userRepository.updateInterestedConcertIDList == [1, 2])
        #expect(sut.state.successMessage == "소식을 받을 공연이 변경되었어요")
        #expect(!sut.state.isSubmitting)
        #expect(!sut.state.hasUnsavedChanges)
    }

    @Test("CTA 비활성 상태에서 제출하면 관심 콘서트 설정 API를 호출하지 않아야 한다")
    func CTA_비활성_상태에서_제출하면_관심_콘서트_설정_API를_호출하지_않아야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1]), nextToken: nil))
        ]
        let sut = InterestConcertSettingStore(mode: .initialSetup)
        try await waitForAsyncTask()

        // When
        sut.send(.submit)

        // Then
        #expect(container.userRepository.updateInterestedConcertListCallCount == 0)
        #expect(!sut.state.isSubmitting)
    }

    @Test("설정 제출 실패 시 설정 실패 문구를 설정하고 제출 로딩을 종료해야 한다")
    func 설정_제출_실패_시_설정_실패_문구를_설정하고_제출_로딩을_종료해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1]), nextToken: nil))
        ]
        container.userRepository.errorStub = .serverError
        let sut = InterestConcertSettingStore(mode: .initialSetup)
        try await waitForAsyncTask()
        sut.send(.toggleConcertSelection(1))

        // When
        sut.send(.submit)
        try await waitForAsyncTask()

        // Then
        #expect(container.userRepository.updateInterestedConcertListCallCount == 1)
        #expect(sut.state.errorMessage == "소식을 받을 공연 추가에 실패했어요")
        #expect(!sut.state.isSubmitting)
    }

    @Test("변경 제출 실패 시 변경 실패 문구를 설정하고 제출 로딩을 종료해야 한다")
    func 변경_제출_실패_시_변경_실패_문구를_설정하고_제출_로딩을_종료해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: nil))
        ]
        container.userRepository.interestConcertListResultQueue = [
            .success(ListResult(items: makeInterestConcertList([1]), nextToken: nil))
        ]
        let sut = InterestConcertSettingStore(mode: .update)
        try await waitForAsyncTask()
        container.userRepository.errorStub = .serverError
        sut.send(.toggleConcertSelection(2))

        // When
        sut.send(.submit)
        try await waitForAsyncTask()

        // Then
        #expect(container.userRepository.updateInterestedConcertListCallCount == 1)
        #expect(sut.state.errorMessage == "소식을 받을 공연 변경에 실패했어요")
        #expect(!sut.state.isSubmitting)
    }
}

// MARK: - Helpers

private extension InterestConcertSettingStoreTests {
    func makeConcertList(_ idList: [Int]) -> [Concert] {
        idList.map(makeConcert)
    }

    func makeInterestConcertList(_ idList: [Int]) -> [InterestConcert] {
        makeConcertList(idList).map {
            InterestConcert(
                concert: $0,
                ticketingSchedule: InterestConcertTicketingSchedule(preSaleDate: nil, generalSaleDate: nil)
            )
        }
    }

    func makeConcert(id: Int) -> Concert {
        Concert(
            id: id,
            title: "테스트 콘서트 \(id)",
            artist: "테스트 아티스트",
            status: .upcoming,
            daysLeft: 10,
            startDate: Date(timeIntervalSince1970: 1_783_584_000 + TimeInterval(id)),
            endDate: Date(timeIntervalSince1970: 1_783_670_400 + TimeInterval(id)),
            posterURL: URL(string: "https://example.com/poster\(id).jpg"),
            venue: "테스트 공연장",
            ticketSite: "인터파크",
            ticketURL: URL(string: "https://ticket.example.com"),
            introduction: "테스트 소개",
            label: nil
        )
    }

    func waitForAsyncTask() async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
    }

    func waitForDebounceTask() async throws {
        try await Task.sleep(nanoseconds: 450_000_000)
    }
}

private struct TestNextToken: NextToken {}

private struct InitialSelectionNextToken: NextToken, Equatable {
    let id: Int
}
