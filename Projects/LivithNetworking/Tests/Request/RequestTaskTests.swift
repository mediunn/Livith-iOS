//
//  RequestTaskTests.swift
//  LivithNetworkingTests
//
//  Created by 김진웅 on 5/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import LivithNetworking

@Suite("RequestTask")
struct RequestTaskTests {
    @Test("plain은 query와 body가 없는 요청이어야 한다")
    func plain은_query와_body가_없는_요청이어야_한다() {
        let sut = RequestTask.plain

        if case .plain = sut {
            #expect(Bool(true))
        } else {
            #expect(Bool(false))
        }
    }

    @Test("query는 URLQueryItem 목록을 보관해야 한다")
    func query는_URLQueryItem_목록을_보관해야_한다() {
        let queryItems = [URLQueryItem(name: "keyword", value: "livith")]

        let sut = RequestTask.query(queryItems)

        if case .query(let storedQueryItems) = sut {
            #expect(storedQueryItems == queryItems)
        } else {
            #expect(Bool(false))
        }
    }

    @Test("body는 Encodable body를 보관해야 한다")
    func body는_Encodable_body를_보관해야_한다() {
        let body = RequestBody(value: "livith")

        let sut = RequestTask.body(body)

        if case .body(let storedBody) = sut {
            #expect(storedBody is RequestBody)
        } else {
            #expect(Bool(false))
        }
    }

    @Test("queryAndBody는 query와 body를 함께 보관해야 한다")
    func queryAndBody는_query와_body를_함께_보관해야_한다() {
        let queryItems = [URLQueryItem(name: "client", value: "mobile")]
        let body = RequestBody(value: "livith")

        let sut = RequestTask.queryAndBody(queryItems: queryItems, body: body)

        if case .queryAndBody(let storedQueryItems, let storedBody) = sut {
            #expect(storedQueryItems == queryItems)
            #expect(storedBody is RequestBody)
        } else {
            #expect(Bool(false))
        }
    }
}

private extension RequestTaskTests {
    struct RequestBody: Encodable {
        let value: String
    }
}
