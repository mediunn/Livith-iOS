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
        return getPage(cursor: cursor, size: size)
    }
}

// MARK: - Mock Notification Data

private extension MockUserRepository {
    static let mockNotifications: [NotificationItem] = generateMockNotifications()

    static func generateMockNotifications() -> [NotificationItem] {
        let titles = [
            "추천 콘서트",
            "예매 일정",
            "콘서트 정보 업데이트",
            "선호 아티스트 공연",
            "혜택 알림"
        ]

        let contents = [
            "좋아하는 아티스트의 내한 공연 소식이 도착했어요!",
            "관심 콘서트로 선택한 공연, 내일 예매가 시작되어요!",
            "관심 콘서트의 공연 정보가 업데이트되었어요.",
            "선호 아티스트의 새로운 공연이 등록되었어요!",
            "라이빗에서 준비한 특별한 혜택을 확인해보세요."
        ]

        let types: [NotificationType] = [
            .interestConcert,
            .ticket1D,
            .concertInfo,
            .recommendation,
            .benefit
        ]

        return (1...30).map { index in
            let typeIndex = index % types.count
            return NotificationItem(
                id: 1000 - index,
                type: types[typeIndex],
                title: titles[typeIndex],
                content: contents[typeIndex],
                targetID: 1600,
                isRead: index > 5,
                createdAt: "2026.02.\(String(format: "%02d", max(1, 6 - (index / 5)))) \(String(format: "%02d", 10 + (index % 12))):\(String(format: "%02d", (index * 7) % 60))"
            )
        }
    }

    func getPage(cursor: Int?, size: Int) -> [NotificationItem] {
        let notifications = Self.mockNotifications
        let startIndex: Int
        if let cursor {
            guard let index = notifications.firstIndex(where: { $0.id == cursor }) else {
                return []
            }
            startIndex = index + 1
        } else {
            startIndex = 0
        }

        let endIndex = min(startIndex + size, notifications.count)
        guard startIndex < endIndex else { return [] }

        return Array(notifications[startIndex..<endIndex])
    }
}
#endif
