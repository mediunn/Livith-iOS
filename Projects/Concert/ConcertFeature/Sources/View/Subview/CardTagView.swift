//
//  CardTagView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct CardTagView: View {

    // MARK: - Property

    private let text: String
    private let fontStyle: Font.Notosans

    // MARK: - Initializer

    init(_ text: String, fontStyle: Font.Notosans = .caption1Semibold) {
        self.text = text
        self.fontStyle = fontStyle
    }

    // MARK: - Body

    var body: some View {
        Text(text)
            .notosans(fontStyle)
            .foregroundStyle(Color.livithColor(.black50))
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(Color.livithColor(.black100))
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    VStack(spacing: 10) {
        CardTagView("일본 내한 가수")
        CardTagView("팬문화 1", fontStyle: .caption1Bold)
    }
    .padding()
    .background(Color.livithColor(.black90))
}
