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

public struct GenreEditView: View {
    
    // MARK: - Properties
    
    @StateObject private var selectionStore: GenreSelectionStore
    
    private let config: GenreEditConfig
    private let onBack: () -> Void
    private let onSubmit: ([PreferredGenre]) -> Void
    
    public init(
        mode: GenreEditConfig,
        selectedGenres: [PreferredGenre] = [],
        onBack: @escaping () -> Void,
        onSubmit: @escaping ([PreferredGenre]) -> Void
    ) {
        self._selectionStore = StateObject(wrappedValue: GenreSelectionStore(selectedGenres: selectedGenres))
        self.config = mode
        self.onBack = onBack
        self.onSubmit = onSubmit
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: .zero) {
            LivithNavigationView(
                type: .back(
                    title: config.navigationTitle,
                    onBack: onBack
                )
            )
            
            VStack(spacing: .zero) {
                if let indicator = config.stepIndicator {
                    StepIndicatorView(currentStep: indicator.current, totalSteps: indicator.total)
                        .padding(.top, Constants.indicatorTopPadding)
                }
                
                titleSection
                    .padding(.top, Constants.titleTopPadding)
                
                GenreSelectionView(store: selectionStore)
                
                Spacer()
                
                LivithButton(config.submitTitle) {
                    onSubmit(selectionStore.state.selectedGenreList)
                }
                .disabled(selectionStore.state.selectedGenreList.isEmpty)
                .padding(.bottom, Constants.bottomPadding)
            }
            .padding(.horizontal, Constants.horizontalPadding)
        }
        .background(Color.livithColor(.black100))
        .navigationBarHidden(true)
    }
}

// MARK: - Subviews

private extension GenreEditView {
    var titleSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(config.title)
                    .notosans(.body1Semibold)
                    .foregroundStyle(Color.livithColor(.white100))
                    .multilineTextAlignment(.leading)
                
                if let subtitle = config.subtitle {
                    Text(subtitle)
                        .notosans(.body4Semibold)
                        .foregroundStyle(.livithColor(.black50))
                }
            }
            
            Spacer()
            
            Text(selectedCountText)
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black50))
        }
    }
}

// MARK: - Helpers

private extension GenreEditView {
    var selectedCountText: String {
        "\(selectionStore.state.selectedGenreList.count)/\(PreferenceSelectionRule.maxCount)"
    }
}

// MARK: - Constants & Literals

private extension GenreEditView {
    enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let titleTopPadding: CGFloat = 30
        static let indicatorTopPadding: CGFloat = 10
        static let bottomPadding: CGFloat = 16
    }
}

// MARK: - Preview

#Preview {
    GenreEditView(
        mode: .onboarding(),
        onBack: { print("뒤로가기 눌림") },
        onSubmit: { selectedGenres in
            print("다음이 눌림: \(selectedGenres.map(\.displayName))")
        }
    )
}

#Preview {
    GenreEditView(
        mode: .home(),
        onBack: { print("뒤로가기 눌림") },
        onSubmit: { selectedGenres in
            print("다음이 눌림: \(selectedGenres.map(\.displayName))")
        }
    )
}

#Preview {
    GenreEditView(
        mode: .edit(),
        onBack: { print("뒤로가기 눌림") },
        onSubmit: { selectedGenres in
            print("다음이 눌림: \(selectedGenres.map(\.displayName))")
        }
    )
}
