//
//  GenreEditView.swift
//  PreferenceFeature
//
//  Created by 김진웅 on 1/29/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Domain
import LivithDesignSystem

struct GenreEditView: View {
    
    // MARK: - Properties
    
    @StateObject private var store: GenreEditStore
    
    @Environment(\.dismiss) private var dismiss
    
    private let onBack: () -> Void
    private let onSubmit: () -> Void
    
    init(
        mode: GenreEditConfig,
        onBack: @escaping () -> Void,
        onSubmit: @escaping () -> Void
    ) {
        self._store = StateObject(wrappedValue: GenreEditStore(mode: mode))
        self.onBack = onBack
        self.onSubmit = onSubmit
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: .zero) {
            LivithNavigationView(
                type: .back(
                    title: store.state.mode.title,
                    onBack: onBack
                )
            )
            
            VStack(spacing: .zero) {
                if let indicator = store.state.mode.stepIndicator {
                    StepIndicatorView(currentStep: indicator.current, totalSteps: indicator.total)
                        .padding(.top, Constants.indicatorTopPadding)
                }
                
                HStack(alignment: .top) {
                    Text(Literals.selectionGuideText)
                        .notosans(.body1Semibold)
                        .foregroundStyle(Color.livithColor(.white100))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Text(selectedCountText)
                        .notosans(.body4Medium)
                        .foregroundStyle(Color.livithColor(.black50))
                }
                .padding(.top, Constants.titleTopPadding)
                
                ScrollView {
                    genreGrid
                        .padding(.top, Constants.sectionSpacing)
                }
                .scrollIndicators(.hidden)
                
                Spacer()
                
                if !store.state.selectedGenreList.isEmpty {
                    selectedGenreChips
                        .padding(.top, Constants.sectionSpacing)
                        .padding(.bottom, Constants.chipBottomPadding)
                }
                
                LivithButton(store.state.mode.submitTitle, action: onSubmit)
                    .disabled(!store.state.isSubmitButtonEnabled)
                    .padding(.bottom, Constants.bottomPadding)
            }
            .padding(.horizontal, Constants.horizontalPadding)
        }
        .background(Color.livithColor(.black100))
        .navigationBarHidden(true)
        .livithToast(
            isPresented: exceedMaxSelectionToastBinding,
            type: .failure,
            message: Literals.exceedMaxSelectionToastMessage
        )
    }
}

// MARK: - Subviews

private extension GenreEditView {
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
        HStack(spacing: Constants.chipSpacing) {
            ForEach(store.state.selectedGenreList) { genre in
                RemovableChip(genre.displayName) {
                    store.send(.toggle(id: genre.id))
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Helpers

private extension GenreEditView {
    var exceedMaxSelectionToastBinding: Binding<Bool> {
        Binding(
            get: { store.state.isMaxSelectionToastPresented },
            set: { isPresented in
                guard !isPresented else { return }
                store.send(.resetMaxSelectionToast)
            }
        )
    }
    
    var selectedCountText: String {
        "\(store.state.selectedGenreList.count)/\(Constants.maxSelectionCount)"
    }
}

// MARK: - Constants & Literals

private extension GenreEditView {
    enum Constants {
        static let maxSelectionCount = 3
        static let gridColumns = 3
        static let gridSpacing: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
        static let sectionSpacing: CGFloat = 30
        static let titleTopPadding: CGFloat = 30
        static let indicatorTopPadding: CGFloat = 10
        static let chipSpacing: CGFloat = 10
        static let chipBottomPadding: CGFloat = 20
        static let bottomPadding: CGFloat = 16
    }
    
    enum Literals {
        static let selectionGuideText = "선호하는 장르를\n3개 선택해 주세요"
        static let exceedMaxSelectionToastMessage = "해제 후 선택해 주세요"
    }
}

// MARK: - Preview

#Preview {
    GenreEditView(
        mode: .onboarding,
        onBack: { print("뒤로가기 눌림") },
        onSubmit: { print("다음이 눌림") }
    )
}

#Preview {
    GenreEditView(
        mode: .home,
        onBack: { print("뒤로가기 눌림") },
        onSubmit: { print("다음이 눌림") }
    )
}

#Preview {
    GenreEditView(
        mode: .edit,
        onBack: { print("뒤로가기 눌림") },
        onSubmit: { print("다음이 눌림") }
    )
}
