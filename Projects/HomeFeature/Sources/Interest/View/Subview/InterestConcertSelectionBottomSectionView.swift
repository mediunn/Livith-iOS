//
//  InterestConcertSelectionBottomSectionView.swift
//  HomeFeature
//
//  Created by 김진웅 on 4/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import DisplaySupport
import Domain
import LivithDesignSystem

struct InterestConcertSelectionBottomSectionView: View {
    let selectedConcertList: [Concert]
    let ctaTitle: String
    let isCTAEnabled: Bool
    let isSubmitting: Bool
    let onRemoveSelectedConcert: (Int) -> Void
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            if !selectedConcertList.isEmpty {
                selectedConcertChipScrollView
                    .padding(.top, 20)
                    .padding(.bottom, 10)
            }

            LivithButton(ctaTitle, variant: .primary, isLoading: isSubmitting, action: onSubmit)
                .disabled(!isCTAEnabled || isSubmitting)
                .padding(.horizontal, Constants.horizontalPadding)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 50)
        .background {
            BackgroundGradientView(
                baseColor: Color.livithColor(.black100),
                transparentOpacity: 0
            )
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: - UIComponents

private extension InterestConcertSelectionBottomSectionView {
    var selectedConcertChipScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(selectedConcertList) { concert in
                    RemovableChip(truncatedTitle(for: ConcertDisplayText.title(for: concert))) {
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
        static let titleMaxCount = 20
    }
}
