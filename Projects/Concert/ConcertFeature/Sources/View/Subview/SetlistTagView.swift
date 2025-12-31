//
//  SetlistTagView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import ConcertDomain
import DSKit

struct SetlistTagView: View {

    // MARK: - Property

    let type: SetlistType

    private var backgroundColor: Color {
        switch type {
        case .expected, .recent:
            return Color.livithColor(.black90)
        case .none:
            return .clear
        }
    }

    private var textColor: Color {
        switch type {
        case .expected, .recent:
            return Color.livithColor(.white100)
        case .none:
            return .clear
        }
    }

    // MARK: - Body

    var body: some View {
        Text(type.displayText)
            .notosans(.caption1Bold)
            .foregroundStyle(textColor)
            .padding(.horizontal, 13)
            .padding(.vertical, 7)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    VStack(spacing: 10) {
        SetlistTagView(type: .expected)
        SetlistTagView(type: .recent)
    }
    .padding()
    .background(Color.livithColor(.black100))
}
