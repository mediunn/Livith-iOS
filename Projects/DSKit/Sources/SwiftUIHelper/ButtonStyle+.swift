//
//  ButtonStyle+.swift
//  DSKit
//
//  Created by 김진웅 on 01/05/26.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

// MARK: - SaturationButtonStyle

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

// MARK: - LivithPrimaryButtonStyle

extension ButtonStyle where Self == LivithPrimaryButtonStyle {
    /// 라이빗의 Primary 버튼 스타일입니다.
    /// - disabled: black50 배경, black30 텍스트
    /// - enabled: yellow30 배경, black100 텍스트
    /// - pressed: yellow60 배경, black100 텍스트
    public static var livithPrimary: LivithPrimaryButtonStyle {
        LivithPrimaryButtonStyle()
    }
}

// MARK: - LivithSecondaryButtonStyle

extension ButtonStyle where Self == LivithSecondaryButtonStyle {
    /// 라이빗의 Secondary(Pink) 버튼 스타일입니다.
    /// - disabled: black50 배경, black30 텍스트
    /// - enabled: translation 배경, black100 텍스트
    /// - pressed: ff8479(분홍색) 배경, black100 텍스트
    public static var livithSecondary: LivithSecondaryButtonStyle {
        LivithSecondaryButtonStyle()
    }
}
