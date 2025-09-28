//
//  UIColor+.swift
//  DesignSystem
//
//  Created by YOUJIM on 4/15/25.
//  Copyright © 2025 Youjin Lee. All rights reserved.
//


import UIKit

public extension UIColor {
    enum LivithColor {
        case black100, black90, black80, black50, black30, black5, white100
        case yellow30, yellow60
        case caution100
        
        public var color: UIColor {
            switch self {
            case .black100:
                DesignSystemAsset.ColorAssets.black100.color
            case .black90:
                DesignSystemAsset.ColorAssets.black90.color
            case .black80:
                DesignSystemAsset.ColorAssets.black80.color
            case .black50:
                DesignSystemAsset.ColorAssets.black50.color
            case .black30:
                DesignSystemAsset.ColorAssets.black30.color
            case .black5:
                DesignSystemAsset.ColorAssets.black5.color
            case .white100:
                DesignSystemAsset.ColorAssets.white100.color
            case .yellow30:
                DesignSystemAsset.ColorAssets.yellow30.color
            case .yellow60:
                DesignSystemAsset.ColorAssets.yellow60.color
            case .caution100:
                DesignSystemAsset.ColorAssets.caution100.color
            }
        }
    }
    
    // MARK: - livithColor
    
    /// LivithColors 열거형을 통해 앱의 컬러 시스템에 접근합니다.
    ///
    /// 사용 예시:
    /// ```swift
    /// view.backgroundColor = .livithColor(.black5)
    /// label.textColor = .livithColor(.black100)
    /// ```
    ///
    /// - Parameter color: LivithColors 열거형 케이스
    /// - Returns: 해당 색상에 맞는 UIColor 객체
    static func livithColor(_ color: LivithColor) -> UIColor {
        return color.color
    }
}

public extension UIColor {
    
    // MARK: - HEX 초기화
    
    /// HEX 코드 문자열로부터 `UIColor` 인스턴스를 생성하는 편의 이니셜라이저.
    ///
    /// - Parameters:
    ///   - hex: 색상을 나타내는 HEX 문자열(예: "#FFFFFF" 또는 "FFFFFF")
    ///   - alpha: 색상의 알파값(투명도). 기본값은 1.0(불투명)
    ///
    /// 사용 예시:
    /// ```swift
    /// let backgroundColor = UIColor("#F5F5F5")
    /// let textColor = UIColor("333333", alpha: 0.8)
    /// ```
    convenience init(_ hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "유효하지 않은 HEX 코드입니다.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
