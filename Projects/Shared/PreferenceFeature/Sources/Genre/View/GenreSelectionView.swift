//
//  GenreSelectionView.swift
//  PreferenceFeature
//
//  Created by 김진웅 on 1/30/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Domain
import LivithDesignSystem

public struct GenreSelectionView: View {
    @ObservedObject private var store: GenreSelectionStore
    
    public init(store: GenreSelectionStore) {
        self.store = store
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            if store.state.isLoading {
                loadingIndicator
            } else {
                ScrollView {
                    genreGrid
                        .padding(.top, Constants.sectionTopSpacing)
                        .padding(.horizontal, Constants.sectionHorizontalSpacing)
                }
                .scrollIndicators(.hidden)
                
                if !store.state.selectedGenreList.isEmpty {
                    selectedGenreChips
                        .padding(.top, Constants.sectionTopSpacing)
                        .padding(.bottom, Constants.chipBottomPadding)
                        .background(BackgroundGradientView())
                }
            }
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
    }
}

// MARK: - Subviews

private extension GenreSelectionView {
    var loadingIndicator: some View {
        VStack {
            Spacer()
            
            ProgressView()
                .tint(Color.livithColor(.white100))
            
            Spacer()
        }
    }
    
    var genreGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: Constants.gridSpacing), count: Constants.gridColumns),
            spacing: Constants.gridSpacing
        ) {
            ForEach(store.state.genreList) { genre in
                PreferenceCard(
                    title: genre.displayName,
                    imageURL: genre.imageURL,
                    isSelected: store.state.selectedGenreList.contains(where: { $0.id == genre.id }),
                    action: {
                        store.send(.toggle(id: genre.id))
                    }
                )
            }
        }
    }
    
    var selectedGenreChips: some View {
        FlowLayout(spacing: Constants.chipSpacing) {
            ForEach(store.state.selectedGenreList) { genre in
                RemovableChip(genre.displayName) {
                    store.send(.toggle(id: genre.id))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Helpers

private extension GenreSelectionView {
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

private extension GenreSelectionView {
    enum Constants {
        static let gridColumns = 3
        static let gridSpacing: CGFloat = 12
        static let sectionTopSpacing: CGFloat = 30
        static let sectionHorizontalSpacing: CGFloat = 2
        static let chipSpacing: CGFloat = 10
        static let chipBottomPadding: CGFloat = 20
    }
    
    enum Literals {
        static let exceedMaxSelectionToastMessage = "해제 후 선택해 주세요"
    }
}

#Preview {
    GenreSelectionView(store: GenreSelectionStore())
        .frame(width: 375, height: 400)
        .background(Color.livithColor(.black100))
}
