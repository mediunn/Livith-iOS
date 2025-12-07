//
//  TokenRefreshService.swift
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
            let response: BaseResponse<DTO.Response.UpdateToken> = try await service.request(
                TokenRefreshEndpoint.updateToken(requestBody)
            )
            
            guard let data = response.data else {
                throw TokenError.noData
            }
            return data
        } catch let error as NetworkError {
            switch error {
            case .unauthorized:
                throw TokenError.expired
            case .noData:
                throw TokenError.noData
            case .noConnection:
                throw TokenError.noConnection
            default:
                throw TokenError.networkError
            }
        } catch {
            throw TokenError.unknown
        }
    }
}
