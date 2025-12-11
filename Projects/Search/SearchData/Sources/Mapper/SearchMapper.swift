//
//  SearchMapper.swift
//  search
//
//  Created by Youjin Lee on 10/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithNetwork
import SearchDomain

public class SearchMapper {
    public init() { }
    
    func toDomain(from response: DTO.Response.FetchFilterSearchResult) -> SearchResultEntity {
        let concerts = response.data.compactMap { concert -> ConcertEntity? in
            guard let status = ConcertStatus(rawValue: concert.status),
                  let posterURL = URL(string: concert.posterURL) else {
                return nil
            }

            return ConcertEntity(
                id: concert.id,
                title: concert.title,
                artist: concert.artist,
                status: status,
                daysLeft: concert.daysLeft,
                startDate: concert.startDate,
                endDate: concert.endDate,
                posterURL: posterURL,
                venue: concert.venue,
                ticketSite: concert.ticketSite,
                ticketURL: URL(string: concert.ticketURL ?? ""),
                introduction: concert.introduction,
                label: concert.label
            )
        }

        return SearchResultEntity(
            concerts: concerts,
            cursor: response.cursor.map { ($0.value, $0.id) },
            totalCount: response.totalCount
        )
    }
}
