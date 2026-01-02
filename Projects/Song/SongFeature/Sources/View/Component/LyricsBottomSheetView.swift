//
//  LyricsBottomSheetView.swift
//  SongFeature
//
//  Created by Youjin Lee on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct LyricsBottomSheetView: View {

    // MARK: - Enum

    public enum SheetPosition: CaseIterable {
        case bottom
        case middle
        case top

        func offset(screenHeight: CGFloat, videoHeight: CGFloat, toggleHeight: CGFloat) -> CGFloat {
            switch self {
            case .bottom:
                return screenHeight - 150
            case .middle:
                return videoHeight + toggleHeight
            case .top:
                return 0
            }
        }
    }

    // MARK: - Property

    @ObservedObject var store: SongLyricsStore

    let screenHeight: CGFloat
    let videoHeight: CGFloat
    let toggleHeight: CGFloat

    @Binding var currentPosition: SheetPosition
    @State private var dragOffset: CGFloat = 0
    @State private var isAppeared: Bool = false

    private var sheetOffset: CGFloat {
        currentPosition.offset(screenHeight: screenHeight, videoHeight: videoHeight, toggleHeight: toggleHeight) + dragOffset
    }

    private var sheetHeight: CGFloat {
        switch currentPosition {
        case .top:
            return screenHeight
        case .middle:
            return screenHeight - videoHeight - toggleHeight
        case .bottom:
            return 150
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: currentPosition == .bottom ? 0 : 20) {
            handleBar

            if currentPosition != .bottom {
                lyricsContentSection
            }
        }
        .frame(height: sheetHeight, alignment: .top)
        .background(Color.livithColor(.black90))
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 30,
                topTrailingRadius: 30
            )
        )
        .offset(y: sheetOffset)
        .gesture(dragGesture)
        .animation(isAppeared ? .spring(response: 0.4, dampingFraction: 0.8) : .none, value: currentPosition)
        .animation(isAppeared ? .spring(response: 0.4, dampingFraction: 0.8) : .none, value: dragOffset)
        .task {
            try? await Task.sleep(for: .milliseconds(300))
            isAppeared = true
        }
    }
}

// MARK: - Subviews

private extension LyricsBottomSheetView {
    var handleBar: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.livithColor(.black80))
                .frame(width: 76, height: 6)
                .padding(.vertical, 10)
        }
        .frame(maxWidth: .infinity)
    }

    var lyricsContentSection: some View {
        Group {
            if store.state.hasLyrics {
                LyricsContentView(store: store)
            } else {
                lyricsEmptyView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var lyricsEmptyView: some View {
        VStack {
            Spacer()
            LivithEmptyView(text: "가사 정보가 없어요")
            Spacer()
        }
    }
}

// MARK: - Gestures

private extension LyricsBottomSheetView {
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation.height
            }
            .onEnded { value in
                let velocity = value.predictedEndTranslation.height - value.translation.height
                let threshold: CGFloat = 100

                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    if velocity > threshold || value.translation.height > threshold {
                        moveToNextLowerPosition()
                    } else if velocity < -threshold || value.translation.height < -threshold {
                        moveToNextHigherPosition()
                    }
                    dragOffset = 0
                }
            }
    }

    func moveToNextLowerPosition() {
        switch currentPosition {
        case .top:
            currentPosition = .middle
        case .middle:
            currentPosition = .bottom
        case .bottom:
            break
        }
    }

    func moveToNextHigherPosition() {
        switch currentPosition {
        case .bottom:
            currentPosition = .middle
        case .middle:
            currentPosition = .top
        case .top:
            break
        }
    }
}
