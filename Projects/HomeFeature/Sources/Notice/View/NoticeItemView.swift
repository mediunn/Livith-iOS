//
//  NoticeItemView.swift
//  HomeFeature
//
//  Created by Youjin Lee on 1/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

// MARK: - NoticeItemState

public enum NoticeItemState {
    case normal
    case read
}

// MARK: - NoticeItemView

public struct NoticeItemView: View {

    // MARK: - Property

    private let title: String
    private let description: String
    private let timeAgo: String
    private let state: NoticeItemState
    private let action: () -> Void

    // MARK: - Initializer

    public init(
        title: String,
        description: String,
        timeAgo: String,
        state: NoticeItemState = .normal,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.timeAgo = timeAgo
        self.state = state
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .notosans(.body4Semibold)
                        .foregroundStyle(titleColor)

                    Text(description)
                        .notosans(.caption1Regular)
                        .foregroundStyle(descriptionColor)
                        .multilineTextAlignment(.leading)
                }

                Text(timeAgo)
                    .notosans(.caption2Semibold)
                    .foregroundStyle(Color.livithColor(.black50))
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
        .buttonStyle(NoticeItemButtonStyle(state: state))
    }
}

// MARK: - Computed Properties

private extension NoticeItemView {
    var titleColor: Color {
        switch state {
        case .normal:
            return Color.livithColor(.white100)
        case .read:
            return Color.livithColor(.black50)
        }
    }

    var descriptionColor: Color {
        switch state {
        case .normal:
            return Color.livithColor(.black30)
        case .read:
            return Color.livithColor(.black50)
        }
    }
}

// MARK: - NoticeItemButtonStyle

private struct NoticeItemButtonStyle: ButtonStyle {
    let state: NoticeItemState

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(backgroundColor(isPressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        if isPressed {
            return Color.livithColor(.black90)
        }

        return Color.livithColor(.black100)
    }
}

// MARK: - Preview

#Preview("Normal") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        VStack(spacing: 12) {
            NoticeItemView(
                title: "(광고) 추천 콘서트를 가져왔어요 🎵",
                description: "선택하신 취향을 바탕으로\n지금 가장 잘 맞는 콘서트 하나를 골라봤어요!",
                timeAgo: "5시간 전",
                state: .normal,
                action: {}
            )

            NoticeItemView(
                title: "(광고) 추천 콘서트를 가져왔어요 🎵",
                description: "선택하신 취향을 바탕으로\n지금 가장 잘 맞는 콘서트 하나를 골라봤어요!",
                timeAgo: "5시간 전",
                state: .read,
                action: {}
            )
        }
        .padding()
    }
}
