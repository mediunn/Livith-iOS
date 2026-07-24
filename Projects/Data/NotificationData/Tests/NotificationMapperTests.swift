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
    @Test("EntryAlerts 응답을 InterestEntryAlert 목록으로 변환해야 한다")
    func entryAlerts_응답을_InterestEntryAlert_목록으로_변환해야_한다() throws {
        // Given
        let sut = NotificationMapper()
        let json = """
        {
            "items": [
                {
                    "kind": "AUTO_REMOVED_COMPLETED",
                    "title": "자동 정리된 공연 2",
                    "content": "오크 록 내한 공연 외 1건이 자동 정리 됐어요"
                },
                {
                    "kind": "AUTO_REMOVED_CANCELED",
                    "title": "취소된 공연 1",
                    "content": "오크 록 내한 공연이 취소되어 자동 정리 됐어요"
                },
                {
                    "kind": "REQUEST_REGISTERED",
                    "title": "natori ONE-MAN LIVE...콘서트",
                    "content": "나의 관심 콘서트에 추가됐어요",
                    "concertId": 55
                },
                {
                    "kind": "REQUEST_FAILED",
                    "title": "natori ONE-MAN LIVE...콘서트",
                    "content": "정확한 정보가 부족하여 추가되지 않았어요"
                }
            ]
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchEntryAlerts.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result.count == 4)
        #expect(result[0].kind == .autoRemovedCompleted)
        #expect(result[0].title == "자동 정리된 공연 2")
        #expect(result[0].content == "오크 록 내한 공연 외 1건이 자동 정리 됐어요")
        #expect(result[0].concertID == nil)
        #expect(result[1].kind == .autoRemovedCanceled)
        #expect(result[2].kind == .requestRegistered)
        #expect(result[2].concertID == 55)
        #expect(result[3].kind == .requestFailed)
        #expect(result[3].concertID == nil)
    }

    @Test("정의되지 않은 EntryAlert kind는 크래시 없이 unknown으로 매핑해야 한다")
    func 정의되지_않은_EntryAlert_kind는_크래시_없이_unknown으로_매핑해야_한다() throws {
        // Given
        let sut = NotificationMapper()
        let json = """
        {
            "items": [
                {
                    "kind": "SOME_FUTURE_KIND",
                    "title": "제목",
                    "content": "내용"
                }
            ]
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchEntryAlerts.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result.count == 1)
        #expect(result[0].kind == .unknown)
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
