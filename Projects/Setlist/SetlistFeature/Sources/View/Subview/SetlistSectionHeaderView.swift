//
//  SetlistSectionHeaderView.swift
//  SetlistFeature
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import SetlistDomain

struct SetlistSectionHeaderView: View {

    // MARK: - Property

    let type: SetlistType
    let onReportTapped: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(alignment: .center) {
            HStack(spacing: 8) {
                Text(type.displayText)
                    .notosans(.body1Semibold)
                    .foregroundStyle(Color.livithColor(.white100))

                if let badgeText = type.badgeText {
                    badgeView(text: badgeText)
                }
            }

            Spacer()

            reportButton
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Subviews

private extension SetlistSectionHeaderView {
    func badgeView(text: String) -> some View {
        Text(text)
            .notosans(.caption1Bold)
            .foregroundStyle(Color.livithColor(.black100))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.livithColor(.yellow60))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }

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
}

#Preview {
    VStack(spacing: 20) {
        SetlistSectionHeaderView(type: .expected, onReportTapped: {})
        SetlistSectionHeaderView(type: .recent, onReportTapped: {})
        SetlistSectionHeaderView(type: .none, onReportTapped: {})
    }
    .padding(.vertical, 20)
    .background(Color.livithColor(.black100))
}
