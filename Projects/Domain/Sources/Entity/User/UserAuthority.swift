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
    public let marketingConsent: Bool
    public let nightNotification: Bool
    public let ticketSchedule: Bool
    public let concertInfoUpdate: Bool
    public let favoriteArtistConcert: Bool
    public let preferenceBasedConcert: Bool

    public init(
        deviceNotification: Bool,
        marketingConsent: Bool,
        nightNotification: Bool = false,
        ticketSchedule: Bool = true,
        concertInfoUpdate: Bool = true,
        favoriteArtistConcert: Bool = true,
        preferenceBasedConcert: Bool = true
    ) {
        self.deviceNotification = deviceNotification
        self.marketingConsent = marketingConsent
        self.nightNotification = nightNotification
        self.ticketSchedule = ticketSchedule
        self.concertInfoUpdate = concertInfoUpdate
        self.favoriteArtistConcert = favoriteArtistConcert
        self.preferenceBasedConcert = preferenceBasedConcert
    }
}
