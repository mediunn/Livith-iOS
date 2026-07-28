//
//  LivithColor.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

public extension Color {
    enum LivithColor: String {
        case black100 = "Black100"
        case black90 = "Black90"
        case black80 = "Black80"
        case black50 = "Black50"
        case black30 = "Black30"
        case black5 = "Black5"
        case white100 = "White100"
        case yellow30 = "Yellow30"
        case yellow60 = "Yellow60"
        case caution100 = "Caution100"
        case translation = "Translation"
        case original = "Original"

        public var color: Color {
            Color(rawValue, bundle: .livithDesignSystem)
        }
    }

    // MARK: - livithColor

    /// LivithColors 열거형을 통해 앱의 컬러 시스템에 접근합니다.
    ///
    /// 사용 예시:
    /// ```swift
    /// Text("Hello")
    ///     .foregroundColor(.livithColor(.black100))
    /// ```
    ///
    /// - Parameter color: LivithColors 열거형 케이스
    /// - Returns: 해당 색상에 맞는 Color 객체
    static func livithColor(_ color: LivithColor) -> Color {
        return color.color
    }
}

public extension Color {

    // MARK: - HEX 초기화

    /// HEX 코드 문자열로부터 `Color` 인스턴스를 생성하는 이니셜라이저.
    ///
    /// - Parameters:
    ///   - hex: 색상을 나타내는 HEX 문자열(예: "#FFFFFF" 또는 "FFFFFF")
    ///   - opacity: 색상의 불투명도. 기본값은 1.0(불투명)
    ///
    /// 사용 예시:
    /// ```swift
    /// let backgroundColor = Color("#F5F5F5")
    /// let textColor = Color("333333")
    /// ```
    init(hex: String, opacity: Double = 1.0) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        assert(hexFormatted.count == 6, "유효하지 않은 HEX 코드입니다.")

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        self.init(
            .sRGB,
            red: Double((rgbValue & 0xFF0000) >> 16) / 255,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255,
            blue: Double(rgbValue & 0x0000FF) / 255,
            opacity: opacity
        )
    }
}
