//
//  HomeNoInterestStore.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import HomeDomain

enum HomeNoInterestIntent {
    case onAppear
    case onRefresh
    case onToastDisappear
    case _fetchHomeSectionListResult(Result<HomeSectionList, Error>)
}

struct HomeNoInterestState {
    var sectionList: HomeSectionList = []
    var isLoading: Bool = false
    var errorMessage: String = ""
}

final class HomeNoInterestStore: ObservableObject {
    @Published private(set) var state: HomeNoInterestState = .init()
    
    @Injected private var repository: HomeRepository
    
    private var refreshTask: Task<Void, Never>?
    
    @MainActor
    func send(_ intent: HomeNoInterestIntent) {
        switch intent {
        case .onAppear:
            performFetchHomeSectionList()

        case .onRefresh:
            state.isLoading = true
            performFetchHomeSectionList()

        case .onToastDisappear:
            state.errorMessage = ""

        case ._fetchHomeSectionListResult(let result):
            state.isLoading = false
            switch result {
            case .success(let sectionList):
                state.sectionList = sectionList
            case .failure(let error):
                state.errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Helpers

private extension HomeNoInterestStore {
    func performFetchHomeSectionList() {
        refreshTask?.cancel()

        refreshTask = Task {
            do {
                let result = try await repository.fetchSectionList()
                await send(._fetchHomeSectionListResult(.success(result)))
            } catch {
                await send(._fetchHomeSectionListResult(.failure(error)))
            }
        }
    }
}
