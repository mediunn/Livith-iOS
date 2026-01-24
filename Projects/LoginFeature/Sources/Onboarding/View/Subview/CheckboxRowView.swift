//
//  CheckboxRowView.swift
//  LoginFeature
//
//  Created by 김진웅 on 1/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

struct CheckboxRow: View {
    let title: String
    let isRequired: Bool
    let isChecked: Bool
    let action: () -> Void
    let trailingView: AnyView
    
    init(
        _ title: String,
        isRequired: Bool = false,
        isChecked: Bool,
        action: @escaping () -> Void,
        trailingView: AnyView = AnyView(EmptyView())
    ) {
        self.title = title
        self.isRequired = isRequired
        self.isChecked = isChecked
        self.action = action
        self.trailingView = trailingView
    }
    
    var body: some View {
        HStack {
            Button {
                action()
            } label: {
                HStack(spacing: 4) {
                    Image.livithIcon(isChecked ? .checkboxLineEnabled : .checkboxLineDefault)
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text(title)
                        .notosans(.body2Medium)
                        .foregroundStyle(Color.livithColor(.white100))
                    
                    if isRequired {
                        Text(Literals.requiredText)
                            .notosans(.caption1Regular)
                            .foregroundStyle(Color.livithColor(.black50))
                    }
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            trailingView
        }
    }
}

// MARK: - Literals

private extension CheckboxRow {
    enum Literals {
        static let requiredText = "필수"
    }
}
