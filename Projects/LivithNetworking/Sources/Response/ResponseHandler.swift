//
//  ResponseHandler.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

struct ResponseHandler: Sendable {
    private let decoder: JSONDecoder

    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    func handle<T: Decodable>(
        _ type: T.Type,
        data: Data,
        response: HTTPURLResponse
    ) throws(ResponseError) -> T {
        guard (200..<300).contains(response.statusCode) else {
            let message = try? decoder.decode(ServerResponse<EmptyResponse>.self, from: data).message
            throw .invalidStatusCode(response.statusCode, message: message)
        }

        do {
            let serverResponse = try decoder.decode(ServerResponse<T>.self, from: data)

            if let data = serverResponse.data {
                return data
            }

            if T.self == EmptyResponse.self {
                return EmptyResponse() as! T
            }

            throw ResponseError.noData
        } catch let error as ResponseError {
            throw error
        } catch {
            throw .decodingFailed(error)
        }
    }
}
