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

    public func markNotificationAsRead(id: Int) async throws(UserError) {}
}

// MARK: - Mock Notification Data

private extension MockUserRepository {
    static let mockNotifications: [NotificationItem] = generateMockNotifications()

    static func generateMockNotifications() -> [NotificationItem] {
        let titles = [
            "관심 콘서트 알림",
            "예매 D-1 알림",
            "예매 D-7 알림",
            "오늘 예매 시작",
            "콘서트 정보 업데이트",
            "선호 아티스트 공연 오픈",
            "추천 콘서트"
        ]

        let contents = [
            "관심 콘서트의 새로운 소식이 도착했어요!",
            "관심 콘서트로 선택한 공연, 내일 예매가 시작되어요!",
            "관심 콘서트로 선택한 공연, 일주일 뒤 예매가 시작되어요!",
            "관심 콘서트로 선택한 공연, 오늘 예매가 시작되어요!",
            "관심 콘서트의 공연 정보가 업데이트되었어요.",
            "선호 아티스트의 새로운 공연이 등록되었어요!",
            "좋아하는 아티스트의 내한 공연 소식이 도착했어요!"
        ]

        let types: [NotificationType] = [
            .interestConcert,
            .ticket1D,
            .ticket7D,
            .ticketToday,
            .concertInfoUpdate,
            .artistConcertOpen,
            .recommend
        ]

        return (1...30).map { index in
            let typeIndex = index % types.count
            let createdAt: Date
            if index <= 5 {
                // 24시간 미만: n시간 전
                createdAt = Date().addingTimeInterval(-Double(index) * 3600)
            } else if index <= 15 {
                // 24시간~6일: n일 전
                createdAt = Date().addingTimeInterval(-Double(index - 4) * 86400)
            } else {
                // 7일 이상: 년도.월.일
                createdAt = Date().addingTimeInterval(-Double(index) * 86400)
            }
            return NotificationItem(
                id: 1000 - index,
                type: types[typeIndex],
                title: titles[typeIndex],
                content: contents[typeIndex],
                targetID: 1600,
                isRead: index > 5,
                createdAt: createdAt
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
