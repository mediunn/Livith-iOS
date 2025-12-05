//
//  LoginEndpoint.swift
//  LoginData
//
//  Created by 김진웅 on 12/5/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithNetwork

enum LoginEndpoint {
    case appleLogin(identityToken: String)
    case kakaoLogin(accessToken: String)
}

extension LoginEndpoint: NetworkEndpoint {
    var path: String? {
        switch self {
        case .appleLogin:
            return "/api/v4/auth/apple/mobile"
        case .kakaoLogin:
            return "/api/v4/auth/kakao/mobile"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .appleLogin, .kakaoLogin:
            return .post
        }
    }
    
    var body: (any Encodable)? {
        switch self {
        case .appleLogin(let identityToken):
            return DTO.Request.AppleLogin(identityToken: identityToken)
        case .kakaoLogin(let accessToken):
            return DTO.Request.KakaoLogin(accessToken: accessToken)
        }
    }
}
