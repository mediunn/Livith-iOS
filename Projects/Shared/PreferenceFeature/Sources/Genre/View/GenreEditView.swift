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
    private let isSubmitting: Bool
    private let onBack: () -> Void
    private let onSubmit: ([PreferredGenre]) -> Void
    
    public init(
        mode: GenreEditConfig,
        isSubmitting: Bool = false,
        onBack: @escaping () -> Void,
        onSubmit: @escaping ([PreferredGenre]) -> Void
    ) {
        self._selectionStore = StateObject(wrappedValue: GenreSelectionStore(selectedGenres: mode.initialSelection))
        self.config = mode
        self.isSubmitting = isSubmitting
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
                
                LivithButton(config.submitTitle, isLoading: isSubmitting) {
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
                Text(Literals.title)
                    .notosans(.body1Semibold)
                    .foregroundStyle(Color.livithColor(.white100))
                    .multilineTextAlignment(.leading)
                
                if config.showSubtitle {
                    Text(Literals.subtitle)
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

// MARK: - Constants

private extension GenreEditView {
    enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let titleTopPadding: CGFloat = 30
        static let indicatorTopPadding: CGFloat = 10
        static let bottomPadding: CGFloat = 16
    }
    
    enum Literals {
        static let title = "선호하는 장르를\n3개 선택해 주세요"
        static let subtitle = "마이페이지에서 언제든 바꿀 수 있어요"
    }
}
