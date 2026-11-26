//
//  InterestConcertSettingViewModelTests.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 5/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import HomeFeature
import Domain

@MainActor
struct InterestConcertSettingViewModelTests {

    // MARK: - Properties

    let concertRepository = MockConcertRepository()
    let userRepository = MockUserRepository()
    let searchRepository = MockSearchRepository()

    private func makeViewModel(mode: InterestConcertSettingMode) -> InterestConcertSettingViewModel {
        InterestConcertSettingViewModel(
            mode: mode,
            concertCatalogRepository: concertRepository,
            searchRepository: searchRepository,
            interestConcertRepository: userRepository
        )
    }

    // MARK: - Tests

    @Test("첫 진입 시 콘서트 첫 페이지를 조회하고 목록을 설정해야 한다")
    func 첫_진입_시_콘서트_첫_페이지를_조회하고_목록을_설정해야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), position: TestPosition()))
        ]

        // When
        let sut = makeViewModel(mode: .initialSetup)
        await sut.loadIfNeeded()

        // Then
        #expect(concertRepository.fetchAllConcertListCallCount == 1)
        #expect(concertRepository.fetchAllConcertListPositionList.isEmpty == false)
        if let position = concertRepository.fetchAllConcertListPositionList.first,
           position != nil {
            Issue.record("첫 페이지 조회는 position 없이 호출해야 한다")
        }
        #expect(concertRepository.fetchAllConcertListSizeList.first == 12)
        #expect(sut.displayedConcertList.map(\.id) == [1, 2])
        #expect(sut.hasMoreConcertList)
        #expect(!sut.isInitialLoading)
    }

    @Test("다음 페이지 조회 시 position을 그대로 넘기고 목록 뒤에 추가해야 한다")
    func 다음_페이지_조회_시_position을_그대로_넘기고_목록_뒤에_추가해야_한다() async throws {
        // Given
        let position = TestPosition()
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), position: position)),
            .success(ListResult(items: makeConcertList([3]), position: nil))
        ]
        let sut = makeViewModel(mode: .initialSetup)
        await sut.loadIfNeeded()

        // When
        await sut.loadNextPage()

        // Then
        #expect(concertRepository.fetchAllConcertListCallCount == 2)
        #expect(concertRepository.fetchAllConcertListPositionList.dropFirst().first != nil)
        #expect(sut.displayedConcertList.map(\.id) == [1, 2, 3])
        #expect(!sut.hasMoreConcertList)
        #expect(!sut.isLoadingMore)
    }

    @Test("update 모드는 저장된 관심 콘서트를 조회해 초기 선택값으로 사용해야 한다")
    func update_모드는_저장된_관심_콘서트를_조회해_초기_선택값으로_사용해야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), position: nil))
        ]
        userRepository.interestConcertListResultQueue = [
            .success(ListResult(items: makeInterestConcertList([2, 4]), position: nil))
        ]

        // When
        let sut = makeViewModel(mode: .update)
        await sut.loadIfNeeded()

        // Then
        #expect(userRepository.fetchInterestedConcertListCallCount == 1)
        #expect(userRepository.fetchInterestedConcertListFilter?.sort == nil)
        #expect(userRepository.fetchInterestedConcertListFilter?.limit == 50)
        #expect(userRepository.fetchInterestedConcertListFilter?.position == nil)
        #expect(sut.selectedConcertIDList == [2, 4])
        #expect(sut.selectedConcertList.map(\.id) == [2, 4])
        #expect(!sut.hasUnsavedChanges)
    }

    @Test("update 모드는 저장된 관심 콘서트 목록을 이어 조회할 위치가 없을 때까지 조회해 초기 선택값으로 사용해야 한다")
    func update_모드는_저장된_관심_콘서트를_마지막_페이지까지_조회해_초기_선택값으로_사용해야_한다() async throws {
        // Given
        let position = InitialSelectionPosition(id: 2)
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), position: nil))
        ]
        userRepository.interestConcertListResultQueue = [
            .success(ListResult(items: makeInterestConcertList([2, 4]), position: position)),
            .success(ListResult(items: makeInterestConcertList([5]), position: nil))
        ]

        // When
        let sut = makeViewModel(mode: .update)
        await sut.loadIfNeeded()

        // Then
        #expect(userRepository.fetchInterestedConcertListCallCount == 2)
        let filterList = userRepository.fetchInterestedConcertListFilterList
        #expect(filterList.map(\.sort) == [nil, nil])
        #expect(filterList.map(\.limit) == [50, 50])
        #expect(filterList.first?.position == nil)
        #expect(filterList.dropFirst().first?.position as? InitialSelectionPosition == position)
        #expect(sut.selectedConcertIDList == [2, 4, 5])
        #expect(sut.selectedConcertList.map(\.id) == [2, 4, 5])
        #expect(!sut.isInitialLoading)
        #expect(!sut.hasUnsavedChanges)
    }

    @Test("update 모드는 관심 콘서트 전체 조회가 끝날 때까지 초기 로딩 상태를 유지해야 한다")
    func update_모드는_관심_콘서트_전체_조회가_끝날_때까지_초기_로딩_상태를_유지해야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), position: nil))
        ]
        userRepository.fetchInterestedConcertListDelayQueue = [300_000_000]
        userRepository.interestConcertListResultQueue = [
            .success(ListResult(items: makeInterestConcertList([2]), position: nil))
        ]

        // When
        let sut = makeViewModel(mode: .update)
        let load = Task { await sut.loadIfNeeded() }
        await Task.yield()

        // Then
        #expect(sut.isInitialLoading)

        // When
        await load.value

        // Then
        #expect(!sut.isInitialLoading)
        #expect(sut.selectedConcertIDList == [2])
    }

    @Test("update 모드는 초기 로딩 중 선택 변경과 제출을 무시해야 한다")
    func update_모드는_초기_로딩_중_선택_변경과_제출을_무시해야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), position: nil))
        ]
        userRepository.fetchInterestedConcertListDelayQueue = [300_000_000]
        userRepository.interestConcertListResultQueue = [
            .success(ListResult(items: makeInterestConcertList([2]), position: nil))
        ]
        let sut = makeViewModel(mode: .update)
        let load = Task { await sut.loadIfNeeded() }
        await Task.yield()

        // When
        sut.toggleConcertSelection(1)
        let didSave = await sut.submit()
        #expect(!didSave)

        // Then
        #expect(sut.selectedConcertIDList.isEmpty)
        #expect(!sut.hasUnsavedChanges)
        #expect(userRepository.updateInterestedConcertListCallCount == 0)

        // Cleanup
        await load.value
    }

    @Test("update 모드는 관심 콘서트 다음 페이지 조회 실패 시 부분 선택값을 반영하지 않아야 한다")
    func update_모드는_관심_콘서트_다음_페이지_조회_실패_시_부분_선택값을_반영하지_않아야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), position: nil))
        ]
        userRepository.interestConcertListResultQueue = [
            .success(ListResult(items: makeInterestConcertList([2]), position: InitialSelectionPosition(id: 2))),
            .failure(.serverError)
        ]

        // When
        let sut = makeViewModel(mode: .update)
        await sut.loadIfNeeded()

        // Then
        #expect(userRepository.fetchInterestedConcertListCallCount == 2)
        #expect(sut.selectedConcertIDList.isEmpty)
        #expect(sut.selectedConcertList.isEmpty)
        #expect(!sut.isInitialLoading)
        #expect(sut.isErrorToastPresented)
        #expect(!sut.errorMessage.isEmpty)
    }

    @Test("initialSetup 모드는 선택 변경에 따라 CTA 활성화 상태를 갱신해야 한다")
    func initialSetup_모드는_선택_변경에_따라_CTA_활성화_상태를_갱신해야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), position: nil))
        ]
        let sut = makeViewModel(mode: .initialSetup)
        await sut.loadIfNeeded()

        #expect(!sut.hasUnsavedChanges)

        // When
        sut.toggleConcertSelection(1)

        // Then
        #expect(sut.selectedConcertIDList == [1])
        #expect(sut.selectedConcertList.map(\.id) == [1])
        #expect(sut.hasUnsavedChanges)

        // When
        sut.toggleConcertSelection(1)

        // Then
        #expect(sut.selectedConcertIDList.isEmpty)
        #expect(sut.selectedConcertList.isEmpty)
        #expect(!sut.hasUnsavedChanges)
    }

    @Test("update 모드는 초기 선택과 달라질 때만 CTA를 활성화해야 한다")
    func update_모드는_초기_선택과_달라질_때만_CTA를_활성화해야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), position: nil))
        ]
        userRepository.interestConcertListResultQueue = [
            .success(ListResult(items: makeInterestConcertList([1, 2]), position: nil))
        ]
        let sut = makeViewModel(mode: .update)
        await sut.loadIfNeeded()

        // When
        sut.toggleConcertSelection(2)

        // Then
        #expect(sut.selectedConcertIDList == [1])
        #expect(sut.hasUnsavedChanges)

        // When
        sut.toggleConcertSelection(2)

        // Then
        #expect(Set(sut.selectedConcertIDList) == Set([1, 2]))
        #expect(!sut.hasUnsavedChanges)
    }

    @Test("공연 요청에서 돌아오면 선택을 유지하고 새 설정 화면은 저장된 선택으로 시작한다")
    func 화면_재표시와_새_진입의_선택_수명() async {
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1]), position: nil))
        ]
        let sut = makeViewModel(mode: .initialSetup)
        await sut.loadIfNeeded()
        sut.toggleConcertSelection(1)
        await sut.loadIfNeeded()
        #expect(sut.selectedConcertIDList == [1])
        #expect(concertRepository.fetchAllConcertListCallCount == 1)

        let reopened = makeViewModel(mode: .initialSetup)
        await reopened.loadIfNeeded()
        #expect(reopened.selectedConcertIDList.isEmpty)
    }

    @Test("검색을 지운 뒤 늦게 도착한 검색 페이지가 기본 목록을 덮지 않는다")
    func 검색_취소_후_기본_목록_유지() async throws {
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1]), position: nil))
        ]
        searchRepository.searchResultStub = ListResult(items: makeConcertList([2]), position: TestSearchPosition(value: 2))
        let sut = makeViewModel(mode: .initialSetup)
        await sut.loadIfNeeded()
        sut.updateSearchText("공연")
        try await waitUntil { sut.displayedConcertList.map(\.id) == [2] }

        searchRepository.fetchFilterSearchResultDelayQueue = [150_000_000]
        let next = Task { await sut.loadNextPage() }
        try await waitUntil { searchRepository.fetchFilterSearchResultCallCount == 2 }
        sut.clearSearchText()
        await next.value

        #expect(sut.displayedConcertList.map(\.id) == [1])
        #expect(!sut.isLoadingMore)
        #expect(!sut.hasMoreConcertList)
    }

    @Test("검색어 입력은 원문을 저장하고 초기화는 기본 목록과 포커스 상태를 갱신해야 한다")
    func 검색어_입력은_원문을_저장하고_초기화는_기본_목록과_포커스_상태를_갱신해야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), position: nil))
        ]
        let sut = makeViewModel(mode: .initialSetup)
        await sut.loadIfNeeded()

        // When
        sut.updateSearchText("  freedom  ")

        // Then
        #expect(sut.searchText == "  freedom  ")

        // When
        sut.clearSearchText()

        // Then
        #expect(sut.searchText.isEmpty)
        #expect(sut.displayedConcertList.map(\.id) == [1, 2])
        #expect(sut.isSearchFocused)
    }

    @Test("검색어 입력 후 debounce 전에는 검색 API를 호출하지 않아야 한다")
    func 검색어_입력_후_debounce_전에는_검색_API를_호출하지_않아야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), position: nil))
        ]
        searchRepository.searchResultStub = ListResult(
            items: makeConcertList([3]),
            position: nil
        )
        let sut = makeViewModel(mode: .initialSetup)
        await sut.loadIfNeeded()

        // When
        sut.updateSearchText("  freedom  ")
        try await waitForAsyncTask()

        // Then
        #expect(searchRepository.fetchFilterSearchResultCallCount == 0)
        #expect(sut.searchText == "  freedom  ")

        // Cleanup
        sut.clearSearchText()
    }

    @Test("검색어 입력 후 debounce가 지나면 고정 status로 검색 API를 호출하고 결과를 표시해야 한다")
    func 검색어_입력_후_debounce가_지나면_고정_status로_검색_API를_호출하고_결과를_표시해야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), position: nil))
        ]
        searchRepository.searchResultStub = ListResult(
            items: makeConcertList([3]),
            position: TestSearchPosition(value: 3)
        )
        let sut = makeViewModel(mode: .initialSetup)
        await sut.loadIfNeeded()

        // When
        sut.updateSearchText("  freedom  ")
        try await waitUntil { searchRepository.fetchFilterSearchResultCallCount == 1 && !sut.isSearchLoading }

        // Then
        #expect(searchRepository.fetchFilterSearchResultCallCount == 1)
        #expect(searchRepository.fetchFilterSearchResultGenreList.first == [])
        #expect(searchRepository.fetchFilterSearchResultSortList.isEmpty == false)
        if let sort = searchRepository.fetchFilterSearchResultSortList.first,
           sort != nil {
            Issue.record("검색 API는 sort 없이 호출해야 한다")
        }
        #expect(searchRepository.fetchFilterSearchResultStatusList.first == [.ongoing, .upcoming])
        #expect(searchRepository.fetchFilterSearchResultKeywordList.first == "freedom")
        #expect(searchRepository.fetchFilterSearchResultPositionValueList.isEmpty == false)
        if let positionValue = searchRepository.fetchFilterSearchResultPositionValueList.first,
           positionValue != nil {
            Issue.record("검색 첫 요청은 조회 위치 없이 호출해야 한다")
        }
        #expect(searchRepository.fetchFilterSearchResultSizeList.first == 12)
        #expect(sut.displayedConcertList.map(\.id) == [3])
    }

    @Test("검색 첫 요청 중에는 로딩 상태를 표시해야 한다")
    func 검색_첫_요청_중에는_로딩_상태를_표시해야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), position: nil))
        ]
        searchRepository.fetchFilterSearchResultDelayQueue = [300_000_000]
        searchRepository.searchResultStub = ListResult(
            items: makeConcertList([3]),
            position: nil
        )
        let sut = makeViewModel(mode: .initialSetup)
        await sut.loadIfNeeded()

        // When
        sut.updateSearchText("freedom")
        try await waitUntil { sut.isSearchLoading }

        // Then
        #expect(sut.isSearchLoading)

        // When
        try await waitUntil { !sut.isSearchLoading }

        // Then
        #expect(!sut.isSearchLoading)
        #expect(sut.displayedConcertList.map(\.id) == [3])
    }

    @Test("검색 실패 시 표시 목록을 비우고 errorMessage를 설정해야 한다")
    func 검색_실패_시_표시_목록을_비우고_errorMessage를_설정해야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), position: nil))
        ]
        searchRepository.searchResultQueue = [
            .failure(.serverError)
        ]
        let sut = makeViewModel(mode: .initialSetup)
        await sut.loadIfNeeded()

        // When
        sut.updateSearchText("freedom")
        try await waitUntil { !sut.errorMessage.isEmpty }

        // Then
        #expect(sut.displayedConcertList.isEmpty)
        #expect(!sut.hasMoreConcertList)
        #expect(!sut.isSearchLoading)
        #expect(sut.isErrorToastPresented)
        #expect(!sut.errorMessage.isEmpty)
    }

    @Test("검색 다음 페이지 조회 시 이어 조회할 위치를 넘기고 목록 뒤에 추가해야 한다")
    func 검색_다음_페이지_조회_시_이어_조회할_위치를_넘기고_목록_뒤에_추가해야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), position: TestPosition()))
        ]
        searchRepository.searchResultQueue = [
            .success(ListResult(items: makeConcertList([3]), position: TestSearchPosition(value: 3))),
            .success(ListResult(items: makeConcertList([4]), position: nil))
        ]
        let sut = makeViewModel(mode: .initialSetup)
        await sut.loadIfNeeded()
        sut.updateSearchText("freedom")
        try await waitUntil { sut.displayedConcertList.map(\.id) == [3] }

        // When
        await sut.loadNextPage()

        // Then
        #expect(concertRepository.fetchAllConcertListCallCount == 1)
        #expect(searchRepository.fetchFilterSearchResultCallCount == 2)
        #expect(searchRepository.fetchFilterSearchResultPositionValueList == [nil, 3])
        #expect(sut.displayedConcertList.map(\.id) == [3, 4])
        #expect(!sut.hasMoreConcertList)
        #expect(!sut.isLoadingMore)
    }

    @Test("검색어를 비우면 검색 API를 추가 호출하지 않고 기본 목록으로 복귀해야 한다")
    func 검색어를_비우면_검색_API를_추가_호출하지_않고_기본_목록으로_복귀해야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), position: nil))
        ]
        searchRepository.searchResultStub = ListResult(
            items: makeConcertList([3]),
            position: nil
        )
        let sut = makeViewModel(mode: .initialSetup)
        await sut.loadIfNeeded()
        sut.updateSearchText("freedom")
        try await waitUntil { sut.displayedConcertList.map(\.id) == [3] }

        // When
        sut.clearSearchText()

        // Then
        #expect(searchRepository.fetchFilterSearchResultCallCount == 1)
        #expect(sut.searchText.isEmpty)
        #expect(sut.displayedConcertList.map(\.id) == [1, 2])
        #expect(sut.isSearchFocused)
    }

    @Test("첫 페이지 조회 실패 시 목록을 비우고 errorMessage를 설정해야 한다")
    func 첫_페이지_조회_실패_시_목록을_비우고_errorMessage를_설정해야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .failure(.serverError)
        ]

        // When
        let sut = makeViewModel(mode: .initialSetup)
        await sut.loadIfNeeded()

        // Then
        #expect(sut.displayedConcertList.isEmpty)
        #expect(!sut.hasMoreConcertList)
        #expect(!sut.isInitialLoading)
        #expect(sut.isErrorToastPresented)
        #expect(!sut.errorMessage.isEmpty)
    }

    @Test("다음 페이지 조회 실패 시 기존 목록을 유지하고 로딩을 종료해야 한다")
    func 다음_페이지_조회_실패_시_기존_목록을_유지하고_로딩을_종료해야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), position: TestPosition())),
            .failure(.serverError)
        ]
        let sut = makeViewModel(mode: .initialSetup)
        await sut.loadIfNeeded()

        // When
        await sut.loadNextPage()

        // Then
        #expect(sut.displayedConcertList.map(\.id) == [1, 2])
        #expect(!sut.isLoadingMore)
        #expect(sut.isErrorToastPresented)
        #expect(!sut.errorMessage.isEmpty)
    }

    @Test("설정 제출 성공 시 선택한 콘서트 ID 목록으로 API를 호출하고 설정 성공 문구를 설정해야 한다")
    func 설정_제출_성공_시_선택한_콘서트_ID_목록으로_API를_호출하고_설정_성공_문구를_설정해야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), position: nil))
        ]
        userRepository.updatedConcertListStub = makeConcertList([1, 2])
        let sut = makeViewModel(mode: .initialSetup)
        await sut.loadIfNeeded()
        sut.toggleConcertSelection(1)
        sut.toggleConcertSelection(2)

        // When
        let didSave = await sut.submit()
        #expect(didSave)

        // Then
        #expect(userRepository.updateInterestedConcertListCallCount == 1)
        #expect(userRepository.updateInterestedConcertIDList == [1, 2])
        #expect(sut.mode.successMessage == "소식을 받을 공연이 설정되었어요")
        #expect(!sut.isSubmitting)
        #expect(!sut.hasUnsavedChanges)
    }

    @Test("변경 제출 성공 시 선택한 콘서트 ID 목록으로 API를 호출하고 변경 성공 문구를 설정해야 한다")
    func 변경_제출_성공_시_선택한_콘서트_ID_목록으로_API를_호출하고_변경_성공_문구를_설정해야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), position: nil))
        ]
        userRepository.interestConcertListResultQueue = [
            .success(ListResult(items: makeInterestConcertList([1]), position: nil))
        ]
        userRepository.updatedConcertListStub = makeConcertList([1, 2])
        let sut = makeViewModel(mode: .update)
        await sut.loadIfNeeded()
        sut.toggleConcertSelection(2)

        // When
        let didSave = await sut.submit()
        #expect(didSave)

        // Then
        #expect(userRepository.updateInterestedConcertListCallCount == 1)
        #expect(userRepository.updateInterestedConcertIDList == [1, 2])
        #expect(sut.mode.successMessage == "소식을 받을 공연이 변경되었어요")
        #expect(!sut.isSubmitting)
        #expect(!sut.hasUnsavedChanges)
    }

    @Test("CTA 비활성 상태에서 제출하면 관심 콘서트 설정 API를 호출하지 않아야 한다")
    func CTA_비활성_상태에서_제출하면_관심_콘서트_설정_API를_호출하지_않아야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1]), position: nil))
        ]
        let sut = makeViewModel(mode: .initialSetup)
        await sut.loadIfNeeded()

        // When
        let didSave = await sut.submit()
        #expect(!didSave)

        // Then
        #expect(userRepository.updateInterestedConcertListCallCount == 0)
        #expect(!sut.isSubmitting)
    }

    @Test("설정 제출 실패 시 설정 실패 문구를 설정하고 제출 로딩을 종료해야 한다")
    func 설정_제출_실패_시_설정_실패_문구를_설정하고_제출_로딩을_종료해야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1]), position: nil))
        ]
        userRepository.errorStub = .serverError
        let sut = makeViewModel(mode: .initialSetup)
        await sut.loadIfNeeded()
        sut.toggleConcertSelection(1)

        // When
        let didSave = await sut.submit()
        #expect(!didSave)

        // Then
        #expect(userRepository.updateInterestedConcertListCallCount == 1)
        #expect(sut.errorMessage == "소식을 받을 공연 추가에 실패했어요")
        #expect(!sut.isSubmitting)
    }

    @Test("같은 저장 오류가 연속 발생해도 토스트를 다시 표시한다")
    func 같은_저장_오류의_반복_표시() async {
        let sut = makeViewModel(mode: .initialSetup)
        await sut.loadIfNeeded()
        sut.toggleConcertSelection(1)
        userRepository.errorStub = .serverError

        _ = await sut.submit()
        #expect(sut.isErrorToastPresented)
        let message = sut.errorMessage
        _ = await sut.submit()

        sut.isErrorToastPresented = false
        sut.presentPendingErrorIfNeeded()
        #expect(sut.isErrorToastPresented)
        #expect(sut.errorMessage == message)
        sut.isErrorToastPresented = false
        sut.presentPendingErrorIfNeeded()
        #expect(!sut.isErrorToastPresented)

        _ = await sut.submit()
        #expect(sut.isErrorToastPresented)
    }

    @Test("변경 제출 실패 시 변경 실패 문구를 설정하고 제출 로딩을 종료해야 한다")
    func 변경_제출_실패_시_변경_실패_문구를_설정하고_제출_로딩을_종료해야_한다() async throws {
        // Given
        concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), position: nil))
        ]
        userRepository.interestConcertListResultQueue = [
            .success(ListResult(items: makeInterestConcertList([1]), position: nil))
        ]
        let sut = makeViewModel(mode: .update)
        await sut.loadIfNeeded()
        userRepository.errorStub = .serverError
        sut.toggleConcertSelection(2)

        // When
        let didSave = await sut.submit()
        #expect(!didSave)

        // Then
        #expect(userRepository.updateInterestedConcertListCallCount == 1)
        #expect(sut.errorMessage == "소식을 받을 공연 변경에 실패했어요")
        #expect(!sut.isSubmitting)
    }
}

// MARK: - Helpers

private extension InterestConcertSettingViewModelTests {
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

    func waitUntil(_ condition: () -> Bool) async throws {
        let deadline = ContinuousClock.now + .seconds(5)
        while !condition(), ContinuousClock.now < deadline {
            try await Task.sleep(for: .milliseconds(5))
        }
        try #require(condition())
    }
}

private struct TestPosition: PagePosition {}

private struct InitialSelectionPosition: PagePosition, Equatable {
    let id: Int
}
