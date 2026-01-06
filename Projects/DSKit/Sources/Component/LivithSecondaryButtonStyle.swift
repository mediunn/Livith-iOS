//
//  LivithSecondaryButtonStyle.swift
//  DSKit
//
//  Created by 김진웅 on 1/5/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

/// 라이빗의 Secondary(Pink) 버튼 스타일입니다.
/// - disabled: black50 배경, black30 텍스트
/// - enabled: translation 배경, black100 텍스트
/// - pressed: ff8479 배경, black100 텍스트
public struct LivithSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .notosans(.body3Semibold)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(backgroundColor(isPressed: configuration.isPressed))
            )
            .foregroundStyle(textColor)
    }
    
    private func backgroundColor(isPressed: Bool) -> Color {
        if !isEnabled {
            return .livithColor(.black50)
        }
        return isPressed ? Color(red: 1.0, green: 0.52, blue: 0.48) : .livithColor(.translation)
    }
    
    private var textColor: Color {
        isEnabled ? .livithColor(.black100) : .livithColor(.black30)
    }
}
