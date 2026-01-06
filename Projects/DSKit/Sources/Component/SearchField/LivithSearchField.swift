//
//  LivithSearchField.swift
//  DSKit
//
//  Created by Youjin Lee on 1/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - Focus State

private enum LivithSearchFieldState {
    case idle
    case focused

    var showBorder: Bool {
        self == .focused
    }

    var showPlaceholder: Bool {
        self == .idle
    }
}

// MARK: - LivithSearchField

public struct LivithSearchField: View {

    // MARK: - Property

    @Binding private var text: String
    @Binding private var isFocused: Bool
    @FocusState private var fieldFocused: Bool

    private let placeholder: String
    private let cornerRadius: CGFloat
    private let onChange: (() -> Void)?
    private let onClear: (() -> Void)?
    private let onSubmit: (() -> Void)?

    private var state: LivithSearchFieldState {
        fieldFocused ? .focused : .idle
    }

    private var showClearButton: Bool {
        fieldFocused && !text.isEmpty
    }

    // MARK: - Initializer

    public init(
        text: Binding<String>,
        isFocused: Binding<Bool> = .constant(false),
        placeholder: String = "찾고 있는 콘서트나 가수를 검색하세요",
        cornerRadius: CGFloat = 10,
        onChange: (() -> Void)? = nil,
        onClear: (() -> Void)? = nil,
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self._isFocused = isFocused
        self.placeholder = placeholder
        self.cornerRadius = cornerRadius
        self.onChange = onChange
        self.onClear = onClear
        self.onSubmit = onSubmit
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: 10) {
            textField
            actionButton
        }
        .padding(.horizontal, 12)
        .frame(height: 52)
        .background(Color.livithColor(.black90))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay {
            if state.showBorder {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.livithColor(.black50), lineWidth: 1)
            }
        }
        .onTapGesture {
            fieldFocused = true
        }
        .onChange(of: fieldFocused) { _, newValue in
            isFocused = newValue
        }
        .onChange(of: isFocused) { _, newValue in
            fieldFocused = newValue
        }
    }
}

// MARK: - Subviews

private extension LivithSearchField {
    var textField: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty && state.showPlaceholder {
                Text(placeholder)
                    .notosans(.body3Medium)
                    .foregroundStyle(Color.livithColor(.black50))
            }

            TextField("", text: $text)
                .notosans(.body3Medium)
                .foregroundStyle(Color.livithColor(.white100))
                .autocorrectionDisabled()
                .focused($fieldFocused)
                .onChange(of: text) { _, _ in
                    onChange?()
                }
                .onSubmit {
                    fieldFocused = false
                    onSubmit?()
                }
        }
    }

    @ViewBuilder
    var actionButton: some View {
        if showClearButton {
            Button {
                text = ""
                onClear?()
            } label: {
                Image.livithIcon(.deleteFillDefault)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            }
        } else {
            Button {
                fieldFocused = false
                onSubmit?()
            } label: {
                Image.livithIcon(.searchLineDefault)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
            }
        }
    }
}

// MARK: - Preview

#Preview("Default") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        LivithSearchField(text: .constant(""))
            .padding(.horizontal, 16)
    }
}

#Preview("With Custom Corner Radius") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        LivithSearchField(
            text: .constant(""),
            cornerRadius: 12
        )
        .padding(.horizontal, 16)
    }
}

#Preview("With Text") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        LivithSearchField(text: .constant("아이유"))
            .padding(.horizontal, 16)
    }
}
