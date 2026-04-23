//
//  InterestConcertSelectionBottomSectionView.swift
//  HomeFeature
//
//  Created by 김진웅 on 4/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Domain
import LivithDesignSystem

struct InterestConcertSelectionBottomSectionView: View {
    let selectedConcertList: [Concert]
    let ctaTitle: String
    let isCTAEnabled: Bool
    let onRemoveSelectedConcert: (Int) -> Void
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: .zero) {
            if !selectedConcertList.isEmpty {
                selectedConcertChipScrollView
                    .padding(.top, Constants.chipTopPadding)
            }

            LivithButton(ctaTitle, variant: .primary, action: onSubmit)
                .disabled(!isCTAEnabled)
                .padding(.top, selectedConcertList.isEmpty ? Constants.emptyChipButtonTopPadding : Constants.buttonTopPadding)
                .padding(.horizontal, Constants.horizontalPadding)
                .padding(.bottom, Constants.bottomPadding)
        }
        .frame(maxWidth: .infinity)
        .background {
            BackgroundGradientView(
                baseColor: Color.livithColor(.black100),
                transparentOpacity: 0.08
            )
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: - UIComponents

private extension InterestConcertSelectionBottomSectionView {
    var selectedConcertChipScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.chipSpacing) {
                ForEach(selectedConcertList) { concert in
                    RemovableChip(truncatedTitle(for: concert.title)) {
                        onRemoveSelectedConcert(concert.id)
                    }
                }
            }
            .padding(.horizontal, Constants.horizontalPadding)
        }
    }
}

// MARK: - Helpers

private extension InterestConcertSelectionBottomSectionView {
    func truncatedTitle(for title: String) -> String {
        guard title.count > Constants.titleMaxCount else { return title }
        return String(title.prefix(Constants.titleMaxCount)) + "..."
    }
}

private extension InterestConcertSelectionBottomSectionView {
    enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let chipSpacing: CGFloat = 8
        static let chipTopPadding: CGFloat = 20
        static let buttonTopPadding: CGFloat = 12
        static let emptyChipButtonTopPadding: CGFloat = 16
        static let bottomPadding: CGFloat = 16
        static let titleMaxCount = 20
    }
}
