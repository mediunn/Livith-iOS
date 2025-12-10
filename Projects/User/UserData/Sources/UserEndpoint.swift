//
//  UserEndpoint.swift
//  User
//
//  Created by Youjin Lee on 12/11/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Alamofire

import LivithNetwork
import UserDomain

public enum UserEndpoint {
    case checkNicknameDuplicate(nickname: String)
    case updateUserNickname(nickname: String)
    case deleteUser(reason: String)
    case logoutSession
}

extension UserEndpoint: NetworkEndpoint {
    public var path: String? {
        switch self {
        case .checkNicknameDuplicate:
            return "/api/v4/users/check-nickname"
        case .updateUserNickname:
            return "/api/v4/users/nickname"
        case .deleteUser:
            return "/api/v4/auth/withdraw"
        case .logoutSession:
            return "/api/v4/auth/logout"
        }
    }
    
    public var query: [String : Any]? {
        switch self {
        case .checkNicknameDuplicate(nickname: let nickname):
            return ["nickname" : nickname]
        case .logoutSession:
            return ["client" : "mobile"]
        default:
            return .none
        }
    }
    
    public var body: (any Encodable)? {
        switch self {
        case .updateUserNickname(nickname: let nickname):
            <#code#>
        case .deleteUser(reason: let reason):
            <#code#>
        case .logoutSession:
            <#code#>
        default:
            return .none
        }
    }
    
    public var method: LivithNetwork.HTTPMethod {
        switch self {
        case .logoutSession, .deleteUser:
            return .post
        case .checkNicknameDuplicate:
            return .get
        case .updateUserNickname:
            return .patch
        }
    }
}
