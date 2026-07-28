//
//  LivithToast.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 12/12/25.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - Toast Type

public enum LivithToastType {
    case success
    case failure
    
    var icon: Image {
        switch self {
        case .success: return .livithIcon(.checkYellow)
        case .failure: return .livithIcon(.cautionTriangleSmall)
        }
    }
}

// MARK: - Toast Position

public enum LivithToastPosition {
    case top
    case safeAreaTop
    case aboveKeyboard
}

// MARK: - Toast View

public struct LivithToast: View {
    
    private enum Layout {
        static let iconSize: CGFloat = 30
        static let horizontalSpacing: CGFloat = 10
        static let leadingPadding: CGFloat = 20
        static let verticalPadding: CGFloat = 12
        static let toastWidth: CGFloat = 343
        static let cornerRadius: CGFloat = 8
        static let shadowRadius: CGFloat = 18
        static let shadowOpacity: Double = 0.4
    }
    
    private let type: LivithToastType
    private let message: String
    
    public init(type: LivithToastType, message: String) {
        self.type = type
        self.message = message
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: Layout.horizontalSpacing) {
            type.icon
                .resizable()
                .frame(width: Layout.iconSize, height: Layout.iconSize)
            
            Text(message)
                .notosans(.body4Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.leading, Layout.leadingPadding)
        .padding(.vertical, Layout.verticalPadding)
        .frame(width: Layout.toastWidth)
        .background(Color.livithColor(.black80))
        .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius))
        .shadow(color: Color.livithColor(.black100).opacity(Layout.shadowOpacity), radius: Layout.shadowRadius)
    }
}

// MARK: - View Extension

public extension View {
    func livithToast(
        isPresented: Binding<Bool>,
        type: LivithToastType,
        message: String
    ) -> some View {
        modifier(LivithToastModifier(
            isPresented: isPresented,
            type: type,
            message: message
        ))
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        LivithToast(type: .failure, message: "닉네임 변경에 실패했어요")
        LivithToast(type: .success, message: "닉네임이 수정되었어요")
    }
    .padding()
    .background(Color.livithColor(.black100))
}
