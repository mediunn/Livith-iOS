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
        let sut = MinimalEndpoint()

        #expect(sut.path == "/concerts")
        #expect(sut.method == .get)
    }

    @Test("task 기본값은 plain이어야 한다")
    func task_기본값은_plain이어야_한다() {
        let sut = MinimalEndpoint()

        if case .plain = sut.task {
            #expect(Bool(true))
        } else {
            #expect(Bool(false))
        }
    }

    @Test("headers 기본값은 빈 딕셔너리여야 한다")
    func headers_기본값은_빈_딕셔너리여야_한다() {
        let sut = MinimalEndpoint()

        #expect(sut.headers.isEmpty)
    }

    @Test("requiresAuthentication 기본값은 true여야 한다")
    func requiresAuthentication_기본값은_true여야_한다() {
        let sut = MinimalEndpoint()

        #expect(sut.requiresAuthentication)
    }

    @Test("task와 headers와 requiresAuthentication을 재정의할 수 있어야 한다")
    func task와_headers와_requiresAuthentication을_재정의할_수_있어야_한다() {
        let sut = CustomEndpoint()

        if case .query(let queryItems) = sut.task {
            #expect(queryItems == [URLQueryItem(name: "keyword", value: "livith")])
        } else {
            #expect(Bool(false))
        }

        #expect(sut.headers == ["X-Client": "iOS"])
        #expect(!sut.requiresAuthentication)
    }
}

private extension NetworkEndpointTests {
    struct MinimalEndpoint: NetworkEndpoint {
        let path: String = "/concerts"
        let method: HTTPMethod = .get
    }

    struct CustomEndpoint: NetworkEndpoint {
        let path: String = "/search/concerts"
        let method: HTTPMethod = .get
        let task: RequestTask = .query([URLQueryItem(name: "keyword", value: "livith")])
        let headers: [String: String] = ["X-Client": "iOS"]
        let requiresAuthentication: Bool = false
    }
}
