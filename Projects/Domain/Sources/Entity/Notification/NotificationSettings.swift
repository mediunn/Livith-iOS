//
//  NotificationSettings.swift
//  Domain
//
//  Created by Youjin Lee on 2/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct NotificationSettings {
    public let benefitAlert: Bool
    public let nightAlert: Bool
    public let ticketAlert: Bool
    public let infoAlert: Bool
    public let interestAlert: Bool
    public let recommendAlert: Bool

    public init(
        benefitAlert: Bool,
        nightAlert: Bool,
        ticketAlert: Bool,
        infoAlert: Bool,
        interestAlert: Bool,
        recommendAlert: Bool
    ) {
        self.benefitAlert = benefitAlert
        self.nightAlert = nightAlert
        self.ticketAlert = ticketAlert
        self.infoAlert = infoAlert
        self.interestAlert = interestAlert
        self.recommendAlert = recommendAlert
    }
}
