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
    case fetchInterestedConcert
    case updateInterestedConcert(id: Int)
    case deleteInterestedConcert
    case fetchRecommendedConcertList
}

extension HomeEndpoint: NetworkEndpoint {
    public var path: String? {
        switch self {
        case .fetchSectionList:
            return "/home/sections"
        case .fetchInterestedConcert:
            return "/users/interest-concert"
        case .updateInterestedConcert:
            return "/users/interest-concert"
        case .deleteInterestedConcert:
            return "/users/interest-concert"
        case .fetchRecommendedConcertList:
            return "/recommendation/concerts"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .fetchSectionList, .fetchInterestedConcert:
            return .get
        case .updateInterestedConcert:
            return .post
        case .deleteInterestedConcert:
            return .delete
        case .fetchRecommendedConcertList:
            return .get
        }
    }
    
    public var body: Encodable? {
        switch self {
        case .updateInterestedConcert(let id):
            return DTO.Request.UpdateUserInterestConcert(concertID: id)
        default:
            return nil
        }        
    }
    
    public var requiresInterceptor: Bool {
        switch self {
        case .fetchInterestedConcert, .updateInterestedConcert, .deleteInterestedConcert, .fetchRecommendedConcertList:
            return true
        case .fetchSectionList:
            return false
        }
    }
}
