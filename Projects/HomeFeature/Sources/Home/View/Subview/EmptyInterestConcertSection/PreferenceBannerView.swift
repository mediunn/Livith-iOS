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

    // MARK: - Property

    @Binding var isExpanded: Bool

    let onTapBanner: () -> Void

    // MARK: - Body

    var body: some View {
        if isExpanded {
            expandedBanner
        } else {
            collapsedBanner
        }
    }
}

// MARK: - UIComponents

private extension PreferenceBannerView {
    var expandedBanner: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Text("나의 취향이 담긴 콘서트를\n추천 받을 수 있어요")
                    .notosans(.body1Semibold)
                    .foregroundStyle(Color.livithColor(.white100))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    isExpanded = false
                } label: {
                    Image.livithIcon(.closeLineSmall)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.livithColor(.black50))
                }
            }

            Image.livithImage(.recommendedConcert)
                .resizable()
                .frame(width: 91, height: 86)
                .padding(.top, 16)

            Button {
                onTapBanner()
            } label: {
                Text("취향 선택하러 가기")
                    .notosans(.body3Semibold)
                    .foregroundStyle(Color.livithColor(.black100))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.livithColor(.original))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 16)
        }
        .padding(16)
        .background(Color.livithColor(.black100))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    var collapsedBanner: some View {
        Button {
            onTapBanner()
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("취향 선택하러 가기")
                        .notosans(.body2Semibold)
                        .foregroundStyle(Color.livithColor(.white100))

                    Text("나의 취향이 담긴 콘서트를 추천받을 수 있어요")
                        .notosans(.caption1Regular)
                        .foregroundStyle(Color.livithColor(.black50))
                }

                Spacer()

                Image.livithImage(.recommendedConcert)
                    .resizable()
                    .frame(width: 61, height: 58)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(16)
            .background(Color.livithColor(.black100))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Expanded") {
    PreferenceBannerView(isExpanded: .constant(true), onTapBanner: {})
        .padding()
        .background(Color.livithColor(.black90))
}

#Preview("Collapsed") {
    PreferenceBannerView(isExpanded: .constant(false), onTapBanner: {})
        .padding()
        .background(Color.livithColor(.black90))
}
