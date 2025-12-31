//
//  ThumbnailCard.swift
//  DSKit
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

public struct ThumbnailCard: View {

    // MARK: - Property

    private let imageURL: URL?
    private let title: String
    private let subtitle: String?
    private let flexible: Bool

    // MARK: - Initializer

    public init(
        imageURL: URL?,
        title: String,
        subtitle: String? = nil,
        flexible: Bool = false
    ) {
        self.imageURL = imageURL
        self.title = title
        self.subtitle = subtitle
        self.flexible = flexible
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            thumbnailImage

            Text(title)
                .notosans(.body2Medium)
                .foregroundStyle(Color.livithColor(.white100))
                .frame(maxWidth: flexible ? .infinity : 108, alignment: .leading)

            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .notosans(.caption1Semibold)
                    .foregroundStyle(Color.livithColor(.black50))
            }
        }
        .frame(maxWidth: flexible ? .infinity : 108, alignment: .top)
        .padding(.bottom, 8)
    }
}

// MARK: - Subviews

private extension ThumbnailCard {
    @ViewBuilder
    var thumbnailImage: some View {
        if let imageURL {
            if flexible {
                AsyncImageView(url: imageURL)
                    .aspectRatio(108/158, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                AsyncImageView(url: imageURL)
                    .frame(width: 108, height: 158)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        } else {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.livithColor(.black80))
                .modifier(ThumbnailSizeModifier(flexible: flexible))
        }
    }
}

// MARK: - Size Modifier

private struct ThumbnailSizeModifier: ViewModifier {
    let flexible: Bool

    func body(content: Content) -> some View {
        if flexible {
            content.aspectRatio(108/158, contentMode: .fit)
        } else {
            content.frame(width: 108, height: 158)
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView(.horizontal) {
        HStack(alignment: .top, spacing: 10) {
            ThumbnailCard(
                imageURL: nil,
                title: "한줄",
                subtitle: "10,000원"
            )

            ThumbnailCard(
                imageURL: nil,
                title: "두줄짜리 제목 테스트입니다",
                subtitle: "10,000원"
            )

            ThumbnailCard(
                imageURL: nil,
                title: "세줄짜리 제목 테스트입니다 길어요",
                subtitle: "10,000원"
            )

            ThumbnailCard(
                imageURL: nil,
                title: "아주 긴 제목입니다 여섯줄이 넘어가는 경우를 테스트합니다 정말 길어요",
                subtitle: "10,000원"
            )
        }
        .padding()
    }
    .background(Color.livithColor(.black100))
}
