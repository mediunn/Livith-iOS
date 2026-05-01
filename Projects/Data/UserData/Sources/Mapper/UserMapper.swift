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

    func toDomain(from dto: DTO.Response.FetchUserInterestConcert) -> InterestConcertPage {
        InterestConcertPage(
            concertList: dto.data.compactMap(toInterestConcert),
            nextCursor: dto.cursor.flatMap(toCursor)
        )
    }

    func toDomain(from dto: DTO.Response.UpdateUserInterestConcert) -> Concert? {
        guard let status = ConcertStatus(rawValue: dto.status),
              let startDate = DateFormatterService.date(from: dto.startDate, type: .dotDate),
              let endDate = DateFormatterService.date(from: dto.endDate, type: .dotDate),
              let posterURL = parseURL(dto.posterURL)
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
            ticketURL: parseURL(dto.ticketURL),
            introduction: dto.introduction,
            label: dto.label
        )
    }

    func toDomain(from dto: DTO.Response.UpdateUserInterestConcertList) -> [Concert] {
        dto.compactMap(toConcert)
    }
}

private extension UserMapper {
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

    func toCursor(from dto: DTO.Response.FetchUserInterestConcert.Cursor) -> InterestConcertPageCursor? {
        guard let dateString = dto.date,
              let id = dto.id,
              let date = DateFormatterService.date(from: dateString, type: .dotDate)
        else {
            return nil
        }

        return InterestConcertPageCursor(date: date, id: id)
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
