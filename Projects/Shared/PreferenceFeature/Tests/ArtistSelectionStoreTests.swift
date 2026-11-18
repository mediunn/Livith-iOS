//
//  ArtistSelectionStoreTests.swift
//  PreferenceFeatureTests
//
//  Created by 김진웅 on 2/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Testing
import Foundation

@testable import PreferenceFeature
import Domain
import DIContainer

@MainActor
struct ArtistSelectionStoreTests {
    
    let container: MockDIContainer
    
    init() {
        self.container = MockDIContainer()
        self.container.registerDependencies()
    }
    
    @Test("초기 상태에서 isLoading은 false여야 한다")
    func testInitialLoadingState() {
        let sut = ArtistSelectionStore()
        #expect(!sut.state.isLoading)
    }
    
    @Test("onAppear 시(검색어 없음) 아티스트 목록이 로드되어야 한다")
    func testOnAppearLoadsArtists() async throws {
        // Given
        let artists = [
            PreferredArtist(id: 1, name: "IU", genreID: 1, imageURL: nil),
            PreferredArtist(id: 2, name: "BTS", genreID: 1, imageURL: nil)
        ]
        container.preferenceRepository.artistSearchResultStub = ListResult(items: artists, nextToken: nil)
        
        let sut = ArtistSelectionStore()
        
        // When
        sut.send(.onAppear)
        
        // Wait
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(sut.state.artistList.count == 2)
        #expect(sut.state.artistList.map(\.name).contains("IU"))
    }
    
    @Test("검색 시 아티스트 목록이 로드되어야 한다")
    func testSearchLoadsArtists() async throws {
        // Given
        let artists = [PreferredArtist(id: 1, name: "IU", genreID: 1, imageURL: nil)]
        container.preferenceRepository.artistSearchResultStub = ListResult(items: artists, nextToken: nil)
        
        let sut = ArtistSelectionStore()
        
        // When
        sut.send(.search(keyword: "IU"))
        
        // Wait (debounce 0.3 + api 0.1)
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Then
        #expect(sut.state.artistList.count == 1)
        #expect(sut.state.artistList.first?.name == "IU")
    }
    
    @Test("아티스트 검색 중 에러가 발생하면 에러 토스트가 표시되어야 한다")
    func testSearchFailure() async throws {
        // Given
        container.preferenceRepository.errorStub = .serverError
        
        let sut = ArtistSelectionStore()
        
        // When
        sut.send(.onAppear) // or search
        
        // Wait
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(sut.state.isErrorToastPresented)
        #expect(sut.state.errorMessage == "서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.")
    }
    
    @Test("아티스트를 토글하면 선택된 목록에 추가되어야 한다")
    func testToggleAddsArtist() async throws {
        // Given
        let artist = PreferredArtist(id: 1, name: "IU", genreID: 1, imageURL: nil)
        container.preferenceRepository.artistSearchResultStub = ListResult(items: [artist], nextToken: nil)
        
        let sut = ArtistSelectionStore()
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        sut.send(.toggle(id: 1))
        
        // Then
        #expect(sut.state.selectedArtistList.count == 1)
        #expect(sut.state.selectedArtistList.first?.id == 1)
    }
    
    @Test("생성자에서 선택된 아티스트가 주입되면 초기 상태에 반영되어야 한다")
    func testInitialSelectionState() {
        // Given
        let selectedArtist = PreferredArtist(id: 1, name: "IU", genreID: 1, imageURL: nil)
        
        // When
        let sut = ArtistSelectionStore(selectedArtistList: [selectedArtist])
        
        // Then
        #expect(sut.state.selectedArtistList.count == 1)
        #expect(sut.state.selectedArtistList.first?.id == 1)
    }
    
    @Test("최대 선택 수를 초과하면 토스트가 표시되어야 한다")
    func testMaxSelectionToast() async throws {
        // Given
        let artists = [
            PreferredArtist(id: 1, name: "A", genreID: 1, imageURL: nil),
            PreferredArtist(id: 2, name: "B", genreID: 1, imageURL: nil),
            PreferredArtist(id: 3, name: "C", genreID: 1, imageURL: nil),
            PreferredArtist(id: 4, name: "D", genreID: 1, imageURL: nil)
        ]
        container.preferenceRepository.artistSearchResultStub = ListResult(items: artists, nextToken: nil)
        
        let initialSelection = [artists[0], artists[1], artists[2]]
        let sut = ArtistSelectionStore(selectedArtistList: initialSelection)
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        sut.send(.toggle(id: 4))
        
        // Then
        #expect(sut.state.selectedArtistList.count == 3)
        #expect(sut.state.isMaxSelectionToastPresented)
    }
    
