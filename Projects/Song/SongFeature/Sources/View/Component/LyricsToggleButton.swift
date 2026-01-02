//
//  LyricsToggleButton.swift
//  SongFeature
//
//  Created by Youjin Lee on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct LyricsToggleButton: View {

    // MARK: - Property

    let title: String
    let isOn: Bool
    var activeBackgroundColor: Color = Color.livithColor(.white100)
    var activeTextColor: Color = Color.livithColor(.black100)
    let action: () -> Void

    private var backgroundColor: Color {
        isOn ? activeBackgroundColor : Color.livithColor(.black80)
    }

    private var textColor: Color {
        isOn ? activeTextColor : Color.livithColor(.black50)
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            Text("\(title) \(isOn ? "ON" : "OFF")")
                .notosans(.body4Semibold)
                .foregroundStyle(textColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    HStack {
        LyricsToggleButton(title: "원어", isOn: true) {}
        LyricsToggleButton(title: "발음", isOn: false) {}
        LyricsToggleButton(
            title: "해석",
            isOn: true,
            activeBackgroundColor: Color.livithColor(.yellow60),
            activeTextColor: Color.livithColor(.black100)
        ) {}
    }
    .padding()
    .background(Color.livithColor(.black100))
}
