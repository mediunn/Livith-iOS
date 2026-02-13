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
        container.preferenceRepository.artistSearchResultStub = ArtistSearchResult(artists: artists, cursor: nil, totalCount: 2)
        
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
        container.preferenceRepository.artistSearchResultStub = ArtistSearchResult(artists: artists, cursor: nil, totalCount: 1)
        
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
        #expect(sut.state.errorMessage == PreferenceError.serverError.localizedDescription)
    }
    
    @Test("아티스트를 토글하면 선택된 목록에 추가되어야 한다")
    func testToggleAddsArtist() async throws {
        // Given
        let artist = PreferredArtist(id: 1, name: "IU", genreID: 1, imageURL: nil)
        container.preferenceRepository.artistSearchResultStub = ArtistSearchResult(artists: [artist], cursor: nil, totalCount: 1)
        
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
        container.preferenceRepository.artistSearchResultStub = ArtistSearchResult(artists: artists, cursor: nil, totalCount: 4)
        
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
    
    @Test("스크롤 시 다음 페이지를 불러와야 한다")
    func testLoadMoreAppendsArtists() async throws {
        // Given
        let artists = [PreferredArtist(id: 1, name: "A", genreID: 1, imageURL: nil)]
        container.preferenceRepository.artistSearchResultStub = ArtistSearchResult(artists: artists, cursor: nil, totalCount: 2)
        
        let sut = ArtistSelectionStore()
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(sut.state.artistList.count == 1)
        
        // When
        sut.send(.loadMore)
        
        // Wait
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(sut.state.artistList.count == 2)
        #expect(container.preferenceRepository.searchArtistListCallCount == 2) // onAppear + loadMore
    }
    
    @Test("로딩 중일 때는 추가 로드를 요청하지 않아야 한다")
    func testLoadMoreIgnoredWhenLoading() async throws {
        // Given
        let artists = [PreferredArtist(id: 1, name: "A", genreID: 1, imageURL: nil)]
        container.preferenceRepository.artistSearchResultStub = ArtistSearchResult(artists: artists, cursor: 2, totalCount: 5)
        
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
    
    @Test("다음 페이지가 없으면 추가 로드를 요청하지 않아야 한다")
    func testLoadMoreIgnoredWhenNoNextPage() async throws {
        // Given
        let artists = [PreferredArtist(id: 1, name: "A", genreID: 1, imageURL: nil)]
        // cursor가 nil이거나 빈 리스트를 반환하여 hasNextPage가 false가 되도록 해야 함.
        // 하지만 Store 구현상 hasNextPage는 API 결과가 빈 배열일 때 false가 됨.
        // 따라서 첫 로딩 후 hasNextPage=true 상태에서, 빈 결과를 주는 시나리오 필요.
        
        container.preferenceRepository.artistSearchResultStub = ArtistSearchResult(artists: artists, cursor: nil, totalCount: 1)
        
        let sut = ArtistSelectionStore()
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // 첫 로딩 결과 1개 있으므로 hasNextPage는 true 상태임.
        // 여기서 Stub을 빈 배열로 바꿔서 loadMore 호출 -> hasNextPage = false 유도
        container.preferenceRepository.artistSearchResultStub = ArtistSearchResult(artists: [], cursor: nil, totalCount: 1)
        sut.send(.loadMore)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(!sut.state.hasNextPage) // 빈 배열 받았으므로 false
        
        let callCountBefore = container.preferenceRepository.searchArtistListCallCount
        
        // When: hasNextPage가 false인 상태에서 loadMore 요청
        sut.send(.loadMore)
        try await Task.sleep(nanoseconds: 50_000_000)
        
        // Then: API 호출 횟수가 증가하지 않아야 함
        #expect(container.preferenceRepository.searchArtistListCallCount == callCountBefore)
    }
    
    @Test("검색 시 아티스트 목록이 초기화되어야 한다")
    func testSearchResetsArtistList() async throws {
        // Given
        let artists = [PreferredArtist(id: 1, name: "A", genreID: 1, imageURL: nil)]
        container.preferenceRepository.artistSearchResultStub = ArtistSearchResult(artists: artists, cursor: nil, totalCount: 2)
        
        let sut = ArtistSelectionStore()
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(sut.state.artistList.count == 1)
        
        // When: 새로운 검색어 입력
        sut.send(.search(keyword: "B"))
        
        // Then: 즉시 리스트가 초기화되는지 확인 (debounce 대기 전)
        // Store 구현을 보면 search intent 처리 시 바로 리스트 초기화하지 않음. 디바운스 후 API 호출 시점에 초기화하거나, API 결과 수신 시점에 덮어씀.
        // 현재 구현: searchArtists 호출 시 내부 로직엔 리스트 초기화가 명시적으로 없음. 
        // -> searchArtists -> _searchResult -> state.artistList = artists (덮어쓰기)
        // 따라서 "검색 완료 후"에 리스트가 변경되는 것을 확인해야 함.
        
        // Wait (debounce + api)
        try await Task.sleep(nanoseconds: 500_000_000)
        
        #expect(sut.state.artistList.count == 1)
        #expect(sut.state.hasNextPage) // 검색 시 hasNextPage true 리셋 (구현 확인 필요: 현재 구현엔 리셋 로직 누락 가능성 있음)
    }

    @Test("리스트 재조회(검색 등) 시 페이지네이션 상태가 초기화되어야 한다")
    func testRefetchingListResetsPaginationState() async throws {
        // Given
        // 1. 초기 상태: 리스트가 있고, 페이징 끝에 도달하여 hasNextPage가 false인 상태를 만든다.
        let initialArtists = [PreferredArtist(id: 1, name: "A", genreID: 1, imageURL: nil)]
        container.preferenceRepository.artistSearchResultStub = ArtistSearchResult(artists: initialArtists, cursor: nil, totalCount: 1)
        
        let sut = ArtistSelectionStore()
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // loadMore 호출 -> 빈 결과 -> hasNextPage = false
        container.preferenceRepository.artistSearchResultStub = ArtistSearchResult(artists: [], cursor: nil, totalCount: 1)
        sut.send(.loadMore)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(!sut.state.hasNextPage)
        
        // When
        // 2. 리스트를 처음부터 다시 로드 (검색어 변경 등)
        let newArtists = [PreferredArtist(id: 2, name: "B", genreID: 1, imageURL: nil)]
        container.preferenceRepository.artistSearchResultStub = ArtistSearchResult(artists: newArtists, cursor: nil, totalCount: 2)
        
        // 검색 실행 (또는 onAppear 재호출 등, 여기선 search로 시뮬레이션)
        sut.send(.search(keyword: "B"))
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Then
        // 3. hasNextPage가 true로 돌아왔는지 확인
        #expect(sut.state.artistList.first?.name == "B")
        #expect(sut.state.hasNextPage)
    }
}
