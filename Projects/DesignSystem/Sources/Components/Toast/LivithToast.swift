//
//  LivithToast.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 12/12/25.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

public enum LivithToastType {
    case success
    case failure

    var icon: Image {
        switch self {
        case .success:
            return .livithIcon(.checkYellow)
        case .failure:
            return .livithIcon(.cautionTriangleSmall)
        }
    }
}

// MARK: - Toast Position

public enum LivithToastPosition {
    case top
    case safeAreaTop
    case aboveKeyboard
}

public struct LivithToast: View {

    // MARK: - Property

    private let type: LivithToastType
    private let message: String

    // MARK: - LifeCycle

    public init(type: LivithToastType, message: String) {
        self.type = type
        self.message = message
    }

    // MARK: - Body

    public var body: some View {
        HStack(alignment: .center, spacing: 10) {
            type.icon
                .resizable()
                .frame(width: 30, height: 30)

            Text(message)
                .notosans(.body4Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .lineLimit(2)

            Spacer()
        }
        .padding(.leading, 20)
        .padding(.vertical, 12)
        .frame(width: 343)
        .background(Color.livithColor(.black80))
        .shadow(color: .livithColor(.black100).opacity(0.4), radius: 18)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Toast ViewModifier

private struct LivithToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let type: LivithToastType
    let message: String
    let duration: TimeInterval?
    let topPadding: CGFloat
    let position: LivithToastPosition
    let keyboardSpacing: CGFloat

    @State private var keyboardHeight: CGFloat = KeyboardHeightObserver.shared.height

    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    GeometryReader { geometry in
                        let toastHeight: CGFloat = 54
                        let toastY: CGFloat = {
                            switch position {
                            case .top:
                                return geometry.safeAreaInsets.top + topPadding
                            case .safeAreaTop:
                                return geometry.safeAreaInsets.top
                            case .aboveKeyboard:
                                return geometry.size.height - keyboardHeight - keyboardSpacing - toastHeight / 2
                            }
                        }()

                        LivithToast(type: type, message: message)
                            .position(x: geometry.size.width / 2, y: toastY)
                            .transition(.opacity)
                    }
                    .onAppear {
                        keyboardHeight = KeyboardHeightObserver.shared.height
                    }
                    .task(id: isPresented) {
                        guard let duration else { return }
                        try? await Task.sleep(for: .seconds(duration))
                        guard !Task.isCancelled else { return }
                        withAnimation { isPresented = false }
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isPresented)
            .onReceive(KeyboardHeightObserver.shared.$height) { height in
                keyboardHeight = height
            }
    }
}

// MARK: - View Extension

public extension View {
    func livithToast(
        isPresented: Binding<Bool>,
        type: LivithToastType,
        message: String,
        duration: TimeInterval? = 2,
        topPadding: CGFloat = 60,
        position: LivithToastPosition = .top,
        keyboardSpacing: CGFloat = 16
    ) -> some View {
        modifier(LivithToastModifier(
            isPresented: isPresented,
            type: type,
            message: message,
            duration: duration,
            topPadding: topPadding,
            position: position,
            keyboardSpacing: keyboardSpacing
        ))
    }
}

#Preview {
    VStack(spacing: 20) {
        LivithToast(type: .failure, message: "닉네임 변경에 실패했어요")
        LivithToast(type: .success, message: "닉네임이 수정되었어요")
    }
    .padding()
    .background(Color.livithColor(.black100))
}
