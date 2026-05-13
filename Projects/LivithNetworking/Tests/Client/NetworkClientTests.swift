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
        let sut = NetworkClient(config: config, transport: TestNetworkTransport())
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
            transport: TestNetworkTransport(output: .success(Data(), URLResponse()))
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
        let data = try HTTPTestResponseFactory().data("""
        {
            "statusCode": 200,
            "error": null,
            "message": "success",
            "data": { "value": "livith" }
        }
        """)
        let response = try HTTPTestResponseFactory().response(statusCode: 200)
        let sut = NetworkClient(
            config: config,
            transport: TestNetworkTransport(output: .success(data, response))
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
        let data = try HTTPTestResponseFactory().data("not-json")
        let response = try HTTPTestResponseFactory().response(statusCode: 500)
        let sut = NetworkClient(
            config: config,
            transport: TestNetworkTransport(output: .success(data, response))
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
        let data = try HTTPTestResponseFactory().data("""
        {
            "statusCode": 200,
            "error": null,
            "message": "success",
            "data": null
        }
        """)
        let response = try HTTPTestResponseFactory().response(statusCode: 200)
        let sut = NetworkClient(
            config: config,
            transport: TestNetworkTransport(output: .success(data, response))
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
        let data = try HTTPTestResponseFactory().data("not-json")
        let response = try HTTPTestResponseFactory().response(statusCode: 200)
        let sut = NetworkClient(
            config: config,
            transport: TestNetworkTransport(output: .success(data, response))
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
        let response = try HTTPTestResponseFactory().response(statusCode: 204)
        let sut = NetworkClient(
            config: config,
            transport: TestNetworkTransport(output: .success(Data(), response))
        )
        let endpoint = NetworkEndpoint(path: "/concerts", method: .delete)

        try await sut.request(endpoint)
    }

    @Test("HTTP 에러 설명은 서버 message를 포함해야 한다")
    func HTTP_에러_설명은_서버_message를_포함해야_한다() {
        let error = NetworkError.badRequest(message: "bad request")

        #expect(error.errorDescription?.contains("bad request") == true)
    }

    @Test("인증 endpoint는 interceptor가 적용된 요청을 전송해야 한다")
    func 인증_endpoint는_interceptor가_적용된_요청을_전송해야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let transport = TestNetworkTransport(
            output: .success(Data(), try HTTPTestResponseFactory().response(statusCode: 204))
        )
        let interceptor = SpyRequestInterceptor()
        let sut = NetworkClient(
            config: config,
            transport: transport,
            interceptor: interceptor
        )
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        try await sut.request(endpoint)

        let request = try #require(await transport.request())
        #expect(request.value(forHTTPHeaderField: "X-Intercepted") == "true")
        #expect(await interceptor.adaptCallCount() == 1)
    }

    @Test("비인증 endpoint는 interceptor를 호출하지 않고 원본 요청을 전송해야 한다")
    func 비인증_endpoint는_interceptor를_호출하지_않고_원본_요청을_전송해야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let transport = TestNetworkTransport(
            output: .success(Data(), try HTTPTestResponseFactory().response(statusCode: 204))
        )
        let interceptor = SpyRequestInterceptor()
        let sut = NetworkClient(
            config: config,
            transport: transport,
            interceptor: interceptor
        )
        let endpoint = NetworkEndpoint(
            path: "/concerts",
            method: .get,
            requiresAuthentication: false
        )

        try await sut.request(endpoint)

        let request = try #require(await transport.request())
        #expect(request.value(forHTTPHeaderField: "X-Intercepted") == nil)
        #expect(await interceptor.adaptCallCount() == 0)
    }

    @Test("인증 endpoint의 adapt 실패는 NetworkError로 전달해야 한다")
    func 인증_endpoint의_adapt_실패는_NetworkError로_전달해야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let transport = TestNetworkTransport(
            output: .success(Data(), try HTTPTestResponseFactory().response(statusCode: 204))
        )
        let interceptor = SpyRequestInterceptor(error: .unauthorized(message: nil))
        let sut = NetworkClient(
            config: config,
            transport: transport,
            interceptor: interceptor
        )
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        do {
            try await sut.request(endpoint)
            #expect(Bool(false))
        } catch .unauthorized(let message) {
            #expect(message == nil)
            #expect(await interceptor.adaptCallCount() == 1)
            #expect(await transport.request() == nil)
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("인증 endpoint는 401 후 retry 요청을 새로 adapt해 재전송해야 한다")
    func 인증_endpoint는_401_후_retry_요청을_새로_adapt해_재전송해야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let fixture = try HTTPTestResponseFactory()
        let transport = TestNetworkTransport(
            outputList: [
                .success(fixture.errorData(statusCode: 401, message: "expired"), try fixture.response(statusCode: 401)),
                .success(fixture.data("""
                {
                    "statusCode": 200,
                    "error": null,
                    "message": "success",
                    "data": { "value": "livith" }
                }
                """), try fixture.response(statusCode: 200))
            ]
        )
        let interceptor = SpyRequestInterceptor(
            authorizationValueList: ["Bearer old-access-token", "Bearer new-access-token"],
            retryResult: .retry
        )
        let sut = NetworkClient(
            config: config,
            transport: transport,
            interceptor: interceptor
        )
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        let value: ResponseBody = try await sut.request(endpoint)

        let requestList = await transport.requests()
        #expect(value == ResponseBody(value: "livith"))
        #expect(requestList.count == 2)
        #expect(requestList.first?.value(forHTTPHeaderField: "Authorization") == "Bearer old-access-token")
        #expect(requestList.last?.value(forHTTPHeaderField: "Authorization") == "Bearer new-access-token")
        #expect(await interceptor.adaptCallCount() == 2)
        #expect(await interceptor.retryCallCount() == 1)
    }

    @Test("인증 endpoint의 refresh 실패는 재전송하지 않고 NetworkError로 전달해야 한다")
    func 인증_endpoint의_refresh_실패는_재전송하지_않고_NetworkError로_전달해야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let fixture = try HTTPTestResponseFactory()
        let transport = TestNetworkTransport(
            outputList: [
                .success(fixture.errorData(statusCode: 401, message: "expired"), try fixture.response(statusCode: 401))
            ]
        )
        let interceptor = SpyRequestInterceptor(
            authorizationValueList: ["Bearer old-access-token"],
            retryError: .unauthorized(message: nil)
        )
        let sut = NetworkClient(
            config: config,
            transport: transport,
            interceptor: interceptor
        )
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        do {
            let _: ResponseBody = try await sut.request(endpoint)
            #expect(Bool(false))
        } catch .unauthorized(let message) {
            #expect(message == nil)
            #expect(await transport.requests().count == 1)
            #expect(await interceptor.retryCallCount() == 1)
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("인증 endpoint는 두 번째 401에서 무한 재시도하지 않아야 한다")
    func 인증_endpoint는_두_번째_401에서_무한_재시도하지_않아야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let fixture = try HTTPTestResponseFactory()
        let transport = TestNetworkTransport(
            outputList: [
                .success(fixture.errorData(statusCode: 401, message: "first"), try fixture.response(statusCode: 401)),
                .success(fixture.errorData(statusCode: 401, message: "second"), try fixture.response(statusCode: 401))
            ]
        )
        let interceptor = SpyRequestInterceptor(
            authorizationValueList: ["Bearer old-access-token", "Bearer new-access-token"],
            retryResult: .retry
        )
        let sut = NetworkClient(
            config: config,
            transport: transport,
            interceptor: interceptor
        )
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        do {
            let _: ResponseBody = try await sut.request(endpoint)
            #expect(Bool(false))
        } catch .unauthorized(let message) {
            #expect(message == "second")
            #expect(await transport.requests().count == 2)
            #expect(await interceptor.retryCallCount() == 1)
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("비인증 endpoint는 401이어도 retry hook을 호출하지 않아야 한다")
    func 비인증_endpoint는_401이어도_retry_hook을_호출하지_않아야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let fixture = try HTTPTestResponseFactory()
        let transport = TestNetworkTransport(
            outputList: [
                .success(fixture.errorData(statusCode: 401, message: "unauthorized"), try fixture.response(statusCode: 401))
            ]
        )
        let interceptor = SpyRequestInterceptor(retryResult: .retry)
        let sut = NetworkClient(
            config: config,
            transport: transport,
            interceptor: interceptor
        )
        let endpoint = NetworkEndpoint(
            path: "/concerts",
            method: .get,
            requiresAuthentication: false
        )

        do {
            let _: ResponseBody = try await sut.request(endpoint)
            #expect(Bool(false))
        } catch .unauthorized(let message) {
            #expect(message == "unauthorized")
            #expect(await transport.requests().count == 1)
            #expect(await interceptor.adaptCallCount() == 0)
            #expect(await interceptor.retryCallCount() == 0)
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("plugin prepare가 수정한 요청을 전송해야 한다")
    func plugin_prepare가_수정한_요청을_전송해야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let transport = TestNetworkTransport(
            output: .success(Data(), try HTTPTestResponseFactory().response(statusCode: 204))
        )
        let plugin = HeaderAppendingPlugin(suffix: "prepared")
        let sut = NetworkClient(
            config: config,
            transport: transport,
            plugins: [plugin]
        )
        let endpoint = NetworkEndpoint(path: "/concerts", method: .delete)

        try await sut.request(endpoint)

        let request = try #require(await transport.request())
        #expect(request.value(forHTTPHeaderField: "X-Plugin-Order") == "prepared")
    }

    @Test("여러 plugin prepare는 배열 순서대로 적용해야 한다")
    func 여러_plugin_prepare는_배열_순서대로_적용해야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let transport = TestNetworkTransport(
            output: .success(Data(), try HTTPTestResponseFactory().response(statusCode: 204))
        )
        let sut = NetworkClient(
            config: config,
            transport: transport,
            plugins: [
                HeaderAppendingPlugin(suffix: "1"),
                HeaderAppendingPlugin(suffix: "2")
            ]
        )
        let endpoint = NetworkEndpoint(path: "/concerts", method: .delete)

        try await sut.request(endpoint)

        let request = try #require(await transport.request())
        #expect(request.value(forHTTPHeaderField: "X-Plugin-Order") == "12")
    }

    @Test("plugin은 성공 응답의 willSend와 didReceive를 호출해야 한다")
    func plugin은_성공_응답의_willSend와_didReceive를_호출해야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let transport = TestNetworkTransport(
            output: .success(Data(), try HTTPTestResponseFactory().response(statusCode: 204))
        )
        let plugin = LifecyclePlugin()
        let sut = NetworkClient(
            config: config,
            transport: transport,
            plugins: [plugin]
        )
        let endpoint = NetworkEndpoint(path: "/concerts", method: .delete)

        try await sut.request(endpoint)

        #expect(await plugin.willSendCallCount() == 1)
        #expect(await plugin.successStatusCodeList() == [204])
    }

    @Test("transport 실패는 plugin didReceive failure로 전달해야 한다")
    func transport_실패는_plugin_didReceive_failure로_전달해야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let transport = TestNetworkTransport(output: .failure(URLError(.timedOut)))
        let plugin = LifecyclePlugin()
        let sut = NetworkClient(
            config: config,
            transport: transport,
            plugins: [plugin]
        )
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        do {
            let _: ResponseBody = try await sut.request(endpoint)
            #expect(Bool(false))
        } catch .timeout {
            #expect(await plugin.failureCallCount() == 1)
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("HTTP 응답이 아니면 plugin didReceive failure로 invalidResponse를 전달해야 한다")
    func HTTP_응답이_아니면_plugin_didReceive_failure로_invalidResponse를_전달해야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let transport = TestNetworkTransport(output: .success(Data(), URLResponse()))
        let plugin = LifecyclePlugin()
        let sut = NetworkClient(
            config: config,
            transport: transport,
            plugins: [plugin]
        )
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        do {
            let _: ResponseBody = try await sut.request(endpoint)
            #expect(Bool(false))
        } catch .invalidResponse {
            #expect(await plugin.didReceiveInvalidResponse())
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("plugin prepare 실패는 전송하지 않고 에러를 전달해야 한다")
    func plugin_prepare_실패는_전송하지_않고_에러를_전달해야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let transport = TestNetworkTransport(
            output: .success(Data(), try HTTPTestResponseFactory().response(statusCode: 204))
        )
        let plugin = FailingPreparePlugin(error: .invalidURL)
        let sut = NetworkClient(
            config: config,
            transport: transport,
            plugins: [plugin]
        )
        let endpoint = NetworkEndpoint(path: "/concerts", method: .delete)

        do {
            try await sut.request(endpoint)
            #expect(Bool(false))
        } catch .invalidURL {
            #expect(await transport.request() == nil)
            #expect(await plugin.didReceiveCallCount() == 0)
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("interceptor adapt 실패는 plugin didReceive를 호출하지 않아야 한다")
    func interceptor_adapt_실패는_plugin_didReceive를_호출하지_않아야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let transport = TestNetworkTransport(
            output: .success(Data(), try HTTPTestResponseFactory().response(statusCode: 204))
        )
        let interceptor = SpyRequestInterceptor(error: .unauthorized(message: nil))
        let plugin = LifecyclePlugin()
        let sut = NetworkClient(
            config: config,
            transport: transport,
            interceptor: interceptor,
            plugins: [plugin]
        )
        let endpoint = NetworkEndpoint(path: "/concerts", method: .delete)

        do {
            try await sut.request(endpoint)
            #expect(Bool(false))
        } catch .unauthorized(let message) {
            #expect(message == nil)
            #expect(await plugin.prepareCallCount() == 1)
            #expect(await plugin.willSendCallCount() == 0)
            #expect(await plugin.didReceiveCallCount() == 0)
            #expect(await transport.request() == nil)
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("401 retry는 첫 요청과 재시도 요청 모두 plugin hook을 호출해야 한다")
    func 사백일_retry는_첫_요청과_재시도_요청_모두_plugin_hook을_호출해야_한다() async throws {
        let config = NetworkConfig(baseURL: try #require(URL(string: "https://api.example.com")))
        let fixture = try HTTPTestResponseFactory()
        let transport = TestNetworkTransport(
            outputList: [
                .success(fixture.errorData(statusCode: 401, message: "expired"), try fixture.response(statusCode: 401)),
                .success(Data(), try fixture.response(statusCode: 204))
            ]
        )
        let interceptor = SpyRequestInterceptor(retryResult: .retry)
        let plugin = LifecyclePlugin()
        let sut = NetworkClient(
            config: config,
            transport: transport,
            interceptor: interceptor,
            plugins: [plugin]
        )
        let endpoint = NetworkEndpoint(path: "/concerts", method: .delete)

        try await sut.request(endpoint)

        #expect(await plugin.prepareCallCount() == 2)
        #expect(await plugin.willSendCallCount() == 2)
        #expect(await plugin.successStatusCodeList() == [401, 204])
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
            transport: TestNetworkTransport(output: .failure(transportError))
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
        let data = try HTTPTestResponseFactory().errorData(statusCode: statusCode, message: message)
        let response = try HTTPTestResponseFactory().response(statusCode: statusCode)
        let sut = NetworkClient(
            config: config,
            transport: TestNetworkTransport(output: .success(data, response))
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
        let data = try HTTPTestResponseFactory().errorData(statusCode: statusCode, message: message)
        let response = try HTTPTestResponseFactory().response(statusCode: statusCode)
        let sut = NetworkClient(
            config: config,
            transport: TestNetworkTransport(output: .success(data, response))
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

    enum TestError: Error, Equatable {
        case expected
    }

    actor HeaderAppendingPlugin: NetworkPlugin {
        private let suffix: String

        init(suffix: String) {
            self.suffix = suffix
        }

        func prepare(
            _ request: URLRequest,
            endpoint: NetworkEndpoint
        ) async throws(NetworkError) -> URLRequest {
            var preparedRequest = request
            let currentValue = preparedRequest.value(forHTTPHeaderField: "X-Plugin-Order") ?? ""
            preparedRequest.setValue(currentValue + suffix, forHTTPHeaderField: "X-Plugin-Order")
            return preparedRequest
        }
    }

    actor FailingPreparePlugin: NetworkPlugin {
        private let error: NetworkError
        private var didReceiveCount = 0

        init(error: NetworkError) {
            self.error = error
        }

        func prepare(
            _ request: URLRequest,
            endpoint: NetworkEndpoint
        ) async throws(NetworkError) -> URLRequest {
            throw error
        }

        func didReceive(
            _ result: Result<NetworkPluginResponse, NetworkError>,
            request: URLRequest,
            endpoint: NetworkEndpoint
        ) async {
            didReceiveCount += 1
        }

        func didReceiveCallCount() -> Int {
            didReceiveCount
        }
    }

    actor LifecyclePlugin: NetworkPlugin {
        private var prepareCount = 0
        private var willSendCount = 0
        private var successStatusCodeListValue: [Int] = []
        private var failureList: [NetworkError] = []

        func prepare(
            _ request: URLRequest,
            endpoint: NetworkEndpoint
        ) async throws(NetworkError) -> URLRequest {
            prepareCount += 1
            return request
        }

        func willSend(
            _ request: URLRequest,
            endpoint: NetworkEndpoint
        ) async {
            willSendCount += 1
        }

        func didReceive(
            _ result: Result<NetworkPluginResponse, NetworkError>,
            request: URLRequest,
            endpoint: NetworkEndpoint
        ) async {
            switch result {
            case .success(let response):
                successStatusCodeListValue.append(response.response.statusCode)
            case .failure(let error):
                failureList.append(error)
            }
        }

        func prepareCallCount() -> Int {
            prepareCount
        }

        func willSendCallCount() -> Int {
            willSendCount
        }

        func successStatusCodeList() -> [Int] {
            successStatusCodeListValue
        }

        func failureCallCount() -> Int {
            failureList.count
        }

        func didReceiveCallCount() -> Int {
            successStatusCodeListValue.count + failureList.count
        }

        func didReceiveInvalidResponse() -> Bool {
            failureList.contains { error in
                guard case .invalidResponse = error else { return false }
                return true
            }
        }
    }

    actor SpyRequestInterceptor: RequestInterceptor {
        private let error: NetworkError?
        private let authorizationValueList: [String]
        private let retryResult: RetryResult
        private let retryError: NetworkError?
        private var adaptCount = 0
        private var retryCount = 0

        init(
            error: NetworkError? = nil,
            authorizationValueList: [String] = [],
            retryResult: RetryResult = .doNotRetry,
            retryError: NetworkError? = nil
        ) {
            self.error = error
            self.authorizationValueList = authorizationValueList
            self.retryResult = retryResult
            self.retryError = retryError
        }

        func adapt(
            _ request: URLRequest
        ) async throws(NetworkError) -> URLRequest {
            adaptCount += 1

            if let error {
                throw error
            }

            var adaptedRequest = request
            adaptedRequest.setValue("true", forHTTPHeaderField: "X-Intercepted")

            if !authorizationValueList.isEmpty {
                let index = min(adaptCount - 1, authorizationValueList.count - 1)
                adaptedRequest.setValue(
                    authorizationValueList[index],
                    forHTTPHeaderField: "Authorization"
                )
            }

            return adaptedRequest
        }

        func retry(
            _ request: URLRequest,
            dueTo error: NetworkError,
            response: HTTPURLResponse?,
            retryCount: Int
        ) async throws(NetworkError) -> RetryResult {
            self.retryCount += 1

            if let retryError {
                throw retryError
            }

            return retryResult
        }

        func adaptCallCount() -> Int {
            adaptCount
        }

        func retryCallCount() -> Int {
            retryCount
        }
    }
}
