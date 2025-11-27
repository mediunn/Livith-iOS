//
//  SortOptionButton.swift
//  Search
//
//  Created by Youjin Lee on 11/6/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct SortOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(width: 70)
                .padding(.vertical, 3)
                .notosans(.body4Semibold)
                .foregroundStyle(isSelected ?
                    Color.livithColor(.black100) :
                    Color.livithColor(.white100))
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(isSelected ?
                            Color.livithColor(.yellow30) :
                            .clear)
                }
        }
    }
}
