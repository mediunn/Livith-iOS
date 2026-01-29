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
        let store = GenreEditStore()
        
        #expect(store.state.selectedGenreList.isEmpty)
    }
    
    @Test("장르를 토글하면 선택된 목록에 추가되어야 한다")
    func testToggleAddsGenreWhenNotSelected() async {
        let store = GenreEditStore()
        
        await store.send(.toggle(id: 1))
        
        #expect(store.state.selectedGenreList.count == 1)
        #expect(store.state.selectedGenreList.first?.id == 1)
    }
    
    @Test("이미 선택된 장르를 토글하면 목록에서 제거되어야 한다")
    func testToggleRemovesGenreWhenAlreadySelected() async {
        let store = GenreEditStore()
        
        await store.send(.toggle(id: 1))
        await store.send(.toggle(id: 1))
        
        #expect(store.state.selectedGenreList.isEmpty)
    }
    
    @Test("3개 선택된 상태에서 새로운 장르를 토글해도 추가되지 않아야 한다")
    func testToggleDoesNotAddWhenMaxSelectionReached() async {
        let store = GenreEditStore()
        
        await store.send(.toggle(id: 1))
        await store.send(.toggle(id: 2))
        await store.send(.toggle(id: 3))
        await store.send(.toggle(id: 4))
        
        #expect(store.state.selectedGenreList.count == 3)
        #expect(!store.state.selectedGenreList.contains { $0.id == 4 })
    }
    
    @Test("3개 선택된 상태에서 이미 선택된 장르를 토글하면 제거되어야 한다")
    func testToggleRemovesGenreEvenWhenMaxSelectionReached() async {
        let store = GenreEditStore()
        
        await store.send(.toggle(id: 1))
        await store.send(.toggle(id: 2))
        await store.send(.toggle(id: 3))
        await store.send(.toggle(id: 2))
        
        #expect(store.state.selectedGenreList.count == 2)
        #expect(!store.state.selectedGenreList.contains { $0.id == 2 })
        #expect(store.state.selectedGenreList.contains { $0.id == 1 })
        #expect(store.state.selectedGenreList.contains { $0.id == 3 })
    }
}
