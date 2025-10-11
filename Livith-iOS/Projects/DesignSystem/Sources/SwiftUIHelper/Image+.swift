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
                Image(uiImage: DesignsystemAsset.ImageAssets.iconBackEnabled.image)
            case .backPressed:
                Image(uiImage: DesignsystemAsset.ImageAssets.iconBackPressed.image)
            case .closeEnabled:
                Image(uiImage: DesignsystemAsset.ImageAssets.iconCloseEnabled.image)
            case .closePressed:
                Image(uiImage: DesignsystemAsset.ImageAssets.iconClosePressed.image)
            case .closeCommon:
                Image(uiImage: DesignsystemAsset.ImageAssets.iconCloseCommon.image)
            case .rightEnabled:
                Image(uiImage: DesignsystemAsset.ImageAssets.iconRightEnabled.image)
            case .rightPressed:
                Image(uiImage: DesignsystemAsset.ImageAssets.iconRightPressed.image)
            case .homeEnabled:
                Image(uiImage: DesignsystemAsset.ImageAssets.iconHomeEnabled.image)
            case .homePressed:
                Image(uiImage: DesignsystemAsset.ImageAssets.iconHomePressed.image)
            case .homeDisabled:
                Image(uiImage: DesignsystemAsset.ImageAssets.iconHomeDisabled.image)
            case .myEnabled:
                Image(uiImage: DesignsystemAsset.ImageAssets.iconMyEnabled.image)
            case .myPressed:
                Image(uiImage: DesignsystemAsset.ImageAssets.iconMyPressed.image)
            case .myDisabled:
                Image(uiImage: DesignsystemAsset.ImageAssets.iconMyDisabled.image)
            case .searchEnabled:
                Image(uiImage: DesignsystemAsset.ImageAssets.iconSearchEnabled.image)
            case .searchPressed:
                Image(uiImage: DesignsystemAsset.ImageAssets.iconSearchPressed.image)
            case .searchDisabled:
                Image(uiImage: DesignsystemAsset.ImageAssets.iconSearchDisabled.image)
            case .playEnabled:
                Image(uiImage: DesignsystemAsset.ImageAssets.iconPlayEnabled.image)
            case .playPressed:
                Image(uiImage: DesignsystemAsset.ImageAssets.iconPlayPressed.image)
            case .livithLogo:
                Image(uiImage: DesignsystemAsset.ImageAssets.imageLivithLogo.image)
            case .livithEmpty:
                Image(uiImage: DesignsystemAsset.ImageAssets.imageLivithEmpty.image)
            case .splash:
                Image(uiImage: DesignsystemAsset.ImageAssets.imageSplash.image)
            case .cultureCommon:
                Image(uiImage: DesignsystemAsset.ImageAssets.iconCultureCommon.image)
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
