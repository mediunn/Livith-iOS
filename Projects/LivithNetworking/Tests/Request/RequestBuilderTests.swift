//
//  RequestBuilderTests.swift
//  LivithNetworkingTests
//
//  Created by 김진웅 on 5/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import LivithNetworking

@Suite("RequestBuilder")
struct RequestBuilderTests {
    @Test("baseURL과 path의 slash를 정규화해 URL을 만들어야 한다")
    func baseURL과_path의_slash를_정규화해_URL을_만들어야_한다() throws {
        let sut = RequestBuilder()
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com/")))
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        let request = try sut.make(endpoint: endpoint, config: config)

        #expect(request.url?.absoluteString == "https://api.example.com/\(TestAPIVersion.path)/concerts")
    }

    @Test("query task는 URL query에 반영해야 한다")
    func query_task는_URL_query에_반영해야_한다() throws {
        let sut = RequestBuilder()
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let endpoint = NetworkEndpoint(
            path: "search/concerts",
            method: .get,
            task: .query([URLQueryItem(name: "keyword", value: "livith")])
        )

        let request = try sut.make(endpoint: endpoint, config: config)
        let url = try #require(request.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))

        #expect(components.path == "/\(TestAPIVersion.path)/search/concerts")
        #expect(components.queryItems == [URLQueryItem(name: "keyword", value: "livith")])
    }

    @Test("method와 endpoint header를 요청에 반영해야 한다")
    func method와_endpoint_header를_요청에_반영해야_한다() throws {
        let sut = RequestBuilder()
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let endpoint = NetworkEndpoint(
            path: "/concerts",
            method: .post,
            headers: ["X-Client": "iOS"]
        )

        let request = try sut.make(endpoint: endpoint, config: config)

        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "X-Client") == "iOS")
    }

    @Test("body task는 JSON body와 Content-Type 기본값을 반영해야 한다")
    func body_task는_JSON_body와_Content_Type_기본값을_반영해야_한다() throws {
        let sut = RequestBuilder()
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let endpoint = NetworkEndpoint(
            path: "/concerts",
            method: .post,
            task: .body(RequestBody(value: "livith"))
        )

        let request = try sut.make(endpoint: endpoint, config: config)
        let body = try JSONDecoder().decode(RequestBody.self, from: try #require(request.httpBody))

        #expect(body == RequestBody(value: "livith"))
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test("queryAndBody task는 URL query와 JSON body를 함께 반영해야 한다")
    func queryAndBody_task는_URL_query와_JSON_body를_함께_반영해야_한다() throws {
        let sut = RequestBuilder()
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let endpoint = NetworkEndpoint(
            path: "/concerts",
            method: .post,
            task: .queryAndBody(
                queryItems: [URLQueryItem(name: "client", value: "mobile")],
                body: RequestBody(value: "livith")
            )
        )

        let request = try sut.make(endpoint: endpoint, config: config)
        let url = try #require(request.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let body = try JSONDecoder().decode(RequestBody.self, from: try #require(request.httpBody))

        #expect(components.queryItems == [URLQueryItem(name: "client", value: "mobile")])
        #expect(body == RequestBody(value: "livith"))
    }

    @Test("endpoint Content-Type은 기본값보다 우선해야 한다")
    func endpoint_Content_Type은_기본값보다_우선해야_한다() throws {
        let sut = RequestBuilder()
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let endpoint = NetworkEndpoint(
            path: "/concerts",
            method: .post,
            task: .body(RequestBody(value: "livith")),
            headers: ["Content-Type": "application/vnd.livith+json"]
        )

        let request = try sut.make(endpoint: endpoint, config: config)

        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/vnd.livith+json")
    }

    @Test("주입한 encoder를 body encoding에 사용해야 한다")
    func 주입한_encoder를_body_encoding에_사용해야_한다() throws {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let sut = RequestBuilder(encoder: encoder)
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let endpoint = NetworkEndpoint(
            path: "/concerts",
            method: .post,
            task: .body(StrategyBody(clientName: "livith"))
        )

        let request = try sut.make(endpoint: endpoint, config: config)
        let data = try #require(request.httpBody)
        let body = try #require(JSONSerialization.jsonObject(with: data) as? [String: String])

        #expect(body["client_name"] == "livith")
        #expect(body["clientName"] == nil)
    }

    @Test("HTTP 요청 URL로 유효하지 않으면 invalidURL을 던져야 한다")
    func HTTP_요청_URL로_유효하지_않으면_invalidURL을_던져야_한다() throws {
        let sut = RequestBuilder()
        let config = NetworkConfig(baseURL: try #require(URL(string: "/api")))
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        do {
            _ = try sut.make(endpoint: endpoint, config: config)
            #expect(Bool(false))
        } catch .invalidURL {
            #expect(Bool(true))
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("body encoding에 실패하면 encodingFailed를 던져야 한다")
    func body_encoding에_실패하면_encodingFailed를_던져야_한다() throws {
        let sut = RequestBuilder()
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let endpoint = NetworkEndpoint(
            path: "/concerts",
            method: .post,
            task: .body(FailingBody())
        )

        do {
            _ = try sut.make(endpoint: endpoint, config: config)
            #expect(Bool(false))
        } catch .encodingFailed(let error) {
            #expect(error is EncodingError)
        } catch {
            #expect(Bool(false))
        }
    }
}

private extension RequestBuilderTests {
    struct RequestBody: Codable, Equatable {
        let value: String
    }

    struct StrategyBody: Encodable {
        let clientName: String
    }

    struct FailingBody: Encodable {
        func encode(to encoder: any Encoder) throws {
            throw EncodingError.invalidValue(
                "livith",
                EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Expected failure")
            )
        }
    }
}
