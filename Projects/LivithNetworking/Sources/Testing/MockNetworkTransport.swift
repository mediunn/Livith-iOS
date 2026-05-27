//
//  MockNetworkTransport.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - MockNetworkTransport

public actor MockNetworkTransport: NetworkTransport {
    public enum Output {
        case success(Data, URLResponse)
        case failure(any Error)
    }

    private var requestList: [URLRequest] = []
    private let outputList: [Output]
    private let delayNanoseconds: UInt64
    private var index = 0

    public init(
        output: Output = .success(Data(), URLResponse()),
        delayNanoseconds: UInt64 = 0
    ) {
        self.outputList = [output]
        self.delayNanoseconds = delayNanoseconds
    }

    public init(
        outputList: [Output],
        delayNanoseconds: UInt64 = 0
    ) {
        self.outputList = outputList
        self.delayNanoseconds = delayNanoseconds
    }

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requestList.append(request)

        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }

        let output = outputList[min(index, outputList.count - 1)]
        index += 1

        switch output {
        case .success(let data, let response):
            return (data, response)
        case .failure(let error):
            throw error
        }
    }

    public func request() -> URLRequest? {
        requestList.last
    }

    public func requests() -> [URLRequest] {
        requestList
    }
}
