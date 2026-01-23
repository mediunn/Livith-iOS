//
//  LivithCard.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - Badge Type

public enum LivithCardBadge: Equatable {
    case status(text: String, remainDays: Int)
    case tag(text: String)
    case none
}

// MARK: - LivithCard

public struct LivithCard: View {

    // MARK: - Property

    private let imageURL: URL?
    private let title: String
    private let subtitle: String?
    private let secondaryText: String?
    private let badge: LivithCardBadge
    private let isSelected: Bool
    private let isFlexible: Bool
    private let titleLineLimit: Int?
    private let onTap: (() -> Void)?

    // MARK: - Initializer

    public init(
        imageURL: URL?,
        title: String,
        subtitle: String? = nil,
        secondaryText: String? = nil,
        badge: LivithCardBadge = .none,
        isSelected: Bool = false,
        isFlexible: Bool = false,
        titleLineLimit: Int? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.imageURL = imageURL
        self.title = title
        self.subtitle = subtitle
        self.secondaryText = secondaryText
        self.badge = badge
        self.isSelected = isSelected
        self.isFlexible = isFlexible
        self.titleLineLimit = titleLineLimit
        self.onTap = onTap
    }

    // MARK: - Body

    public var body: some View {
        if let onTap {
            Button(action: onTap) {
                cardContent
            }
        } else {
            cardContent
        }
    }

    private var cardContent: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 0) {
                thumbnailImage
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isSelected ? Color.livithColor(.yellow30) : .clear, lineWidth: 2)
                    )

                titleText
                    .padding(.top, hasSecondaryText ? 6 : 8)

                if let subtitle, !subtitle.isEmpty {
                    subtitleText(subtitle)
                        .padding(.top, hasSecondaryText ? 8 : 0)
                }

                if let secondaryText, !secondaryText.isEmpty {
                    secondaryTextView(secondaryText)
                        .padding(.top, 2)
                        .padding(.bottom, 6)
                }
            }
            .frame(width: isFlexible ? nil : 108, alignment: .top)
            .frame(maxWidth: isFlexible ? .infinity : nil)
            .padding(.bottom, hasSecondaryText ? 0 : 8)

            badgeView
                .padding(.top, 10)
                .padding(.leading, 10)
        }
        .background(Color.livithColor(.black100))
        .contentShape(Rectangle())
    }
}

// MARK: - Computed Properties

private extension LivithCard {
    var hasSecondaryText: Bool {
        guard let secondaryText else { return false }
        return !secondaryText.isEmpty
    }
}

// MARK: - Subviews

private extension LivithCard {
    @ViewBuilder
    var thumbnailImage: some View {
        if let imageURL {
            if isFlexible {
                Color.clear
                    .aspectRatio(108/158, contentMode: .fit)
                    .overlay {
                        AsyncImageView(url: imageURL)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                AsyncImageView(url: imageURL)
                    .frame(width: 108, height: 158)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        } else {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.livithColor(.black80))
                .aspectRatio(108/158, contentMode: isFlexible ? .fit : .fill)
                .frame(width: isFlexible ? nil : 108, height: isFlexible ? nil : 158)
        }
    }

    var titleText: some View {
        Text(title)
            .lineLimit(titleLineLimit ?? 2)
            .truncationMode(.tail)
            .multilineTextAlignment(.leading)
            .notosans(.body2Medium)
            .foregroundStyle(Color.livithColor(.white100))
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    func subtitleText(_ text: String) -> some View {
        Text(text)
            .lineLimit(1)
            .notosans(.caption1Semibold)
            .foregroundStyle(Color.livithColor(.black50))
    }

    func secondaryTextView(_ text: String) -> some View {
        Text(text)
            .lineLimit(1)
            .notosans(.caption1Semibold)
            .foregroundStyle(Color.livithColor(.black50))
    }

    @ViewBuilder
    var badgeView: some View {
        switch badge {
        case .status(let text, let remainDays):
            LivithChip.dDay(text, remainDays: remainDays, isSelected: isSelected)
        case .tag(let text):
            LivithChip(text, style: .tag)
        case .none:
            EmptyView()
        }
    }
}

// MARK: - Preview

#Preview("Concert Card") {
    HStack(alignment: .top, spacing: 12) {
        LivithCard(
            imageURL: nil,
            title: "아이유 단독 콘서트 'The Golden Hour'",
            subtitle: "2025.12.01 ~ 12.31",
            secondaryText: "아이유",
            badge: .status(text: "D-", remainDays: 3)
        )

        LivithCard(
            imageURL: nil,
            title: "아이유 단독 콘서트 'The Golden Hour'",
            subtitle: "2025.12.01 ~ 12.31",
            secondaryText: "아이유",
            badge: .status(text: "D-", remainDays: 3),
            isSelected: true
        )
    }
    .padding()
    .background(Color.livithColor(.black100))
}

#Preview("Merchandise Card") {
    HStack(alignment: .top, spacing: 12) {
        LivithCard(
            imageURL: nil,
            title: "공식 티셔츠",
            subtitle: "45,000원"
        )

        LivithCard(
            imageURL: nil,
            title: "공식 포토카드 세트 랜덤",
            subtitle: "15,000원"
        )
    }
    .padding()
    .background(Color.livithColor(.black100))
}

#Preview("Setlist Card") {
    HStack(alignment: .top, spacing: 12) {
        LivithCard(
            imageURL: nil,
            title: "2025 World Tour Seoul",
            subtitle: "2025.01.15",
            badge: .tag(text: "공식"),
            isFlexible: true,
            titleLineLimit: 2
        )
    }
    .padding()
    .background(Color.livithColor(.black100))
}
