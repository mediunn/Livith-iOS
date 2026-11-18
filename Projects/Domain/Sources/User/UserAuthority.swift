//
//  UserAuthority.swift
//  Domain
//
//  Created by Youjin Lee on 2/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct UserAuthority: Hashable, Codable {
    public let deviceNotification: Bool
    public var marketingConsent: Bool
    public var benefitNotification: Bool
    public var nightNotification: Bool
    public var ticketSchedule: Bool
    public var concertInfoUpdate: Bool
    public var favoriteArtistConcert: Bool
    public var preferenceBasedConcert: Bool

    public init(
        deviceNotification: Bool,
        marketingConsent: Bool,
        benefitNotification: Bool? = nil,
        nightNotification: Bool = false,
        ticketSchedule: Bool = true,
        concertInfoUpdate: Bool = true,
        favoriteArtistConcert: Bool = true,
        preferenceBasedConcert: Bool = true
    ) {
        self.deviceNotification = deviceNotification
        self.marketingConsent = marketingConsent
        self.benefitNotification = benefitNotification ?? marketingConsent
        self.nightNotification = nightNotification
        self.ticketSchedule = ticketSchedule
        self.concertInfoUpdate = concertInfoUpdate
        self.favoriteArtistConcert = favoriteArtistConcert
        self.preferenceBasedConcert = preferenceBasedConcert
    }
}
