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
        case backEnabled, backPressed
        case closeEnabled, closePressed, closeCommon
        case rightEnabled, rightPressed
        case homeEnabled, homePressed, homeDisabled
        case myEnabled, myPressed, myDisabled
        case searchEnabled, searchPressed, searchDisabled
        case playEnabled, playPressed
        case cultureCommon
        case livithLogo, livithEmpty
        case splash
        
        public var image: Image {
            switch self {
            case .backEnabled:
                Image(uiImage: DesignSystemAsset.ImageAssets.iconBackEnabled.image)
            case .backPressed:
                Image(uiImage: DesignSystemAsset.ImageAssets.iconBackPressed.image)
            case .closeEnabled:
                Image(uiImage: DesignSystemAsset.ImageAssets.iconCloseEnabled.image)
            case .closePressed:
                Image(uiImage: DesignSystemAsset.ImageAssets.iconClosePressed.image)
            case .closeCommon:
                Image(uiImage: DesignSystemAsset.ImageAssets.iconCloseCommon.image)
            case .rightEnabled:
                Image(uiImage: DesignSystemAsset.ImageAssets.iconRightEnabled.image)
            case .rightPressed:
                Image(uiImage: DesignSystemAsset.ImageAssets.iconRightPressed.image)
            case .homeEnabled:
                Image(uiImage: DesignSystemAsset.ImageAssets.iconHomeEnabled.image)
            case .homePressed:
                Image(uiImage: DesignSystemAsset.ImageAssets.iconHomePressed.image)
            case .homeDisabled:
                Image(uiImage: DesignSystemAsset.ImageAssets.iconHomeDisabled.image)
            case .myEnabled:
                Image(uiImage: DesignSystemAsset.ImageAssets.iconMyEnabled.image)
            case .myPressed:
                Image(uiImage: DesignSystemAsset.ImageAssets.iconMyPressed.image)
            case .myDisabled:
                Image(uiImage: DesignSystemAsset.ImageAssets.iconMyDisabled.image)
            case .searchEnabled:
                Image(uiImage: DesignSystemAsset.ImageAssets.iconSearchEnabled.image)
            case .searchPressed:
                Image(uiImage: DesignSystemAsset.ImageAssets.iconSearchPressed.image)
            case .searchDisabled:
                Image(uiImage: DesignSystemAsset.ImageAssets.iconSearchDisabled.image)
            case .playEnabled:
                Image(uiImage: DesignSystemAsset.ImageAssets.iconPlayEnabled.image)
            case .playPressed:
                Image(uiImage: DesignSystemAsset.ImageAssets.iconPlayPressed.image)
            case .livithLogo:
                Image(uiImage: DesignSystemAsset.ImageAssets.imageLivithLogo.image)
            case .livithEmpty:
                Image(uiImage: DesignSystemAsset.ImageAssets.imageLivithEmpty.image)
            case .splash:
                Image(uiImage: DesignSystemAsset.ImageAssets.imageSplash.image)
            case .cultureCommon:
                Image(uiImage: DesignSystemAsset.ImageAssets.iconCultureCommon.image)
            }
        }
    }
    
    // MARK: - livithImage
    
    /// LivithImage 열거형을 통해 앱의 이미지 에셋에 접근합니다.
    ///
    /// 사용 예시:
    /// ```swift
    /// Image.livithImage(.backEnabled)
    ///     .resizable()
    ///     .frame(width: 24, height: 24)
    /// ```
    /// - Parameter image: LivithImage 열거형 케이스
    /// - Returns: 해당 이미지에 맞는 Image 뷰
    static func livithImage(_ image: LivithImage) -> Image {
        return image.image
    }
}