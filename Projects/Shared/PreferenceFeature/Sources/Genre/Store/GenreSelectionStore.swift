//
//  GenreSelectionStore.swift
//  PreferenceFeature
//
//  Created by 김진웅 on 1/30/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

enum GenreSelectionIntent {
    case onAppear
    case toggle(id: Int)
    case resetMaxSelectionToast
}

public struct GenreSelectionState: Equatable {
    public var selectedGenreList: [PreferredGenre] = []
    var isLoading: Bool = false
    var genreList: [PreferredGenre] = []
    var isMaxSelectionToastPresented: Bool = false
}

public final class GenreSelectionStore: ObservableObject {
    @Published public private(set) var state: GenreSelectionState = GenreSelectionState()
    
    public init() {}
    
    @MainActor
    func send(_ intent: GenreSelectionIntent) {
        switch intent {
        case .onAppear:
            state.isLoading = true
            state.genreList = [
                PreferredGenre(id: 1, name: "JPOP", imageURL: URL(string: "https://fastly.picsum.photos/id/366/108/108.jpg?hmac=aV1brwLNkVd52uapZPMKWfSPXS2oPwaXCrko27s_hwQ")!),
                PreferredGenre(id: 2, name: "ROCK_METAL", imageURL: URL(string: "https://fastly.picsum.photos/id/366/108/108.jpg?hmac=aV1brwLNkVd52uapZPMKWfSPXS2oPwaXCrko27s_hwQ")!),
                PreferredGenre(id: 3, name: "RAP_HIPHOP", imageURL: URL(string: "https://fastly.picsum.photos/id/366/108/108.jpg?hmac=aV1brwLNkVd52uapZPMKWfSPXS2oPwaXCrko27s_hwQ")!),
                PreferredGenre(id: 4, name: "CLASSIC_JAZZ", imageURL: URL(string: "https://fastly.picsum.photos/id/366/108/108.jpg?hmac=aV1brwLNkVd52uapZPMKWfSPXS2oPwaXCrko27s_hwQ")!),
                PreferredGenre(id: 5, name: "ACOUSTIC", imageURL: URL(string: "https://fastly.picsum.photos/id/366/108/108.jpg?hmac=aV1brwLNkVd52uapZPMKWfSPXS2oPwaXCrko27s_hwQ")!),
                PreferredGenre(id: 6, name: "ELECTRONIC", imageURL: URL(string: "https://fastly.picsum.photos/id/366/108/108.jpg?hmac=aV1brwLNkVd52uapZPMKWfSPXS2oPwaXCrko27s_hwQ")!)
            ]
            state.isLoading = false
            
        case .toggle(let id):
            guard let genre = state.genreList.first(where: { $0.id == id }) else { return }
            
            if let index = state.selectedGenreList.firstIndex(where: { $0.id == id }) {
                state.selectedGenreList.remove(at: index)
                state.isMaxSelectionToastPresented = false
            } else if state.selectedGenreList.count < PreferenceSelectionRule.maxCount {
                state.selectedGenreList.append(genre)
                state.isMaxSelectionToastPresented = false
            } else {
                state.isMaxSelectionToastPresented = true
            }
            
        case .resetMaxSelectionToast:
            state.isMaxSelectionToastPresented = false
        }
    }
}
