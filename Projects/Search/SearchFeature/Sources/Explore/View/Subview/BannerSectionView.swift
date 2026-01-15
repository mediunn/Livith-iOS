//
//  BannerSectionView.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/19/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem
import SearchDomain

struct BannerSectionView: View {
    
    // MARK: - Constants
    
    private enum Constants {
        static let dragThreshold: CGFloat = 50
        static let minimumDragDistance: CGFloat = 20
        static let animationDuration: Double = 0.3
        static let indicatorBottomPadding: CGFloat = 16
    }
    
    // MARK: - Property
    
    @Binding var currentPage: Int
    let banners: [Banner]
    
    @State private var dragOffset: CGFloat = 0
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            bannerContent
            pageIndicator
        }
        .contentShape(Rectangle())
        .gesture(dragGesture)
    }
}

// MARK: - Subviews

private extension BannerSectionView {
    var bannerContent: some View {
        ForEach(Array(banners.enumerated()), id: \.element.id) { index, banner in
            BannerCell(
                imageURL: banner.imageURL,
                category: banner.category,
                title: banner.title,
                description: banner.description
            )
            .opacity(index == currentPage ? 1 : 0)
        }
    }
    
    var pageIndicator: some View {
        LivithPageIndicatorView(
            currentPage: currentPage,
            pageCount: banners.count
        )
        .padding(.bottom, Constants.indicatorBottomPadding)
    }
}

// MARK: - Gesture

private extension BannerSectionView {
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: Constants.minimumDragDistance)
            .onChanged { dragOffset = $0.translation.width }
            .onEnded(handleDragEnded)
    }
    
    func handleDragEnded(_ value: DragGesture.Value) {
        let horizontalAmount = value.translation.width
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
        return currentPage
    }
    
    var nextIndex: Int {
        (currentPage + 1) % banners.count
    }
    
    var previousIndex: Int {
        (currentPage - 1 + banners.count) % banners.count
    }
}
