//
//  ConcertMapper.swift
//  ConcertData
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import ConcertDomain
import LivithNetwork

struct ConcertMapper {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()

    private static let dotDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    // MARK: - Concert

    func toDomain(from response: DTO.Response.FetchConcertInfo) -> Concert? {
        guard let status = ConcertStatus(rawValue: response.status),
              let posterURL = URL(string: response.posterURL),
              let startDate = Self.dateFormatter.date(from: response.startDate),
              let endDate = Self.dateFormatter.date(from: response.endDate) else {
            return nil
        }

        return Concert(
            id: response.id,
            title: response.title,
            artist: response.artist,
            status: status,
            daysLeft: response.daysLeft,
            startDate: startDate,
            endDate: endDate,
            posterURL: posterURL,
            venue: response.venue,
            ticketSite: response.ticketSite,
            ticketURL: response.ticketURL.flatMap { URL(string: $0) },
            introduction: response.introduction,
            label: response.label
        )
    }

    // MARK: - Schedule

    func toDomain(from response: DTO.Response.FetchConcertSchedule) -> [ConcertSchedule] {
        response.compactMap { schedule in
            guard let scheduledAt = Self.iso8601Formatter.date(from: schedule.scheduledAt) else {
                return nil
            }

            return ConcertSchedule(
                id: schedule.id,
                category: schedule.category,
                scheduledAt: scheduledAt,
                type: ScheduleType(rawValue: schedule.type ?? "") ?? .none
            )
        }
    }

    // MARK: - Culture

    func toDomain(from response: DTO.Response.FetchConcertCultureList) -> [ConcertCulture] {
        response.map { culture in
            ConcertCulture(
                id: culture.id,
                concertID: culture.concertID,
                title: culture.title,
                content: culture.content
            )
        }
    }

    // MARK: - Concert Info

    func toDomain(from response: DTO.Response.FetchConcertInfoList) -> [ConcertInfo] {
        response.map { info in
            ConcertInfo(
                id: info.id,
                imageURL: info.imageURL ?? "",
                title: info.category,
                description: info.content
            )
        }
    }

    // MARK: - Merchandise

    func toDomain(from response: DTO.Response.FetchConcertMerchandiseList) -> [ConcertMerchandise] {
        response.map { merchandise in
            ConcertMerchandise(
                id: merchandise.id,
                name: merchandise.name,
                price: merchandise.price,
                imageURL: merchandise.imageURL
            )
        }
    }

    // MARK: - Setlist

    func toDomain(from response: DTO.Response.FetchConcertSetlistList) -> [ConcertSetlist] {
        response.compactMap { setlist in
            guard let startDate = Self.dotDateFormatter.date(from: setlist.startDate),
                  let endDate = Self.dotDateFormatter.date(from: setlist.endDate),
                  let type = ConcertStatus(rawValue: setlist.type) else {
                return nil
            }

            let status = setlist.status.flatMap { SetlistType(rawValue: $0) } ?? .none

            return ConcertSetlist(
                id: setlist.id,
                title: setlist.title,
                imageURL: setlist.imageURL,
                type: type,
                startDate: startDate,
                endDate: endDate,
                status: status,
                venue: setlist.venue,
                artist: setlist.artist
            )
        }
    }

    // MARK: - Artist

    func toDomain(from response: DTO.Response.FetchConcertArtistInfo) -> Artist {
        Artist(
            id: response.id,
            name: response.artist,
            debutYear: formatDebutYear(response.debutYear),
            category: response.category,
            imageURL: response.imageURL,
            detail: response.detail,
            keywords: response.keywords,
            instagramURL: response.instagramURL
        )
    }

    private func formatDebutYear(_ yearString: String) -> String {
        if let doubleValue = Double(yearString) {
            return String(Int(doubleValue))
        }
        return yearString
    }

    // MARK: - Comment

    func toDomain(from response: DTO.Response.FetchConcertCommentList) -> (comments: [ConcertComment], cursor: (createdAt: String, id: Int)?, totalCount: Int) {
        let comments = response.data.map { comment in
            ConcertComment(
                id: comment.id,
                userID: comment.userID,
                nickname: comment.nickname,
                concertID: comment.concertID,
                content: comment.content,
                createdAt: comment.createdAt
            )
        }

        let cursor = response.cursor.map { ($0.createdAt, $0.id) }

        return (comments, cursor, response.totalCount)
    }

    func toDomain(from response: DTO.Response.CreateConcertComment) -> ConcertComment {
        ConcertComment(
            id: response.id,
            userID: response.userID,
            nickname: response.nickname,
            concertID: response.concertID,
            content: response.content,
            createdAt: response.createdAt
        )
    }

    // MARK: - Setlist Detail

    func toDomain(from response: DTO.Response.FetchConcertSetlist) -> ConcertSetlist? {
        guard let startDate = Self.dotDateFormatter.date(from: response.startDate),
              let endDate = Self.dotDateFormatter.date(from: response.endDate),
              let type = ConcertStatus(rawValue: response.type) else {
            return nil
        }

        let status = response.status.flatMap { SetlistType(rawValue: $0) } ?? .none

        return ConcertSetlist(
            id: response.id,
            title: response.title,
            imageURL: response.imageURL,
            type: type,
            startDate: startDate,
            endDate: endDate,
            status: status,
            venue: response.venue,
            artist: response.artist
        )
    }

    // MARK: - Setlist Song

    func toDomain(from response: DTO.Response.FetchSetlistSongList) -> [SetlistSong] {
        response.map { song in
            SetlistSong(
                id: song.id,
                title: song.title,
                artist: song.artist,
                orderIndex: song.orderIndex
            )
        }
    }
}
