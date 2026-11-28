//  LivithLoader.swift
//  DesignSystem

import SwiftUI

public struct LivithLoader: View {
    private let delay: Duration

    @Environment(\.controlSize) private var controlSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isDelayElapsed = false

    public init(delay: Duration = .milliseconds(700)) {
        self.delay = delay
    }

    public var body: some View {
        Group {
            if isVisible && !reduceMotion {
                KeyframeAnimator(initialValue: Motion(), repeating: true) { motion in
                    ring(dashOffset: motion.dashOffset)
                        .rotationEffect(.degrees(motion.turn + motion.sweep))
                } keyframes: { _ in
                    KeyframeTrack(\.turn) {
                        LinearKeyframe(360, duration: 1.8)
                    }
                    KeyframeTrack(\.sweep) {
                        LinearKeyframe(108, duration: 0.9, timingCurve: .easeInOut)
                        LinearKeyframe(360, duration: 0.9, timingCurve: .easeInOut)
                    }
                    KeyframeTrack(\.dashOffset) {
                        LinearKeyframe(45, duration: 0.9, timingCurve: .easeInOut)
                        LinearKeyframe(180, duration: 0.9, timingCurve: .easeInOut)
                    }
                }
            } else {
                ring(dashOffset: 45)
                    .opacity(isVisible ? 1 : 0)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("로딩 중")
        .accessibilityHidden(!isVisible)
        .task(id: delay) {
            isDelayElapsed = false
            guard delay > .zero else { return }
            do {
                try await Task.sleep(for: delay)
                isDelayElapsed = true
            } catch {
                return
            }
        }
    }

    private struct Motion {
        var turn = 0.0
        var sweep = 0.0
        var dashOffset = 180.0
    }

    private func ring(dashOffset: CGFloat) -> some View {
        let diameter: CGFloat = controlSize == .small || controlSize == .mini ? 16 : 32
        // Scale the reference ring's 66-unit coordinate system to the control size.
        let scale = diameter / 66
        let stroke = StrokeStyle(
            lineWidth: 6 * scale,
            lineCap: .round,
            dash: [180 * scale],
            dashPhase: dashOffset * scale
        )
        return Circle()
            .inset(by: stroke.lineWidth / 2)
            .stroke(Color.livithColor(.yellow30), style: stroke)
            .frame(width: diameter, height: diameter)
    }

    private var isVisible: Bool {
        delay <= .zero || isDelayElapsed
    }
}

#Preview("기본 · 작은 크기") {
    HStack(spacing: 24) {
        LivithLoader()
        LivithLoader(delay: .zero)
            .controlSize(.small)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.livithColor(.black100))
}
