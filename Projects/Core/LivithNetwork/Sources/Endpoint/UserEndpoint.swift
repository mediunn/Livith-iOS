//
//  UserEndpoint.swift
//  LivithNetwork
//
//  Created by 김진웅 on 2026/01/21.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Alamofire

public typealias UserService = NetworkService<UserEndpoint>

public enum UserEndpoint {
    case logout(request: DTO.Request.RequestLogout)
    case checkNicknameDuplicate(nickname: String)
    case updateUserNickname(request: DTO.Request.UpdateUserNickname)
    case withdraw(request: DTO.Request.DeleteUser)
}

extension UserEndpoint: NetworkEndpoint {
    public var path: String? {
        switch self {
        case .logout:
            return "/api/v4/auth/logout"
        case .checkNicknameDuplicate:
            return "/api/v4/users/check-nickname"
        case .updateUserNickname:
            return "/api/v4/users/nickname"
        case .withdraw:
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
        case .logout(request: let request):
            return request
        case .updateUserNickname(request: let request):
            return request
        case .withdraw(request: let request):
            return request
        default:
            return .none
        }
    }
    
    public var method: LivithNetwork.HTTPMethod {
        switch self {
        case .logout:
            return .post
        case .checkNicknameDuplicate:
            return .get
        case .updateUserNickname:
            return .patch
        case .withdraw:
            return .post
        }
    }

    public var requiresInterceptor: Bool {
        switch self {
        case .logout, .checkNicknameDuplicate:
            return false
        case .updateUserNickname, .withdraw:
            return true
        }
    }
}
