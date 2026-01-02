//
//  PopularBadge.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct PopularBadge: View {

    // MARK: - Property

    private let text: String

    // MARK: - Initializer

    init(text: String) {
        self.text = text
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            Image.livithIcon(.badge)
                .resizable()
                .frame(width: 24, height: 24)

            Text(text)
                .notosans(.caption2Semibold)
                .foregroundStyle(Color.livithColor(.black100))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(Color.livithColor(.translation))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    PopularBadge(text: "많이 찾는 콘서트 1위")
        .background(Color.livithColor(.black100))
}
