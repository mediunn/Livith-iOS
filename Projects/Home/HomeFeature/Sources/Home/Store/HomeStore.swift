//
//  HomeStore.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import HomeDomain

enum HomeIntent {
    case onAppear
    case onToastDisappear
    case _fetchUserInterestConcertResult(Result<Concert?, Error>)
}

struct HomeState {
    var mode: HomeMode = .noInterestedConcert
    var errorMessage: String = ""
}

final class HomeStore: ObservableObject {
    @Published private(set) var state: HomeState = .init()

    @Injected private var repository: HomeRepository

    @MainActor
    func send(_ intent: HomeIntent) {
        switch intent {
        case .onAppear:
            performFetchUserInterestedConcert()
            
        case .onToastDisappear:
            state.errorMessage = ""
            
        case ._fetchUserInterestConcertResult(let result):
            switch result {
            case .success(let concert):
                state.mode = concert.map { .hasInterestedConcert($0) } ?? .noInterestedConcert
            case .failure(let error):
                state.errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Helpers

private extension HomeStore {
    func performFetchUserInterestedConcert() {
        Task {
            do {
                let result = try await repository.fetchInterestedConcert()
                await send(. _fetchUserInterestConcertResult(.success(result)))
            } catch {
                await send(._fetchUserInterestConcertResult(.failure(error)))
            }
        }      
    }
}

// MARK: - HomeMode

extension HomeState {
    enum HomeMode {
        case noInterestedConcert
        case hasInterestedConcert(Concert)
    }
}
