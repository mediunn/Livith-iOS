//
//  CommentInputView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI
import UIKit

import LivithDesignSystem

struct CommentInputView: View {

    // MARK: - Constants

    private enum Constants {
        static let maxLength = 400
        static let maxLines = 15
        static let placeholder = "댓글은 400자까지 작성 가능해요"
        static let textFieldHorizontalPadding: CGFloat = 32
        static let buttonWidth: CGFloat = 60
        static let spacing: CGFloat = 8
        static let containerHorizontalPadding: CGFloat = 32
    }

    // MARK: - Property

    @Binding var text: String
    @Binding var isExceedingLineLimit: Bool
    @Binding var isExceedingCharacterLimit: Bool
    let isSubmitting: Bool
    let onSubmit: () -> Void

    private var isSubmitEnabled: Bool {
        !text.isEmpty && !isSubmitting && !isExceedingLineLimit && !isExceedingCharacterLimit
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
        HStack(alignment: .bottom, spacing: 8) {
            textField
            submitButton
        }
    }

    var textField: some View {
        LivithTextField(
            text: $text,
            type: .comment(maxLength: Constants.maxLength),
            placeholder: Constants.placeholder
        )
        .onChange(of: text) { _, newValue in
            let screenWidth = UIScreen.main.bounds.width
            let textFieldWidth = screenWidth - Constants.containerHorizontalPadding - Constants.buttonWidth - Constants.spacing
            let textWidth = textFieldWidth - Constants.textFieldHorizontalPadding
            let lineCount = calculateActualLineCount(text: newValue, containerWidth: textWidth)
            isExceedingLineLimit = lineCount > Constants.maxLines
            isExceedingCharacterLimit = newValue.count > Constants.maxLength
        }
    }

    var submitButton: some View {
        LivithConfirmButton("등록", variant: .primary, action: onSubmit)
            .disabled(!isSubmitEnabled)
    }

    func calculateActualLineCount(text: String, containerWidth: CGFloat) -> Int {
        guard containerWidth > 0 else { return 1 }

        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        let lines = text.components(separatedBy: "\n")

        return lines.reduce(0) { count, line in
            if line.isEmpty {
                return count + 1
            }

            let attributedString = NSAttributedString(
                string: line,
                attributes: [.font: font]
            )
            let boundingRect = attributedString.boundingRect(
                with: CGSize(width: containerWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            )
            let lineHeight = font.lineHeight
            let wrappedLines = max(1, Int(ceil(boundingRect.height / lineHeight)))
            return count + wrappedLines
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()

        CommentInputView(
            text: .constant(""),
            isExceedingLineLimit: .constant(false),
            isExceedingCharacterLimit: .constant(false),
            isSubmitting: false,
            onSubmit: {}
        )

        CommentInputView(
            text: .constant("테스트 댓글입니다"),
            isExceedingLineLimit: .constant(false),
            isExceedingCharacterLimit: .constant(false),
            isSubmitting: false,
            onSubmit: {}
        )
    }
    .background(Color.livithColor(.black100))
}
