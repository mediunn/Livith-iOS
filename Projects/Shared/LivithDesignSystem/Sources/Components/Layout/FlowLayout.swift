//
//  FlowLayout.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

public struct FlowLayout: Layout {

    // MARK: - Cache

    public struct Cache {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
    }

    // MARK: - Property

    private let spacing: CGFloat

    // MARK: - Initializer

    public init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    // MARK: - Layout

    public func makeCache(subviews: Subviews) -> Cache {
        Cache()
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        cache.size = result.size
        cache.positions = result.positions
        return result.size
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        for (index, position) in cache.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }

        let totalHeight = currentY + lineHeight
        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}
