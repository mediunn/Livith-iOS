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
    func toDomain(from response: DTO.Response.FetchFilterSearchResult) -> [ConcertEntity] {
        return response.data.compactMap { concert in
            guard let status = ConcertStatus(rawValue: concert.status),
                  let posterURL = URL(string: concert.posterURL),
                  let ticketURL = URL(string: concert.ticketURL) else {
                return nil
            }

            return ConcertEntity(
                id: concert.id,
                title: concert.title,
                artist: concert.artist,
                status: status,
                daysLeft: concert.daysLeft ?? 0,
                startDate: concert.startDate,
                endDate: concert.endDate,
                posterURL: posterURL,
                venue: concert.venue,
                ticketSite: concert.ticketSite,
                ticketURL: ticketURL,
                introduction: concert.introduction,
                label: concert.label
            )
        }
    }
}
