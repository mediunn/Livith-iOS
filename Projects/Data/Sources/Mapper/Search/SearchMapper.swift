//
//  SearchMapper.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetwork
import LivithFoundation

struct SearchMapper {
    func toDomain(from response: DTO.Response.FetchBannerList) -> [Banner] {
        response.map { dto in
            Banner(
                id: dto.id,
                title: dto.title,
                description: dto.content,
                category: dto.category,
                imageURL: URL(string: dto.imageURL)
            )
        }
    }
    
    func toDomain(from response: DTO.Response.FetchFilterSearchResult) -> SearchResultEntity {
        let concerts = response.data.compactMap { dto -> Concert? in
            guard let posterURL = URL(string: dto.posterURL),
                  let status = ConcertStatus(rawValue: dto.status),
                  let startDate = DateFormatterService.date(from: dto.startDate, type: .dotDate),
                  let endDate = DateFormatterService.date(from: dto.endDate, type: .dotDate)
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
        
        var cursorTuple: (String, Int)?
        if let cursor = response.cursor {
            cursorTuple = (cursor.value, cursor.id)
        }
        
        return SearchResultEntity(
            concerts: concerts,
            cursor: cursorTuple,
            totalCount: response.totalCount
        )
    }
}
