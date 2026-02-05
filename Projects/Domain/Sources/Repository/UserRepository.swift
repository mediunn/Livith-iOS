//
//  UserRepository.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

public protocol UserRepository {
    func updateNickname(_ nickname: String) async throws(UserError)
    func fetchUser() async throws(UserError) -> User
    func fetchInterestedConcert() async throws(UserError) -> Concert?
    @discardableResult
    func updateInterestedConcert(_ concertID: Int) async throws(UserError) -> Concert
    func deleteInterestedConcert() async throws(UserError)
    func updateNotificationConsent(
        field: NotificationConsentField,
        isAgreed: Bool
    ) async throws(UserError) -> NotificationConsentResult
    func updateMarketingConsent() async throws(UserError) -> NotificationConsentResult
    func fetchNotificationSettings() async throws(UserError) -> NotificationSettings
}
