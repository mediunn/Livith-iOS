//
//  ConcertMatchingMapper.swift
//  UserData
//
//  Created by youz2me on 7/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithFoundation
import LivithNetworking

struct ConcertMatchingMapper {
    func toDomain(from response: DTO.Response.CreateExtractionJob) -> [Concert] {
        response.concerts.compactMap { toDomain(from: $0) }
    }

    private func toDomain(from dto: DTO.Response.CreateExtractionJob.MatchedConcert) -> Concert? {
        guard let status = ConcertStatus(rawValue: dto.status) else {
            return nil
        }

        return Concert(
            id: dto.id,
            title: dto.title,
            artist: dto.artist,
            status: status,
            daysLeft: dto.daysLeft,
            startDate: dto.startDate.flatMap { DateFormatterService.date(from: $0, type: .dotDate) },
            endDate: dto.endDate.flatMap { DateFormatterService.date(from: $0, type: .dotDate) },
            posterURL: dto.poster.flatMap { URL(string: $0) },
            venue: dto.venue,
            ticketSite: dto.ticketSite,
            ticketURL: dto.ticketURL.flatMap { URL(string: $0) },
            introduction: dto.introduction,
            label: dto.label
        )
    }
}
