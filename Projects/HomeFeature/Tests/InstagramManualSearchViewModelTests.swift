//
//  InstagramManualSearchViewModelTests.swift
//  HomeFeatureTests
//
//  Created by youz2me on 7/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import HomeFeature
import Domain

@MainActor
struct InstagramManualSearchViewModelTests {

    let catalog = MockConcertRepository()
    let search = MockSearchRepository()
    let interest = MockUserRepository()

    @Test("화면을 다시 표시해도 첫 페이지와 선택을 유지한다")
    func loadOnce() async {
        catalog.concertListStub = [makeConcert(id: 1)]
        let model = makeModel()
        #expect(catalog.fetchAllConcertListCallCount == 0)
        await model.loadIfNeeded()
        model.toggleConcertSelection(1)
        await model.loadIfNeeded()

        #expect(catalog.fetchAllConcertListCallCount == 1)
        #expect(model.displayedConcertList.map(\.id) == [1])
        #expect(model.selectedConcertID == 1)
        #expect(!model.isInitialLoading)
    }

    @Test("디바운스 중 입력을 바꾸면 마지막 검색어로만 조회한다")
    func debounceSearch() async {
        let model = makeModel()
        model.searchText = "원"
        let first = Task { await model.searchIfNeeded() }
        await Task.yield()
        first.cancel()
        model.searchText = " 원 오크 록 "
        await model.searchIfNeeded()
        await first.value
        await model.searchIfNeeded()

        #expect(search.fetchFilterSearchResultKeywordList == ["원 오크 록"])
        #expect(search.fetchFilterSearchResultStatusList == [[.ongoing, .upcoming]])
        #expect(search.fetchFilterSearchResultSizeList == [12])
    }

    @Test("검색과 기본 목록은 각자의 커서로 이어서 조회한다")
    func paginateBothLists() async {
        catalog.concertListResultQueue = [
            .success(page([1], next: 10)), .success(page([2]))
        ]
        search.searchResultQueue = [
            .success(page([3], next: 30)), .success(page([4]))
        ]
        let model = makeModel()
        await model.loadIfNeeded()
        model.searchText = "공연"
        await model.searchIfNeeded()
        await model.loadNextPage()
        await model.loadNextPage()
        #expect(model.displayedConcertList.map(\.id) == [3, 4])
        #expect(search.fetchFilterSearchResultPositionValueList == [nil, 30])

        model.searchText = ""
        #expect(model.displayedConcertList.map(\.id) == [1])
        await model.loadNextPage()
        await model.loadNextPage()
        #expect(model.displayedConcertList.map(\.id) == [1, 2])
        #expect(catalog.fetchAllConcertListPositionList.map { ($0 as? TestSearchPosition)?.value } == [nil, 10])
    }

    @Test("검색어를 지운 후 도착한 검색 페이지의 성공이나 실패를 무시한다", arguments: [true, false])
    func ignoreStalePage(succeeds: Bool) async throws {
        catalog.concertListStub = [makeConcert(id: 1)]
        search.searchResultQueue = [
            .success(page([2], next: 20)), succeeds ? .success(page([3])) : .failure(.serverError)
        ]
        let model = makeModel()
        await model.loadIfNeeded()
        model.searchText = "공연"
        await model.searchIfNeeded()

        let (requests, started) = AsyncStream.makeStream(of: CheckedContinuation<Void, Never>.self)
        search.beforeReturningSearchResult = {
            await withCheckedContinuation { started.yield($0) }
        }
        let nextPage = Task {
            defer { started.finish() }
            await model.loadNextPage()
        }
        var iterator = requests.makeAsyncIterator()
        let pendingResponse = await iterator.next()
        let response = try #require(pendingResponse)
        #expect(model.isLoadingMore)
        model.searchText = ""
        response.resume()
        await nextPage.value

        #expect(model.displayedConcertList.map(\.id) == [1])
        #expect(!model.isErrorToastPresented)
        #expect(!model.isLoadingMore)
    }

    @Test("다른 공연을 누르면 선택을 옮기고 같은 공연을 누르면 등록을 비활성화한다")
    func toggleSelection() async {
        catalog.concertListStub = [makeConcert(id: 1), makeConcert(id: 2)]
        let model = makeModel()
        await model.loadIfNeeded()
        #expect(!model.canRegister)
        model.toggleConcertSelection(1)
        model.toggleConcertSelection(2)
        #expect(model.selectedConcertID == 2)
        #expect(model.canRegister)
        model.toggleConcertSelection(2)
        #expect(model.selectedConcertID == nil)
        #expect(!model.canRegister)
        #expect(await model.register() == false)
        #expect(interest.checkInterestedConcertCallCount == 0)
    }

    @Test("검색어를 지워도 선택한 공연을 등록하고 이미 관심 공연이면 갱신을 생략한다", arguments: [true, false])
    func registerSelection(alreadyInterested: Bool) async {
        interest.checkInterestedConcertResult = alreadyInterested
        interest.updatedConcertStub = makeConcert(id: 2)
        search.searchResultStub = page([2])
        let model = makeModel()
        await model.loadIfNeeded()
        model.searchText = "공연"
        await model.searchIfNeeded()
        model.toggleConcertSelection(2)
        model.searchText = ""

        #expect(await model.register())
        #expect(interest.checkInterestedConcertID == 2)
        #expect(interest.updateInterestedConcertCallCount == (alreadyInterested ? 0 : 1))
        #expect(!model.isRegistering)
    }

    @Test("검색 오류를 표시하는 동안 등록이 실패하면 기존 토스트를 닫은 뒤 등록 오류를 표시한다")
    func presentRegistrationErrorAfterSearchError() async {
        catalog.concertListStub = [makeConcert(id: 1)]
        search.errorStub = .noConnection
        let model = makeModel()
        await model.loadIfNeeded()
        model.toggleConcertSelection(1)
        model.searchText = "공연"
        await model.searchIfNeeded()
        let searchError = model.errorMessage
        #expect(model.isErrorToastPresented)

        #expect(await model.register() == false)
        #expect(model.errorMessage == searchError)
        model.isErrorToastPresented = false
        model.presentPendingErrorIfNeeded()
        #expect(model.isErrorToastPresented)
        #expect(model.errorMessage == "관심 콘서트 등록에 실패했어요\n다시 시도해주세요")
    }

    @Test("등록이 실패하면 토스트를 표시하고 같은 공연으로 다시 시도할 수 있다")
    func retryRegistration() async {
        catalog.concertListStub = [makeConcert(id: 1)]
        let model = makeModel()
        await model.loadIfNeeded()
        model.toggleConcertSelection(1)
        #expect(await model.register() == false)
        #expect(model.isErrorToastPresented)
        #expect(model.errorMessage == "관심 콘서트 등록에 실패했어요\n다시 시도해주세요")
        #expect(model.selectedConcertID == 1)
        #expect(model.canRegister)

        interest.updatedConcertStub = makeConcert(id: 1)
        #expect(await model.register())
    }
}

private extension InstagramManualSearchViewModelTests {
    func makeModel() -> InstagramManualSearchViewModel {
        InstagramManualSearchViewModel(
            concertCatalogRepository: catalog,
            searchRepository: search,
            interestConcertRepository: interest
        )
    }

    func page(_ idList: [Int], next: Int? = nil) -> ListResult<Concert> {
        ListResult(items: idList.map(makeConcert), position: next.map(TestSearchPosition.init))
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
}
