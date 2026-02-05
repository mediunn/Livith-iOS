//
//  OnboardingEndpoint.swift
//  LivithNetwork
//
//  Created by 김진웅 on 12/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public typealias OnboardingService = NetworkService<OnboardingEndpoint>

public enum OnboardingEndpoint {
    case appleLogin(identityToken: String)
    case kakaoLogin(accessToken: String)
    case signup(DTO.Request.Signup)
    case checkNicknameDuplicate(nickname: String)
    case fetchUserInfo
}

extension OnboardingEndpoint: NetworkEndpoint {
    public var path: String? {
        switch self {
        case .appleLogin:
            return "/auth/apple/mobile"
        case .kakaoLogin:
            return "/auth/kakao/mobile"
        case .signup:
            return "/auth/signup"
        case .checkNicknameDuplicate:
            return "/users/check-nickname"
        case .fetchUserInfo:
            return "/users/me"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .appleLogin, .kakaoLogin, .signup:
            return .post
        case .checkNicknameDuplicate, .fetchUserInfo:
            return .get
        }
    }
    
    public var query: [String: Any]? {
        switch self {
        case .appleLogin, .kakaoLogin, .fetchUserInfo:
            return nil
        case .signup:
            return ["client": "mobile"]
        case .checkNicknameDuplicate(let nickname):
            return ["nickname": nickname]
        }
    }
    
    public var body: Encodable? {
        switch self {
        case .appleLogin(let identityToken):
            return DTO.Request.AppleLogin(identityToken: identityToken)
        case .kakaoLogin(let accessToken):
            return DTO.Request.KakaoLogin(accessToken: accessToken)
        case .signup(let requestDTO):
            return requestDTO
        case .checkNicknameDuplicate:
            return nil
        case .fetchUserInfo:
            return nil
        }
    }

    public var requiresInterceptor: Bool {
        switch self {
        case .fetchUserInfo:
            return true
        default:
            return false
        }
    }
}
