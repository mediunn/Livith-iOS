//
//  LivithTextView.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - LivithTextViewType

public enum LivithTextViewType {
    case basic(maxLength: Int)
    case report(maxLength: Int)

    var backgroundColor: Color {
        switch self {
        case .basic: return Color.livithColor(.black80)
        case .report: return Color.livithColor(.black5)
        }
    }

    var textColor: Color {
        switch self {
        case .basic: return Color.livithColor(.white100)
        case .report: return Color.livithColor(.black100)
        }
    }

    var borderColor: Color {
        switch self {
        case .basic: return Color.livithColor(.black50)
        case .report: return Color.livithColor(.black30)
        }
    }

    var maxLength: Int {
        switch self {
        case .basic(let max), .report(let max): return max
        }
    }
}

// MARK: - LivithTextView

public struct LivithTextView: View {

    // MARK: - Property

    @Binding private var text: String
    @Binding private var externalFocused: Bool
    @FocusState private var fieldFocused: Bool

    private let type: LivithTextViewType
    private let placeholder: String
    private let height: CGFloat

    private var isOverLimit: Bool {
        text.count > type.maxLength
    }

    private var characterCountColor: Color {
        isOverLimit ? Color.livithColor(.caution100) : Color.livithColor(.black50)
    }

    // MARK: - Initializer

    public init(
        text: Binding<String>,
        isFocused: Binding<Bool> = .constant(false),
        type: LivithTextViewType,
        placeholder: String,
        height: CGFloat = 172
    ) {
        self._text = text
        self._externalFocused = isFocused
        self.type = type
        self.placeholder = placeholder
        self.height = height
    }

    // MARK: - Body

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            textEditorContent

            characterCountLabel
        }
        .onChange(of: fieldFocused) { _, newValue in
            externalFocused = newValue
        }
        .onChange(of: externalFocused) { _, newValue in
            fieldFocused = newValue
        }
    }
}

// MARK: - Subviews

private extension LivithTextView {
    var textEditorContent: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .notosans(.body3Medium)
                    .foregroundStyle(Color.livithColor(.black50))
                    .padding(.top, 8)
                    .padding(.leading, 4)
            }

            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .foregroundStyle(type.textColor)
                .notosans(.body3Medium)
                .focused($fieldFocused)
        }
        .padding(12)
        .frame(height: height)
        .background(type.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(fieldFocused ? type.borderColor : Color.clear, lineWidth: 1)
        )
    }

    var characterCountLabel: some View {
        Text("\(text.count)/\(type.maxLength)")
            .notosans(.body4Medium)
            .foregroundStyle(characterCountColor)
            .padding(.trailing, 12)
            .padding(.bottom, 12)
    }
}

// MARK: - Preview

#Preview("Basic Type") {
    VStack(spacing: 20) {
        LivithTextView(
            text: .constant(""),
            type: .basic(maxLength: 200),
            placeholder: "내용을 입력해주세요",
            height: 206
        )

        LivithTextView(
            text: .constant("입력중"),
            type: .basic(maxLength: 200),
            placeholder: "내용을 입력해주세요",
            height: 206
        )
    }
    .padding(.horizontal, 16)
    .background(Color.livithColor(.black90))
}

#Preview("Report Type") {
    VStack(spacing: 20) {
        LivithTextView(
            text: .constant(""),
            type: .report(maxLength: 200),
            placeholder: "신고 사유를 작성해주세요",
            height: 172
        )

        LivithTextView(
            text: .constant("신고 사유입니다"),
            type: .report(maxLength: 200),
            placeholder: "신고 사유를 작성해주세요",
            height: 172
        )
    }
    .padding(.horizontal, 16)
    .background(Color.livithColor(.white100))
}
