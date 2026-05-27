//
//  SearchMapper.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetworking
import LivithFoundation

struct SearchMapper {
    func toDomain(from response: DTO.Response.FetchBannerList) -> [Banner] {
        response.map { dto in
            Banner(
                id: dto.id,
                title: dto.title,
                description: dto.content,
                category: dto.category,
                imageURL: URL(string: dto.imageURL),
                linkURL: makeBannerLinkURL(from: dto.linkURL)
            )
        }
    }

    func toDomain(from response: DTO.Response.FetchFilterSearchResult) -> SearchResult {
        let concerts = response.data.compactMap { dto -> Concert? in
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

        return SearchResult(
            concerts: concerts,
            cursor: response.cursor,
            totalCount: response.totalCount
        )
    }
}

private extension SearchMapper {
    func parseDate(_ dateString: String?, type: DateFormatType) -> Date? {
        guard let dateString else { return nil }

        return DateFormatterService.date(from: dateString, type: type)
    }

    func parseURL(_ urlString: String?) -> URL? {
        guard let urlString else { return nil }

        return URL(string: urlString)
    }

    func makeBannerLinkURL(from string: String?) -> URL? {
        guard let string,
              let url = URL(string: string),
              url.scheme?.lowercased() == "https",
              url.host?.isEmpty == false
        else {
            return nil
        }

        return url
    }
}
