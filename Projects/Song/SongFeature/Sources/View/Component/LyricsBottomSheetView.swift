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

    enum SheetPosition: CaseIterable {
        case bottom
        case middle
        case top

        func offset(screenHeight: CGFloat, videoHeight: CGFloat, toggleHeight: CGFloat) -> CGFloat {
            switch self {
            case .bottom:
                return screenHeight - 50
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

    @State private var currentPosition: SheetPosition = .middle
    @State private var dragOffset: CGFloat = 0

    private var sheetOffset: CGFloat {
        currentPosition.offset(screenHeight: screenHeight, videoHeight: videoHeight, toggleHeight: toggleHeight) + dragOffset
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            handleBar
            lyricsContentSection
        }
        .background(Color.livithColor(.black100))
        .clipShape(RoundedRectangle(cornerRadius: currentPosition == .top ? 0 : 20))
        .offset(y: sheetOffset)
        .gesture(dragGesture)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentPosition)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
    }
}

// MARK: - Subviews

private extension LyricsBottomSheetView {
    var handleBar: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.livithColor(.black50))
                .frame(width: 40, height: 4)
                .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity)
        .background(Color.livithColor(.black100))
        .contentShape(Rectangle())
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
