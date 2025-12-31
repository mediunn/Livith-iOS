//
//  TicketReturnBanner.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct TicketReturnBanner: View {

    // MARK: - Property

    let onSettingTapped: () -> Void
    let onDismiss: () -> Void

    @State private var offset: CGFloat = 0
    @State private var isDragging: Bool = false
    @State private var timerResetCount: Int = 0

    private let autoDismissDelay: TimeInterval = 5.0
    private let dismissThreshold: CGFloat = 50

    // MARK: - Body

    var body: some View {
        VStack {
            Spacer()

            bannerContent
                .offset(y: offset)
                .gesture(dragGesture)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .task(id: timerResetCount) {
            try? await Task.sleep(for: .seconds(autoDismissDelay))
            guard !Task.isCancelled, !isDragging else { return }
            onDismiss()
        }
    }
}

// MARK: - Subviews

private extension TicketReturnBanner {
    var bannerContent: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("웹사이트를 보셨나요?\n관심 콘서트 설정하고 공연 알림을 받으세요")
                .notosans(.body4Semibold)
                .foregroundStyle(Color.livithColor(.white100))

            Spacer()

            Button {
                onSettingTapped()
            } label: {
                Text("콘서트 설정")
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
                if value.translation.height > 0 {
                    offset = value.translation.height
                }
            }
            .onEnded { value in
                isDragging = false
                if value.translation.height > dismissThreshold {
                    withAnimation(.easeOut(duration: 0.2)) {
                        offset = 200
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

#Preview {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        TicketReturnBanner(
            onSettingTapped: {},
            onDismiss: {}
        )
    }
}
