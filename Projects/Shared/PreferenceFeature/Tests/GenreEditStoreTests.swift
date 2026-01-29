//
//  GenreEditStoreTests.swift
//  PreferenceFeatureTests
//
//  Created by 김진웅 on 1/29/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Testing
import Foundation

import Domain
@testable import PreferenceFeature

// MARK: - Tests

struct GenreEditStoreTests {
    
    @Test("초기 상태에서 선택된 장르가 없어야 한다")
    func testInitialState() {
        // Given
        let sut = GenreEditStore(mode: .onboarding)
        
        // Then
        #expect(sut.state.selectedGenreList.isEmpty)
    }
    
    @Test("장르를 토글하면 선택된 목록에 추가되어야 한다")
    func testToggleAddsGenreWhenNotSelected() async {
        // Given
        let sut = GenreEditStore(mode: .onboarding)
        
        // When
        await sut.send(.toggle(id: 1))
        
        // Then
        #expect(sut.state.selectedGenreList.count == 1)
        #expect(sut.state.selectedGenreList.first?.id == 1)
    }
    
    @Test("이미 선택된 장르를 토글하면 목록에서 제거되어야 한다")
    func testToggleRemovesGenreWhenAlreadySelected() async {
        // Given
        let sut = GenreEditStore(mode: .onboarding)
        await sut.send(.toggle(id: 1))
        
        // When
        await sut.send(.toggle(id: 1))
        
        // Then
        #expect(sut.state.selectedGenreList.isEmpty)
    }
    
    @Test("3개 선택된 상태에서 새로운 장르를 토글해도 추가되지 않아야 한다")
    func testToggleDoesNotAddWhenMaxSelectionReached() async {
        // Given
        let sut = GenreEditStore(mode: .onboarding)
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
        let sut = GenreEditStore(mode: .onboarding)
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
        let sut = GenreEditStore(mode: .onboarding)
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
        let sut = GenreEditStore(mode: .onboarding)
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
        let sut = GenreEditStore(mode: .onboarding)
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
    
    @Test("edit 모드에서 변경 실패 시 isUpdateFailureToastPresented가 true여야 한다")
    func testUpdateFailureShowsToastInEditMode() async {
        // Given
        let sut = GenreEditStore(mode: .edit)
        
        // When
        await sut.send(.submitFailed)
        
        // Then
        #expect(sut.state.isUpdateFailureToastPresented)
    }
    
    @Test("onboarding 모드에서는 submitFailed가 토스트에 영향을 주지 않아야 한다")
    func testUpdateFailureDoesNotAffectOnboardingMode() async {
        // Given
        let sut = GenreEditStore(mode: .onboarding)
        
        // When
        await sut.send(.submitFailed)
        
        // Then
        #expect(!sut.state.isUpdateFailureToastPresented)
    }
    
    @Test("resetUpdateFailureToast intent는 isUpdateFailureToastPresented를 false로 만든다")
    func testResetUpdateFailureToast() async {
        // Given
        let sut = GenreEditStore(mode: .edit)
        await sut.send(.submitFailed)
        
        // When
        await sut.send(.resetUpdateFailureToast)
        
        // Then
        #expect(!sut.state.isUpdateFailureToastPresented)
    }
}
