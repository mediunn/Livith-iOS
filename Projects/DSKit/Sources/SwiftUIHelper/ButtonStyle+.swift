//
//  ButtonStyle+.swift
//  DSKit
//
//  Created by 김진웅 on 01/05/26.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

extension ButtonStyle where Self == SaturationButtonStyle {
    /// 버튼이 눌렸을 때 채도가 낮아지는 스타일입니다.
    /// - Parameter saturationValue: 채도 감소 정도 (0.0 ~ 1.0, 기본값: 0.5)
    public static func saturation(saturationValue: Double = 0.5) -> SaturationButtonStyle {
        SaturationButtonStyle(saturationValue: saturationValue)
    }
    
    /// 기본 채도 감소 스타일 (채도값: 0.5)
    public static var saturation: SaturationButtonStyle {
        SaturationButtonStyle()
    }
}
