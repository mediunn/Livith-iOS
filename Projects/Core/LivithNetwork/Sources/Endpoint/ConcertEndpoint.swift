//
//  ConcertEndpoint.swift
//  LivithNetwork
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public typealias ConcertService = NetworkService<ConcertEndpoint>

public enum ConcertEndpoint {
    case fetchConcertInfo(concertID: Int)
    case fetchConcertSchedule(concertID: Int)
    case fetchConcertCultureList(concertID: Int)
    case fetchConcertMerchandiseList(concertID: Int)
    case fetchConcertSetlistList(concertID: Int)
    case fetchConcertArtistInfo(concertID: Int)
    case setInterestConcert(concertID: Int)
}

extension ConcertEndpoint: NetworkEndpoint {
    public var path: String? {
        switch self {
        case .fetchConcertInfo(let concertID):
            return "/api/v4/concerts/\(concertID)"
        case .fetchConcertSchedule(let concertID):
            return "/api/v4/concerts/\(concertID)/schedule"
        case .fetchConcertCultureList(let concertID):
            return "/api/v4/concerts/\(concertID)/cultures"
        case .fetchConcertMerchandiseList(let concertID):
            return "/api/v4/concerts/\(concertID)/mds"
        case .fetchConcertSetlistList(let concertID):
            return "/api/v4/concerts/\(concertID)/setlists"
        case .fetchConcertArtistInfo(let concertID):
            return "/api/v4/concerts/\(concertID)/artist"
        case .setInterestConcert:
            return "/api/v4/users/interest-concert"
        }
    }

    public var query: [String: Any]? {
        return nil
    }

    public var method: HTTPMethod {
        switch self {
        case .setInterestConcert:
            return .post
        default:
            return .get
        }
    }

    public var headers: HTTPHeaders? {
        return nil
    }

    public var body: Encodable? {
        switch self {
        case .setInterestConcert(let concertID):
            return DTO.Request.UpdateUserInterestConcert(concertID: concertID)
        default:
            return nil
        }
    }

    public var requiresInterceptor: Bool {
        switch self {
        case .setInterestConcert:
            return true
        default:
            return false
        }
    }
}
