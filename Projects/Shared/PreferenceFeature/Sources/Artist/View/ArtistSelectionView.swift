//
//  ArtistSelectionView.swift
//  PreferenceFeature
//
//  Created by 김진웅 on 2/2/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Amplitude
import Domain
import LivithDesignSystem

public struct ArtistSelectionView: View {
    @ObservedObject private var store: ArtistSelectionStore
    @Binding private var isSearchFocused: Bool
    
    public init(store: ArtistSelectionStore, isSearchFocused: Binding<Bool>) {
        self.store = store
        self._isSearchFocused = isSearchFocused
    }
    
    public var body: some View {
        VStack(spacing: .zero) {
            searchBar
                .padding(.top, Constants.searchBarTopPadding)
                .padding(.bottom, Constants.gridTopPadding)
            
            scrollContent
        }
        .livithToast(
            isPresented: exceedMaxSelectionToastBinding,
            type: .failure,
            message: Literals.exceedMaxSelectionToastMessage
        )
        .livithToast(
            isPresented: errorToastBinding,
            type: .failure,
            message: store.state.errorMessage
        )
        .onAppear {
            store.send(.onAppear)
        }
        .onChange(of: isSearchFocused) { _, isFocused in
            if isFocused {
                AmplitudeService.shared.trackEvent(tag: .click(.searchBarArtistPreference))
            }
        }
    }
}

// MARK: - Subviews

private extension ArtistSelectionView {
    var searchBar: some View {
        LivithTextField(
            text: searchTextBinding,
            isFocused: $isSearchFocused,
            type: .search,
            placeholder: Literals.searchPlaceholder,
            onSubmit: {
                AmplitudeService.shared.trackEvent(tag: .click(.searchCompleteArtistPreference))
            },
            onChange: {
                store.send(.search(keyword: store.state.searchKeyword))
            }
        )
    }
    
    @ViewBuilder
    var scrollContent: some View {
        if store.state.isLoading {
            loadingIndicator
        } else {
            loadedContent
        }
    }

    var loadedContent: some View {
        ZStack(alignment: .bottom) {
            artistContent
            selectedArtistChipOverlay
        }
    }

    @ViewBuilder
    var artistContent: some View {
        if store.state.artistList.isEmpty {
            artistGridEmptyView
        } else {
            artistGridScrollView
        }
    }

    var artistGridScrollView: some View {
        ScrollView {
            artistGrid
                .padding(2)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
    }

    @ViewBuilder
    var selectedArtistChipOverlay: some View {
        if !store.state.selectedArtistList.isEmpty {
            selectedArtistChips
                .padding(.vertical, Constants.chipVerticalPadding)
                .background(BackgroundGradientView())
        }
    }
    
    var loadingIndicator: some View {
        VStack {
            Spacer()
            
            ProgressView()
                .tint(Color.livithColor(.white100))
            
            Spacer()
        }
    }
    
    var artistGridEmptyView: some View {
        VStack {
            Spacer()
            
            LivithEmptyView(text: "검색 결과가 없어요")
            
            Spacer()
        }
    }
    
    var artistGrid: some View {
        LazyVGrid(
            columns: gridItems,
            spacing: Constants.gridSpacing
        ) {
            ForEach(store.state.artistList) { artist in
                artistCard(for: artist)
            }
        }
    }

    func artistCard(for artist: PreferredArtist) -> some View {
        PreferenceCard(
            title: artist.name,
            imageURL: artist.imageURL,
            isSelected: isArtistSelected(artist),
            action: {
                AmplitudeService.shared.trackEvent(tag: .click(.searchCellArtistPreference))
                store.send(.toggle(id: artist.id))
            }
        )
        .onAppear {
            guard shouldLoadMore(for: artist) else { return }
            store.send(.loadMore)
        }
    }
    
    var selectedArtistChips: some View {
        FlowLayout(spacing: Constants.chipSpacing) {
            ForEach(store.state.selectedArtistList) { artist in
                RemovableChip(artist.name) {
                    store.send(.toggle(id: artist.id))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Helpers

private extension ArtistSelectionView {
    var gridItems: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: Constants.gridSpacing),
            count: Constants.gridColumns
        )
    }

    func isArtistSelected(_ artist: PreferredArtist) -> Bool {
        store.state.selectedArtistList.contains(where: { $0.id == artist.id })
    }

    func shouldLoadMore(for artist: PreferredArtist) -> Bool {
        artist == store.state.artistList.last
    }

    var searchTextBinding: Binding<String> {
        Binding(
            get: { store.state.searchKeyword },
            set: { store.send(.search(keyword: $0)) }
        )
    }
    
    var exceedMaxSelectionToastBinding: Binding<Bool> {
        Binding(
            get: { store.state.isMaxSelectionToastPresented },
            set: { isPresented in
                guard !isPresented else { return }
                store.send(.resetMaxSelectionToast)
            }
        )
    }
    
    var errorToastBinding: Binding<Bool> {
        Binding(
            get: { store.state.isErrorToastPresented },
            set: { isPresented in
                guard !isPresented else { return }
                store.send(.resetErrorToast)
            }
        )
    }
}

// MARK: - Constants & Literals

private extension ArtistSelectionView {
    enum Constants {
        static let gridColumns = 3
        static let gridSpacing: CGFloat = 12
        static let searchBarTopPadding: CGFloat = 30
        static let gridTopPadding: CGFloat = 20
        static let chipVerticalPadding: CGFloat = 15
        static let chipSpacing: CGFloat = 10
    }
    
    enum Literals {
        static let searchPlaceholder = "아티스트를 검색하세요"
        static let exceedMaxSelectionToastMessage = "해제 후 선택해 주세요"
    }
}

#Preview {
    ArtistSelectionView(store: ArtistSelectionStore(), isSearchFocused: .constant(false))
        .frame(width: 375, height: 600)
        .background(Color.livithColor(.black100))
}
