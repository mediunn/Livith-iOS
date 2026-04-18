//
//  LivithCalloutView.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - LivithCalloutAlignment

public enum LivithCalloutAlignment {
    case leading
    case center
    case trailing
}

// MARK: - LivithCalloutPlacement

public enum LivithCalloutPlacement {
    case top(LivithCalloutAlignment)
    case bottom(LivithCalloutAlignment)
}

// MARK: - LivithCalloutStyle

public struct LivithCalloutStyle {
    public let backgroundColor: Color
    public let foregroundColor: Color
    public let highlightColor: Color
    public let cornerRadius: CGFloat
    public let contentInsets: EdgeInsets
    public let tailSize: CGSize
    public let minBubbleHeight: CGFloat
    public let textAlignment: TextAlignment

    public init(
        backgroundColor: Color,
        foregroundColor: Color,
        highlightColor: Color,
        cornerRadius: CGFloat,
        contentInsets: EdgeInsets,
        tailSize: CGSize,
        minBubbleHeight: CGFloat,
        textAlignment: TextAlignment = .center
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.highlightColor = highlightColor
        self.cornerRadius = cornerRadius
        self.contentInsets = contentInsets
        self.tailSize = tailSize
        self.minBubbleHeight = minBubbleHeight
        self.textAlignment = textAlignment
    }
}

public extension LivithCalloutStyle {
    static let gray = Self(
        backgroundColor: .livithColor(.black80),
        foregroundColor: .livithColor(.black50),
        highlightColor: .livithColor(.black5),
        cornerRadius: 24,
        contentInsets: EdgeInsets(top: 7, leading: 12, bottom: 7, trailing: 12),
        tailSize: CGSize(width: 12, height: 8),
        minBubbleHeight: 32
    )

    static let yellow = Self(
        backgroundColor: .livithColor(.yellow30),
        foregroundColor: .livithColor(.black100),
        highlightColor: .livithColor(.black100),
        cornerRadius: 24,
        contentInsets: EdgeInsets(top: 7.5, leading: 15, bottom: 7.5, trailing: 15),
        tailSize: CGSize(width: 12, height: 8),
        minBubbleHeight: 32
    )
}

// MARK: - LivithCalloutView

public struct LivithCalloutView: View {

    // MARK: - Property

    private let text: String
    private let highlightText: String?
    private let style: LivithCalloutStyle
    private let placement: LivithCalloutPlacement
    private let tailInset: CGFloat

    // MARK: - Initializer

    public init(
        _ text: String,
        highlight highlightText: String? = nil,
        style: LivithCalloutStyle = .gray,
        placement: LivithCalloutPlacement = .bottom(.center),
        tailInset: CGFloat = 24
    ) {
        self.text = text
        self.highlightText = highlightText
        self.style = style
        self.placement = placement
        self.tailInset = tailInset
    }

    // MARK: - Body

    public var body: some View {
        bubbleView
            .padding(placement.containerPaddingEdge, style.tailSize.height)
            .overlay(alignment: placement.overlayAlignment) {
                tailView
            }
    }
}

// MARK: - Subviews

private extension LivithCalloutView {
    var bubbleView: some View {
        Text(attributedString)
            .notosans(.caption1Bold)
            .multilineTextAlignment(style.textAlignment)
            .padding(style.contentInsets)
            .frame(minHeight: style.minBubbleHeight)
            .background(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(style.backgroundColor)
            )
    }

    @ViewBuilder
    var tailView: some View {
        let tail = TriangleTail(edge: placement.edge)
            .fill(style.backgroundColor)
            .frame(width: style.tailSize.width, height: style.tailSize.height)
            .frame(maxWidth: .infinity, alignment: placement.frameAlignment)

        switch placement.alignment {
        case .leading:
            tail.padding(.leading, resolvedTailInset)
        case .center:
            tail
        case .trailing:
            tail.padding(.trailing, resolvedTailInset)
        }
    }
}

// MARK: - Helpers

private extension LivithCalloutView {
    var attributedString: AttributedString {
        var attributedString = AttributedString(text)
        attributedString.foregroundColor = style.foregroundColor

        if let highlightText = highlightText,
           let range = attributedString.range(of: highlightText) {
            attributedString[range].foregroundColor = style.highlightColor
        }

        return attributedString
    }

    var resolvedTailInset: CGFloat {
        switch placement.alignment {
        case .center:
            return .zero
        case .leading, .trailing:
            return max(tailInset, style.cornerRadius)
        }
    }
}

// MARK: - Triangle Tail

private struct TriangleTail: Shape {
    let edge: LivithCalloutEdge

    func path(in rect: CGRect) -> Path {
        var path = Path()

        switch edge {
        case .top:
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        case .bottom:
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        }

        path.closeSubpath()
        return path
    }
}

private enum LivithCalloutEdge {
    case top
    case bottom
}

private extension LivithCalloutPlacement {
    var edge: LivithCalloutEdge {
        switch self {
        case .top:
            return .top
        case .bottom:
            return .bottom
        }
    }

    var alignment: LivithCalloutAlignment {
        switch self {
        case .top(let alignment), .bottom(let alignment):
            return alignment
        }
    }

    var frameAlignment: Alignment {
        switch alignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }

    var overlayAlignment: Alignment {
        switch edge {
        case .top:
            return .top
        case .bottom:
            return .bottom
        }
    }

    var containerPaddingEdge: Edge.Set {
        switch edge {
        case .top:
            return .top
        case .bottom:
            return .bottom
        }
    }
}

// MARK: - Preview

#Preview("Gray") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        VStack(spacing: 20) {
            LivithCalloutView(
                "회원가입하고 모든 서비스 이용해보세요!",
                highlight: "모든 서비스 이용"
            )

            LivithCalloutView(
                "카카오로 최근에 로그인 했어요",
                highlight: "카카오",
                placement: .top(.leading)
            )

            LivithCalloutView(
                "Apple로 최근에 로그인 했어요",
                highlight: "Apple",
                placement: .bottom(.trailing),
                tailInset: 24
            )
        }
        .padding()
    }
}

#Preview("Yellow") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        VStack(spacing: 24) {
            LivithCalloutView(
                "관심 콘서트 설정하고 공연 일정·셋리스트 정보 빠르게",
                style: .yellow,
                placement: .top(.trailing),
                tailInset: 24
            )
            .frame(maxWidth: 340)

            LivithCalloutView(
                "관심 콘서트 알림과 소식을 한 곳에서 받아보세요",
                style: .yellow,
                placement: .bottom(.center)
            )
            .frame(maxWidth: 320)
        }
        .padding()
    }
}
