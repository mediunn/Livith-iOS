//
//  ToggleWarningPopup.swift
//  SongFeature
//
//  Created by Youjin Lee on 1/2/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct ToggleWarningPopup: View {

    // MARK: - Property

    private let message: String

    // MARK: - Initializer

    init(message: String) {
        self.message = message
    }

    // MARK: - Body

    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .notosans(.body2Medium)
                .foregroundStyle(Color.livithColor(.white100))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 90)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.livithColor(.black90).opacity(0.9))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 6))
                )
                .shadow(color: .livithColor(.yellow30).opacity(0.2), radius: 5)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
    }
}

#Preview {
    ToggleWarningPopup(message: "최소 1개의 가사 옵션은\n선택되어 있어야 해요")
        .background(Color.livithColor(.black100))
}
