//
//  HTTPTestResponseFactory.swift
//  LivithNetworkingTests
//
//  Created by 김진웅 on 5/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

struct HTTPTestResponseFactory {
    private let baseURL: URL

    init(baseURL: URL? = URL(string: "https://api.example.com")) throws {
        self.baseURL = try #require(baseURL)
    }

    func data(_ string: String) -> Data {
        Data(string.utf8)
    }

    func errorData(
        statusCode: Int,
        message: String?
    ) -> Data {
        let messageValue = message.map { "\"\($0)\"" } ?? "null"

        return data("""
        {
            "statusCode": \(statusCode),
            "error": "ERROR",
            "message": \(messageValue),
            "data": null
        }
        """)
    }

    func response(
        statusCode: Int,
        url: URL? = nil,
        headerFields: [String: String]? = nil
    ) throws -> HTTPURLResponse {
        try #require(HTTPURLResponse(
            url: url ?? baseURL,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: headerFields
        ))
    }
}
