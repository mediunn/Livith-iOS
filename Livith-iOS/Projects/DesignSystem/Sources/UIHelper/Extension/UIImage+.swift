//
//  UIImage+.swift
//  DesignSystem
//
//  Created by YOUJIM on 4/15/25.
//  Copyright © 2025 Youjin Lee. All rights reserved.
//


import UIKit

public extension UIImage {
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
        
        public var image: UIImage {
            switch self {
            case .backEnabled:
                DesignSystemAsset.ImageAssets.iconBackEnabled.image
            case .backPressed:
                DesignSystemAsset.ImageAssets.iconBackPressed.image
            case .closeEnabled:
                DesignSystemAsset.ImageAssets.iconCloseEnabled.image
            case .closePressed:
                DesignSystemAsset.ImageAssets.iconClosePressed.image
            case .closeCommon:
                DesignSystemAsset.ImageAssets.iconCloseCommon.image
            case .rightEnabled:
                DesignSystemAsset.ImageAssets.iconRightEnabled.image
            case .rightPressed:
                DesignSystemAsset.ImageAssets.iconRightPressed.image
            case .homeEnabled:
                DesignSystemAsset.ImageAssets.iconHomeEnabled.image
            case .homePressed:
                DesignSystemAsset.ImageAssets.iconHomePressed.image
            case .homeDisabled:
                DesignSystemAsset.ImageAssets.iconHomeDisabled.image
            case .myEnabled:
                DesignSystemAsset.ImageAssets.iconMyEnabled.image
            case .myPressed:
                DesignSystemAsset.ImageAssets.iconMyPressed.image
            case .myDisabled:
                DesignSystemAsset.ImageAssets.iconMyDisabled.image
            case .searchEnabled:
                DesignSystemAsset.ImageAssets.iconSearchEnabled.image
            case .searchPressed:
                DesignSystemAsset.ImageAssets.iconSearchPressed.image
            case .searchDisabled:
                DesignSystemAsset.ImageAssets.iconSearchDisabled.image
            case .playEnabled:
                DesignSystemAsset.ImageAssets.iconPlayEnabled.image
            case .playPressed:
                DesignSystemAsset.ImageAssets.iconPlayPressed.image
            case .livithLogo:
                DesignSystemAsset.ImageAssets.imageLivithLogo.image
            case .livithEmpty:
                DesignSystemAsset.ImageAssets.imageLivithEmpty.image
            case .splash:
                DesignSystemAsset.ImageAssets.imageSplash.image
            case .cultureCommon:
                DesignSystemAsset.ImageAssets.iconCultureCommon.image
            }
        }
    }
    
    // MARK: - livithImage

    /// LivithImage 열거형을 통해 앱의 이미지 에셋에 접근합니다.
    ///
    /// 사용 예시:
    /// ```swift
    /// imageView.image = .livithImage(.backEnabled)
    /// button.setImage(.livithImage(.homeEnabled), for: .normal)
    /// ```
    /// - Parameter image: LivithImage 열거형 케이스
    /// - Returns: 해당 이미지에 맞는 UIImage 객체
    static func livithImage(_ image: LivithImage) -> UIImage {
        return image.image
    }
}
