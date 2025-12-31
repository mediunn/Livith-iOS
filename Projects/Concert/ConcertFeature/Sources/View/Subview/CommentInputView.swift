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
        static let placeholder = "댓글은 400자까지 작성 가능해요"
    }

    // MARK: - Property

    @Binding var text: String
    let isSubmitting: Bool
    let onSubmit: () -> Void

    private var isOverLimit: Bool {
        text.count > Constants.maxLength
    }

    private var isSubmitEnabled: Bool {
        !text.isEmpty && !isOverLimit && !isSubmitting
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if isOverLimit {
                errorMessage
            }

            inputRow
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.livithColor(.black100))
    }
}

// MARK: - Subviews

private extension CommentInputView {
    var errorMessage: some View {
        Text("400자가 넘었어!")
            .notosans(.caption1Semibold)
            .foregroundStyle(Color.livithColor(.red))
            .padding(.leading, 4)
    }

    var inputRow: some View {
        HStack(spacing: 8) {
            textField
            submitButton
        }
    }

    var textField: some View {
        TextField(Constants.placeholder, text: $text, axis: .vertical)
            .notosans(.body3Medium)
            .foregroundStyle(Color.livithColor(.white100))
            .lineLimit(1...5)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.livithColor(.black90))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isOverLimit ? Color.livithColor(.red) : Color.clear, lineWidth: 1)
            }
    }

    var submitButton: some View {
        Button(action: onSubmit) {
            Text("등록")
                .notosans(.body2Semibold)
                .foregroundStyle(
                    isSubmitEnabled
                        ? Color.livithColor(.black100)
                        : Color.livithColor(.black60)
                )
                .padding(.horizontal, 20)
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

        CommentInputView(
            text: .constant(String(repeating: "가", count: 401)),
            isSubmitting: false,
            onSubmit: {}
        )
    }
    .background(Color.livithColor(.black100))
}
