//
//  UnlimitedTextField.swift
//  ShareFeature
//
//  Created by JinUng41 on 7/9/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct UnlimitedTextField: View {

    // MARK: - Properties

    @Binding private var text: String
    @Binding private var isFocused: Bool
    @FocusState private var fieldFocused: Bool

    private let placeholder: String
    private let isMultiline: Bool
    private let minHeight: CGFloat
    private let submitLabel: SubmitLabel
    private let onSubmit: (() -> Void)?

    // MARK: - Initializer

    init(
        text: Binding<String>,
        isFocused: Binding<Bool> = .constant(false),
        placeholder: String,
        isMultiline: Bool = false,
        minHeight: CGFloat = 52,
        submitLabel: SubmitLabel = .done,
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self._isFocused = isFocused
        self.placeholder = placeholder
        self.isMultiline = isMultiline
        self.minHeight = minHeight
        self.submitLabel = submitLabel
        self.onSubmit = onSubmit
    }

    // MARK: - Body

    var body: some View {
        Group {
            if isMultiline {
                multilineContent
            } else {
                singleLineContent
            }
        }
        .background(Color.livithColor(.black90))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            if fieldFocused {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.livithColor(.black50), lineWidth: 1)
            }
        }
        .onChange(of: fieldFocused) { _, newValue in
            isFocused = newValue
        }
        .onChange(of: isFocused) { _, newValue in
            fieldFocused = newValue
        }
    }
}

// MARK: - UIComponents

private extension UnlimitedTextField {
    var singleLineContent: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty && !fieldFocused {
                Text(placeholder)
                    .notosans(.body3Medium)
                    .foregroundStyle(Color.livithColor(.black50))
            }

            TextField("", text: $text)
                .notosans(.body3Medium)
                .foregroundStyle(Color.livithColor(.white100))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(submitLabel)
                .focused($fieldFocused)
                .onSubmit {
                    onSubmit?()
                }
        }
        .padding(.horizontal, 12)
        .frame(height: minHeight)
        .contentShape(Rectangle())
        .onTapGesture {
            fieldFocused = true
        }
    }

    var multilineContent: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty && !fieldFocused {
                Text(placeholder)
                    .notosans(.body3Medium)
                    .foregroundStyle(Color.livithColor(.black50))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 16)
            }

            TextField("", text: $text, axis: .vertical)
                .notosans(.body3Medium)
                .foregroundStyle(Color.livithColor(.white100))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($fieldFocused)
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
        }
        .frame(minHeight: minHeight, alignment: .topLeading)
        .contentShape(Rectangle())
        .onTapGesture {
            fieldFocused = true
        }
    }
}
