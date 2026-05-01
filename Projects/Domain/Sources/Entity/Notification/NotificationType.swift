//
//  NotificationType.swift
//  Domain
//
//  Created by Youjin Lee on 2/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum NotificationType: String {
    case preTicketingOpen = "PRE_TICKETING_OPEN"
    case generalTicketingOpen = "GENERAL_TICKETING_OPEN"
    case preTicketing1D = "PRE_TICKETING_1D"
    case preTicketing30M = "PRE_TICKETING_30M"
    case generalTicketing1D = "GENERAL_TICKETING_1D"
    case generalTicketing30M = "GENERAL_TICKETING_30M"
    case interestConcert = "INTEREST_CONCERT"
    case concertInfoUpdateSetlist = "CONCERT_INFO_UPDATE_SETLIST"
    case concertInfoUpdateMD = "CONCERT_INFO_UPDATE_MD"
    case concertInfoUpdateDetail = "CONCERT_INFO_UPDATE_DETAIL"
    case concertInfoUpdateSchedule = "CONCERT_INFO_UPDATE_SCHEDULE"
    case concertInfoUpdateTicket = "CONCERT_INFO_UPDATE_TICKET"
    case artistConcertOpen = "ARTIST_CONCERT_OPEN"
    case recommend = "RECOMMEND"

    public var isTicketType: Bool {
        switch self {
        case .preTicketingOpen, .generalTicketingOpen,
             .preTicketing1D, .preTicketing30M,
             .generalTicketing1D, .generalTicketing30M:
            return true
        default:
            return false
        }
    }
}
