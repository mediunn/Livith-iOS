//
//  HomeEndpoint.swift
//  LivithNetwork
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public typealias HomeService = NetworkService<HomeEndpoint>

public enum HomeEndpoint {
    case fetchSectionList
    case fetchInterestedConcertList(DTO.Request.FetchInterestConcertList)
    case updateInterestedConcerts(DTO.Request.UpdateInterestedConcerts)
    case checkInterestedConcert(concertID: Int)
    case fetchRecommendedConcertList
}

extension HomeEndpoint: NetworkEndpoint {
    public var path: String? {
        switch self {
        case .fetchSectionList:
            return "/home/sections"
        case .fetchInterestedConcertList, .updateInterestedConcerts:
            return "/users/interest-concerts"
        case .checkInterestedConcert(let concertID):
            return "/users/interest-concerts/\(concertID)/exists"
        case .fetchRecommendedConcertList:
            return "/recommendation/concerts"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .fetchSectionList, .fetchInterestedConcertList, .checkInterestedConcert, .fetchRecommendedConcertList:
            return .get
        case .updateInterestedConcerts:
            return .put
        }
    }

    public var query: [String: Any]? {
        switch self {
        case .fetchInterestedConcertList(let request):
            let query: [String: Any?] = [
                "sort": request.sort.rawValue,
                "size": request.size,
                "cursorDate": request.cursorDate,
                "cursorId": request.cursorID
            ]
            return query.compactMapValues { $0 }
        default:
            return nil
        }
    }

    public var body: Encodable? {
        switch self {
        case .updateInterestedConcerts(let request):
            return request
        default:
            return nil
        }
    }

    public var requiresInterceptor: Bool {
        switch self {
        case .fetchInterestedConcertList, .updateInterestedConcerts, .checkInterestedConcert, .fetchRecommendedConcertList:
            return true
        case .fetchSectionList:
            return false
        }
    }
}
