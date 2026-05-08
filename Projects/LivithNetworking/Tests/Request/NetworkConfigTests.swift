//
//  NetworkConfigTests.swift
//  LivithNetworkingTests
//
//  Created by 김진웅 on 5/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import LivithNetworking

@Suite("NetworkConfig")
struct NetworkConfigTests {
    @Test("주입한 baseURL을 그대로 보관해야 한다")
    func 주입한_baseURL을_그대로_보관해야_한다() throws {
        let baseURL = try #require(URL(string: "https://api.livith.com"))

        let sut = NetworkConfig(baseURL: baseURL)

        #expect(sut.baseURL == baseURL)
    }

    @Test("비동기 요청 흐름에서 전달할 수 있도록 Sendable이어야 한다")
    func 비동기_요청_흐름에서_전달할_수_있도록_Sendable이어야_한다() throws {
        let baseURL = try #require(URL(string: "https://api.livith.com"))
        let sut = NetworkConfig(baseURL: baseURL)

        Self.assertSendable(sut)
    }

    private static func assertSendable<T: Sendable>(_ value: T) {
        _ = value
    }
}
