//
//  MockUserRepository.swift
//  UserData
//
//  Created by Youjin Lee on 2/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

#if DEBUG
public struct MockUserRepository: UserRepository {
    public init() {}

    public func updateNickname(_ nickname: String) async throws(UserError) {}

    public func fetchUser() async throws(UserError) -> User {
        User(
            id: 1,
            provider: "kakao",
            providerID: "12345",
            email: "test@test.com",
            nickname: "테스트유저",
            authority: UserAuthority(deviceNotification: true, marketingConsent: true)
        )
    }

    public func fetchInterestedConcert() async throws(UserError) -> Concert? {
        nil
    }

    @discardableResult
    public func updateInterestedConcert(_ concertID: Int) async throws(UserError) -> Concert {
        throw UserError.unknown
    }

    public func deleteInterestedConcert() async throws(UserError) {}

    public func updateNotificationConsent(
        field: NotificationConsentField,
        isAgreed: Bool
    ) async throws(UserError) -> NotificationConsentResult {
        NotificationConsentResult(
            sender: "라이빗",
            agreedAt: "2026.02.06 12:00",
            message: "알림 설정이 변경되었습니다."
        )
    }

    public func updateMarketingConsent() async throws(UserError) -> NotificationConsentResult {
        NotificationConsentResult(
            sender: "라이빗",
            agreedAt: "2026.02.06 12:00",
            message: "마케팅 수신 동의가 완료되었습니다."
        )
    }

    public func fetchNotificationSettings() async throws(UserError) -> NotificationSettings {
        NotificationSettings(
            benefitAlert: true,
            nightAlert: false,
            ticketAlert: true,
            infoAlert: true,
            interestAlert: true,
            recommendAlert: true
        )
    }

    public func fetchNotificationList(cursor: Int?, size: Int) async throws(UserError) -> [NotificationItem] {
        try? await Task.sleep(for: .milliseconds(300))
        return MockNotificationData.getPage(cursor: cursor, size: size)
    }
}
#endif
