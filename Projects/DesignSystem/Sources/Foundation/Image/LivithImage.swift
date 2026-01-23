//
//  LivithImage.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

public extension Image {
    enum LivithImage: String {
        case concertCardEmpty = "image_concert_card_empty"
        case instagram = "image_instagram"
        case livithLogo = "image_livith_logo"
        case livithEmpty = "image_livith_empty"
        case splash = "image_splash"
        case feedback = "btn_feedback"
        case polygon = "image_polygon"
        case welcome = "image_welcome"
        case interestConcertComplete = "image_interest_concert_complete"
        case youtubeEmpty = "image_youtube_empty"

        public var image: Image {
            Image(rawValue, bundle: .livithDesignSystem)
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
