//
//  ToastContainerView.swift
//  LivithDesignSystem
//
//  Created by 김진웅 on 01/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

struct ToastContainerView: View {
    
    private enum Animation {
        static let springResponse: Double = 0.4
        static let springDamping: Double = 0.8
        static let keyboardAnimationDuration: Double = 0.2
        static let dismissDelay: Double = 0.4
    }
    
    let content: ToastContent
    let configuration: ToastConfiguration
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    @ObservedObject private var keyboardObserver = KeyboardHeightObserver.shared
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                topSpacer(geometry: geometry)
                toastView
                bottomSpacer
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.spring(response: Animation.springResponse, dampingFraction: Animation.springDamping), value: isVisible)
            .animation(.easeOut(duration: Animation.keyboardAnimationDuration), value: keyboardObserver.height)
        }
        .onAppear {
            withAnimation { isVisible = true }
            scheduleDismissIfNeeded()
        }
    }
}

// MARK: - Subviews

private extension ToastContainerView {
    func topSpacer(geometry: GeometryProxy) -> some View {
        Group {
            switch configuration.position {
            case .top:
                Spacer().frame(height: geometry.safeAreaInsets.top + configuration.topPadding)
            case .safeAreaTop:
                Spacer().frame(height: geometry.safeAreaInsets.top)
            case .aboveKeyboard:
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var toastView: some View {
        if isVisible {
            LivithToast(type: content.type, message: content.message)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onTapGesture { dismissToast() }
        }
    }
    
    @ViewBuilder
    var bottomSpacer: some View {
        if configuration.position == .aboveKeyboard {
            Spacer().frame(height: keyboardObserver.height + configuration.keyboardSpacing)
        } else {
            Spacer()
        }
    }
}

// MARK: - Actions

private extension ToastContainerView {
    func scheduleDismissIfNeeded() {
        guard let duration = configuration.duration else { return }
        Task {
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            await MainActor.run { dismissToast() }
        }
    }
    
    func dismissToast() {
        guard isVisible else { return }
        withAnimation { isVisible = false }
        Task {
            try? await Task.sleep(nanoseconds: UInt64(Animation.dismissDelay * 1_000_000_000))
            await MainActor.run { onDismiss() }
        }
    }
}
