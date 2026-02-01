//
//  PreferenceBannerView.swift
//  HomeFeature
//
//  Created by Youjin Lee on 2/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct PreferenceBannerView: View {
    @Binding var isExpanded: Bool

    let onTapBanner: () -> Void

    var body: some View {
        if isExpanded {
            expandedBanner
        } else {
            collapsedBanner
        }
    }
}

// MARK: - Expanded Banner

private extension PreferenceBannerView {
    var expandedBanner: some View {
        VStack(spacing: 0) {
            HStack {
                Text(Literals.expandedTitle)
                    .notosans(.body1Semibold)
                    .foregroundStyle(Color.livithColor(.white100))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded = false
                    }
                } label: {
                    Image.livithIcon(.close)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.livithColor(.black50))
                }
            }

            Image.livithImage(.recommendedConcert)
                .resizable()
                .frame(width: 56, height: 56)
                .padding(.top, 20)

            Button {
                onTapBanner()
            } label: {
                Text(Literals.buttonTitle)
                    .notosans(.body2Semibold)
                    .foregroundStyle(Color.livithColor(.black100))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.livithColor(.black30))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 20)
        }
        .padding(20)
        .background(Color.livithColor(.black80))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Collapsed Banner

private extension PreferenceBannerView {
    var collapsedBanner: some View {
        Button {
            onTapBanner()
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Literals.collapsedTitle)
                        .notosans(.body2Semibold)
                        .foregroundStyle(Color.livithColor(.white100))

                    Text(Literals.collapsedSubtitle)
                        .notosans(.caption1Regular)
                        .foregroundStyle(Color.livithColor(.black50))
                }

                Spacer()

                Image.livithImage(.recommendedConcert)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(8)
                    .background(Color.livithColor(.black90))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(16)
            .background(Color.livithColor(.black80))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Constants

private extension PreferenceBannerView {
    enum Literals {
        static let expandedTitle = "나의 취향이 담긴 콘서트를\n추천 받을 수 있어요"
        static let buttonTitle = "취향 선택하러 가기"
        static let collapsedTitle = "취향 선택하러 가기"
        static let collapsedSubtitle = "나의 취향이 담긴 콘서트를 추천받을 수 있어요"
    }
}

// MARK: - Preview

#Preview("Expanded") {
    PreferenceBannerView(isExpanded: .constant(true), onTapBanner: {})
        .padding()
        .background(Color.livithColor(.black100))
}

#Preview("Collapsed") {
    PreferenceBannerView(isExpanded: .constant(false), onTapBanner: {})
        .padding()
        .background(Color.livithColor(.black100))
}
