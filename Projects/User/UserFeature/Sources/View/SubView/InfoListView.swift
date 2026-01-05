//
//  InfoListView.swift
//  User
//
//  Created by Youjin Lee on 12/9/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

public struct InfoListView: View {
    
    // MARK: - Enum
    
    public enum SettingRowType {
        case navigation
        case value(String)
        case action
    }
    
    let title: String
    let type: SettingRowType
    var action: (() -> Void)? = nil
    
    public var body: some View {
        Button {
            action?()
        } label: {
            HStack {
                Text(title)
                    .notosans(.body2Medium)
                    .foregroundStyle(Color.livithColor(.black30))

                Spacer()

                switch type {
                case .navigation:
                    Image.livithIcon(.rightLineDefault)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.livithColor(.black50))
                case .value(let value):
                    Text(value)
                        .notosans(.body2Regular)
                        .foregroundStyle(Color.livithColor(.black30))
                case .action:
                    EmptyView()
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
