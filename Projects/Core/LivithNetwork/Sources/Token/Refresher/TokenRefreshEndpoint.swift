//
//  TokenRefreshEndpoint.swift
//  LivithNetwork
//
//  Created by 김진웅 on 12/7/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Alamofire

public enum TokenRefreshEndpoint {
    case updateToken(DTO.Request.UpdateToken)
}

extension TokenRefreshEndpoint: NetworkEndpoint {
    public var path: String? {
        switch self {
        case .updateToken:
            return "/api/v4/auth/refresh"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .updateToken:
            return .post
        }
    }
    
    public var query: [String : Any]? {
        switch self {
        case .updateToken:
            return ["client": "mobile"]
        }
    }
    
    public var body: Encodable? {
        switch self {
        case .updateToken(let body):
            return body
        }
    }
}