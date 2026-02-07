//
//  AuthenticationInterceptor.swift
//  LivithNetwork
//
//  Created by 김진웅 on 12/11/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Alamofire

public final class AuthenticationInterceptor: RequestInterceptor {
    private let tokenService: TokenService
    
    public init(tokenService: TokenService = TokenServiceImpl()) {
        self.tokenService = tokenService
    }
    
    public func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, any Error>) -> Void
    ) {
        Task {
            do {
                let accessToken = try await tokenService.getAccessToken()

                var adaptedRequest = urlRequest
                adaptedRequest.headers.add(.authorization(bearerToken: accessToken))
                completion(.success(adaptedRequest))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 
        else {
            completion(.doNotRetry)
            return
        }

        Task {
            do {
                try await tokenService.refresh()
                completion(.retry)
            } catch {
                completion(.doNotRetry)
            }
        }
    }
}
