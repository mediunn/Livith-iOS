//
//  Notosans.swift
//  DesignSystem
//
//  Created by Youjin Lee on 11/2/25.
//  Copyright © 2025 Livith. All rights reserved.
//


import SwiftUI

/// `Notosans`는 다양한 텍스트 스타일을 정의하는 열거형입니다.
public enum Notosans {
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
                return DesignSystemFontFamily.NotoSansKR.bold.name
            case .headSemibold, .body1Semibold, .body2Semibold, .body3Semibold, .caption1Semibold, .caption2Semibold:
                return DesignSystemFontFamily.NotoSansKR.semiBold.name
            case .headMedium, .body2Medium, .body3Medium, .body4Medium:
                return DesignSystemFontFamily.NotoSansKR.medium.name
            default:
                return DesignSystemFontFamily.NotoSansKR.regular.name
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
                return size * 1.3
            case .caption1Regular, .caption2Semibold, .caption2Regular:
                return size * 1.2
            default:
                return size * 1.4
            }
        }
        
        /// 해당 스타일의 베이스라인 오프셋(Baseline Offset)을 반환합니다.
        public var baselineOffset: CGFloat {
            return (lineHeight - size) / 3
        }
    }
