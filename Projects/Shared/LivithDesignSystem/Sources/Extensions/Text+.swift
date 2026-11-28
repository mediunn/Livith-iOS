//
//  Text+.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

public extension Text {
    /// 특정 키워드를 하이라이팅한 Text 생성
    init(
        _ content: String,
        highlighting highlightText: String,
        color highlightColor: Color
    ) {
        guard !highlightText.isEmpty,
              let range = content.range(of: highlightText) else {
            self.init(content)
            return
        }

        let before = String(content[..<range.lowerBound])
        let highlighted = String(content[range])
        let after = String(content[range.upperBound...])

        self = Text(before)
            + Text(highlighted).foregroundColor(highlightColor)
            + Text(after)
    }

    /// 특정 키워드를 하이라이팅 (폰트도 변경)
    init(
        _ content: String,
        highlighting highlightText: String,
        color highlightColor: Color,
        font highlightFont: Font
    ) {
        guard !highlightText.isEmpty,
              let range = content.range(of: highlightText) else {
            self.init(content)
            return
        }

        let before = String(content[..<range.lowerBound])
        let highlighted = String(content[range])
        let after = String(content[range.upperBound...])

        self = Text(before)
            + Text(highlighted)
                .foregroundColor(highlightColor)
                .font(highlightFont)
            + Text(after)
    }
}
