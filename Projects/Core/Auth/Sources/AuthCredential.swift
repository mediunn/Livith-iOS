//
//  AuthCredential.swift
//  Auth
//
//  Created by 김진웅 on 12/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

/// 소셜 로그인 결과를 담는 모델
public struct AuthCredential {
    public let provider: AuthProvider
    public let token: String
    public let userID: String?
    
    public init(provider: AuthProvider, token: String, userID: String?) {
        self.provider = provider
        self.token = token
        self.userID = userID
    }
}

/// 지원하는 소셜 로그인 종류
public enum AuthProvider {
    case kakao
    case apple
}
