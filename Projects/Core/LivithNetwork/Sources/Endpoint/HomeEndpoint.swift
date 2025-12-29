//
//  HomeEndpoint.swift
//  LivithNetwork
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public typealias HomeAPIService = NetworkService<HomeEndpoint>

public enum HomeEndpoint {
    case fetchSectionList
    case fetchInterestedConcert
    case updateInterestedConcert(id: Int)
    case deleteInterestedConcert
}

extension HomeEndpoint: NetworkEndpoint {
    public var path: String? {
        switch self {
        case .fetchSectionList:
            return "/api/v4/home/sections"
        case .fetchInterestedConcert:
            return "/api/v4/users/interest-concert"
        case .updateInterestedConcert:
            return "/api/v4/users/interest-concert"
        case .deleteInterestedConcert:
            return "/api/v4/users/interest-concert"
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
        }
    }
    
    public var query: [String: Any]? {
        switch self {
        case .fetchSectionList, .fetchInterestedConcert, .updateInterestedConcert, .deleteInterestedConcert:
            return nil
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
        case .fetchInterestedConcert, .updateInterestedConcert, .deleteInterestedConcert:
            return true
        case .fetchSectionList:
            return false
        }
    }
}
