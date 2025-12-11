//
//  LogoutEndpoint.swift
//  User
//
//  Created by Youjin Lee on 12/11/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Alamofire

import LivithNetwork
import UserDomain

public enum LogoutEndpoint {
    case logoutSession(request: DTO.Request.RequestLogout)
}

extension LogoutEndpoint: NetworkEndpoint {
    public var path: String? {
        return "/api/v4/auth/logout"
    }
    
    public var query: [String : Any]? {
        return .none
    }
    
    public var body: (any Encodable)? {
        switch self {
        case .logoutSession(request: let request):
            return request
        }
    }
    
    public var method: LivithNetwork.HTTPMethod {
        return .post
    }
}
