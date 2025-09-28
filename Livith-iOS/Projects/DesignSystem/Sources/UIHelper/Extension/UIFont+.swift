//
//  UIFont+.swift
//  Livith-iOS
//
//  Created by YOUJIM on 4/14/25.
//  Copyright © 2025 Youjin Lee. All rights reserved.
//


import UIKit

public extension UIFont {
    
    // MARK: - Notosans

    /// `Notosans`는 다양한 텍스트 스타일을 정의하는 열거형입니다.
    ///
    /// - `headLarge`, `headSmall`: 헤드라인 스타일 (큰 텍스트)
    /// - `bodyLarge`, `bodyMedium`, `bodySmall`: 본문 스타일
    /// - `captionLarge`, `captionSmall`, `captionExtraSmall`: 캡션 스타일 (작은 텍스트)
    ///
    /// 각 스타일은 특정 폰트 패밀리(`Pretendard`)와 크기, 자간, 줄 높이를 갖습니다.
    enum Notosans {
        case title
        case headLarge, headSmall
        case bodyLarge, bodyMedium, bodySmall
        case captionLarge, captionSmall, captionExtraSmall
        
        /// 해당 스타일의 폰트 이름을 반환합니다.
        ///
        /// - `SemiBold`: `headLarge`, `bodyLarge`, `captionLarge`
        /// - `Medium`: `bodyMedium`
        /// - `Regular`: 그 외 스타일
        var fontName: DesignSystemFontConvertible {
            switch self {
            case .title:
                return DesignSystemFontFamily.NotoSansKR.bold
            case .headLarge, .bodyLarge, .captionLarge:
                return DesignSystemFontFamily.NotoSansKR.semiBold
            case .bodyMedium:
                return DesignSystemFontFamily.NotoSansKR.medium
            default:
                return DesignSystemFontFamily.NotoSansKR.regular
            }
        }
        
        /// 해당 스타일의 폰트 크기를 반환합니다.
        ///
        /// - Returns: 스타일에 따른 `CGFloat` 크기 값
        public var size: CGFloat {
            switch self {
            case .title: return 26
            case .headLarge, .headSmall: return 22
            case .bodyLarge: return 18
            case .bodyMedium: return 16
            case .bodySmall: return 14
            case .captionLarge, .captionSmall: return 12
            case .captionExtraSmall: return 10
            }
        }
        
        /// 해당 스타일의 자간(Kerning)을 반환합니다.
        ///
        /// - 기본적으로 폰트 크기의 -5% 값을 적용하여 자연스러운 글자 간격을 유지합니다.
        /// - Returns: `CGFloat` 값 (음수 값 적용)
        public var kerning: CGFloat {
            return size * -0.05
        }
        
        /// 해당 스타일의 줄 높이(Line Height)를 반환합니다.
        ///
        /// - 디자인 명세에 따라 폰트 크기 기준으로 줄 높이를 적용하여 가독성을 고려합니다.
        /// - Returns: `CGFloat` 값
        public var lineHeight: CGFloat {
            switch self {
            case .title, .headLarge, .headSmall, .bodyLarge, .bodyMedium, .bodySmall:
                return size * 1.4
            case .captionLarge:
                return size * 1.3
            case .captionSmall, .captionExtraSmall:
                return size * 1.2
            }
        }
        
        /// 해당 스타일의 베이스라인 오프셋(Baseline Offset)을 반환합니다.
        ///
        /// - 기본적으로 (줄 높이 - 폰트 크기)의 1/3을 적용하여 시각적 정렬을 조정합니다.
        /// - Returns: `CGFloat` 값
        public var baselineOffset: CGFloat {
            return (lineHeight - size) / 3
        }
    }
    
    /// `Notosans` 폰트를 반환하는 정적 메서드.
    ///
    /// - Parameter style: `Notosans` 스타일(enum)
    /// - Returns: 해당 스타일에 맞는 `UIFont` 객체를 반환합니다.
    ///
    /// 사용 예시:
    /// ```swift
    /// let titleFont = UIFont.notosans(.headLarge)
    /// let captionFont = UIFont.notosans(.captionLarge)
    /// ```
    static func notosans(_ style: Notosans) -> UIFont {
        return UIFont(font: style.fontName, size: style.size) ?? .systemFont(ofSize: style.size)
    }
}
