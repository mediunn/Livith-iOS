//
//  CommentCardView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Domain
import LivithDesignSystem

struct CommentCardView: View {

    // MARK: - Property

    let comment: ConcertComment
    let isMine: Bool
    let onDelete: () -> Void
    let onReport: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow

            Text(comment.content)
                .notosans(.body2Regular)
                .foregroundStyle(Color.livithColor(.white100))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.livithColor(.black90))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Subviews

private extension CommentCardView {
    var headerRow: some View {
        HStack(spacing: 10) {
            profileImage

            Text(comment.writer)
                .notosans(.body3Semibold)
                .foregroundStyle(Color.livithColor(.white100))

            Spacer()

            if isMine {
                deleteButton
            } else {
                reportButton
            }
        }
    }

    var profileImage: some View {
        Circle()
            .fill(Color.livithColor(.black50))
            .frame(width: 32, height: 32)
            .overlay {
                Image.livithIcon(.profile)
                    .resizable()
                    .frame(width: 32, height: 32)
            }
    }

    var deleteButton: some View {
        LivithReportButton("삭제", action: onDelete)
    }

    var reportButton: some View {
        LivithReportButton("신고", action: onReport)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        CommentCardView(
            comment: ConcertComment(
                id: 1,
                userID: 1,
                writer: "라이빗",
                content: "님들아 제발 이땐 [아아아~~~] 떼창 해줘라 ㅠㅠ 왜 맨날 안하고 넘어가는건지 모르겠음 ㅠㅠ 일본에서는 이 파트 꼭 다들 열심히 죽어라 하는데 왜 안하는거야!!!",
                createdAt: Date()
            ),
            isMine: true,
            onDelete: {},
            onReport: {}
        )

        CommentCardView(
            comment: ConcertComment(
                id: 2,
                userID: 2,
                writer: "라이빗",
                content: "하 언제와 진심 개큰기대중임 제발",
                createdAt: Date()
            ),
            isMine: false,
            onDelete: {},
            onReport: {}
        )
    }
    .padding()
    .background(Color.livithColor(.black100))
}
