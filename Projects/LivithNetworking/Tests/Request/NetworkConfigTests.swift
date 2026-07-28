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
    @Test("baseURL에 api 버전 prefix가 자동으로 추가되어야 한다")
    func baseURL에_api_version_prefix가_자동_추가되어야_한다() throws {
        let baseURL = try #require(URL(string: "https://api.livith.com"))

        let sut = NetworkConfig(baseURL: baseURL)

        #expect(sut.baseURL == URL(string: "https://api.livith.com/\(TestAPIVersion.path)")!)
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
