//
//  SectionHeaderView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct SectionHeaderView: View {

    // MARK: - Property

    private let badgeCount: Int?
    private let firstLine: String
    private let secondLine: String
    private let onReportTapped: () -> Void

    // MARK: - Initializer

    init(
        badgeCount: Int? = nil,
        firstLine: String,
        secondLine: String,
        onReportTapped: @escaping () -> Void
    ) {
        self.badgeCount = badgeCount
        self.firstLine = firstLine
        self.secondLine = secondLine
        self.onReportTapped = onReportTapped
    }

    // MARK: - Body

    var body: some View {
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

                Text(secondLine)
                    .notosans(.body1Semibold)
                    .foregroundStyle(Color.livithColor(.white100))
            }

            Spacer()

            reportButton
        }
    }
}

// MARK: - Subviews

private extension SectionHeaderView {
    var reportButton: some View {
        Button(action: onReportTapped) {
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

    func badgeText(count: Int) -> some View {
        Text("\(count)개")
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
    }
    .padding()
    .background(Color.livithColor(.black100))
}
