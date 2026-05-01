//
//  NotificationType.swift
//  Domain
//
//  Created by Youjin Lee on 2/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum NotificationType: String {
    case preTicketOpen = "PRE_TICKET_OPEN"
    case generalTicketOpen = "GENERAL_TICKET_OPEN"
    case preTicket1D = "PRE_TICKET_1D"
    case preTicket30M = "PRE_TICKET_30M"
    case generalTicket1D = "GENERAL_TICKET_1D"
    case generalTicket30M = "GENERAL_TICKET_30M"
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
        case .preTicketOpen, .generalTicketOpen,
             .preTicket1D, .preTicket30M,
             .generalTicket1D, .generalTicket30M:
            return true
        default:
            return false
        }
    }
}
