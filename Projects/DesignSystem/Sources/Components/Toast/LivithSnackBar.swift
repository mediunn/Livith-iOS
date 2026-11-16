//
//  LivithSnackBar.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

public struct LivithSnackBar: View {

    // MARK: - Property

    private let message: String
    private let actionTitle: String
    private let dismissEdge: VerticalEdge
    private let onActionTapped: () -> Void
    private let onDismiss: () -> Void

    @State private var offset: CGFloat = 0
    @State private var isDragging: Bool = false
    @State private var timerResetCount: Int = 0

    private let autoDismissDelay: TimeInterval = 5.0
    private let dismissThreshold: CGFloat = 50

    // MARK: - Initializer

    public init(
        message: String,
        actionTitle: String,
        dismissEdge: VerticalEdge = .bottom,
        onActionTapped: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.message = message
        self.actionTitle = actionTitle
        self.dismissEdge = dismissEdge
        self.onActionTapped = onActionTapped
        self.onDismiss = onDismiss
    }

    // MARK: - Body

    public var body: some View {
        bannerContent
            .offset(y: offset)
            .gesture(dragGesture)
            .task(id: timerResetCount) {
                try? await Task.sleep(for: .seconds(autoDismissDelay))
                guard !Task.isCancelled, !isDragging else { return }
                onDismiss()
            }
    }
}

// MARK: - Subviews

private extension LivithSnackBar {
    var bannerContent: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(message)
                .notosans(.body4Semibold)
                .foregroundStyle(Color.livithColor(.white100))

            Spacer()

            Button {
                onActionTapped()
            } label: {
                Text(actionTitle)
                    .notosans(.caption1Semibold)
                    .foregroundStyle(Color.livithColor(.yellow30))
            }
        }
        .padding(16)
        .background(Color.livithColor(.black80))
        .shadow(color: .black.opacity(0.2), radius: 9)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                isDragging = true
                let translation = value.translation.height
                
                // top: 위로 드래그 시, bottom: 아래로 드래그 시만 반응
                if (dismissEdge == .top && translation < 0) || (dismissEdge == .bottom && translation > 0) {
                    offset = translation
                }
            }
            .onEnded { value in
                isDragging = false
                let translation = value.translation.height
                let shouldDismiss = (dismissEdge == .top && translation < -dismissThreshold) ||
                                   (dismissEdge == .bottom && translation > dismissThreshold)
                
                if shouldDismiss {
                    withAnimation(.easeOut(duration: 0.2)) {
                        offset = dismissEdge == .top ? -200 : 200
                    }
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(200))
                        guard !Task.isCancelled else { return }
                        onDismiss()
                    }
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        offset = 0
                    }
                    timerResetCount += 1
                }
            }
    }
}

// MARK: - Preview

#Preview("Bottom") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        LivithSnackBar(
            message: "웹사이트를 보셨나요?\n관심 콘서트 설정하고 공연 알림을 받으세요",
            actionTitle: "콘서트 설정",
            dismissEdge: .bottom,
            onActionTapped: {},
            onDismiss: {}
        )
        .padding([.horizontal, .bottom], 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

#Preview("Top") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        LivithSnackBar(
            message: "선호 장르가 변경되었어요",
            actionTitle: "확인",
            dismissEdge: .top,
            onActionTapped: {},
            onDismiss: {}
        )
        .padding([.horizontal, .top], 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
