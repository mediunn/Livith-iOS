//
//  LyricsBottomSheetView.swift
//  SongFeature
//
//  Created by Youjin Lee on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct LyricsBottomSheetView: View {

    // MARK: - Enum

    public enum SheetPosition: CaseIterable {
        case bottom
        case middle
        case top

        func offset(screenHeight: CGFloat, videoHeight: CGFloat, toggleHeight: CGFloat) -> CGFloat {
            let result: CGFloat
            switch self {
            case .bottom:
                result = screenHeight - 150
            case .middle:
                result = videoHeight + toggleHeight
            case .top:
                result = 0
            }
            return result.isFinite ? result : 0
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
        let offset = currentPosition.offset(screenHeight: screenHeight, videoHeight: videoHeight, toggleHeight: toggleHeight) + dragOffset
        return offset.isFinite ? offset : 0
    }

    private var sheetHeight: CGFloat {
        let height: CGFloat
        switch currentPosition {
        case .top:
            height = max(screenHeight, 150)
        case .middle:
            height = max(screenHeight - videoHeight - toggleHeight, 150)
        case .bottom:
            height = 150
        }
        return height.isFinite ? height : 150
    }

    // MARK: - Body

    var body: some View {
        LivithBottomSheet(
            handleStyle: .dark,
            handleWidth: 76,
            cornerRadius: 30
        ) {
            if currentPosition != .bottom {
                lyricsContentSection
                    .padding(.top, 20)
            }
        }
        .frame(height: sheetHeight, alignment: .top)
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
    var lyricsContentSection: some View {
        LyricsContentView(store: store)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
