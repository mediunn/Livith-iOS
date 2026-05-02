//
//  ConcertMapper.swift
//  Data
//
//  Created by 김진웅 on 1/22/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithFoundation
import LivithNetwork

struct ConcertMapper {
    func toDomain(from response: DTO.Response.FetchConcertSetlist) -> Setlist? {
        guard let startDate = DateFormatterService.date(from: response.startDate, type: .dotDate),
              let endDate = DateFormatterService.date(from: response.endDate, type: .dotDate)
        else {
            return nil
        }
        
        return Setlist(
            id: response.id,
            title: response.title,
            imageURL: response.imageURL.flatMap { URL(string: $0) },
            type: .init(value: response.type),
            status: response.status.flatMap { SetlistStatus(rawValue: $0) },
            startDate: startDate,
            endDate: endDate,
            venue: response.venue,
            artist: response.artist
        )
    }
    
    func toDomain(from response: DTO.Response.FetchSectionList) -> [ConcertSection] {
        response.compactMap { section in
            let concerts = section.concerts.compactMap { toDomain(from: $0) }
            return ConcertSection(id: section.id, title: section.sectionTitle, concerts: concerts)
        }
    }
    
    func toDomain(from response: DTO.Response.FetchHomeSectionList) -> [ConcertSection] {
        response.compactMap { section in
            let concerts = section.concerts.compactMap { toDomain(from: $0) }
            return ConcertSection(id: section.id, title: section.sectionTitle, concerts: concerts)
        }
    }
    
    func toDomain(from response: DTO.Response.FetchConcertInfo) -> Concert? {
        guard let status = ConcertStatus(rawValue: response.status),
              let startDate = DateFormatterService.date(from: response.startDate, type: .dotDate),
              let endDate = DateFormatterService.date(from: response.endDate, type: .dotDate),
              let posterURL = URL(string: response.posterURL)
        else {
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
    
    func toDomain(from response: DTO.Response.FetchConcertSchedule) -> [ConcertSchedule] {
        response.compactMap { toDomain(from: $0) }
    }
    
    func toDomain(from response: DTO.Response.FetchConcertCultureList) -> [ConcertCulture] {
        response.map {
            ConcertCulture(
                id: $0.id,
                concertID: $0.concertID,
                title: $0.title,
                content: $0.content
            )
        }
    }
    
    func toDomain(from response: DTO.Response.FetchConcertInfoList) -> [ConcertInfo] {
        response.map {
            ConcertInfo(
                id: $0.id,
                imageURL: $0.imageURL ?? "",
                title: $0.category,
                description: $0.content
            )
        }
    }
    
    func toDomain(from response: DTO.Response.FetchConcertMerchandiseList) -> [ConcertMerchandise] {
        response.map {
            ConcertMerchandise(
                id: $0.id,
                name: $0.name,
                price: $0.price,
                imageURL: $0.imageURL.flatMap { URL(string: $0) }
            )
        }
    }
    
    func toDomain(from response: DTO.Response.FetchConcertSetlistList) -> [Setlist] {
        response.compactMap {
            toDomain(from: $0)
        }
    }
    
    func toDomain(from response: DTO.Response.FetchConcertArtistInfo) -> Artist {
        Artist(
            id: response.id,
            name: response.artist,
            debutYear: formatDebutYear(response.debutYear),
            category: response.category,
            imageURL: response.imageURL.flatMap { URL(string: $0) },
            detail: response.detail,
            keywords: response.keywords,
            instagramURL: response.instagramURL.flatMap { URL(string: $0) },
            twitterURL: response.twitterURL.flatMap { URL(string: $0) }
        )
    }

    func toDomain(from response: DTO.Response.FetchConcertList) -> [Concert] {
        response.data.compactMap { toDomain(from: $0) }
    }

    func toConcertListResult(from response: DTO.Response.FetchConcertList) -> ListResult<Concert> {
        ListResult(
            items: toDomain(from: response),
            nextToken: response.cursor.map { ConcertListNextToken(cursor: $0) }
        )
    }

    func toDomain(from response: DTO.Response.FetchRecommendedConcertList) -> [Concert] {
        response.compactMap { toDomain(from: $0) }
    }

    func toDomain(from dto: DTO.Response.RecommendedConcert) -> Concert? {
        guard let status = ConcertStatus(rawValue: dto.status),
              let startDate = DateFormatterService.date(from: dto.startDate, type: .dotDate),
              let endDate = DateFormatterService.date(from: dto.endDate, type: .dotDate),
              let posterURL = URL(string: dto.poster)
        else {
            return nil
        }

        return Concert(
            id: dto.id,
            title: dto.title,
            artist: dto.artist,
            status: status,
            daysLeft: dto.daysLeft,
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

    func toDomain(from dto: DTO.Response.FetchFilterSearchResult.FilteredConcert) -> Concert? {
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
}

// MARK: - Helpers

private extension ConcertMapper {
    func toDomain(from dto: DTO.Response.HomeSection.Concert) -> Concert? {
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
            daysLeft: dto.daysLeft,
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
    
    func toDomain(from dto: DTO.Response.ConcertSchedule) -> ConcertSchedule? {
        guard let date = DateFormatterService.date(from: dto.scheduledAt, type: .iso8601) else {
            return nil
        }
        
        return ConcertSchedule(
            id: dto.id,
            category: dto.category,
            scheduledAt: date,
            type: .init(value: dto.type ?? "")
        )
    }
    
    func toDomain(from dto: DTO.Response.FetchConcertList.FilteredConcert) -> Concert? {
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
    
    func toDomain(from dto: DTO.Response.ConcertSetlist) -> Setlist? {
        guard let startDate = DateFormatterService.date(from: dto.startDate, type: .dotDate),
              let endDate = DateFormatterService.date(from: dto.endDate, type: .dotDate)
        else {
            return nil
        }
        
        return Setlist(
            id: dto.id,
            title: dto.title,
            imageURL: dto.imageURL.flatMap { URL(string: $0) },
            type: .init(value: dto.type),
            status: dto.status.flatMap { SetlistStatus(rawValue: $0) },
            startDate: startDate,
            endDate: endDate,
            venue: dto.venue,
            artist: dto.artist
        )
    }
    
    func formatDebutYear(_ yearString: String) -> String {
        guard let doubleValue = Double(yearString) else { return yearString }
        return String(Int(doubleValue))
    }
}
