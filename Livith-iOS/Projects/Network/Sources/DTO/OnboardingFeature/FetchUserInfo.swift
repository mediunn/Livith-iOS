//
//  FetchUserInfo.swift
//  network
//
//  Created by Youjin Lee on 10/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

// MARK: - 31. 사용자 정보 조회

public extension DTO.Response {
    struct FetchUserInfo: Decodable {
        let accessToken: String
        let refreshToken: String
        let user: User
    }
    
    struct User: Decodable {
        let id: String
        let nickname: String
        let email: String
    }
}
