//
//  TokenRefresher.swift
//  LivithNetwork
//
//  Created by 김진웅 on 12/7/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

typealias TokenRefreshService = NetworkService<TokenRefreshEndpoint>

final class TokenRefresher {
    private let service: TokenRefreshService
    
    init(service: TokenRefreshService = .init()) {
        self.service = service
    }
    
    func refresh(with refreshToken: String) async throws(TokenError) -> DTO.Response.UpdateToken {
        do {
            let requestBody = DTO.Request.UpdateToken(refreshToken: refreshToken)
            return try await service.request(
                TokenRefreshEndpoint.updateToken(requestBody)
            )
        } catch {
            switch error {
            case .unauthorized:
                throw .refreshTokenExpired
            case .serverError, .noConnection:
                throw .networkError
            default:
                throw .unknown
            }
        }
    }
}
