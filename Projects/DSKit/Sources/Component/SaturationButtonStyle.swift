//
//  SaturationButtonStyle.swift
//  DSKit
//
//  Created by 김진웅 on 01/05/26.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

/// 버튼이 눌렸을 때 채도가 낮아지는 커스텀 버튼 스타일입니다.
public struct SaturationButtonStyle: ButtonStyle {
    /// 채도 감소 정도 (0.0 ~ 1.0, 기본값: 0.5)
    let saturationValue: Double
    
    public init(saturationValue: Double = 0.5) {
        self.saturationValue = saturationValue
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .saturation(configuration.isPressed ? saturationValue : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
