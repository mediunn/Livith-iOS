//
//  InterestConcertSearchStore.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import HomeDomain
import DIContainer

enum InterestConcertSearchIntent {
    case updateText(String)
    case onSearch
}

struct InterestConcertSearchState {
    var searchText: String = ""
    var recommendKeywordList: [String] = ["아이유", "아이즈원", "아이브"]
}

final class InterestConcertSearchStore: ObservableObject {
    @Published private(set) var state = InterestConcertSearchState()

    @Injected private var repository: HomeRepository
    
    @MainActor
    func send(_ intent: InterestConcertSearchIntent) {
        switch intent {
        case .updateText(let text):
            state.searchText = text
        case .onSearch:
            break
        }
    }
}

// MARK: - Helpers

private extension InterestConcertSearchView {
    
}
