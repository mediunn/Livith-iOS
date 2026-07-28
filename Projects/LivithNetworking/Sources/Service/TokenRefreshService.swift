//
//  TokenRefreshService.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - TokenRefreshService

protocol TokenRefreshService: Sendable {
    func refresh(with refreshToken: String) async throws(NetworkError) -> Token
}

// MARK: - TokenRefreshServiceImpl

actor TokenRefreshServiceImpl: TokenRefreshService {
    private let networkClient: NetworkClient
    private var refreshTask: Task<Token, any Error>?

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func refresh(with refreshToken: String) async throws(NetworkError) -> Token {
        if let refreshTask {
            return try await value(from: refreshTask)
        }

        let task = Task {
            try await self.performRefresh(with: refreshToken)
        }
        refreshTask = task

        defer { refreshTask = nil }

        return try await value(from: task)
    }
}

private extension TokenRefreshServiceImpl {
    func performRefresh(with refreshToken: String) async throws(NetworkError) -> Token {
        let response: DTO.Response.Token = try await networkClient.request(
            NetworkEndpoint(
                path: Literals.path,
                method: .post,
                task: .queryAndBody(
                    queryItems: [URLQueryItem(name: Literals.clientQueryKey, value: Literals.clientQueryValue)],
                    body: DTO.Request.Token(refreshToken: refreshToken)
                ),
                authentication: .none
            )
        )

        return Token(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            refreshTokenIssuedAt: .now
        )
    }

    func value(from task: Task<Token, any Error>) async throws(NetworkError) -> Token {
        do {
            return try await task.value
        } catch let error as NetworkError {
            throw error
        } catch {
            throw .unknown(error)
        }
    }

    enum Literals {
        static let path = "/auth/refresh"
        static let clientQueryKey = "client"
        static let clientQueryValue = "mobile"
    }
}
