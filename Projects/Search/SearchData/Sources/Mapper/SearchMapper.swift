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

struct SearchMapper {
    func toDomain(from response: DTO.Response.FetchFilterSearchResult) -> SearchResultEntity {
        let concerts = response.data.compactMap { concert -> Concert? in
            guard let status = ConcertStatus(rawValue: concert.status),
                  let posterURL = URL(string: concert.posterURL) else {
                return nil
            }

            return Concert(
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
    
    func toDomain(from response: DTO.Response.Banners) -> [Banner] {
        response.map { banner in
            Banner(
                id: banner.id,
                title: banner.title,
                description: banner.content,
                category: banner.category,
                imageURL: URL(string: banner.imageURL)
            )
        }
    }
    
    func toDomain(from response: DTO.Response.Sections) -> [ConcertSection] {
        response.map { section in
            let concerts = section.concerts.compactMap { concert -> Concert? in
                guard let status = ConcertStatus(rawValue: concert.status),
                      let posterURL = URL(string: concert.posterURL)
                else {
                    return nil
                }

                return Concert(
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

            return ConcertSection(
                id: section.id,
                title: section.sectionTitle,
                concerts: concerts
            )
        }
    }
}
