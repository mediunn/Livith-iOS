//
//  UserService.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - UserService

public protocol UserService: Sendable {
    func logout(refreshToken: String) async throws(NetworkError) -> DTO.Response.RequestLogout
    func checkNicknameDuplicate(nickname: String) async throws(NetworkError) -> DTO.Response.CheckNicknameDuplicate
    func updateNickname(_ nickname: String) async throws(NetworkError) -> DTO.Response.UpdateUserNickname
    func withdraw(reason: String) async throws(NetworkError) -> DTO.Response.DeleteUser
}

// MARK: - UserServiceImpl

struct UserServiceImpl: UserService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func logout(refreshToken: String) async throws(NetworkError) -> DTO.Response.RequestLogout {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/auth/logout",
                method: .post,
                task: .body(DTO.Request.RequestLogout(refreshToken: refreshToken)),
                authentication: .none
            )
        )
    }

    public func checkNicknameDuplicate(nickname: String) async throws(NetworkError) -> DTO.Response.CheckNicknameDuplicate {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/users/check-nickname",
                method: .get,
                task: .query([URLQueryItem(name: "nickname", value: nickname)]),
                authentication: .none
            )
        )
    }

    public func updateNickname(_ nickname: String) async throws(NetworkError) -> DTO.Response.UpdateUserNickname {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/users/nickname",
                method: .patch,
                task: .body(DTO.Request.UpdateUserNickname(nickname: nickname)),
                authentication: .required
            )
        )
    }

    public func withdraw(reason: String) async throws(NetworkError) -> DTO.Response.DeleteUser {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/auth/withdraw",
                method: .post,
                task: .body(DTO.Request.DeleteUser(reason: reason)),
                authentication: .required
            )
        )
    }
}
