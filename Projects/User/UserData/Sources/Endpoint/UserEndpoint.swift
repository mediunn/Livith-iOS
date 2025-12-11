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
    case updateUserNickname(request: DTO.Request.UpdateUserNickname)
    case deleteUser(request: DTO.Request.DeleteUser)
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
        }
    }
    
    public var query: [String : Any]? {
        switch self {
        case .checkNicknameDuplicate(nickname: let nickname):
            return ["nickname" : nickname]
        default:
            return .none
        }
    }
    
    public var body: (any Encodable)? {
        switch self {
        case .updateUserNickname(request: let request):
            return request
        case .deleteUser(request: let request):
            return request
        default:
            return .none
        }
    }
    
    public var method: LivithNetwork.HTTPMethod {
        switch self {
        case .deleteUser:
            return .post
        case .checkNicknameDuplicate:
            return .get
        case .updateUserNickname:
            return .patch
        }
    }
}
