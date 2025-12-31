//
//  ConcertNavigationBar.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct ConcertNavigationBar: View {

    // MARK: - Property

    private let title: String
    private let onBack: () -> Void

    // MARK: - Initializer

    init(title: String, onBack: @escaping () -> Void) {
        self.title = title
        self.onBack = onBack
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 4) {
            Button {
                onBack()
            } label: {
                Image.livithIcon(.backLineDefault)
                    .resizable()
                    .frame(width: 38, height: 38)
            }

            Text(title)
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 66)
        .background(Color.livithColor(.black100))
    }
}

#Preview {
    ConcertNavigationBar(title: "Gen Hoshino presents MAD Asia in Seoul", onBack: {})
}
