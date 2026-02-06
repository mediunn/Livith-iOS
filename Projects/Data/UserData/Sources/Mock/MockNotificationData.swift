//
//  MockNotificationData.swift
//  UserData
//
//  Created by Youjin Lee on 2/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

#if DEBUG
enum MockNotificationData {
    static let notifications: [NotificationItem] = generateMockNotifications()

    private static func generateMockNotifications() -> [NotificationItem] {
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
            NotificationItem(
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

    static func getPage(cursor: Int?, size: Int) -> [NotificationItem] {
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
