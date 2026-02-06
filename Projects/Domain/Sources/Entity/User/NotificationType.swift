//
//  NotificationType.swift
//  Domain
//
//  Created by Youjin Lee on 2/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum NotificationType: String {
    case interestConcert = "INTEREST_CONCERT"
    case ticket1D = "TICKET_1D"
    case ticket3D = "TICKET_3D"
    case ticket7D = "TICKET_7D"
    case concertInfo = "CONCERT_INFO"
    case recommendation = "RECOMMENDATION"
    case benefit = "BENEFIT"
    case unknown

    public init(rawValue: String) {
        switch rawValue {
        case "INTEREST_CONCERT": self = .interestConcert
        case "TICKET_1D": self = .ticket1D
        case "TICKET_3D": self = .ticket3D
        case "TICKET_7D": self = .ticket7D
        case "CONCERT_INFO": self = .concertInfo
        case "RECOMMENDATION": self = .recommendation
        case "BENEFIT": self = .benefit
        default: self = .unknown
        }
    }
}
