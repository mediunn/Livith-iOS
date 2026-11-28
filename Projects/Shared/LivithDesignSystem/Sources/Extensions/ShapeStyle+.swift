//
//  ShapeStyle+.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

public extension ShapeStyle where Self == Color {
    /// `.foregroundStyle()` 또는 `.background()` 모디파이어에서 바로 Livith 컬러를 사용할 수 있습니다.
    ///
    /// 사용 예시:
    /// ```swift
    /// Text("Hello")
    ///     .foregroundStyle(.livithColor(.black100))
    ///     .background(.livithColor(.white100))
    /// ```
    ///
    /// - Parameter color: LivithColor 열거형 케이스
    /// - Returns: 해당 색상에 맞는 Color 객체
    static func livithColor(_ color: Color.LivithColor) -> Color {
        return color.color
    }
}
