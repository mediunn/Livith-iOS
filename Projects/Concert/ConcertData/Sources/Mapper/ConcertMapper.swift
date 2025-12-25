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

    // MARK: - Concert

    func toDomain(from response: DTO.Response.FetchConcertInfo) -> Concert? {
        guard let status = ConcertStatus(rawValue: response.status),
              let posterURL = URL(string: response.posterURL) else {
            return nil
        }

        return Concert(
            id: response.id,
            title: response.title,
            artist: response.artist,
            status: status,
            daysLeft: response.daysLeft,
            startDate: response.startDate,
            endDate: response.endDate,
            posterURL: posterURL,
            venue: response.venue,
            ticketSite: response.ticketSite,
            ticketURL: URL(string: response.ticketURL ?? ""),
            introduction: response.introduction,
            label: response.label
        )
    }

    // MARK: - Schedule

    func toDomain(from response: DTO.Response.FetchConcertSchedule) -> [ConcertSchedule] {
        response.compactMap { schedule in
            guard let scheduledAt = ISO8601DateFormatter().date(from: schedule.scheduledAt) else {
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
        let formatter = ISO8601DateFormatter()

        return response.compactMap { setlist in
            guard let startDate = formatter.date(from: setlist.startDate),
                  let endDate = formatter.date(from: setlist.endDate),
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
            debutYear: response.debutYear,
            category: response.category,
            imageURL: response.imageURL,
            detail: response.detail,
            keywords: response.keywords,
            instagramURL: response.instagramURL
        )
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
}
