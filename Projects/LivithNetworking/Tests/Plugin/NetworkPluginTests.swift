//
//  NetworkPluginTests.swift
//  LivithNetworkingTests
//
//  Created by 김진웅 on 5/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import LivithNetworking

@Suite("NetworkPlugin")
struct NetworkPluginTests {
    @Test("기본 prepare는 원본 요청을 반환해야 한다")
    func 기본_prepare는_원본_요청을_반환해야_한다() async throws {
        let sut = EmptyNetworkPlugin()
        let request = URLRequest(url: try #require(URL(string: "https://api.example.com/concerts")))
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        let preparedRequest = try await sut.prepare(request, endpoint: endpoint)

        #expect(preparedRequest == request)
    }
}

private struct EmptyNetworkPlugin: NetworkPlugin {}
