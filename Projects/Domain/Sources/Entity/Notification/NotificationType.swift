//
//  NotificationType.swift
//  Domain
//
//  Created by Youjin Lee on 2/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum NotificationType: String {
    case ticket1D = "TICKET_1D"
    case ticket7D = "TICKET_7D"
    case ticketToday = "TICKET_TODAY"
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
        case .ticket1D, .ticket7D, .ticketToday:
            return true
        default:
            return false
        }
    }
}
