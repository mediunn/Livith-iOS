//
//  LivithFont.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI
import UIKit

public extension Font {

    // MARK: - Notosans

    /// `Notosans`는 다양한 텍스트 스타일을 정의하는 열거형입니다.
    enum Notosans: String, CaseIterable {
        case title
        case headSemibold, headMedium, headRegular
        case body1Semibold
        case body2Semibold, body2Medium, body2Regular
        case body3Semibold, body3Medium, body3Regular
        case body4Semibold, body4Medium, body4Regular
        case caption1Bold, caption1Semibold, caption1Regular
        case caption2Semibold, caption2Regular


        /// 해당 스타일의 폰트 이름을 반환합니다.
        var fontName: String {
            switch self {
            case .title, .caption1Bold:
                return "NotoSansKR-Bold"
            case .headSemibold, .body1Semibold, .body2Semibold, .body3Semibold, .body4Semibold, .caption1Semibold, .caption2Semibold:
                return "NotoSansKR-SemiBold"
            case .headMedium, .body2Medium, .body3Medium, .body4Medium:
                return "NotoSansKR-Medium"
            default:
                return "NotoSansKR-Regular"
            }
        }

        /// 해당 스타일의 폰트 크기를 반환합니다.
        public var size: CGFloat {
            switch self {
            case .title: return 26
            case .headSemibold, .headMedium, .headRegular: return 22
            case .body1Semibold: return 18
            case .body2Semibold, .body2Medium, .body2Regular: return 16
            case .body3Semibold, .body3Medium, .body3Regular: return 15
            case .body4Semibold, .body4Medium, .body4Regular: return 14
            case .caption1Bold, .caption1Semibold, .caption1Regular: return 12
            case .caption2Semibold, .caption2Regular: return 10
            }
        }

        /// 해당 스타일의 자간(Kerning)을 반환합니다.
        public var kerning: CGFloat {
            return size * -0.05
        }

        /// 해당 스타일의 줄 높이(Line Height)를 반환합니다.
        public var lineHeight: CGFloat {
            switch self {
            case .caption1Bold, .caption1Semibold:
                return 1.28
            case .caption1Regular, .caption2Semibold, .caption2Regular:
                return 1.18
            default:
                return 1.38
            }
        }
    }

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

    public static func registerFont() {
        let fontNames = [
            "NotoSansKR-Bold",
            "NotoSansKR-SemiBold",
            "NotoSansKR-Medium",
            "NotoSansKR-Regular"
        ]

        let bundle = Bundle.livithDesignSystem

        for fontName in fontNames {
            guard let url = bundle.url(forResource: fontName, withExtension: "ttf") else {
                print("[LivithDesignSystem] 폰트 파일을 찾을 수 없습니다: \(fontName).ttf")
                continue
            }

            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil) {
                print("[LivithDesignSystem] 폰트 등록 실패: \(fontName)")
            }
        }
    }
}

// MARK: - NotosansModifier

public struct NotosansModifier: ViewModifier {
    let style: Font.Notosans

    private static var isFontRegistered = false

    init(style: Font.Notosans) {
        self.style = style

        if !Self.isFontRegistered {
            Font.registerFont()
            Self.isFontRegistered = true
        }
    }

    private var uiFont: UIFont {
        guard let font = UIFont(name: style.fontName, size: style.size) else {
            fatalError("폰트를 찾을 수 없습니다.")
        }

        return font
    }

    private var lineSpacing: CGFloat {
        let desiredLineHeight = style.size * style.lineHeight
        return desiredLineHeight - uiFont.lineHeight
    }

    private var padding: CGFloat {
        return lineSpacing / 2.0
    }

    public func body(content: Content) -> some View {
        content
            .font(.notosans(style))
            .kerning(style.kerning)
            .lineSpacing(lineSpacing)
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
    func notosans(_ style: Font.Notosans) -> some View {
        modifier(NotosansModifier(style: style))
    }
}
