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
import LivithNetworking

struct UserMapper {
    func toDomain(from dto: DTO.Response.UpdateUserNickname) -> User {
        User(
            id: dto.id,
            provider: dto.provider,
            providerID: dto.providerID,
            email: dto.email,
            nickname: dto.nickname,
            hasPreferences: false,
            authority: UserAuthority(deviceNotification: true, marketingConsent: dto.marketingConsent)
        )
    }

    func toDomain(from dto: DTO.Response.FetchUserInfo) -> User {
        User(
            id: dto.id,
            provider: dto.provider,
            providerID: dto.providerID,
            email: dto.email,
            nickname: dto.nickname,
            hasPreferences: dto.hasPreferredGenre,
            authority: UserAuthority(deviceNotification: true, marketingConsent: dto.marketingConsent)
        )
    }

    func toDomain(from dto: DTO.Response.FetchUserInterestConcert) -> ListResult<InterestConcert> {
        ListResult(
            items: dto.data.compactMap(toInterestConcert),
            nextToken: dto.cursor.flatMap(toNextToken)
        )
    }

    func toDomain(from dto: DTO.Response.UpdateUserInterestConcert) -> Concert? {
        guard let status = ConcertStatus(rawValue: dto.status) else {
            return nil
        }

        let startDate = dto.startDate.flatMap { DateFormatterService.date(from: $0, type: .dotDate) }
        let daysLeft = dto.daysLeft ?? startDate.map(calculateDaysLeft)

        return Concert(
            id: dto.id,
            title: dto.title,
            artist: dto.artist,
            status: status,
            daysLeft: daysLeft,
            startDate: startDate,
            endDate: dto.endDate.flatMap { DateFormatterService.date(from: $0, type: .dotDate) },
            posterURL: parseURL(dto.posterURL),
            venue: dto.venue,
            ticketSite: dto.ticketSite,
            ticketURL: parseURL(dto.ticketURL),
            introduction: dto.introduction,
            label: dto.label
        )
    }

    func toDomain(from dto: DTO.Response.UpdateUserInterestConcertList) -> [Concert] {
        dto.compactMap(toConcert)
    }

    func toDomain(from dto: DTO.Response.FetchInterestConcertEntryAlerts) -> [InterestConcertEntryAlert] {
        dto.items.compactMap(toInterestConcertEntryAlert)
    }
}

private extension UserMapper {
    func toInterestConcertEntryAlert(
        from dto: DTO.Response.FetchInterestConcertEntryAlerts.AlertItem
    ) -> InterestConcertEntryAlert? {
        guard let kind = toInterestConcertEntryAlertKind(from: dto.kind) else {
            return nil
        }

        return InterestConcertEntryAlert(
            kind: kind,
            title: dto.title,
            content: dto.content,
            concertID: dto.concertID
        )
    }

    func toInterestConcertEntryAlertKind(from rawValue: String) -> InterestConcertEntryAlertKind? {
        switch rawValue {
        case "AUTO_REMOVED_COMPLETED":
            return .autoRemovedCompleted
        case "AUTO_REMOVED_CANCELED":
            return .autoRemovedCanceled
        case "REQUEST_REGISTERED":
            return .requestRegistered
        case "REQUEST_FAILED":
            return .requestFailed
        default:
            return nil
        }
    }

    func calculateDaysLeft(from date: Date) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: today, to: targetDate).day ?? 0
    }

    func toInterestConcert(from dto: DTO.Response.FetchUserInterestConcert.Concert) -> InterestConcert? {
        guard let status = ConcertStatus(rawValue: dto.status) else {
            return nil
        }

        let concert = Concert(
            id: dto.id,
            title: dto.title,
            artist: dto.artist,
            status: status,
            daysLeft: dto.daysLeft,
            startDate: parseDate(dto.startDate, type: .dotDate),
            endDate: parseDate(dto.endDate, type: .dotDate),
            posterURL: parseURL(dto.posterURL),
            venue: dto.venue,
            ticketSite: dto.ticketSite,
            ticketURL: parseURL(dto.ticketURL),
            introduction: dto.introduction,
            label: dto.label
        )
        let ticketingSchedule = InterestConcertTicketingSchedule(
            preSaleDate: parseDate(dto.preSaleDate, type: .iso8601),
            generalSaleDate: parseDate(dto.generalSaleDate, type: .iso8601)
        )
        return InterestConcert(concert: concert, ticketingSchedule: ticketingSchedule)
    }

    func toConcert(from dto: DTO.Response.UpdatedUserInterestConcert) -> Concert? {
        guard let status = ConcertStatus(rawValue: dto.status) else {
            return nil
        }

        return Concert(
            id: dto.id,
            title: dto.title,
            artist: dto.artist,
            status: status,
            daysLeft: dto.daysLeft,
            startDate: parseDate(dto.startDate, type: .dotDate),
            endDate: parseDate(dto.endDate, type: .dotDate),
            posterURL: parseURL(dto.posterURL),
            venue: dto.venue,
            ticketSite: dto.ticketSite,
            ticketURL: parseURL(dto.ticketURL),
            introduction: dto.introduction,
            label: dto.label
        )
    }

    func toNextToken(from dto: DTO.Response.FetchUserInterestConcert.Cursor) -> InterestConcertListNextToken? {
        guard let cursorDate = dto.date,
              let id = dto.id
        else {
            return nil
        }

        return InterestConcertListNextToken(cursorDate: cursorDate, id: id)
    }

    func parseDate(_ dateString: String?, type: DateFormatType) -> Date? {
        guard let dateString else { return nil }

        return DateFormatterService.date(from: dateString, type: type)
    }

    func parseURL(_ urlString: String?) -> URL? {
        guard let urlString,
              let url = URL(string: urlString),
              url.scheme != nil,
              url.host != nil
        else {
            return nil
        }

        return url
    }
}
