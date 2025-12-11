//
//  OnboardingEndpoint.swift
//  LoginData
//
//  Created by 김진웅 on 11/10/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithNetwork

enum OnboardingEndpoint {
    case signup(request: DTO.Request.CreateUser)
    case checkNicknameDuplicate(nickname: String)
}

extension OnboardingEndpoint: NetworkEndpoint {
    var path: String? {
        switch self {
        case .signup:
            return "/api/v4/auth/signup"
        case .checkNicknameDuplicate:
            return "/api/v4/users/check-nickname"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .signup:
            return .post
        case .checkNicknameDuplicate:
            return .get
        }
    }
    
    var query: [String: Any]? {
        switch self {
        case .signup:
            return ["client": "mobile"]
        case .checkNicknameDuplicate(let nickname):
            return ["nickname": nickname]
        }
    }
    
    var body: Encodable? {
        switch self {
        case .signup(let request):
            return request
        case .checkNicknameDuplicate:
            return nil
        }
    }
}
