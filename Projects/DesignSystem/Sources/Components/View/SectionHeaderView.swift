//
//  SectionHeaderView.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

public struct SectionHeaderView<TrailingContent: View>: View {

    // MARK: - Property

    private let badgeCount: Int?
    private let badgeSuffix: String
    private let firstLine: String
    private let secondLine: String?
    private let trailingContent: TrailingContent

    // MARK: - Initializer

    public init(
        badgeCount: Int? = nil,
        badgeSuffix: String = "개",
        firstLine: String,
        secondLine: String? = nil,
        @ViewBuilder trailingContent: () -> TrailingContent
    ) {
        self.badgeCount = badgeCount
        self.badgeSuffix = badgeSuffix
        self.firstLine = firstLine
        self.secondLine = secondLine
        self.trailingContent = trailingContent()
    }

    // MARK: - Body

    public var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 4) {
                    if let count = badgeCount {
                        badgeText(count: count)
                    }

                    Text(firstLine)
                        .notosans(.body1Semibold)
                        .foregroundStyle(Color.livithColor(.white100))
                }

                if let secondLine, !secondLine.isEmpty {
                    Text(secondLine)
                        .notosans(.body1Semibold)
                        .foregroundStyle(Color.livithColor(.white100))
                }
            }

            Spacer()

            trailingContent
        }
    }
}

// MARK: - Convenience Initializer (Report Button)

public extension SectionHeaderView where TrailingContent == ReportButton {
    init(
        badgeCount: Int? = nil,
        badgeSuffix: String = "개",
        firstLine: String,
        secondLine: String? = nil,
        onReportTapped: @escaping () -> Void
    ) {
        self.badgeCount = badgeCount
        self.badgeSuffix = badgeSuffix
        self.firstLine = firstLine
        self.secondLine = secondLine
        self.trailingContent = ReportButton(action: onReportTapped)
    }
}

// MARK: - Report Button

public struct ReportButton: View {
    let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text("정보 제보")
                .notosans(.caption1Semibold)
                .foregroundStyle(Color.livithColor(.black50))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.livithColor(.black80), lineWidth: 1)
                )
        }
    }
}

// MARK: - Subviews

private extension SectionHeaderView {
    func badgeText(count: Int) -> some View {
        Text("\(count)\(badgeSuffix)")
            .notosans(.body1Semibold)
            .foregroundStyle(Color.livithColor(.black100))
            .padding(.horizontal, 8)
            .padding(.vertical, 1)
            .background(Color.livithColor(.yellow30))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

#Preview {
    VStack(spacing: 20) {
        SectionHeaderView(
            firstLine: "아티스트 정보",
            secondLine: "함께 알아볼까요?",
            onReportTapped: {}
        )

        SectionHeaderView(
            badgeCount: 5,
            firstLine: "의 팬문화와",
            secondLine: "꿀팁을 알아봐요",
            onReportTapped: {}
        )

        SectionHeaderView(
            firstLine: "예상",
            onReportTapped: {}
        )

        SectionHeaderView(
            badgeCount: 8,
            badgeSuffix: "건",
            firstLine: "의 MD 정보를",
            secondLine: "한 눈에 확인해요"
        ) {
            Image.livithIcon(.rightLineDefault)
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
    .padding()
    .background(Color.livithColor(.black100))
}
