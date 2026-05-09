//
//  NetworkClientTests.swift
//  LivithNetworkingTests
//
//  Created by 김진웅 on 5/9/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import LivithNetworking

@Suite("NetworkClient")
struct NetworkClientTests {
    @Test("요청 생성 실패는 requestBuildFailed로 감싸야 한다")
    func 요청_생성_실패는_requestBuildFailed로_감싸야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "/api")))
        let sut = NetworkClient(config: config, transport: FakeTransport())
        let endpoint = Endpoint(path: "/concerts", method: .get)

        do {
            let _: ResponseBody = try await sut.request(endpoint)
            #expect(Bool(false))
        } catch .requestBuildFailed(let error) {
            #expect(error == .invalidURL)
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("전송 실패는 transportFailed로 감싸야 한다")
    func 전송_실패는_transportFailed로_감싸야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let sut = NetworkClient(
            config: config,
            transport: FakeTransport(output: .failure(TestError.expected))
        )
        let endpoint = Endpoint(path: "/concerts", method: .get)

        do {
            let _: ResponseBody = try await sut.request(endpoint)
            #expect(Bool(false))
        } catch .transportFailed(let error) {
            #expect(error as? TestError == .expected)
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("HTTP 응답이 아니면 invalidResponse를 던져야 한다")
    func HTTP_응답이_아니면_invalidResponse를_던져야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let sut = NetworkClient(
            config: config,
            transport: FakeTransport(output: .success(Data(), URLResponse()))
        )
        let endpoint = Endpoint(path: "/concerts", method: .get)

        do {
            let _: ResponseBody = try await sut.request(endpoint)
            #expect(Bool(false))
        } catch .invalidResponse {
            #expect(Bool(true))
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("값 응답 성공 시 decoded value를 반환해야 한다")
    func 값_응답_성공_시_decoded_value를_반환해야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let data = makeData("""
        {
            "statusCode": 200,
            "error": null,
            "message": "success",
            "data": { "value": "livith" }
        }
        """)
        let response = try makeResponse(statusCode: 200)
        let sut = NetworkClient(
            config: config,
            transport: FakeTransport(output: .success(data, response))
        )
        let endpoint = Endpoint(path: "/concerts", method: .get)

        let value: ResponseBody = try await sut.request(endpoint)

        #expect(value == ResponseBody(value: "livith"))
    }

    @Test("값 응답 실패 status는 responseFailed로 감싸고 message를 보존해야 한다")
    func 값_응답_실패_status는_responseFailed로_감싸고_message를_보존해야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let data = makeData("""
        {
            "statusCode": 404,
            "error": "NOT_FOUND",
            "message": "not found",
            "data": null
        }
        """)
        let response = try makeResponse(statusCode: 404)
        let sut = NetworkClient(
            config: config,
            transport: FakeTransport(output: .success(data, response))
        )
        let endpoint = Endpoint(path: "/concerts", method: .get)

        do {
            let _: ResponseBody = try await sut.request(endpoint)
            #expect(Bool(false))
        } catch .responseFailed(.invalidStatusCode(let statusCode, let message)) {
            #expect(statusCode == 404)
            #expect(message == "not found")
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("void 응답 성공은 2xx status만으로 성공해야 한다")
    func void_응답_성공은_2xx_status만으로_성공해야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let response = try makeResponse(statusCode: 204)
        let sut = NetworkClient(
            config: config,
            transport: FakeTransport(output: .success(Data(), response))
        )
        let endpoint = Endpoint(path: "/concerts", method: .delete)

        try await sut.request(endpoint)
    }

    @Test("void 응답 실패 status는 message를 보존해야 한다")
    func void_응답_실패_status는_message를_보존해야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let data = makeData("""
        {
            "statusCode": 400,
            "error": "BAD_REQUEST",
            "message": "bad request",
            "data": null
        }
        """)
        let response = try makeResponse(statusCode: 400)
        let sut = NetworkClient(
            config: config,
            transport: FakeTransport(output: .success(data, response))
        )
        let endpoint = Endpoint(path: "/concerts", method: .delete)

        do {
            try await sut.request(endpoint)
            #expect(Bool(false))
        } catch .responseFailed(.invalidStatusCode(let statusCode, let message)) {
            #expect(statusCode == 400)
            #expect(message == "bad request")
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("void 응답 실패 body decode에 실패하면 message는 nil이어야 한다")
    func void_응답_실패_body_decode에_실패하면_message는_nil이어야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let data = makeData("not-json")
        let response = try makeResponse(statusCode: 500)
        let sut = NetworkClient(
            config: config,
            transport: FakeTransport(output: .success(data, response))
        )
        let endpoint = Endpoint(path: "/concerts", method: .delete)

        do {
            try await sut.request(endpoint)
            #expect(Bool(false))
        } catch .responseFailed(.invalidStatusCode(let statusCode, let message)) {
            #expect(statusCode == 500)
            #expect(message == nil)
        } catch {
            #expect(Bool(false))
        }
    }
}

private extension NetworkClientTests {
    struct Endpoint: NetworkEndpoint {
        let path: String
        let method: HTTPMethod
        let task: RequestTask
        let headers: [String: String]

        init(
            path: String,
            method: HTTPMethod,
            task: RequestTask = .plain,
            headers: [String: String] = [:]
        ) {
            self.path = path
            self.method = method
            self.task = task
            self.headers = headers
        }
    }

    struct ResponseBody: Decodable, Equatable {
        let value: String
    }

    func makeData(_ string: String) -> Data {
        Data(string.utf8)
    }

    func makeResponse(statusCode: Int) throws -> HTTPURLResponse {
        let url = try #require(URL(string: "https://api.example.com"))

        return try #require(HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        ))
    }

    enum TestError: Error, Equatable {
        case expected
    }

    struct FakeTransport: NetworkTransport {
        enum Output {
            case success(Data, URLResponse)
            case failure(Error)
        }

        let output: Output

        init(output: Output = .success(Data(), URLResponse())) {
            self.output = output
        }

        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            switch output {
            case .success(let data, let response):
                return (data, response)
            case .failure(let error):
                throw error
            }
        }
    }
}
