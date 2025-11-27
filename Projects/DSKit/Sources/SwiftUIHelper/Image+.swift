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
        case checkboxFillDefault, checkboxFillEnabled
        case checkboxLineDefault, checkboxLineEnabled
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
                DSKitAsset.ImageAssets.icnApple.swiftUIImage
            case .backLineDefault:
                DSKitAsset.ImageAssets.icnBackLineDefault.swiftUIImage
            case .backLinePressed:
                DSKitAsset.ImageAssets.icnBackLinePressed.swiftUIImage
            case .calendarLine:
                DSKitAsset.ImageAssets.icnCalendarLine.swiftUIImage
            case .cautionFill:
                DSKitAsset.ImageAssets.icnCautionFill.swiftUIImage
            case .cautionTriangleBig:
                DSKitAsset.ImageAssets.icnCautionTriangleBig.swiftUIImage
            case .cautionTriangleSmall:
                DSKitAsset.ImageAssets.icnCautionTriangleSmall.swiftUIImage
            case .change:
                DSKitAsset.ImageAssets.icnChange.swiftUIImage
            case .checkRed:
                DSKitAsset.ImageAssets.icnCheckRed.swiftUIImage
            case .checkYellow:
                DSKitAsset.ImageAssets.icnCheckYellow.swiftUIImage
            case .checkboxFillDefault:
                DSKitAsset.ImageAssets.icnCheckboxFillDefault.swiftUIImage
            case .checkboxFillEnabled:
                DSKitAsset.ImageAssets.icnCheckboxFillEnabled.swiftUIImage
            case .checkboxLineDefault:
                DSKitAsset.ImageAssets.icnCheckboxLineDefault.swiftUIImage
            case .checkboxLineEnabled:
                DSKitAsset.ImageAssets.icnCheckboxLineEnabled.swiftUIImage
            case .closeLineSmall:
                DSKitAsset.ImageAssets.icnCloseLineSmall.swiftUIImage
            case .deleteFillDefault:
                DSKitAsset.ImageAssets.icnDeleteFillDefault.swiftUIImage
            case .deleteFillPressed:
                DSKitAsset.ImageAssets.icnDeleteFillPressed.swiftUIImage
            case .down1_5LineSmall:
                DSKitAsset.ImageAssets.icnDown15LineSmall.swiftUIImage
            case .downLineSmall:
                DSKitAsset.ImageAssets.icnDownLineSmall.swiftUIImage
            case .durationLine:
                DSKitAsset.ImageAssets.icnDurationLine.swiftUIImage
            case .earth:
                DSKitAsset.ImageAssets.icnEarth.swiftUIImage
            case .genreLine:
                DSKitAsset.ImageAssets.icnGenreLine.swiftUIImage
            case .help:
                DSKitAsset.ImageAssets.icnHelp.swiftUIImage
            case .homeDisabled:
                DSKitAsset.ImageAssets.icnHomeDisabled.swiftUIImage
            case .homeEnabled:
                DSKitAsset.ImageAssets.icnHomeEnabled.swiftUIImage
            case .homePressed:
                DSKitAsset.ImageAssets.icnHomePressed.swiftUIImage
            case .kakao:
                DSKitAsset.ImageAssets.icnKakao.swiftUIImage
            case .linkBlackFill:
                DSKitAsset.ImageAssets.icnLinkBlackFill.swiftUIImage
            case .linkGrayFill:
                DSKitAsset.ImageAssets.icnLinkGrayFill.swiftUIImage
            case .locationLine:
                DSKitAsset.ImageAssets.icnLocationLine.swiftUIImage
            case .myDisabled:
                DSKitAsset.ImageAssets.icnMyDisabled.swiftUIImage
            case .myEnabled:
                DSKitAsset.ImageAssets.icnMyEnabled.swiftUIImage
            case .myPressed:
                DSKitAsset.ImageAssets.icnMyPressed.swiftUIImage
            case .playFillDefault:
                DSKitAsset.ImageAssets.icnPlayFillDefault.swiftUIImage
            case .playFillPressed:
                DSKitAsset.ImageAssets.icnPlayFillPressed.swiftUIImage
            case .plusFillBig:
                DSKitAsset.ImageAssets.icnPlusFillBig.swiftUIImage
            case .plusLine:
                DSKitAsset.ImageAssets.icnPlusLine.swiftUIImage
            case .plusLineSmall:
                DSKitAsset.ImageAssets.icnPlusLineSmall.swiftUIImage
            case .profile:
                DSKitAsset.ImageAssets.icnProfile.swiftUIImage
            case .profileBig:
                DSKitAsset.ImageAssets.icnProfileBig.swiftUIImage
            case .rightLineDefault:
                DSKitAsset.ImageAssets.icnRightLineDefault.swiftUIImage
            case .rightLinePressed:
                DSKitAsset.ImageAssets.icnRightLinePressed.swiftUIImage
            case .rightLineSmall:
                DSKitAsset.ImageAssets.icnRightLineSmall.swiftUIImage
            case .searchLineDefault:
                DSKitAsset.ImageAssets.icnSearchLineDefault.swiftUIImage
            case .searchLinePressed:
                DSKitAsset.ImageAssets.icnSearchLinePressed.swiftUIImage
            case .searchLineVariant2:
                DSKitAsset.ImageAssets.icnSearchLineVariant2.swiftUIImage
            case .settingLine:
                DSKitAsset.ImageAssets.icnSettingLine.swiftUIImage
            case .ticketDisabled:
                DSKitAsset.ImageAssets.icnTicketDisabled.swiftUIImage
            case .ticketEnabled:
                DSKitAsset.ImageAssets.icnTicketEnabled.swiftUIImage
            case .ticketPressed:
                DSKitAsset.ImageAssets.icnTicketPressed.swiftUIImage
            case .trash:
                DSKitAsset.ImageAssets.icnTrash.swiftUIImage
            case .upLineSmall:
                DSKitAsset.ImageAssets.icnLineSmallUp.swiftUIImage
            }
        }
    }
    
    enum LivithImage {
        case livithLogo, livithEmpty
        case splash
        
        public var image: Image {
            switch self {
            case .livithLogo:
                DSKitAsset.ImageAssets.imageLivithLogo.swiftUIImage
            case .livithEmpty:
                DSKitAsset.ImageAssets.imageLivithEmpty.swiftUIImage
            case .splash:
                DSKitAsset.ImageAssets.imageSplash.swiftUIImage
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
