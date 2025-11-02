//
//  Font+.swift
//  DesignSystem
//
//  Created by YOUJIM on 4/14/25.
//  Copyright © 2025 Youjin Lee. All rights reserved.
//

import SwiftUI

public extension Font {
    
    // MARK: - Notosans
    
    /// `Notosans` 폰트를 반환하는 정적 메서드.
    ///
    /// 사용 예시:
    /// ```swift
    /// Text("Hello")
    ///     .font(.notosans(.headLarge))
    /// ```
    static func notosans(_ style: Notosans) -> Font {
        return .custom(style.fontName, size: style.size)
    }
}

// MARK: - Text Modifier for Notosans

public struct NotosansModifier: ViewModifier {
    let style: Notosans
    
    public func body(content: Content) -> some View {
        content
            .font(.notosans(style))
            .kerning(style.kerning)
            .lineSpacing(style.lineHeight - style.size)
            .baselineOffset(style.baselineOffset)
    }
}

public extension View {
    /// Notosans 스타일을 적용하는 View Modifier
    ///
    /// 사용 예시:
    /// ```swift
    /// Text("Hello")
    ///     .notosans(.headLarge)
    /// ```
    func notosans(_ style: Notosans) -> some View {
        modifier(NotosansModifier(style: style))
    }
}
