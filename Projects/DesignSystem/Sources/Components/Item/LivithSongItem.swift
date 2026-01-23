//
//  LivithSongItem.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

public struct LivithSongItem: View {

    // MARK: - Property

    private let orderIndex: Int
    private let title: String
    private let artist: String
    private let onTapped: () -> Void

    // MARK: - Initializer

    public init(
        orderIndex: Int,
        title: String,
        artist: String,
        onTapped: @escaping () -> Void
    ) {
        self.orderIndex = orderIndex
        self.title = title
        self.artist = artist
        self.onTapped = onTapped
    }

    // MARK: - Body

    public var body: some View {
        Button(action: onTapped) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "%02d. %@", orderIndex, title))
                        .notosans(.body2Medium)
                        .foregroundStyle(Color.livithColor(.white100))
                        .lineLimit(1)

                    Text(artist)
                        .notosans(.caption1Regular)
                        .foregroundStyle(Color.livithColor(.black50))
                        .lineLimit(1)
                }

                Spacer()

                Image.livithIcon(.playFillDefault)
                    .resizable()
                    .frame(width: 32, height: 32)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 11)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 10) {
        LivithSongItem(orderIndex: 1, title: "恋 (Koi)", artist: "Hosino Gen") {}
        LivithSongItem(orderIndex: 2, title: "SUN", artist: "Hosino Gen") {}
        LivithSongItem(orderIndex: 3, title: "喜劇 (Comedy)", artist: "Hosino Gen") {}
    }
    .padding(.vertical, 16)
    .background(Color.livithColor(.black90))
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .padding()
    .background(Color.livithColor(.black100))
}
