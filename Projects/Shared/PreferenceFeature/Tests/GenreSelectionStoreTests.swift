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
import Domain
import DIContainer

@MainActor
struct GenreSelectionStoreTests {
    
    let container: MockDIContainer
    
    init() {
        self.container = MockDIContainer()
        self.container.registerDependencies()
    }
    
    @Test("초기 상태에서 isLoading은 false여야 한다")
    func testInitialLoadingState() {
        let sut = GenreSelectionStore()
        #expect(!sut.state.isLoading)
    }
    
    @Test("onAppear 시 장르 목록이 로드되어야 한다")
    func testOnAppearLoadsGenres() async throws {
        // Given
        container.preferenceRepository.genreListStub = [
            PreferredGenre(id: 1, name: "Pop", imageURL: nil),
            PreferredGenre(id: 2, name: "Rock", imageURL: nil)
        ]
        
        let sut = GenreSelectionStore()
        
        // When
        sut.send(.onAppear)
        
        // Wait for async task
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        
        // Then
        #expect(sut.state.genreList.count == 2)
        #expect(sut.state.genreList.map(\.name).contains("Pop"))
        #expect(sut.state.genreList.map(\.name).contains("Rock"))
    }
    
    @Test("onAppear 실패 시 에러 토스트가 표시되어야 한다")
    func testOnAppearFailure() async throws {
        // Given
        container.preferenceRepository.errorStub = .serverError
        
        let sut = GenreSelectionStore()
        
        // When
        sut.send(.onAppear)
        
        // Wait
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(sut.state.isErrorToastPresented)
        #expect(sut.state.errorMessage == PreferenceError.serverError.localizedDescription)
    }
    
    @Test("장르를 토글하면 선택된 목록에 추가되어야 한다")
    func testToggleAddsGenreWhenNotSelected() async throws {
        // Given
        container.preferenceRepository.genreListStub = [PreferredGenre(id: 1, name: "Pop", imageURL: nil)]
        
        let sut = GenreSelectionStore()
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        sut.send(.toggle(id: 1))
        
        // Then
        #expect(sut.state.selectedGenreList.count == 1)
        #expect(sut.state.selectedGenreList.first?.id == 1)
    }
    
    @Test("이미 선택된 장르를 토글하면 목록에서 제거되어야 한다")
    func testToggleRemovesGenreWhenAlreadySelected() async throws {
        // Given
        let genre = PreferredGenre(id: 1, name: "Pop", imageURL: nil)
        container.preferenceRepository.genreListStub = [genre]
        
        // 초기 선택 상태 주입
        let sut = GenreSelectionStore(selectedGenres: [genre])
        sut.send(.onAppear) // 장르 로드
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        sut.send(.toggle(id: 1))
        
        // Then
        #expect(sut.state.selectedGenreList.isEmpty)
    }
    
    @Test("3개 선택된 상태에서 새로운 장르를 토글해도 추가되지 않고 토스트가 떠야 한다")
    func testToggleMaxSelectionReached() async throws {
        // Given
        container.preferenceRepository.genreListStub = [
            PreferredGenre(id: 1, name: "Pop", imageURL: nil),
            PreferredGenre(id: 2, name: "Rock", imageURL: nil),
            PreferredGenre(id: 3, name: "Jazz", imageURL: nil),
            PreferredGenre(id: 4, name: "Classic", imageURL: nil)
        ]
        
        let initialSelection = [
            PreferredGenre(id: 1, name: "Pop", imageURL: nil),
            PreferredGenre(id: 2, name: "Rock", imageURL: nil),
            PreferredGenre(id: 3, name: "Jazz", imageURL: nil)
        ]
        
        let sut = GenreSelectionStore(selectedGenres: initialSelection)
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        sut.send(.toggle(id: 4))
        
        // Then
        #expect(sut.state.selectedGenreList.count == 3)
        #expect(!sut.state.selectedGenreList.contains { $0.id == 4 })
        #expect(sut.state.isMaxSelectionToastPresented)
    }
    
    @Test("resetErrorToast intent는 isErrorToastPresented를 false로 만든다")
    func testResetErrorToastIntent() async throws {
        // Given
        container.preferenceRepository.errorStub = .serverError
        let sut = GenreSelectionStore()
        sut.send(.onAppear)
        try await Task.sleep(nanoseconds: 100_000_000) // 에러 발생 대기
        
        #expect(sut.state.isErrorToastPresented) // Precondition
        
        // When
        sut.send(.resetErrorToast)
        
        // Then
        #expect(!sut.state.isErrorToastPresented)
    }
    
    @Test("생성자에서 유저 선호 장르가 주입되면 이미 선택되어 있는 장르로 표현되어야 한다")
    func testInitialSelectionState() {
        // Given
        let selectedGenre = PreferredGenre(id: 1, name: "Pop", imageURL: nil)
        
        // When
        let sut = GenreSelectionStore(selectedGenres: [selectedGenre])
        
        // Then
        #expect(sut.state.selectedGenreList.count == 1)
        #expect(sut.state.selectedGenreList.first?.id == 1)
    }
}
