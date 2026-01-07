//
//  SocialLoginProvider+SocialAuthVendor.swift
//  LoginData
//
//  Created by 김진웅 on 1/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import SocialAuth
import LoginDomain

extension SocialLoginProvider {
    /// 도메인 계층의 SocialLoginProvider를 인프라 계층의 SocialAuthVendor로 변환합니다.
    var authVendor: SocialAuthVendor {
        switch self {
        case .apple:
            return .apple
        case .kakao:
            return .kakao
        }
    }
}
