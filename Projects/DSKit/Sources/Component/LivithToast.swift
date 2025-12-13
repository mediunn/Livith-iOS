//
//  LivithToast.swift
//  DSKit
//
//  Created by Youjin Lee on 12/12/25.
//  Copyright © 2025 Livith. All rights reserved.
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
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Toast ViewModifier

private struct LivithToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let type: LivithToastType
    let message: String
    let duration: TimeInterval
    let topPadding: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if isPresented {
                    LivithToast(type: type, message: message)
                        .padding(.top, topPadding)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            Task {
                                try? await Task.sleep(for: .seconds(duration))
                                await MainActor.run {
                                    withAnimation { isPresented = false }
                                }
                            }
                        }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isPresented)
    }
}

// MARK: - View Extension

public extension View {
    func livithToast(
        isPresented: Binding<Bool>,
        type: LivithToastType,
        message: String,
        duration: TimeInterval = 2,
        topPadding: CGFloat = 60
    ) -> some View {
        modifier(LivithToastModifier(
            isPresented: isPresented,
            type: type,
            message: message,
            duration: duration,
            topPadding: topPadding
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
