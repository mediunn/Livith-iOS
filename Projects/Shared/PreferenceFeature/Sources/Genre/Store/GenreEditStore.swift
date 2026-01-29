//
//  GenreEditStore.swift
//  PreferenceFeature
//
//  Created by 김진웅 on 1/29/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

enum GenreEditIntent {
    case toggle(id: Int)
    case resetMaxSelectionToast
    case submitFailed
    case resetUpdateFailureToast
}

struct GenreEditState: Equatable {
    let config: GenreEditConfig
    var genreList: [PreferredGenre] = [
        PreferredGenre(id: 1, name: "JPOP", imageURL: URL(string: "https://fastly.picsum.photos/id/366/108/108.jpg?hmac=aV1brwLNkVd52uapZPMKWfSPXS2oPwaXCrko27s_hwQ")!),
        PreferredGenre(id: 2, name: "ROCK_METAL", imageURL: URL(string: "https://fastly.picsum.photos/id/366/108/108.jpg?hmac=aV1brwLNkVd52uapZPMKWfSPXS2oPwaXCrko27s_hwQ")!),
        PreferredGenre(id: 3, name: "RAP_HIPHOP", imageURL: URL(string: "https://fastly.picsum.photos/id/366/108/108.jpg?hmac=aV1brwLNkVd52uapZPMKWfSPXS2oPwaXCrko27s_hwQ")!),
        PreferredGenre(id: 4, name: "CLASSIC_JAZZ", imageURL: URL(string: "https://fastly.picsum.photos/id/366/108/108.jpg?hmac=aV1brwLNkVd52uapZPMKWfSPXS2oPwaXCrko27s_hwQ")!),
        PreferredGenre(id: 5, name: "ACOUSTIC", imageURL: URL(string: "https://fastly.picsum.photos/id/366/108/108.jpg?hmac=aV1brwLNkVd52uapZPMKWfSPXS2oPwaXCrko27s_hwQ")!),
        PreferredGenre(id: 6, name: "ELECTRONIC", imageURL: URL(string: "https://fastly.picsum.photos/id/366/108/108.jpg?hmac=aV1brwLNkVd52uapZPMKWfSPXS2oPwaXCrko27s_hwQ")!)
    ]
    var selectedGenreList: [PreferredGenre] = []
    var isMaxSelectionToastPresented: Bool = false
    var isUpdateFailureToastPresented: Bool = false

    var isSubmitButtonEnabled: Bool { !selectedGenreList.isEmpty }
}

final class GenreEditStore: ObservableObject {
    private static let maxSelectionCount = 3
    @Published private(set) var state: GenreEditState
    
    init(config: GenreEditConfig) {
        self.state = GenreEditState(config: config)
    }
    
    @MainActor
    func send(_ intent: GenreEditIntent) {
        switch intent {
        case .toggle(let id):
            guard let genre = state.genreList.first(where: { $0.id == id }) else { return }
            
            if let index = state.selectedGenreList.firstIndex(where: { $0.id == id }) {
                state.selectedGenreList.remove(at: index)
                state.isMaxSelectionToastPresented = false
            } else if state.selectedGenreList.count < Self.maxSelectionCount {
                state.selectedGenreList.append(genre)
                state.isMaxSelectionToastPresented = false
            } else {
                state.isMaxSelectionToastPresented = true
            }

        case .resetMaxSelectionToast:
            state.isMaxSelectionToastPresented = false
            
        case .submitFailed:
            guard state.config == .edit else { return }
            state.isUpdateFailureToastPresented = true
            
        case .resetUpdateFailureToast:
            state.isUpdateFailureToastPresented = false
        }
    }
}
