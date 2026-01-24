//
//  LivithIcon.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

public extension Image {
    enum LivithIcon: String {
        case apple = "icn_apple"
        case badge = "icn_badge"
        case backLineDefault = "icn_back_line_default"
        case backLinePressed = "icn_back_line_pressed"
        case calendarLine = "icn_calendar_line"
        case cautionFill = "icn_caution_fill"
        case cautionTriangleBig = "icn_caution_triangle_big"
        case cautionTriangleSmall = "icn_caution_triangle_small"
        case change = "icn_change"
        case checkRed = "icn_check_red"
        case checkYellow = "icn_check_yellow"
        case checkboxFillDefault = "icn_checkbox_fill_default"
        case checkboxFillEnabled = "icn_checkbox_fill_enabled"
        case checkboxLineDefault = "icn_checkbox_line_default"
        case checkboxLineEnabled = "icn_checkbox_line_enabled"
        case closeLineSmall = "icn_close_line_small"
        case deleteFillDefault = "icn_delete_fill_default"
        case deleteFillPressed = "icn_delete_fill_pressed"
        case down1_5LineSmall = "icn_down_1_5_line_small"
        case downLineSmall = "icn_down_line_small"
        case upLineSmall = "icn_line_small_up"
        case durationLine = "icn_duration_line"
        case earth = "icn_earth"
        case genreLine = "icn_genre_line"
        case help = "icn_help"
        case homeDisabled = "icn_home_disabled"
        case homeEnabled = "icn_home_enabled"
        case homePressed = "icn_home_pressed"
        case kakao = "icn_kakao"
        case linkBlackFill = "icn_link_black_fill"
        case linkGrayFill = "icn_link_gray_fill"
        case locationLine = "icn_location_line"
        case myDisabled = "icn_my_disabled"
        case myEnabled = "icn_my_enabled"
        case myPressed = "icn_my_pressed"
        case playFillDefault = "icn_play_fill_default"
        case playFillPressed = "icn_play_fill_pressed"
        case plusFillBig = "icn_plus_fill_big"
        case plusLine = "icn_plus_line"
        case plusLineSmall = "icn_plus_line_small"
        case profile = "icn_profile"
        case profileBig = "icn_profile_big"
        case rightLineDefault = "icn_right_line_default"
        case rightLinePressed = "icn_right_line_pressed"
        case rightLineSmall = "icn_right_line_small"
        case searchLineDefault = "icn_search_line_default"
        case searchLinePressed = "icn_search_line_pressed"
        case searchLineVariant2 = "icn_search_line_variant2"
        case settingLine = "icn_setting_line"
        case ticketDisabled = "icn_ticket_disabled"
        case ticketEnabled = "icn_ticket_enabled"
        case ticketPressed = "icn_ticket_pressed"
        case trash = "icn_trash"

        public var image: Image {
            Image(rawValue, bundle: .livithDesignSystem)
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
}
