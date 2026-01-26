//
//  BottomSheet.swift
//  LivithDesignSystem
//
//  Created by 김진웅 on 1/26/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - Handle Style

public enum HandleStyle {
    case dark
    case light
    
    var color: Color {
        switch self {
        case .dark:
            return Color.livithColor(.black80)
        case .light:
            return Color.livithColor(.white100)
        }
    }
    
    var width: CGFloat {
        switch self {
        case .dark:
            return 60
        case .light:
            return 132
        }
    }
}

/// 바텀시트의 콘텐츠 영역을 표시하는 재사용 가능한 View 컴포넌트입니다.
/// 핸들바, 배경색, 상단 둥근 모서리를 포함합니다.
public struct BottomSheet<Content: View>: View {
    
    // MARK: - Properties
    
    let handleStyle: HandleStyle
    let contentBackground: Color
    let content: () -> Content
    
    // MARK: - Initializer
    
    public init(
        handleStyle: HandleStyle = .dark,
        contentBackground: Color = .livithColor(.black90),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.handleStyle = handleStyle
        self.contentBackground = contentBackground
        self.content = content
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: 0) {
            handleBar
                .padding(.top, 10)
            
            content()
                .frame(maxWidth: .infinity)
        }
        .background(contentBackground)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 20,
                topTrailingRadius: 20
            )
        )
    }
    
    private var handleBar: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(handleStyle.color)
            .frame(width: handleStyle.width, height: 6)
    }
}
