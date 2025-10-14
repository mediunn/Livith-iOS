//
//  ResponseHandler.swift
//  network
//
//  Created by Youjin Lee on 10/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public protocol ResponseHandlerProtocol {
    func handle<T: Decodable>(data: Data, response: HTTPURLResponse) async throws(NetworkError) -> T
}

public final class ResponseHandler: ResponseHandlerProtocol {
    private let decoder: JSONDecoder

    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    public func handle<T: Decodable>(data: Data, response: HTTPURLResponse) async throws(NetworkError) -> T {
        let statusCode = response.statusCode

        guard (200..<300).contains(statusCode) else {
            let errorMessage = try? decoder.decode(BaseResponse<EmptyResponse>.self, from: data).message
            throw NetworkError.from(statusCode: statusCode, message: errorMessage)
        }
        
        do {
            let decodedValue = try decoder.decode(T.self, from: data)
            return decodedValue
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
