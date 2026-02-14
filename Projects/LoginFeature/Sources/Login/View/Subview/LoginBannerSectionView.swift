//
//  LoginBannerSectionView.swift
//  LoginFeature
//
//  Created by 김진웅 on 2/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct LoginBannerSectionView: View {

    // MARK: - Constants

    private enum Constants {
        static let images: [Image.LivithImage] = [
            .onboarding01,
            .onboarding02,
            .onboarding03,
            .onboarding04
        ]
        static let onboardingImageAspectRatio: CGFloat = 374.0 / 579.0
        static let indicatorTopPadding: CGFloat = 10
        static let dragThreshold: CGFloat = 50
        static let minimumDragDistance: CGFloat = 20
        static let animationDuration: Double = 0.5
    }

    // MARK: - Property

    @State private var currentPage: Int = 0

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ForEach(Array(Constants.images.enumerated()), id: \.offset) { index, image in
                    Image.livithImage(image)
                        .resizable()
                        .aspectRatio(Constants.onboardingImageAspectRatio, contentMode: .fit)
                        .opacity(index == currentPage ? 1 : 0)
                }
            }
            .aspectRatio(Constants.onboardingImageAspectRatio, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .gesture(dragGesture)

            LivithPageIndicatorView(
                currentPage: currentPage,
                pageCount: Constants.images.count
            )
            .padding(.top, Constants.indicatorTopPadding)
        }
    }
}

// MARK: - Gesture

private extension LoginBannerSectionView {
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: Constants.minimumDragDistance)
            .onEnded(handleDragEnded)
    }

    func handleDragEnded(_ value: DragGesture.Value) {
        guard !Constants.images.isEmpty else { return }

        let horizontalAmount = value.translation.width
        let newIndex = calculateNewIndex(from: horizontalAmount)

        if newIndex != currentPage {
            withAnimation(.easeInOut(duration: Constants.animationDuration)) {
                currentPage = newIndex
            }
        }
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
        (currentPage + 1) % Constants.images.count
    }

    var previousIndex: Int {
        (currentPage - 1 + Constants.images.count) % Constants.images.count
    }
}

#Preview {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        LoginBannerSectionView()
    }
}
