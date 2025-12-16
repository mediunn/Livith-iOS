//
//  TokenRefresher.swift
//  LivithNetwork
//
//  Created by 김진웅 on 12/7/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

struct TokenRefresher {
    private let urlSession: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init(
        urlSession: URLSession = .shared,
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init()
    ) {
        self.urlSession = urlSession
        self.encoder = encoder
        self.decoder = decoder
    }
    
    func refresh(with refreshToken: String) async throws(TokenError) -> DTO.Response.UpdateToken {
        do {
            let request = try buildRequest(refreshToken: refreshToken)
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw TokenError.unknown
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 {
                    throw TokenError.refreshTokenExpired
                } else {
                    throw TokenError.networkError
                }
            }
            
            let result = try decoder.decode(BaseResponse<DTO.Response.UpdateToken>.self, from: data)
            
            guard let data = result.data else {
                throw TokenError.noData
            }
            return data
        } catch let error as TokenError {
            throw error
        } catch {
            throw .networkError
        }
    }
    
    private func buildRequest(refreshToken: String) throws -> URLRequest {
        var components = URLComponents(
            url: Bundle.baseURL.appendingPathComponent(Literals.tokenRefreshPath),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [URLQueryItem(name: Literals.clientQueryKey, value: Literals.clientQueryValue)]
        guard let url = components?.url else {
            throw TokenError.unknown
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = Literals.postMethod
        request.setValue(Literals.contentTypeValue, forHTTPHeaderField: Literals.contentTypeKey)
        
        let requestBody = DTO.Request.UpdateToken(refreshToken: refreshToken)
        request.httpBody = try encoder.encode(requestBody)
        
        return request
    }
}

// MARK: - Literals

private extension TokenRefresher {
    enum Literals {
        static let tokenRefreshPath = "/api/v4/auth/refresh"
        static let clientQueryKey = "client"
        static let clientQueryValue = "mobile"
        static let postMethod = "POST"
        static let contentTypeKey = "Content-Type"
        static let contentTypeValue = "application/json"
    }
}
