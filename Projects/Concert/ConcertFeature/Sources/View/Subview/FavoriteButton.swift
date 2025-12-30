//
//  FavoriteButton.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct FavoriteButton: View {

    // MARK: - Property

    private let action: () -> Void

    // MARK: - Initializer

    init(action: @escaping () -> Void) {
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 2) {
                Image.livithIcon(.plusLineSmall)
                    .resizable()
                    .frame(width: 20, height: 20)

                Text("관심 콘서트 설정하기")
                    .notosans(.caption1Semibold)
                    .foregroundStyle(Color.livithColor(.white100))
            }
            .padding(10)
            .background(Color.livithColor(.black100))
            .cornerRadius(8)
            .shadow(
                color: .livithColor(.white100).opacity(0.3),
                radius: 6
            )
        }
    }
}

#Preview {
    FavoriteButton(action: {})
        .background(Color.livithColor(.black80))
}
