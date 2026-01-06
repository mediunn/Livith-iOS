//
//  SearchBarView.swift
//  DesignSystem
//
//  Created by Youjin Lee on 11/2/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

public struct SearchBarView: View {

    // MARK: Property

    @Binding var input: String

    private let onBack: () -> Void
    private let onChange: () -> Void
    private let onClear: () -> Void
    private let onSubmit: () -> Void

    // MARK: - Initializer

    public init(
        input: Binding<String>,
        onBack: @escaping () -> Void,
        onChange: @escaping () -> Void,
        onClear: @escaping () -> Void,
        onSubmit: @escaping () -> Void
    ) {
        self._input = input
        self.onBack = onBack
        self.onChange = onChange
        self.onClear = onClear
        self.onSubmit = onSubmit
    }

    // MARK: - Body

    public var body: some View {
        HStack(alignment: .center) {
            backButton

            LivithSearchField(
                text: $input,
                onChange: onChange,
                onClear: onClear,
                onSubmit: onSubmit
            )
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// MARK: - Subviews

private extension SearchBarView {
    var backButton: some View {
        Button(action: onBack) {
            Image.livithIcon(.backLineDefault)
                .resizable()
                .scaledToFit()
                .frame(width: 38, height: 38)
        }
    }
}
