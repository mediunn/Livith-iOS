//
//  LoginRepositoryImpl.swift
//  LoginData
//
//  Created by 김진웅 on 12/5/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Auth
import LivithNetwork

final class LoginRepositoryImpl {
    typealias LoginService = NetworkService<LoginEndpoint>
    
    private let appleLoginService: AppleLoginService
    private let kakaoLoginService: KakaoLoginService
    private let loginService: LoginService
    
    init(
        appleLoginService: AppleLoginService = .init(),
        kakaoLoginService: KakaoLoginService = .init(),
        loginService: LoginService = .init()
    ) {
        self.appleLoginService = appleLoginService
        self.kakaoLoginService = kakaoLoginService
        self.loginService = loginService
    }
}
