//
//  Image+.swift
//  DesignSystem
//
//  Created by YOUJIM on 4/15/25.
//  Copyright © 2025 Youjin Lee. All rights reserved.
//

import SwiftUI

public extension Image {
    enum LivithImage {
        case livithLogo, livithEmpty
        case splash
        case icnLineBackCommon
        case checkboxFill, checkboxLine
        
        public var image: Image {
            switch self {
            case .livithLogo:
                DesignSystemAsset.ImageAssets.imageLivithLogo.swiftUIImage
            case .livithEmpty:
                DesignSystemAsset.ImageAssets.imageLivithEmpty.swiftUIImage
            case .splash:
                DesignSystemAsset.ImageAssets.imageSplash.swiftUIImage
            case .icnLineBackCommon:
                DesignSystemAsset.ImageAssets.icnLineBackCommon.swiftUIImage
            case .checkboxFill:
                DesignSystemAsset.ImageAssets.checkboxFill.swiftUIImage
            case .checkboxLine:
                DesignSystemAsset.ImageAssets.checkboxLine.swiftUIImage
            }
        }
    }
    
    // MARK: - livithImage
    
    /// LivithImage 열거형을 통해 앱의 이미지 에셋에 접근합니다.
    ///
    /// 사용 예시:
    /// ```swift
    /// Image.livithImage(.livithLogo)
    ///     .resizable()
    ///     .frame(width: 24, height: 24)
    /// ```
    /// - Parameter image: LivithImage 열거형 케이스
    /// - Returns: 해당 이미지에 맞는 Image 뷰
    static func livithImage(_ image: LivithImage) -> Image {
        return image.image
    }
}
