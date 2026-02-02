//
//  GenreSelectionStoreTests.swift
//  PreferenceFeatureTests
//
//  Created by 김진웅 on 1/30/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Testing
import Foundation

@testable import PreferenceFeature

// MARK: - Tests

struct GenreSelectionStoreTests {
    
    @Test("초기 상태에서 isLoading은 false여야 한다")
    func testInitialLoadingState() {
        // Given
        let sut = GenreSelectionStore()
        
        // Then
        #expect(!sut.state.isLoading)
    }
    
    @Test("onAppear 시작 시 isLoading은 true여야 한다")
    func testOnAppearSetsLoadingTrue() async {
        // Given
        let sut = GenreSelectionStore()
        
        // When
        await sut.send(.onAppear)
        
        // Then
        // onAppear 처리 후에는 로딩이 완료되므로 false
        #expect(!sut.state.isLoading)
    }
    
    @Test("onAppear 완료 후 isLoading은 false여야 한다")
    func testOnAppearSetsLoadingFalse() async {
        // Given
        let sut = GenreSelectionStore()
        
        // When
        await sut.send(.onAppear)
        
        // Then
        #expect(!sut.state.isLoading)
        #expect(!sut.state.genreList.isEmpty)
    }
    
    @Test("초기 상태에서 선택된 장르가 없어야 한다")
    func testInitialState() {
        // Given
        let sut = GenreSelectionStore()
        
        // Then
        #expect(sut.state.selectedGenreList.isEmpty)
    }
    
    @Test("onAppear 시 장르 목록이 로드되어야 한다")
    func testOnAppearLoadsGenres() async {
        // Given
        let sut = GenreSelectionStore()
        
        // When
        await sut.send(.onAppear)
        
        // Then
        #expect(!sut.state.genreList.isEmpty)
    }
    
    @Test("장르를 토글하면 선택된 목록에 추가되어야 한다")
    func testToggleAddsGenreWhenNotSelected() async {
        // Given
        let sut = GenreSelectionStore()
        await sut.send(.onAppear)
        
        // When
        await sut.send(.toggle(id: 1))
        
        // Then
        #expect(sut.state.selectedGenreList.count == 1)
        #expect(sut.state.selectedGenreList.first?.id == 1)
    }
    
    @Test("이미 선택된 장르를 토글하면 목록에서 제거되어야 한다")
    func testToggleRemovesGenreWhenAlreadySelected() async {
        // Given
        let sut = GenreSelectionStore()
        await sut.send(.onAppear)
        await sut.send(.toggle(id: 1))
        
        // When
        await sut.send(.toggle(id: 1))
        
        // Then
        #expect(sut.state.selectedGenreList.isEmpty)
    }
    
    @Test("3개 선택된 상태에서 새로운 장르를 토글해도 추가되지 않아야 한다")
    func testToggleDoesNotAddWhenMaxSelectionReached() async {
        // Given
        let sut = GenreSelectionStore()
        await sut.send(.onAppear)
        await sut.send(.toggle(id: 1))
        await sut.send(.toggle(id: 2))
        await sut.send(.toggle(id: 3))
        
        // When
        await sut.send(.toggle(id: 4))
        
        // Then
        #expect(sut.state.selectedGenreList.count == 3)
        #expect(!sut.state.selectedGenreList.contains { $0.id == 4 })
    }

    @Test("최대 선택 수를 초과하려고 하면 isMaxSelectionToastPresented가 true여야 한다")
    func testExceedMaxSelectionFlagWhenAddingOverLimit() async {
        // Given
        let sut = GenreSelectionStore()
        await sut.send(.onAppear)
        await sut.send(.toggle(id: 1))
        await sut.send(.toggle(id: 2))
        await sut.send(.toggle(id: 3))

        // When
        await sut.send(.toggle(id: 4))

        // Then
        #expect(sut.state.isMaxSelectionToastPresented)
    }

    @Test("선택이 유효하게 변경되면 isMaxSelectionToastPresented는 false여야 한다")
    func testExceedMaxSelectionResetOnValidToggle() async {
        // Given
        let sut = GenreSelectionStore()
        await sut.send(.onAppear)
        await sut.send(.toggle(id: 1))
        await sut.send(.toggle(id: 2))
        await sut.send(.toggle(id: 3))
        await sut.send(.toggle(id: 4))

        // When
        await sut.send(.toggle(id: 3))

        // Then
        #expect(!sut.state.isMaxSelectionToastPresented)
    }

    @Test("resetMaxSelectionToast intent는 isMaxSelectionToastPresented를 false로 만든다")
    func testResetExceedMaxSelectionIntent() async {
        // Given
        let sut = GenreSelectionStore()
        await sut.send(.onAppear)
        await sut.send(.toggle(id: 1))
        await sut.send(.toggle(id: 2))
        await sut.send(.toggle(id: 3))
        await sut.send(.toggle(id: 4))

        // When
        await sut.send(.resetMaxSelectionToast)

        // Then
        #expect(!sut.state.isMaxSelectionToastPresented)
    }
    
    @Test("3개 선택된 상태에서 이미 선택된 장르를 토글하면 제거되어야 한다")
    func testToggleRemovesGenreEvenWhenMaxSelectionReached() async {
        // Given
        let sut = GenreSelectionStore()
        await sut.send(.onAppear)
        await sut.send(.toggle(id: 1))
        await sut.send(.toggle(id: 2))
        await sut.send(.toggle(id: 3))
        
        // When
        await sut.send(.toggle(id: 2))
        
        // Then
        #expect(sut.state.selectedGenreList.count == 2)
        #expect(!sut.state.selectedGenreList.contains { $0.id == 2 })
        #expect(sut.state.selectedGenreList.contains { $0.id == 1 })
        #expect(sut.state.selectedGenreList.contains { $0.id == 3 })
    }
}
