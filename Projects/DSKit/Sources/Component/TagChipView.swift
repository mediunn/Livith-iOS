//
//  TagChipView.swift
//  DSKit
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

public struct TagChipView: View {

    // MARK: - Property

    private let text: String
    private let backgroundColor: Color
    private let textColor: Color

    // MARK: - Initializer

    public init(
        text: String,
        backgroundColor: Color = Color.livithColor(.black80),
        textColor: Color = Color.livithColor(.black30)
    ) {
        self.text = text
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }

    // MARK: - Body

    public var body: some View {
        Text(text)
            .notosans(.caption1Bold)
            .foregroundStyle(textColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    FlowLayout(spacing: 4) {
        TagChipView(text: "다채로운 사운드")
        TagChipView(text: "팝")
        TagChipView(text: "재즈")
        TagChipView(text: "펑크")
        TagChipView(text: "시티팝")
    }
    .padding()
    .background(Color.livithColor(.black100))
}
