//
//  ArtistSelectionStore.swift
//  PreferenceFeature
//
//  Created by 김진웅 on 2/2/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

enum ArtistSelectionIntent {
    case onAppear
    case search(keyword: String)
    case toggle(id: Int)
    case resetMaxSelectionToast
}

public struct ArtistSelectionState: Equatable {
    public var selectedArtistList: [PreferredArtist] = []
    var isLoading: Bool = false
    var allArtistList: [PreferredArtist] = []
    var filteredArtistList: [PreferredArtist] = []
    var searchKeyword: String = ""
    var isMaxSelectionToastPresented: Bool = false
}

public final class ArtistSelectionStore: ObservableObject {
    @Published public private(set) var state: ArtistSelectionState = ArtistSelectionState()
    
    public init() {}
    
    @MainActor
    func send(_ intent: ArtistSelectionIntent) {
        switch intent {
        case .onAppear:
            state.isLoading = true
            state.allArtistList = ArtistSelectionStore.mockArtists()
            state.filteredArtistList = state.allArtistList
            state.isLoading = false
            
        case .search(let keyword):
            state.searchKeyword = keyword
            if keyword.isEmpty {
                state.filteredArtistList = state.allArtistList
            } else {
                state.filteredArtistList = state.allArtistList.filter { artist in
                    artist.name.lowercased().contains(keyword.lowercased())
                }
            }
            
        case .toggle(let id):
            guard let artist = state.allArtistList.first(where: { $0.id == id }) else { return }
            
            if let index = state.selectedArtistList.firstIndex(where: { $0.id == id }) {
                state.selectedArtistList.remove(at: index)
                state.isMaxSelectionToastPresented = false
            } else if state.selectedArtistList.count < PreferenceSelectionRule.maxCount {
                state.selectedArtistList.append(artist)
                state.isMaxSelectionToastPresented = false
            } else {
                state.isMaxSelectionToastPresented = true
            }
            
        case .resetMaxSelectionToast:
            state.isMaxSelectionToastPresented = false
        }
    }
}

// MARK: - Mock Data

extension ArtistSelectionStore {
    static func mockArtists() -> [PreferredArtist] {
        [
            PreferredArtist(id: 1, name: "34", genreID: 1, imageURL: mockImageURL()),
            PreferredArtist(id: 2, name: "Sunset Rollercoaster", genreID: 1, imageURL: mockImageURL()),
            PreferredArtist(id: 3, name: "IU", genreID: 2, imageURL: mockImageURL()),
            PreferredArtist(id: 4, name: "IUee", genreID: 2, imageURL: mockImageURL()),
            PreferredArtist(id: 5, name: "IUeee434", genreID: 2, imageURL: mockImageURL()),
            PreferredArtist(id: 6, name: "Day6", genreID: 3, imageURL: mockImageURL()),
            PreferredArtist(id: 7, name: "Seventeen", genreID: 1, imageURL: mockImageURL()),
            PreferredArtist(id: 8, name: "NewJeans", genreID: 2, imageURL: mockImageURL()),
            PreferredArtist(id: 9, name: "Stray Kids", genreID: 1, imageURL: mockImageURL()),
            PreferredArtist(id: 10, name: "BTS", genreID: 2, imageURL: mockImageURL()),
            PreferredArtist(id: 11, name: "BLACKPINK", genreID: 3, imageURL: mockImageURL()),
            PreferredArtist(id: 12, name: "EXO", genreID: 1, imageURL: mockImageURL()),
            PreferredArtist(id: 13, name: "TWICE", genreID: 2, imageURL: mockImageURL()),
            PreferredArtist(id: 14, name: "Red Velvet", genreID: 3, imageURL: mockImageURL()),
            PreferredArtist(id: 15, name: "GOT7", genreID: 1, imageURL: mockImageURL()),
            PreferredArtist(id: 16, name: "Aespa", genreID: 2, imageURL: mockImageURL()),
            PreferredArtist(id: 17, name: "Enhypen", genreID: 1, imageURL: mockImageURL()),
            PreferredArtist(id: 18, name: "IVE", genreID: 3, imageURL: mockImageURL()),
            PreferredArtist(id: 19, name: "Le Sserafim", genreID: 2, imageURL: mockImageURL()),
            PreferredArtist(id: 20, name: "CL", genreID: 1, imageURL: mockImageURL()),
            PreferredArtist(id: 21, name: "Psy", genreID: 2, imageURL: mockImageURL()),
            PreferredArtist(id: 22, name: "Jay Park", genreID: 3, imageURL: mockImageURL()),
            PreferredArtist(id: 23, name: "Taeyeon", genreID: 1, imageURL: mockImageURL()),
            PreferredArtist(id: 24, name: "Taemin", genreID: 2, imageURL: mockImageURL()),
            PreferredArtist(id: 25, name: "Jungkook", genreID: 1, imageURL: mockImageURL()),
            PreferredArtist(id: 26, name: "Lisa", genreID: 3, imageURL: mockImageURL()),
            PreferredArtist(id: 27, name: "Jennie", genreID: 2, imageURL: mockImageURL()),
            PreferredArtist(id: 28, name: "Rose", genreID: 1, imageURL: mockImageURL()),
            PreferredArtist(id: 29, name: "Jisoo", genreID: 2, imageURL: mockImageURL()),
            PreferredArtist(id: 30, name: "HyunA", genreID: 3, imageURL: mockImageURL())
        ]
    }
    
    private static func mockImageURL() -> URL? {
        URL(string: "https://fastly.picsum.photos/id/366/108/108.jpg?hmac=aV1brwLNkVd52uapZPMKWfSPXS2oPwaXCrko27s_hwQ")
    }
}