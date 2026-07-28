//
//  AppleLogin.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 34. iOS 애플 로그인

public extension DTO.Request {
    struct AppleLogin: Encodable {
        let identityToken: String
    }
}

public extension DTO.Response {
    struct AppleLogin: Decodable {
        public let isNewUser: Bool
        public let accessToken: String?
        public let refreshToken: String?
        public let tempUser: TempUser?

        enum CodingKeys: String, CodingKey {
            case isNewUser, accessToken, refreshToken
            case tempUser = "tempUserData"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            isNewUser = try container.decode(Bool.self, forKey: .isNewUser)

            if isNewUser {
                tempUser = try container.decode(TempUser.self, forKey: .tempUser)
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

public extension DTO.Response.AppleLogin {
    struct TempUser: Decodable {
        public let provider: String
        public let providerID: String
        public let email: String

        enum CodingKeys: String, CodingKey {
            case provider, email
            case providerID = "providerId"
        }
    }
}
