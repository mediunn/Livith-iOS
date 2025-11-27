//
//  FilterButton.swift
//  Search
//
//  Created by Youjin Lee on 11/4/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DesignSystem

public enum FilterButtonStyle {
    case genre
    case status
}

public enum FilterButtonType: Equatable {
    case selected(text: String)
    case normal
}

public struct FilterButton: View {
    let style: FilterButtonStyle
    let type: FilterButtonType
    let action: () -> Void
    let onClear: (() -> Void)?
    
    public init(
        style: FilterButtonStyle,
        type: FilterButtonType,
        action: @escaping () -> Void,
        onClear: (() -> Void)? = nil
    ) {
        self.style = style
        self.type = type
        self.action = action
        self.onClear = onClear
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 0) {
                icon
                    .frame(width: 20, height: 20)
                
                title
                    .padding(.leading, 4)
                
                statusButton
                    .padding(.trailing, 8)
            }
            .padding(.leading, 6)
        }
        .frame(height: 30)
        .background(background)
    }
}

private extension FilterButton {
    @ViewBuilder
    var background: some View {
        switch type {
        case .normal:
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Color.livithColor(.black50),
                  lineWidth: 1)
        case .selected:
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.livithColor(.yellow30))
        }
    }
    
    var icon: some View {
        switch style {
        case .genre:
            Image.livithIcon(.genreLine)
                .renderingMode(.template)
                .tint((type == .normal) ?
                      Color.livithColor(.black30) :
                        Color.livithColor(.black100))
        case .status:
            
            Image.livithIcon(.calendarLine)
                .renderingMode(.template)
                .tint(type == .normal ?
                      Color.livithColor(.black30) :
                        Color.livithColor(.black100))
        }
    }

    
    var title: some View {
        Group {
            switch type {
            case .normal:
                Group {
                    switch style {
                    case .genre:
                        Text("전체장르")
                    case .status:
                        Text("전체기간")
                    }
                }
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black30))
            case .selected(let text):
                Text(text)
                    .notosans(.body4Semibold)
                    .foregroundStyle(Color.livithColor(.black100))
            }
        }
        
    }
    
    @ViewBuilder
    var statusButton: some View {
        switch type {
        case .normal:
            Image.livithIcon(.downLineSmall)
                .renderingMode(.template)
                .tint(Color.livithColor(.black30))
        case .selected:
            Button(action: {
                onClear?()
            }) {
                Image.livithIcon(.closeLineSmall)
                    .renderingMode(.template)
                    .tint(Color.livithColor(.black100))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    FilterButton(style: .status, type: .selected(text: "J-POP, ..."), action: {})
        .background(Color.livithColor(.black100))
    
    FilterButton(style: .status, type: .normal, action: {})
        .background(Color.livithColor(.black100))
}
