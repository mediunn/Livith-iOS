//
//  BannerSectionView.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/19/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem
import Domain

struct BannerSectionView: View {

    // MARK: - Property

    private enum Constants {
        static let dragThreshold: CGFloat = 50
        static let minimumDragDistance: CGFloat = 20
        static let animationDuration: Double = 0.5
        static let indicatorBottomPadding: CGFloat = 16
    }

    @Binding var currentPage: Int
    let banners: [Banner]
    let onTapBanner: (Banner) -> Void

    @State private var dragOffset: CGFloat = 0

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            bannerContent
            pageIndicator
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: handleTap)
        .simultaneousGesture(dragGesture)
    }
}

// MARK: - UIComponents

private extension BannerSectionView {
    var bannerContent: some View {
        ForEach(Array(banners.enumerated()), id: \.element.id) { index, banner in
            BannerCell(
                imageURL: banner.imageURL,
                category: banner.category,
                title: banner.title,
                description: banner.description
            )
            .opacity(index == safeCurrentPage ? 1 : 0)
        }
    }

    var pageIndicator: some View {
        LivithPageIndicatorView(
            currentPage: safeCurrentPage,
            pageCount: banners.count
        )
        .padding(.bottom, Constants.indicatorBottomPadding)
    }
}

// MARK: - Helpers

private extension BannerSectionView {
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: Constants.minimumDragDistance)
            .onChanged { dragOffset = $0.translation.width }
            .onEnded(handleDragEnded)
    }

    func handleDragEnded(_ value: DragGesture.Value) {
        guard !banners.isEmpty else {
            dragOffset = 0
            return
        }

        let horizontalAmount = value.translation.width
        let verticalAmount = value.translation.height
        guard abs(horizontalAmount) > abs(verticalAmount) else {
            dragOffset = 0
            return
        }

        let newIndex = calculateNewIndex(from: horizontalAmount)

        if newIndex != currentPage {
            withAnimation(.easeInOut(duration: Constants.animationDuration)) {
                currentPage = newIndex
            }
        }

        dragOffset = 0
    }

    func calculateNewIndex(from horizontalAmount: CGFloat) -> Int {
        if horizontalAmount < -Constants.dragThreshold {
            return nextIndex
        } else if horizontalAmount > Constants.dragThreshold {
            return previousIndex
        }
        return safeCurrentPage
    }

    var nextIndex: Int {
        guard !banners.isEmpty else { return 0 }
        return (safeCurrentPage + 1) % banners.count
    }

    var previousIndex: Int {
        guard !banners.isEmpty else { return 0 }
        return (safeCurrentPage - 1 + banners.count) % banners.count
    }

    var safeCurrentPage: Int {
        guard !banners.isEmpty else { return 0 }
        return min(max(currentPage, 0), banners.count - 1)
    }

    func handleTap() {
        guard !banners.isEmpty else { return }

        onTapBanner(banners[safeCurrentPage])
    }
}
