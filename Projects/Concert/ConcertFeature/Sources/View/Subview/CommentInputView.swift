//
//  CommentInputView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct CommentInputView: View {

    // MARK: - Constants

    private enum Constants {
        static let maxLength = 400
        static let maxLines = 15
        static let placeholder = "댓글은 400자까지 작성 가능해요"
    }

    // MARK: - Property

    @Binding var text: String
    let isSubmitting: Bool
    let onSubmit: () -> Void

    private var isSubmitEnabled: Bool {
        !text.isEmpty && !isSubmitting
    }

    // MARK: - Body

    var body: some View {
        inputRow
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.livithColor(.black100))
    }
}

// MARK: - Subviews

private extension CommentInputView {
    var inputRow: some View {
        HStack(spacing: 8) {
            textField
            submitButton
        }
    }

    var textField: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(Constants.placeholder)
                .foregroundStyle(Color.livithColor(.black50)),
            axis: .vertical
        )
        .notosans(.body3Medium)
        .foregroundStyle(Color.livithColor(.white100))
        .lineLimit(1...4)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.livithColor(.black90))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onChange(of: text) { oldValue, newValue in
            let lineCount = newValue.components(separatedBy: "\n").count
            if lineCount > Constants.maxLines {
                text = oldValue
            } else if newValue.count > Constants.maxLength {
                text = String(newValue.prefix(Constants.maxLength))
            }
        }
    }

    var submitButton: some View {
        Button(action: onSubmit) {
            Text("등록")
                .notosans(.body3Medium)
                .foregroundStyle(
                    isSubmitEnabled
                        ? Color.livithColor(.black100)
                        : Color.livithColor(.black50)
                )
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    isSubmitEnabled
                        ? Color.livithColor(.yellow30)
                        : Color.livithColor(.black80)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(!isSubmitEnabled)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()

        CommentInputView(
            text: .constant(""),
            isSubmitting: false,
            onSubmit: {}
        )

        CommentInputView(
            text: .constant("테스트 댓글입니다"),
            isSubmitting: false,
            onSubmit: {}
        )
    }
    .background(Color.livithColor(.black100))
}
