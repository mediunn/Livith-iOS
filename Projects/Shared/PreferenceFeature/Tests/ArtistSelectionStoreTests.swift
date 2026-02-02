//
//  ArtistSelectionStoreTests.swift
//  PreferenceFeatureTests
//
//  Created by 김진웅 on 2/2/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Testing
import Foundation

@testable import PreferenceFeature

struct ArtistSelectionStoreTests {
    
    // MARK: - 초기 상태 테스트
    
    @Test("초기 상태에서 isLoading은 false여야 한다")
    func testInitialLoadingState() {
        let sut = ArtistSelectionStore()
        #expect(!sut.state.isLoading)
    }
    
    @Test("초기 상태에서 선택된 아티스트가 없어야 한다")
    func testInitialState() {
        let sut = ArtistSelectionStore()
        #expect(sut.state.selectedArtistList.isEmpty)
    }
    
    @Test("초기 상태에서 검색 키워드는 빈 문자열이어야 한다")
    func testInitialSearchKeyword() {
        let sut = ArtistSelectionStore()
        #expect(sut.state.searchKeyword.isEmpty)
    }
    
    // MARK: - onAppear 테스트
    
    @Test("onAppear 완료 후 isLoading은 false여야 한다")
    func testOnAppearSetsLoadingFalse() async {
        let sut = ArtistSelectionStore()
        await sut.send(.onAppear)
        #expect(!sut.state.isLoading)
        #expect(!sut.state.allArtistList.isEmpty)
    }
    
    @Test("onAppear 시 아티스트 목록이 로드되어야 한다")
    func testOnAppearLoadsArtists() async {
        let sut = ArtistSelectionStore()
        await sut.send(.onAppear)
        #expect(!sut.state.allArtistList.isEmpty)
        #expect(sut.state.filteredArtistList == sut.state.allArtistList)
    }
    
    // MARK: - 검색 테스트
    
    @Test("검색어 입력 시 filteredArtistList가 필터링되어야 한다")
    func testSearchFiltersArtists() async {
        let sut = ArtistSelectionStore()
        await sut.send(.onAppear)
        
        await sut.send(.search(keyword: "IU"))
        
        #expect(sut.state.searchKeyword == "IU")
        #expect(sut.state.filteredArtistList.allSatisfy { $0.name.lowercased().contains("iu") })
    }
    
    @Test("빈 검색어 입력 시 전체 목록이 표시되어야 한다")
    func testEmptySearchShowsAllArtists() async {
        let sut = ArtistSelectionStore()
        await sut.send(.onAppear)
        await sut.send(.search(keyword: "IU"))
        
        await sut.send(.search(keyword: ""))
        
        #expect(sut.state.filteredArtistList == sut.state.allArtistList)
    }
    
    @Test("대소문자 구분 없이 검색되어야 한다")
    func testSearchIsCaseInsensitive() async {
        let sut = ArtistSelectionStore()
        await sut.send(.onAppear)
        
        await sut.send(.search(keyword: "bts"))
        
        #expect(sut.state.filteredArtistList.contains { $0.name == "BTS" })
    }
    
    // MARK: - 토글 테스트
    
    @Test("아티스트를 토글하면 선택된 목록에 추가되어야 한다")
    func testToggleAddsArtistWhenNotSelected() async {
        let sut = ArtistSelectionStore()
        await sut.send(.onAppear)
        
        await sut.send(.toggle(id: 1))
        
        #expect(sut.state.selectedArtistList.count == 1)
        #expect(sut.state.selectedArtistList.first?.id == 1)
    }
    
    @Test("이미 선택된 아티스트를 토글하면 목록에서 제거되어야 한다")
    func testToggleRemovesArtistWhenAlreadySelected() async {
        let sut = ArtistSelectionStore()
        await sut.send(.onAppear)
        await sut.send(.toggle(id: 1))
        
        await sut.send(.toggle(id: 1))
        
        #expect(sut.state.selectedArtistList.isEmpty)
    }
    
