//
//  FilterOptionButton.swift
//  Search
//
//  Created by Youjin Lee on 11/5/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DesignSystem

public struct FilterOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .notosans(.body4Medium)
                .foregroundStyle(textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(background)
        }
        .buttonStyle(.plain)
        .transaction { $0.animation = nil }
    }
    
    private var textColor: Color {
        isSelected ? Color.livithColor(.black100) : Color.livithColor(.black30)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(isSelected ? Color.livithColor(.yellow30) : Color.clear)
            .strokeBorder(isSelected ? Color.clear : Color.livithColor(.black50), lineWidth: 1)
    }
}
