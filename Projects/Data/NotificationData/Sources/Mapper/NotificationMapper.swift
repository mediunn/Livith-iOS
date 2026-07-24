//
//  NotificationMapper.swift
//  NotificationData
//
//  Created by Youjin Lee on 2/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithFoundation
import LivithNetworking

struct NotificationMapper {
    func toDomain(from dto: DTO.Response.FetchNotificationSettings) -> NotificationSettings {
        NotificationSettings(
            benefitAlert: dto.benefitAlert,
            nightAlert: dto.nightAlert,
            ticketAlert: dto.ticketAlert,
            infoAlert: dto.infoAlert,
            interestAlert: dto.interestAlert,
            recommendAlert: dto.recommendAlert
        )
    }

    func toDomain(from dto: DTO.Response.UpdateNotificationConsent) -> NotificationConsentResult {
        NotificationConsentResult(
            sender: dto.sender,
            agreedAt: dto.agreedAt,
            message: dto.message
        )
    }

    func toDomain(from dto: DTO.Response.FetchEntryAlerts) -> [InterestEntryAlert] {
        dto.items.map { item in
            InterestEntryAlert(
                kind: InterestEntryAlert.Kind(rawValue: item.kind) ?? .unknown,
                title: item.title,
                content: item.content,
                concertID: item.concertID
            )
        }
    }

    func toDomain(from dto: DTO.Response.FetchNotificationList) -> NotificationItem {
        let createdAt = DateFormatterService.date(from: dto.createdAt, type: .dotDateTime) ?? Date()
        return NotificationItem(
            id: dto.id,
            type: NotificationType(rawValue: dto.type) ?? .unknown,
            title: dto.title,
            content: dto.content,
            targetID: dto.targetID.flatMap { Int($0) },
            isRead: dto.isRead,
            createdAt: createdAt
        )
    }
}
