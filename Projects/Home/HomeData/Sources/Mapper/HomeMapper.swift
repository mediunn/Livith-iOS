//
//  HomeMapper.swift
//  HomeData
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithFoundation
import LivithNetwork
import HomeDomain

struct HomeMapper {
    
    func toDomain(from response: DTO.Response.FetchHomeSectionList) -> [ConcertSection] {
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
    
    func toDomain(from response: DTO.Response.FetchUserInterestConcert) -> Concert? {
        guard let status = ConcertStatus(rawValue: response.status),
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
    
    func toDomain(from response: DTO.Response.UpdateUserInterestConcert) -> Concert? {
        guard let status = ConcertStatus(rawValue: response.status),
              let posterURL = URL(string: response.posterURL)
        else {
            return nil
        }
        
        return Concert(
            id: response.id,
            title: response.title,
            artist: response.artist,
            status: status,
            daysLeft: .zero,
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
    
    func toDomain(from response: DTO.Response.FetchConcertList) -> [Concert] {
        return response.data.map { concert in
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
        .compactMap { $0 }
    }
    
    func toDomain(from response: DTO.Response.FetchFilterSearchResult) -> [Concert] {
        return response.data.map { concert in
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
        .compactMap { $0 }
    }
    
    func toDomain(from response: DTO.Response.FetchConcertSetlist) -> Setlist {
        let startDate = DateFormatterService.date(from: response.startDate, type: .iso8601) ?? Date()
        let endDate = DateFormatterService.date(from: response.endDate, type: .iso8601) ?? Date()
		
        return Setlist(
            id: response.id,
            title: response.title,
            imageURL: response.imageURL,
            type: SetlistType(rawValue: response.type) ?? .none,
            startDate: startDate,
            endDate: endDate,
            venue: response.venue,
            artist: response.artist
        )
    }
    
    func toDomain(from response: DTO.Response.FetchSetlistSongList) -> SetlistSongList {
        return response.map { song in
            SetlistSong(
                id: song.id,
                title: song.title,
                artist: song.artist,
                orderIndex: song.orderIndex
            )
        }
    }

	func toDomain(from response: DTO.Response.FetchConcertSchedule) -> ConcertScheduleList {
        return response.map { schedule in
            ConcertSchedule(
                id: schedule.id,
                category: schedule.category,
                schduledAt: DateFormatterService.date(from: schedule.scheduledAt, type: .iso8601) ?? .now
            )
        }
    }
}
