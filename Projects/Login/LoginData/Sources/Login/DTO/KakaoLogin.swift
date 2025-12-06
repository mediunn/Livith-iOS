//
//  KakaoLogin.swift
//  LoginData
//
//  Created by 김진웅 on 12/5/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithNetwork

// MARK: - 28. iOS 카카오 로그인

extension DTO.Request {
    struct KakaoLogin: Encodable {
        let accessToken: String
    }
}

extension DTO.Response {
    struct KakaoLogin: Decodable {
        let isNewUser: Bool
        let accessToken: String?
        let refreshToken: String?
        let tempUser: TempUser?
        
        enum CodingKeys: String, CodingKey {
            case isNewUser, accessToken, refreshToken
            case tempUser = "tempUserData"
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: DTO.Response.KakaoLogin.CodingKeys.self)
            
            isNewUser = try container.decode(Bool.self, forKey: .isNewUser)
            
            if isNewUser {
                tempUser = try container.decode(DTO.Response.KakaoLogin.TempUser.self, forKey: .tempUser)
                accessToken = nil
                refreshToken = nil
            } else {
                accessToken = try container.decode(String.self, forKey: .accessToken)
                refreshToken = try container.decode(String.self, forKey: .refreshToken)
                tempUser = nil
            }
        }
    }
}

extension DTO.Response.KakaoLogin {
    struct TempUser: Decodable {
        let providerID: String
        let provider: String
        
        enum CodingKeys: String, CodingKey {
            case providerID = "providerId"
            case provider
        }
    }
}
