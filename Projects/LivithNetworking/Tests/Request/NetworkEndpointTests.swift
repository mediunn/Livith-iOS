//
//  NetworkEndpointTests.swift
//  LivithNetworkingTests
//
//  Created by 김진웅 on 5/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import LivithNetworking

@Suite("NetworkEndpoint")
struct NetworkEndpointTests {
    @Test("필수 path와 method를 제공해야 한다")
    func 필수_path와_method를_제공해야_한다() {
        let sut = NetworkEndpoint(path: "/concerts", method: .get)

        #expect(sut.path == "/concerts")
        #expect(sut.method == .get)
    }

    @Test("task 기본값은 plain이어야 한다")
    func task_기본값은_plain이어야_한다() {
        let sut = NetworkEndpoint(path: "/concerts", method: .get)

        if case .plain = sut.task {
            #expect(Bool(true))
        } else {
            #expect(Bool(false))
        }
    }

    @Test("headers 기본값은 빈 딕셔너리여야 한다")
    func headers_기본값은_빈_딕셔너리여야_한다() {
        let sut = NetworkEndpoint(path: "/concerts", method: .get)

        #expect(sut.headers.isEmpty)
    }

    @Test("authentication 기본값은 required여야 한다")
    func authentication_기본값은_required여야_한다() {
        let sut = NetworkEndpoint(path: "/concerts", method: .get)

        #expect(sut.authentication == .required)
    }

    @Test("cache 기본값은 disabled여야 한다")
    func cache_기본값은_disabled여야_한다() {
        let sut = NetworkEndpoint(path: "/concerts", method: .get)

        #expect(sut.cache == .disabled)
    }

    @Test("authentication과 cache를 재정의할 수 있어야 한다")
    func authentication과_cache를_재정의할_수_있어야_한다() {
        let sut = NetworkEndpoint(
            path: "/search/concerts",
            method: .get,
            task: .query([URLQueryItem(name: "keyword", value: "livith")]),
            headers: ["X-Client": "iOS"],
            authentication: .none,
            cache: .enabled
        )

        if case .query(let queryItems) = sut.task {
            #expect(queryItems == [URLQueryItem(name: "keyword", value: "livith")])
        } else {
            #expect(Bool(false))
        }

        #expect(sut.headers == ["X-Client": "iOS"])
        #expect(sut.authentication == .none)
        #expect(sut.cache == .enabled)
    }
}
