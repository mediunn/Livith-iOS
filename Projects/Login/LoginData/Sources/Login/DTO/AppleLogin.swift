//
//  AppleLogin.swift
//  LoginData
//
//  Created by 김진웅 on 12/5/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithNetwork

// MARK: - 34. iOS 애플 로그인

extension DTO.Request {
    struct AppleLogin: Encodable {
        let identityToken: String
    }
}

extension DTO.Response {
    struct AppleLogin: Decodable {
        let isNewUser: Bool
        let accessToken: String?
        let refreshToken: String?
        let tempUser: TempUser?
        
        enum CodingKeys: String, CodingKey {
            case isNewUser, accessToken, refreshToken
            case tempUser = "tempUserData"
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: DTO.Response.AppleLogin.CodingKeys.self)
            
            isNewUser = try container.decode(Bool.self, forKey: .isNewUser)
            
            if isNewUser {
                tempUser = try container.decode(DTO.Response.AppleLogin.TempUser.self, forKey: .tempUser)
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

extension DTO.Response.AppleLogin {
    struct TempUser: Decodable {
        let provider: String
        let providerID: String
        let email: String
        
        enum CodingKeys: String, CodingKey {
            case provider, email
            case providerID = "providerId"
        }
    }
}
