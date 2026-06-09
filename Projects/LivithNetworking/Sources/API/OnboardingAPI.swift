//
//  OnboardingAPI.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum OnboardingAPI {
    public static func appleLogin(identityToken: String) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/auth/apple/mobile",
            method: .post,
            task: .body(DTO.Request.AppleLogin(identityToken: identityToken)),
            authentication: .none
        )
    }

    public static func kakaoLogin(accessToken: String) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/auth/kakao/mobile",
            method: .post,
            task: .body(DTO.Request.KakaoLogin(accessToken: accessToken)),
            authentication: .none
        )
    }

    public static func signup(_ signup: DTO.Request.Signup) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/auth/signup",
            method: .post,
            task: .queryAndBody(
                queryItems: [URLQueryItem(name: "client", value: "mobile")],
                body: signup
            ),
            authentication: .none
        )
    }

    public static func fetchUserInfo() -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/users/me",
            method: .get,
            task: .plain,
            authentication: .required
        )
    }
}
