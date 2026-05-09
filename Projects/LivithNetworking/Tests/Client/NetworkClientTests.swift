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
    @Test("요청 URL 생성 실패는 invalidURL을 던져야 한다")
    func 요청_URL_생성_실패는_invalidURL을_던져야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "/api")))
        let sut = NetworkClient(config: config, transport: FakeTransport())
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        do {
            let _: ResponseBody = try await sut.request(endpoint)
            #expect(Bool(false))
        } catch .invalidURL {
            #expect(Bool(true))
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("CancellationError는 cancelled로 매핑해야 한다")
    func CancellationError는_cancelled로_매핑해야_한다() async throws {
        let error = try await catchValueError(transportError: CancellationError())

        guard case .cancelled = error else {
            #expect(Bool(false))
            return
        }
    }

    @Test("URLError cancelled는 cancelled로 매핑해야 한다")
    func URLError_cancelled는_cancelled로_매핑해야_한다() async throws {
        let error = try await catchValueError(transportError: URLError(.cancelled))

        guard case .cancelled = error else {
            #expect(Bool(false))
            return
        }
    }

    @Test("URLError timedOut은 timeout으로 매핑하고 원본을 보존해야 한다")
    func URLError_timedOut은_timeout으로_매핑하고_원본을_보존해야_한다() async throws {
        let error = try await catchValueError(transportError: URLError(.timedOut))

        guard case .timeout(let underlyingError) = error else {
            #expect(Bool(false))
            return
        }

        #expect((underlyingError as? URLError)?.code == .timedOut)
    }

    @Test("연결 계열 URLError는 noConnection으로 매핑해야 한다")
    func 연결_계열_URLError는_noConnection으로_매핑해야_한다() async throws {
        let codeList: [URLError.Code] = [
            .notConnectedToInternet,
            .networkConnectionLost,
            .cannotConnectToHost,
            .cannotFindHost,
            .dnsLookupFailed
        ]

        for code in codeList {
            let error = try await catchValueError(transportError: URLError(code))

            guard case .noConnection(let underlyingError) = error else {
                #expect(Bool(false))
                continue
            }

            #expect((underlyingError as? URLError)?.code == code)
        }
    }

    @Test("그 외 전송 실패는 unknown으로 매핑하고 원본을 보존해야 한다")
    func 그_외_전송_실패는_unknown으로_매핑하고_원본을_보존해야_한다() async throws {
        let error = try await catchValueError(transportError: TestError.expected)

        guard case .unknown(let underlyingError) = error else {
            #expect(Bool(false))
            return
        }

        #expect(underlyingError as? TestError == .expected)
    }

    @Test("HTTP 응답이 아니면 invalidResponse를 던져야 한다")
    func HTTP_응답이_아니면_invalidResponse를_던져야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let sut = NetworkClient(
            config: config,
            transport: FakeTransport(output: .success(Data(), URLResponse()))
        )
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

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
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        let value: ResponseBody = try await sut.request(endpoint)

        #expect(value == ResponseBody(value: "livith"))
    }

    @Test("값 응답의 400 실패는 badRequest로 매핑하고 message를 보존해야 한다")
    func 값_응답의_400_실패는_badRequest로_매핑하고_message를_보존해야_한다() async throws {
        let error = try await catchValueError(statusCode: 400, message: "bad request")

        guard case .badRequest(let message) = error else {
            #expect(Bool(false))
            return
        }

        #expect(message == "bad request")
    }

    @Test("값 응답의 401 실패는 unauthorized로 매핑하고 message를 보존해야 한다")
    func 값_응답의_401_실패는_unauthorized로_매핑하고_message를_보존해야_한다() async throws {
        let error = try await catchValueError(statusCode: 401, message: "unauthorized")

        guard case .unauthorized(let message) = error else {
            #expect(Bool(false))
            return
        }

        #expect(message == "unauthorized")
    }

    @Test("값 응답의 403 실패는 forbidden으로 매핑하고 message를 보존해야 한다")
    func 값_응답의_403_실패는_forbidden으로_매핑하고_message를_보존해야_한다() async throws {
        let error = try await catchValueError(statusCode: 403, message: "forbidden")

        guard case .forbidden(let message) = error else {
            #expect(Bool(false))
            return
        }

        #expect(message == "forbidden")
    }

    @Test("값 응답의 404 실패는 notFound로 매핑하고 message를 보존해야 한다")
    func 값_응답의_404_실패는_notFound로_매핑하고_message를_보존해야_한다() async throws {
        let error = try await catchValueError(statusCode: 404, message: "not found")

        guard case .notFound(let message) = error else {
            #expect(Bool(false))
            return
        }

        #expect(message == "not found")
    }

    @Test("기타 4xx 실패는 clientError로 매핑하고 status와 message를 보존해야 한다")
    func 기타_4xx_실패는_clientError로_매핑하고_status와_message를_보존해야_한다() async throws {
        let error = try await catchValueError(statusCode: 418, message: "teapot")

        guard case .clientError(let statusCode, let message) = error else {
            #expect(Bool(false))
            return
        }

        #expect(statusCode == 418)
        #expect(message == "teapot")
    }

    @Test("5xx 실패는 serverError로 매핑하고 status와 message를 보존해야 한다")
    func 오백번대_실패는_serverError로_매핑하고_status와_message를_보존해야_한다() async throws {
        let error = try await catchValueError(statusCode: 503, message: "maintenance")

        guard case .serverError(let statusCode, let message) = error else {
            #expect(Bool(false))
            return
        }

        #expect(statusCode == 503)
        #expect(message == "maintenance")
    }

    @Test("void 응답 실패 status는 message를 보존해야 한다")
    func void_응답_실패_status는_message를_보존해야_한다() async throws {
        let error = try await catchVoidError(statusCode: 400, message: "bad request")

        guard case .badRequest(let message) = error else {
            #expect(Bool(false))
            return
        }

        #expect(message == "bad request")
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
        let endpoint = NetworkEndpoint(path: "/concerts", method: .delete)

        do {
            try await sut.request(endpoint)
            #expect(Bool(false))
        } catch .serverError(let statusCode, let message) {
            #expect(statusCode == 500)
            #expect(message == nil)
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("값 응답 성공 status에서 wrapper data가 없으면 noData를 던져야 한다")
    func 값_응답_성공_status에서_wrapper_data가_없으면_noData를_던져야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let data = makeData("""
        {
            "statusCode": 200,
            "error": null,
            "message": "success",
            "data": null
        }
        """)
        let response = try makeResponse(statusCode: 200)
        let sut = NetworkClient(
            config: config,
            transport: FakeTransport(output: .success(data, response))
        )
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        do {
            let _: ResponseBody = try await sut.request(endpoint)
            #expect(Bool(false))
        } catch .noData {
            #expect(Bool(true))
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("값 응답 성공 status에서 decoding에 실패하면 decodingFailed를 던져야 한다")
    func 값_응답_성공_status에서_decoding에_실패하면_decodingFailed를_던져야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let data = makeData("not-json")
        let response = try makeResponse(statusCode: 200)
        let sut = NetworkClient(
            config: config,
            transport: FakeTransport(output: .success(data, response))
        )
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        do {
            let _: ResponseBody = try await sut.request(endpoint)
            #expect(Bool(false))
        } catch .decodingFailed {
            #expect(Bool(true))
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
        let endpoint = NetworkEndpoint(path: "/concerts", method: .delete)

        try await sut.request(endpoint)
    }

    @Test("HTTP 에러 설명은 서버 message를 포함해야 한다")
    func HTTP_에러_설명은_서버_message를_포함해야_한다() {
        let error = NetworkError.badRequest(message: "bad request")

        #expect(error.errorDescription?.contains("bad request") == true)
    }

    @Test("서버 message가 없어도 HTTP 에러 설명은 비어 있지 않아야 한다")
    func 서버_message가_없어도_HTTP_에러_설명은_비어_있지_않아야_한다() throws {
        let error = NetworkError.serverError(statusCode: 500, message: nil)
        let description = try #require(error.errorDescription)

        #expect(!description.isEmpty)
    }
}

private extension NetworkClientTests {
    struct ResponseBody: Decodable, Equatable {
        let value: String
    }

    func catchValueError(transportError: Error) async throws -> NetworkError {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let sut = NetworkClient(
            config: config,
            transport: FakeTransport(output: .failure(transportError))
        )
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        do {
            let _: ResponseBody = try await sut.request(endpoint)
            #expect(Bool(false))
            return .unknown(TestError.expected)
        } catch {
            return error
        }
    }

    func catchValueError(
        statusCode: Int,
        message: String?
    ) async throws -> NetworkError {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let data = makeErrorData(statusCode: statusCode, message: message)
        let response = try makeResponse(statusCode: statusCode)
        let sut = NetworkClient(
            config: config,
            transport: FakeTransport(output: .success(data, response))
        )
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        do {
            let _: ResponseBody = try await sut.request(endpoint)
            #expect(Bool(false))
            return .unknown(TestError.expected)
        } catch {
            return error
        }
    }

    func catchVoidError(
        statusCode: Int,
        message: String?
    ) async throws -> NetworkError {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let data = makeErrorData(statusCode: statusCode, message: message)
        let response = try makeResponse(statusCode: statusCode)
        let sut = NetworkClient(
            config: config,
            transport: FakeTransport(output: .success(data, response))
        )
        let endpoint = NetworkEndpoint(path: "/concerts", method: .delete)

        do {
            try await sut.request(endpoint)
            #expect(Bool(false))
            return .unknown(TestError.expected)
        } catch {
            return error
        }
    }

    func makeData(_ string: String) -> Data {
        Data(string.utf8)
    }

    func makeErrorData(
        statusCode: Int,
        message: String?
    ) -> Data {
        let messageValue = message.map { "\"\($0)\"" } ?? "null"

        return makeData("""
        {
            "statusCode": \(statusCode),
            "error": "ERROR",
            "message": \(messageValue),
            "data": null
        }
        """)
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
