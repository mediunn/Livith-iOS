//
//  LivithListItem.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - Type

public enum LivithListItemType {
    /// 오른쪽 화살표 표시 (네비게이션)
    case navigation
    /// 오른쪽에 값 표시
    case value(String)
    /// 트레일링 없음 (액션만)
    case action
}

// MARK: - LivithListItem

public struct LivithListItem: View {

    // MARK: - Property

    private let title: String
    private let type: LivithListItemType
    private let action: (() -> Void)?

    // MARK: - Lifecycle

    public init(
        _ title: String,
        type: LivithListItemType = .navigation,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.type = type
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        if let action = action {
            Button {
                action()
            } label: {
                contentView
            }
            .buttonStyle(.plain)
        } else {
            contentView
        }
    }

    private var contentView: some View {
        HStack {
            Text(title)
                .notosans(.body2Medium)
                .foregroundStyle(Color.livithColor(.black30))

            Spacer()

            trailingView
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }
}

// MARK: - Subviews

private extension LivithListItem {
    @ViewBuilder
    var trailingView: some View {
        switch type {
        case .navigation:
            Image.livithIcon(.rightLineDefault)
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.livithColor(.black50))
        case .value(let value):
            Text(value)
                .notosans(.body2Regular)
                .foregroundStyle(Color.livithColor(.black30))
        case .action:
            EmptyView()
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        LivithListItem("닉네임 수정", type: .navigation) {}
        LivithListItem("버전 정보", type: .value("1.0.0"))
        LivithListItem("로그아웃", type: .action) {}
    }
    .background(Color.livithColor(.black90))
}
