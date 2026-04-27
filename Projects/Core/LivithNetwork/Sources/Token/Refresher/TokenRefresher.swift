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
        print("[TokenRefresher] 🔵 refresh(with:) 시작")
        do {
            let request = try buildRequest(refreshToken: refreshToken)
            print("[TokenRefresher] 🟡 HTTP 요청 전송")
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("[TokenRefresher] ❌ refresh(with:) 실패: 유효하지 않은 HTTP 응답")
                throw TokenError.unknown
            }
            
            if let dataString = String(data: data, encoding: .utf8) {
                print("[TokenRefresher] 🔍 원본 데이터: \(dataString)")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw mapStatusCodeToError(httpResponse.statusCode)
            }
            
            let result: BaseResponse<DTO.Response.UpdateToken>
            do {
                result = try decoder.decode(BaseResponse<DTO.Response.UpdateToken>.self, from: data)
            } catch {
                print("[TokenRefresher] ❌ refresh(with:) 실패: 응답 디코딩 실패 - \(error)")
                throw TokenError.refresh(.decodingFailed)
            }
            
            guard let data = result.data else {
                print("[TokenRefresher] ❌ refresh(with:) 실패: 응답 데이터 없음")
                throw TokenError.refresh(.emptyResponse)
            }
            print("[TokenRefresher] ✅ refresh(with:) 완료")
            return data
        } catch let error as TokenError {
            throw error
        } catch {
            throw TokenError.refresh(.noConnection)
        }
    }
    
    private func buildRequest(refreshToken: String) throws -> URLRequest {
        print("[TokenRefresher] 🟡 buildRequest(refreshToken:) 시작, refreshToken: \(refreshToken)")
        var components = URLComponents(
            url: Bundle.baseURL.appendingPathComponent(Literals.tokenRefreshPath),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [URLQueryItem(name: Literals.clientQueryKey, value: Literals.clientQueryValue)]
        guard let url = components?.url else {
            print("[TokenRefresher] ❌ buildRequest(refreshToken:) 실패: URL 생성 실패")
            throw TokenError.unknown
        }
        
        print("[TokenRefresher] 🟡 URL 생성 완료: \(url.absoluteString)")
        var request = URLRequest(url: url)
        request.httpMethod = Literals.postMethod
        request.setValue(Literals.contentTypeValue, forHTTPHeaderField: Literals.contentTypeKey)
        
        let requestBody = DTO.Request.UpdateToken(refreshToken: refreshToken)
        request.httpBody = try encoder.encode(requestBody)
        
        return request
    }

    private func mapStatusCodeToError(_ statusCode: Int) -> TokenError {
        let error = switch statusCode {
        case 400:
            TokenError.refresh(.badRequest)
        case 401:
            TokenError.refresh(.unauthorized)
        case 403:
            TokenError.refresh(.forbidden)
        case 404:
            TokenError.refresh(.notFound)
        case 400...499:
            TokenError.refresh(.unauthorized)
        case 500...599:
            TokenError.refresh(.serverError)
        default:
            TokenError.unknown
        }
        print("[TokenRefresher] ❌ HTTP 오류 발생: 상태 코드 \(statusCode), 오류: \(error)")
        return error
    }
}

// MARK: - Literals

private extension TokenRefresher {
    enum Literals {
        static let tokenRefreshPath = "auth/refresh"
        static let clientQueryKey = "client"
        static let clientQueryValue = "mobile"
        static let postMethod = "POST"
        static let contentTypeKey = "Content-Type"
        static let contentTypeValue = "application/json"
    }
}
