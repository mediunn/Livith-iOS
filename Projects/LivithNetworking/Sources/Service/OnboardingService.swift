//
//  OnboardingService.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - OnboardingService

public protocol OnboardingService: Sendable {
    func appleLogin(identityToken: String) async throws(NetworkError) -> DTO.Response.AppleLogin
    func kakaoLogin(accessToken: String) async throws(NetworkError) -> DTO.Response.KakaoLogin
    func signup(_ signup: DTO.Request.Signup) async throws(NetworkError) -> DTO.Response.Signup
    func fetchUserInfo() async throws(NetworkError) -> DTO.Response.FetchUserInfo
}

// MARK: - OnboardingServiceImpl

struct OnboardingServiceImpl: OnboardingService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func appleLogin(identityToken: String) async throws(NetworkError) -> DTO.Response.AppleLogin {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/auth/apple/mobile",
                method: .post,
                task: .body(DTO.Request.AppleLogin(identityToken: identityToken)),
                authentication: .none
            )
        )
    }

    public func kakaoLogin(accessToken: String) async throws(NetworkError) -> DTO.Response.KakaoLogin {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/auth/kakao/mobile",
                method: .post,
                task: .body(DTO.Request.KakaoLogin(accessToken: accessToken)),
                authentication: .none
            )
        )
    }

    public func signup(_ signup: DTO.Request.Signup) async throws(NetworkError) -> DTO.Response.Signup {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/auth/signup",
                method: .post,
                task: .queryAndBody(
                    queryItems: [URLQueryItem(name: "client", value: "mobile")],
                    body: signup
                ),
                authentication: .none
            )
        )
    }

    public func fetchUserInfo() async throws(NetworkError) -> DTO.Response.FetchUserInfo {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/users/me",
                method: .get,
                task: .plain,
                authentication: .required
            )
        )
    }
}
