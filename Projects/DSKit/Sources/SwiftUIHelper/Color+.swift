//
//  Color+.swift
//  DesignSystem
//
//  Created by YOUJIM on 4/15/25.
//  Copyright © 2025 Youjin Lee. All rights reserved.
//

import SwiftUI

public extension Color {
    enum LivithColor {
        case black100, black90, black80, black50, black30, black5, white100
        case yellow30, yellow60
        case caution100
        case transition, original
        
        public var color: Color {
            switch self {
            case .black100:
                Color(DSKitAsset.ColorAssets.black100.color)
            case .black90:
                Color(DSKitAsset.ColorAssets.black90.color)
            case .black80:
                Color(DSKitAsset.ColorAssets.black80.color)
            case .black50:
                Color(DSKitAsset.ColorAssets.black50.color)
            case .black30:
                Color(DSKitAsset.ColorAssets.black30.color)
            case .black5:
                Color(DSKitAsset.ColorAssets.black5.color)
            case .white100:
                Color(DSKitAsset.ColorAssets.white100.color)
            case .yellow30:
                Color(DSKitAsset.ColorAssets.yellow30.color)
            case .yellow60:
                Color(DSKitAsset.ColorAssets.yellow60.color)
            case .caution100:
                Color(DSKitAsset.ColorAssets.caution100.color)
            case .transition:
                Color(DSKitAsset.ColorAssets.transition.color)
            case .original:
                Color(DSKitAsset.ColorAssets.original.color)
            }
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
    init(_ hex: String, opacity: Double = 1.0) {
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