    @Test("서버가 준 다음 토큰으로 조회하고 결과를 목록에 추가해야 한다")
    func testLoadMoreAppendsArtists() async throws {
        let firstArtist = PreferredArtist(id: 1, name: "A", genreID: 1, imageURL: nil)
        let secondArtist = PreferredArtist(id: 2, name: "B", genreID: 1, imageURL: nil)
        container.preferenceRepository.artistSearchResultStub = ListResult(
            items: [firstArtist],
            nextToken: TestSearchNextToken(value: 42)
        )

        let sut = ArtistSelectionStore()
        sut.send(.onAppear)
        try await Task.sleep(for: .milliseconds(100))

        container.preferenceRepository.artistSearchResultStub = ListResult(items: [secondArtist], nextToken: nil)
        sut.send(.loadMore)
        try await Task.sleep(for: .milliseconds(100))

        #expect(sut.state.artistList.map(\.id) == [1, 2])
        #expect(container.preferenceRepository.searchArtistListTokenValueList == [nil, 42])
        #expect(!sut.state.hasNextPage)
    }

    @Test("로딩 중일 때는 추가 로드를 요청하지 않아야 한다")
    func testLoadMoreIgnoredWhenLoading() async throws {
        // Given
        let artists = [PreferredArtist(id: 1, name: "A", genreID: 1, imageURL: nil)]
        container.preferenceRepository.artistSearchResultStub = ListResult(items: artists, nextToken: TestSearchNextToken(value: 2))
        
        let sut = ArtistSelectionStore()
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // When: 연속으로 호출
        sut.send(.loadMore)
        sut.send(.loadMore)
        
        // Wait
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then: Call Count는 onAppear(1) + loadMore(1) = 2회여야 함 (두 번째 loadMore는 무시됨)
        #expect(container.preferenceRepository.searchArtistListCallCount == 2)
    }
    
    @Test("첫 페이지에 결과가 있어도 다음 토큰이 없으면 추가 조회하지 않아야 한다")
    func testLoadMoreIgnoredWhenNoNextPage() async throws {
        let artist = PreferredArtist(id: 1, name: "A", genreID: 1, imageURL: nil)
        container.preferenceRepository.artistSearchResultStub = ListResult(items: [artist], nextToken: nil)

        let sut = ArtistSelectionStore()
        sut.send(.onAppear)
        try await Task.sleep(for: .milliseconds(100))

        sut.send(.loadMore)
        try await Task.sleep(for: .milliseconds(100))

        #expect(sut.state.artistList.map(\.id) == [1])
        #expect(!sut.state.hasNextPage)
        #expect(container.preferenceRepository.searchArtistListTokenValueList == [nil])
    }

    @Test("검색어가 바뀌면 이전 페이지의 토큰을 버리고 새 검색 결과로 교체해야 한다")
    func testSearchResetsArtistList() async throws {
        let firstArtist = PreferredArtist(id: 1, name: "A", genreID: 1, imageURL: nil)
        let newArtist = PreferredArtist(id: 2, name: "B", genreID: 1, imageURL: nil)
        container.preferenceRepository.artistSearchResultStub = ListResult(
            items: [firstArtist],
            nextToken: TestSearchNextToken(value: 42)
        )

        let sut = ArtistSelectionStore()
        sut.send(.onAppear)
        try await Task.sleep(for: .milliseconds(100))

        container.preferenceRepository.artistSearchResultStub = ListResult(
            items: [newArtist],
            nextToken: TestSearchNextToken(value: 55)
        )
        sut.send(.search(keyword: "B"))
        sut.send(.loadMore)
        try await Task.sleep(for: .milliseconds(500))

        #expect(sut.state.artistList.map(\.id) == [2])
        #expect(sut.state.hasNextPage)
        #expect(container.preferenceRepository.searchArtistListTokenValueList == [nil, nil])
    }
}
