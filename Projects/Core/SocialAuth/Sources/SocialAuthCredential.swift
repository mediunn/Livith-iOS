//
//  SocialAuthCredential.swift
//  SocialAuth
//
//  Created by 김진웅 on 12/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

/// 소셜 로그인 결과를 담는 모델
public struct SocialAuthCredential {
    public let vendor: SocialAuthVendor
    public let token: String
    public let userID: String?
    
    public init(vendor: SocialAuthVendor, token: String, userID: String?) {
        self.vendor = vendor
        self.token = token
        self.userID = userID
    }
}
