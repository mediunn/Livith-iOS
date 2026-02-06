//
//  UserMapper.swift
//  Data
//
//  Created by 김진웅 on 2026/01/22.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithFoundation
import LivithNetwork

struct UserMapper {
    func toDomain(from dto: DTO.Response.UpdateUserNickname) -> User {
        User(
            id: dto.id,
            interestConcertID: dto.interestConcertID,
            provider: dto.provider,
            providerID: dto.providerID,
            email: dto.email,
            nickname: dto.nickname,
            authority: UserAuthority(deviceNotification: true, marketingConsent: dto.marketingConsent)
        )
    }

    func toDomain(from dto: DTO.Response.FetchUserInfo) -> User {
        User(
            id: dto.id,
            interestConcertID: dto.interestConcertID,
            provider: dto.provider,
            providerID: dto.providerID,
            email: dto.email,
            nickname: dto.nickname,
            authority: UserAuthority(deviceNotification: true, marketingConsent: dto.marketingConsent)
        )
    }

    func toDomain(from dto: DTO.Response.FetchUserInterestConcert) -> Concert? {
        guard let status = ConcertStatus(rawValue: dto.status),
              let startDate = DateFormatterService.date(from: dto.startDate, type: .dotDate),
              let endDate = DateFormatterService.date(from: dto.endDate, type: .dotDate),
              let posterURL = URL(string: dto.posterURL)
        else {
            return nil
        }

        return Concert(
            id: dto.id,
            title: dto.title,
            artist: dto.artist,
            status: status,
            daysLeft: calculateDaysLeft(from: startDate),
            startDate: startDate,
            endDate: endDate,
            posterURL: posterURL,
            venue: dto.venue,
            ticketSite: dto.ticketSite,
            ticketURL: dto.ticketURL.flatMap { URL(string: $0) },
            introduction: dto.introduction,
            label: dto.label
        )
    }

    func toDomain(from dto: DTO.Response.UpdateUserInterestConcert) -> Concert? {
        guard let status = ConcertStatus(rawValue: dto.status),
              let startDate = DateFormatterService.date(from: dto.startDate, type: .dotDate),
              let endDate = DateFormatterService.date(from: dto.endDate, type: .dotDate),
              let posterURL = URL(string: dto.posterURL)
        else {
            return nil
        }

        let daysLeft = calculateDaysLeft(from: startDate)

        return Concert(
            id: dto.id,
            title: dto.title,
            artist: dto.artist,
            status: status,
            daysLeft: daysLeft,
            startDate: startDate,
            endDate: endDate,
            posterURL: posterURL,
            venue: dto.venue,
            ticketSite: dto.ticketSite,
            ticketURL: dto.ticketURL.flatMap { URL(string: $0) },
            introduction: dto.introduction,
            label: dto.label
        )
    }

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

    func toDomain(from dto: DTO.Response.FetchNotificationList) -> NotificationItem {
        NotificationItem(
            id: dto.id,
            type: NotificationType(rawValue: dto.type),
            title: dto.title,
            content: dto.content,
            targetID: dto.targetID.flatMap { Int($0) },
            isRead: dto.isRead,
            createdAt: dto.createdAt
        )
    }

    private func calculateDaysLeft(from date: Date) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: today, to: targetDate).day ?? 0
    }
}
