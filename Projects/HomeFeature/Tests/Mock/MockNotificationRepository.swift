//
//  MockNotificationRepository.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 2/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

final class MockNotificationRepository: NotificationRepository {
    var unreadNotificationCountStub: Int = 0
    var notificationListStub: [NotificationItem] = []
    var entryAlertsStub: [InterestEntryAlert] = []
    var errorStub: NotificationError?
    var markAllNotificationsAsReadErrorStub: NotificationError?
    var fetchEntryAlertsErrorStub: NotificationError?

    var fetchUnreadNotificationCountCallCount: Int = 0
    var markAllNotificationsAsReadCallCount: Int = 0
    var fetchEntryAlertsCallCount: Int = 0

    func fetchNotificationList(cursor: Int?, size: Int) async throws(NotificationError) -> [NotificationItem] {
        if let error = errorStub {
            throw error
        }
        return notificationListStub
    }

    func markNotificationAsRead(id: Int) async throws(NotificationError) {
        if let error = errorStub {
            throw error
        }
    }

    func markAllNotificationsAsRead() async throws(NotificationError) {
        markAllNotificationsAsReadCallCount += 1
        if let error = markAllNotificationsAsReadErrorStub {
            throw error
        }
    }

    func fetchEntryAlerts() async throws(NotificationError) -> [InterestEntryAlert] {
        fetchEntryAlertsCallCount += 1
        if let error = fetchEntryAlertsErrorStub {
            throw error
        }
        return entryAlertsStub
    }

    func fetchUnreadNotificationCount() async throws(NotificationError) -> Int {
        fetchUnreadNotificationCountCallCount += 1
        if let error = errorStub {
            throw error
        }
        return unreadNotificationCountStub
    }

    func updateNotificationConsent(
        field: NotificationConsentField,
        isAgreed: Bool
    ) async throws(NotificationError) -> NotificationConsentResult {
        if let error = errorStub {
            throw error
        }
        return NotificationConsentResult(sender: "mock", agreedAt: "mock", message: "mock")
    }

    func updateMarketingConsent() async throws(NotificationError) -> NotificationConsentResult {
        if let error = errorStub {
            throw error
        }
        return NotificationConsentResult(sender: "mock", agreedAt: "mock", message: "mock")
    }

    func fetchNotificationSettings() async throws(NotificationError) -> NotificationSettings {
        if let error = errorStub {
            throw error
        }
        return NotificationSettings(
            benefitAlert: false,
            nightAlert: false,
            ticketAlert: false,
            infoAlert: false,
            interestAlert: false,
            recommendAlert: false
        )
    }

    func registerFCMToken(_ token: String) async throws(NotificationError) {
        if let error = errorStub {
            throw error
        }
    }

    func deleteFCMToken(_ token: String) async throws(NotificationError) {
        if let error = errorStub {
            throw error
        }
    }
}
