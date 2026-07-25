//
//  NotificationMapperTests.swift
//  NotificationDataTests
//
//  Created by Youjin Lee on 7/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

import LivithNetworking
import Domain
@testable import NotificationData

@Suite("알림 매퍼 테스트")
struct NotificationMapperTests {
    @Test("정의되지 않은 알림 타입은 크래시 없이 unknown으로 매핑해야 한다")
    func 정의되지_않은_알림_타입은_크래시_없이_unknown으로_매핑해야_한다() throws {
        // Given
        let sut = NotificationMapper()
        let dto = try notificationListItemDTO(type: "SOME_FUTURE_TYPE")

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result.type == .unknown)
    }

    @Test(
        "신규 알림 타입 rawValue를 대응 케이스로 매핑해야 한다",
        arguments: [
            ("PRE_TICKETING_10MIN", NotificationType.preTicketing10M),
            ("GENERAL_TICKETING_10MIN", NotificationType.generalTicketing10M),
            ("ADD_TICKETING_10MIN", NotificationType.addTicketing10M),
            ("ADD_TICKETING_30MIN", NotificationType.addTicketing30M),
            ("ADD_TICKETING_1D", NotificationType.addTicketing1D),
            ("USER_INTEREST_CONCERT", NotificationType.userInterestConcert)
        ]
    )
    func 신규_알림_타입_rawValue를_대응_케이스로_매핑해야_한다(
        rawValue: String,
        expected: NotificationType
    ) throws {
        // Given
        let sut = NotificationMapper()
        let dto = try notificationListItemDTO(type: rawValue)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result.type == expected)
    }

    @Test("FetchNotificationList의 모든 필드를 NotificationItem으로 변환해야 한다")
    func fetchNotificationList의_모든_필드를_NotificationItem으로_변환해야_한다() throws {
        // Given
        let sut = NotificationMapper()
        let dto = try notificationListItemDTO(type: "INTEREST_CONCERT")

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result.id == 123)
        #expect(result.type == .interestConcert)
        #expect(result.title == "추천 콘서트")
        #expect(result.content == "좋아하는 아티스트의 내한 공연 소식이 도착했어요!")
        #expect(result.targetID == 55)
        #expect(result.isRead == false)
    }
}

// MARK: - Helper

private extension NotificationMapperTests {
    func notificationListItemDTO(type: String) throws -> DTO.Response.FetchNotificationList {
        let json = """
        {
            "id": 123,
            "type": "\(type)",
            "title": "추천 콘서트",
            "content": "좋아하는 아티스트의 내한 공연 소식이 도착했어요!",
            "targetId": "55",
            "isRead": false,
            "createdAt": "2026.01.20 14:30"
        }
        """.data(using: .utf8)!
        return try JSONDecoder().decode(DTO.Response.FetchNotificationList.self, from: json)
    }
}