    @Test("존재하지 않는 아티스트 ID를 토글하면 아무 변화가 없어야 한다")
    func testToggleNonExistentArtistDoesNothing() async {
        let sut = ArtistSelectionStore()
        await sut.send(.onAppear)
        
        await sut.send(.toggle(id: 9999))
        
        #expect(sut.state.selectedArtistList.isEmpty)
    }
    
    @Test("3개 선택된 상태에서 새로운 아티스트를 토글해도 추가되지 않아야 한다")
    func testToggleDoesNotAddWhenMaxSelectionReached() async {
        let sut = ArtistSelectionStore()
        await sut.send(.onAppear)
        await sut.send(.toggle(id: 1))
        await sut.send(.toggle(id: 2))
        await sut.send(.toggle(id: 3))
        
        await sut.send(.toggle(id: 4))
        
        #expect(sut.state.selectedArtistList.count == 3)
        #expect(!sut.state.selectedArtistList.contains { $0.id == 4 })
    }
    
    @Test("3개 선택된 상태에서 이미 선택된 아티스트를 토글하면 제거되어야 한다")
    func testToggleRemovesArtistEvenWhenMaxSelectionReached() async {
        let sut = ArtistSelectionStore()
        await sut.send(.onAppear)
        await sut.send(.toggle(id: 1))
        await sut.send(.toggle(id: 2))
        await sut.send(.toggle(id: 3))
        
        await sut.send(.toggle(id: 2))
        
        #expect(sut.state.selectedArtistList.count == 2)
        #expect(!sut.state.selectedArtistList.contains { $0.id == 2 })
        #expect(sut.state.selectedArtistList.contains { $0.id == 1 })
        #expect(sut.state.selectedArtistList.contains { $0.id == 3 })
    }
    
    // MARK: - 최대 선택 토스트 테스트
    
    @Test("최대 선택 수를 초과하려고 하면 isMaxSelectionToastPresented가 true여야 한다")
    func testExceedMaxSelectionFlagWhenAddingOverLimit() async {
        let sut = ArtistSelectionStore()
        await sut.send(.onAppear)
        await sut.send(.toggle(id: 1))
        await sut.send(.toggle(id: 2))
        await sut.send(.toggle(id: 3))
        
        await sut.send(.toggle(id: 4))
        
        #expect(sut.state.isMaxSelectionToastPresented)
    }
    
    @Test("선택이 유효하게 변경되면 isMaxSelectionToastPresented는 false여야 한다")
    func testExceedMaxSelectionResetOnValidToggle() async {
        let sut = ArtistSelectionStore()
        await sut.send(.onAppear)
        await sut.send(.toggle(id: 1))
        await sut.send(.toggle(id: 2))
        await sut.send(.toggle(id: 3))
        await sut.send(.toggle(id: 4))
        
        await sut.send(.toggle(id: 3))  // 하나 제거
        
        #expect(!sut.state.isMaxSelectionToastPresented)
    }
    
    @Test("resetMaxSelectionToast intent는 isMaxSelectionToastPresented를 false로 만든다")
    func testResetMaxSelectionToastIntent() async {
        let sut = ArtistSelectionStore()
        await sut.send(.onAppear)
        await sut.send(.toggle(id: 1))
        await sut.send(.toggle(id: 2))
        await sut.send(.toggle(id: 3))
        await sut.send(.toggle(id: 4))
        
        await sut.send(.resetMaxSelectionToast)
        
        #expect(!sut.state.isMaxSelectionToastPresented)
    }
    
    @Test("새 아티스트 선택 시 isMaxSelectionToastPresented는 false여야 한다")
    func testAddingArtistResetsToastFlag() async {
        let sut = ArtistSelectionStore()
        await sut.send(.onAppear)
        
        await sut.send(.toggle(id: 1))
        
        #expect(!sut.state.isMaxSelectionToastPresented)
    }
}
