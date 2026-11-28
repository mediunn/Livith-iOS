//
//  LivithTextField.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - LivithTextFieldType

public enum LivithTextFieldType {
    case search
    case text(maxLength: Int)
    case comment(maxLength: Int)

    var cornerRadius: CGFloat {
        switch self {
        case .search: return 10
        case .text: return 12
        case .comment: return 8
        }
    }

    var showsBorder: Bool {
        switch self {
        case .search, .text: return true
        case .comment: return false
        }
    }

    var isMultiline: Bool {
        switch self {
        case .comment: return true
        case .search, .text: return false
        }
    }

    var showsCharacterCount: Bool {
        switch self {
        case .text: return true
        case .search, .comment: return false
        }
    }

    var maxLength: Int? {
        switch self {
        case .search: return nil
        case .text(let max), .comment(let max): return max
        }
    }
}

// MARK: - LivithTextField

public struct LivithTextField: View {

    // MARK: - Property

    @Binding private var text: String
    @Binding private var externalFocused: Bool
    @FocusState private var fieldFocused: Bool

    private let type: LivithTextFieldType
    private let placeholder: String
    private let onSubmit: (() -> Void)?
    private let onChange: (() -> Void)?
    private let onClear: (() -> Void)?

    private var showClearButton: Bool {
        fieldFocused && !text.isEmpty
    }

    // MARK: - Initializer

    public init(
        text: Binding<String>,
        isFocused: Binding<Bool> = .constant(false),
        type: LivithTextFieldType,
        placeholder: String,
        onSubmit: (() -> Void)? = nil,
        onChange: (() -> Void)? = nil,
        onClear: (() -> Void)? = nil
    ) {
        self._text = text
        self._externalFocused = isFocused
        self.type = type
        self.placeholder = placeholder
        self.onSubmit = onSubmit
        self.onChange = onChange
        self.onClear = onClear
    }

    // MARK: - Body

    public var body: some View {
        Group {
            switch type {
            case .search:
                searchTypeContent
            case .text:
                textTypeContent
            case .comment:
                commentTypeContent
            }
        }
        .background(Color.livithColor(.black90))
        .clipShape(RoundedRectangle(cornerRadius: type.cornerRadius))
        .overlay {
            if type.showsBorder && fieldFocused {
                RoundedRectangle(cornerRadius: type.cornerRadius)
                    .stroke(Color.livithColor(.black50), lineWidth: 1)
            }
        }
        .onChange(of: fieldFocused) { _, newValue in
            externalFocused = newValue
        }
        .onChange(of: externalFocused) { _, newValue in
            fieldFocused = newValue
        }
    }
}

// MARK: - Search Type

private extension LivithTextField {
    var searchTypeContent: some View {
        HStack(spacing: 10) {
            searchTextField
            searchActionButton
        }
        .padding(.horizontal, 12)
        .frame(height: 52)
        .contentShape(Rectangle())
        .onTapGesture {
            fieldFocused = true
        }
    }

    var searchTextField: some View {
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
    var searchActionButton: some View {
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

// MARK: - Text Type

private extension LivithTextField {
    var textTypeContent: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty && !fieldFocused {
                Text(placeholder)
                    .notosans(.body3Medium)
                    .foregroundStyle(Color.livithColor(.black50))
            }

            HStack {
                TextField("", text: $text)
                    .notosans(.body3Medium)
                    .foregroundStyle(Color.livithColor(.white100))
                    .autocorrectionDisabled()
                    .focused($fieldFocused)
                    .onChange(of: text) { oldValue, newValue in
                        if let maxLength = type.maxLength, newValue.count > maxLength {
                            text = oldValue
                        }
                        onChange?()
                    }
                    .onSubmit {
                        fieldFocused = false
                        onSubmit?()
                    }

                if !text.isEmpty {
                    Spacer()

                    if let maxLength = type.maxLength {
                        Text("\(text.count)/\(maxLength)")
                            .notosans(.caption1Regular)
                            .foregroundStyle(Color.livithColor(.black50))
                    }

                    if fieldFocused {
                        Button {
                            text = ""
                            onClear?()
                        } label: {
                            Image.livithIcon(.deleteFillDefault)
                                .frame(width: 24, height: 24)
                        }
                    }
                }
            }
        }
        .padding(16)
        .contentShape(Rectangle())
        .onTapGesture {
            fieldFocused = true
        }
    }
}

// MARK: - Comment Type

private extension LivithTextField {
    var commentTypeContent: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder)
                .foregroundStyle(Color.livithColor(.black50)),
            axis: .vertical
        )
        .notosans(.body3Medium)
        .foregroundStyle(Color.livithColor(.white100))
        .lineLimit(1...4)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(minHeight: 41)
        .focused($fieldFocused)
        .onChange(of: text) { oldValue, newValue in
            if let maxLength = type.maxLength, newValue.count > maxLength {
                text = String(newValue.prefix(maxLength))
            }
            onChange?()
        }
        .onSubmit {
            onSubmit?()
        }
    }
}

// MARK: - Preview

#Preview("Search Type") {
    VStack(spacing: 20) {
        LivithTextField(
            text: .constant(""),
            type: .search,
            placeholder: "찾고 있는 콘서트나 가수를 검색하세요"
        )

        LivithTextField(
            text: .constant("아이유"),
            type: .search,
            placeholder: "찾고 있는 콘서트나 가수를 검색하세요"
        )
    }
    .padding(.horizontal, 16)
    .background(Color.livithColor(.black100))
}

#Preview("Text Type") {
    VStack(spacing: 20) {
        LivithTextField(
            text: .constant(""),
            type: .text(maxLength: 10),
            placeholder: "예시) 홍길동"
        )

        LivithTextField(
            text: .constant("리이빗"),
            type: .text(maxLength: 10),
            placeholder: "예시) 홍길동"
        )
    }
    .padding(.horizontal, 16)
    .background(Color.livithColor(.black100))
}

#Preview("Comment Type") {
    VStack(spacing: 20) {
        LivithTextField(
            text: .constant(""),
            type: .comment(maxLength: 400),
            placeholder: "댓글은 400자까지 작성 가능해요"
        )

        LivithTextField(
            text: .constant("테스트 댓글입니다"),
            type: .comment(maxLength: 400),
            placeholder: "댓글은 400자까지 작성 가능해요"
        )
    }
    .padding(.horizontal, 16)
    .background(Color.livithColor(.black100))
}
