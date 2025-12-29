//
//  ConcertIntroductionCard.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct ConcertIntroductionCard: View {

    // MARK: - Property

    private let introduction: String

    // MARK: - Initializer

    init(introduction: String) {
        self.introduction = introduction
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("한 줄 소개")
                .notosans(.caption1Semibold)
                .foregroundStyle(Color.livithColor(.black50))

            Text(introduction)
                .notosans(.body3Medium)
                .foregroundStyle(Color.livithColor(.white100))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.livithColor(.black90))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ConcertIntroductionCard(introduction: "호시노 겐의 n 년만의 내한!\nKoi 열풍으로 한국에서도 인기 아티스트")
        .padding(16)
        .background(Color.livithColor(.black100))
}
