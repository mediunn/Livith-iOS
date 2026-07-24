//
//  NotificationRepository.swift
//  Domain
//
//  Created by Youjin Lee on 2/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public protocol NotificationRepository {
    func fetchNotificationList(cursor: Int?, size: Int) async throws(NotificationError) -> [NotificationItem]
    func markNotificationAsRead(id: Int) async throws(NotificationError)
    func markAllNotificationsAsRead() async throws(NotificationError)
    func fetchEntryAlerts() async throws(NotificationError) -> [InterestEntryAlert]
    func fetchUnreadNotificationCount() async throws(NotificationError) -> Int
    func updateNotificationConsent(
        field: NotificationConsentField,
        isAgreed: Bool
    ) async throws(NotificationError) -> NotificationConsentResult
    func updateMarketingConsent() async throws(NotificationError) -> NotificationConsentResult
    func fetchNotificationSettings() async throws(NotificationError) -> NotificationSettings
    func registerFCMToken(_ token: String) async throws(NotificationError)
    func deleteFCMToken(_ token: String) async throws(NotificationError)
}
