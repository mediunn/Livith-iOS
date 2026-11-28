//
//  MarqueeText.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

public struct MarqueeText: View {

    // MARK: - Property

    private let text: String
    private let font: Font.Notosans
    private let textColor: Color
    private let speed: CGFloat
    private let delaySeconds: Double

    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var offset: CGFloat = 0
    @State private var animationTask: Task<Void, Never>?

    // MARK: - Initializer

    public init(
        text: String,
        font: Font.Notosans,
        textColor: Color,
        speed: CGFloat = 50,
        delaySeconds: Double = 3
    ) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.speed = speed
        self.delaySeconds = delaySeconds
    }

    private var needsScroll: Bool {
        textWidth > containerWidth && containerWidth > 0
    }

    // MARK: - Body

    public var body: some View {
        GeometryReader { geometry in
            HStack {
                Text(text)
                    .notosans(font)
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .background(
                        GeometryReader { textGeometry in
                            Color.clear
                                .preference(key: TextWidthKey.self, value: textGeometry.size.width)
                        }
                    )
                    .offset(x: offset)
            }
            .frame(height: geometry.size.height, alignment: .leading)
            .onPreferenceChange(TextWidthKey.self) { width in
                textWidth = width
                if containerWidth > 0 {
                    restartAnimation()
                }
            }
            .onAppear {
                containerWidth = geometry.size.width
            }
            .onChange(of: geometry.size.width) { _, newValue in
                containerWidth = newValue
                restartAnimation()
            }
        }
        .clipped()
        .onDisappear {
            animationTask?.cancel()
        }
    }
}

// MARK: - Animation

private extension MarqueeText {
    func startAnimation() {
        guard needsScroll else { return }

        animationTask?.cancel()
        animationTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(delaySeconds))
                guard !Task.isCancelled else { return }

                let scrollDistance = textWidth - containerWidth
                let duration = scrollDistance / speed

                withAnimation(.linear(duration: duration)) {
                    offset = -scrollDistance
                }

                try? await Task.sleep(for: .seconds(duration))
                guard !Task.isCancelled else { return }

                try? await Task.sleep(for: .seconds(delaySeconds))
                guard !Task.isCancelled else { return }

                offset = 0
            }
        }
    }

    func restartAnimation() {
        animationTask?.cancel()
        offset = 0
        startAnimation()
    }
}

// MARK: - PreferenceKey

private struct TextWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        MarqueeText(
            text: "짧은 텍스트",
            font: Font.Notosans.body1Semibold,
            textColor: Color.livithColor(.white100)
        )
        .frame(width: 200, height: 30)
        .background(Color.gray)

        MarqueeText(
            text: "이것은 매우 긴 텍스트입니다. 화면을 넘어가면 자동으로 스크롤됩니다.",
            font: .body1Semibold,
            textColor: .white
        )
        .frame(width: 200, height: 30)
        .background(Color.gray)
    }
    .padding()
    .background(Color.livithColor(.black100))
}
