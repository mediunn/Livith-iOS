//
//  Image+.swift
//  DesignSystem
//
//  Created by YOUJIM on 4/15/25.
//  Copyright © 2025 Youjin Lee. All rights reserved.
//

import SwiftUI

public extension Image {
    enum LivithIcon {
        case apple
        case backLineDefault, backLinePressed
        case calendarLine
        case cautionFill
        case cautionTriangleBig, cautionTriangleSmall
        case change
        case checkRed, checkYellow
        case closeLineSmall
        case deleteFillDefault, deleteFillPressed
        case down1_5LineSmall, downLineSmall
        case upLineSmall
        case durationLine
        case earth
        case genreLine
        case help
        case homeDisabled, homeEnabled, homePressed
        case kakao
        case linkBlackFill, linkGrayFill
        case locationLine
        case myDisabled, myEnabled, myPressed
        case playFillDefault, playFillPressed
        case plusFillBig, plusLine, plusLineSmall
        case profile, profileBig
        case rightLineDefault, rightLinePressed, rightLineSmall
        case searchLineDefault, searchLinePressed, searchLineVariant2
        case settingLine
        case ticketDisabled, ticketEnabled, ticketPressed
        case trash

        public var image: Image {
            switch self {
            case .apple:
                DesignSystemAsset.ImageAssets.icnApple.swiftUIImage
            case .backLineDefault:
                DesignSystemAsset.ImageAssets.icnBackLineDefault.swiftUIImage
            case .backLinePressed:
                DesignSystemAsset.ImageAssets.icnBackLinePressed.swiftUIImage
            case .calendarLine:
                DesignSystemAsset.ImageAssets.icnCalendarLine.swiftUIImage
            case .cautionFill:
                DesignSystemAsset.ImageAssets.icnCautionFill.swiftUIImage
            case .cautionTriangleBig:
                DesignSystemAsset.ImageAssets.icnCautionTriangleBig.swiftUIImage
            case .cautionTriangleSmall:
                DesignSystemAsset.ImageAssets.icnCautionTriangleSmall.swiftUIImage
            case .change:
                DesignSystemAsset.ImageAssets.icnChange.swiftUIImage
            case .checkRed:
                DesignSystemAsset.ImageAssets.icnCheckRed.swiftUIImage
            case .checkYellow:
                DesignSystemAsset.ImageAssets.icnCheckYellow.swiftUIImage
            case .closeLineSmall:
                DesignSystemAsset.ImageAssets.icnCloseLineSmall.swiftUIImage
            case .deleteFillDefault:
                DesignSystemAsset.ImageAssets.icnDeleteFillDefault.swiftUIImage
            case .deleteFillPressed:
                DesignSystemAsset.ImageAssets.icnDeleteFillPressed.swiftUIImage
            case .down1_5LineSmall:
                DesignSystemAsset.ImageAssets.icnDown15LineSmall.swiftUIImage
            case .downLineSmall:
                DesignSystemAsset.ImageAssets.icnDownLineSmall.swiftUIImage
            case .durationLine:
                DesignSystemAsset.ImageAssets.icnDurationLine.swiftUIImage
            case .earth:
                DesignSystemAsset.ImageAssets.icnEarth.swiftUIImage
            case .genreLine:
                DesignSystemAsset.ImageAssets.icnGenreLine.swiftUIImage
            case .help:
                DesignSystemAsset.ImageAssets.icnHelp.swiftUIImage
            case .homeDisabled:
                DesignSystemAsset.ImageAssets.icnHomeDisabled.swiftUIImage
            case .homeEnabled:
                DesignSystemAsset.ImageAssets.icnHomeEnabled.swiftUIImage
            case .homePressed:
                DesignSystemAsset.ImageAssets.icnHomePressed.swiftUIImage
            case .kakao:
                DesignSystemAsset.ImageAssets.icnKakao.swiftUIImage
            case .linkBlackFill:
                DesignSystemAsset.ImageAssets.icnLinkBlackFill.swiftUIImage
            case .linkGrayFill:
                DesignSystemAsset.ImageAssets.icnLinkGrayFill.swiftUIImage
            case .locationLine:
                DesignSystemAsset.ImageAssets.icnLocationLine.swiftUIImage
            case .myDisabled:
                DesignSystemAsset.ImageAssets.icnMyDisabled.swiftUIImage
            case .myEnabled:
                DesignSystemAsset.ImageAssets.icnMyEnabled.swiftUIImage
            case .myPressed:
                DesignSystemAsset.ImageAssets.icnMyPressed.swiftUIImage
            case .playFillDefault:
                DesignSystemAsset.ImageAssets.icnPlayFillDefault.swiftUIImage
            case .playFillPressed:
                DesignSystemAsset.ImageAssets.icnPlayFillPressed.swiftUIImage
            case .plusFillBig:
                DesignSystemAsset.ImageAssets.icnPlusFillBig.swiftUIImage
            case .plusLine:
                DesignSystemAsset.ImageAssets.icnPlusLine.swiftUIImage
            case .plusLineSmall:
                DesignSystemAsset.ImageAssets.icnPlusLineSmall.swiftUIImage
            case .profile:
                DesignSystemAsset.ImageAssets.icnProfile.swiftUIImage
            case .profileBig:
                DesignSystemAsset.ImageAssets.icnProfileBig.swiftUIImage
            case .rightLineDefault:
                DesignSystemAsset.ImageAssets.icnRightLineDefault.swiftUIImage
            case .rightLinePressed:
                DesignSystemAsset.ImageAssets.icnRightLinePressed.swiftUIImage
            case .rightLineSmall:
                DesignSystemAsset.ImageAssets.icnRightLineSmall.swiftUIImage
            case .searchLineDefault:
                DesignSystemAsset.ImageAssets.icnSearchLineDefault.swiftUIImage
            case .searchLinePressed:
                DesignSystemAsset.ImageAssets.icnSearchLinePressed.swiftUIImage
            case .searchLineVariant2:
                DesignSystemAsset.ImageAssets.icnSearchLineVariant2.swiftUIImage
            case .settingLine:
                DesignSystemAsset.ImageAssets.icnSettingLine.swiftUIImage
            case .ticketDisabled:
                DesignSystemAsset.ImageAssets.icnTicketDisabled.swiftUIImage
            case .ticketEnabled:
                DesignSystemAsset.ImageAssets.icnTicketEnabled.swiftUIImage
            case .ticketPressed:
                DesignSystemAsset.ImageAssets.icnTicketPressed.swiftUIImage
            case .trash:
                DesignSystemAsset.ImageAssets.icnTrash.swiftUIImage
            case .upLineSmall:
                DesignSystemAsset.ImageAssets.icnLineSmallUp.swiftUIImage
            }
        }
    }
    
    enum LivithImage {
        case livithLogo, livithEmpty
        case splash
        
        public var image: Image {
            switch self {
            case .livithLogo:
                DesignSystemAsset.ImageAssets.imageLivithLogo.swiftUIImage
            case .livithEmpty:
                DesignSystemAsset.ImageAssets.imageLivithEmpty.swiftUIImage
            case .splash:
                DesignSystemAsset.ImageAssets.imageSplash.swiftUIImage
            }
        }
    }
    
    // MARK: - livithIcon

    /// LivithIcon 열거형을 통해 앱의 아이콘 에셋에 접근합니다.
    ///
    /// 사용 예시:
    /// ```swift
    /// Image.livithIcon(.apple)
    ///     .resizable()
    ///     .frame(width: 24, height: 24)
    /// ```
    /// - Parameter icon: LivithIcon 열거형 케이스
    /// - Returns: 해당 아이콘에 맞는 Image 뷰
    static func livithIcon(_ icon: LivithIcon) -> Image {
        return icon.image
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
