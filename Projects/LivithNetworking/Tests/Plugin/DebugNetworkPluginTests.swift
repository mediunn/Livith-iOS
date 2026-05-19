//
//  DebugNetworkPluginTests.swift
//  LivithNetworkingTests
//
//  Created by 김진웅 on 5/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import LivithNetworking

@Suite("DebugNetworkPlugin")
struct DebugNetworkPluginTests {
    @Test("요청 로그는 query와 fragment를 제거한 URL을 출력해야 한다")
    func 요청_로그는_query와_fragment를_제거한_URL을_출력해야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin { message in
            recorder.append(message)
        }
        let request = URLRequest(url: try #require(URL(string: "https://api.example.com/concerts?token=secret&q=livith#access-token")))
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        await sut.willSend(request, endpoint: endpoint)

        let message = try #require(recorder.messages().first)
        #expect(message.contains("GET"))
        #expect(message.contains("https://api.example.com/concerts"))
        #expect(!message.contains("token=secret"))
        #expect(!message.contains("q=livith"))
        #expect(!message.contains("access-token"))
    }

    @Test("로그는 모듈명과 구분선을 포함해야 한다")
    func 로그는_모듈명과_구분선을_포함해야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin { message in
            recorder.append(message)
        }
        let request = URLRequest(url: try #require(URL(string: "https://api.example.com/concerts")))
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        await sut.willSend(request, endpoint: endpoint)

        let message = try #require(recorder.messages().first)
        #expect(message.contains("LivithNetworking"))
        #expect(message.contains("────"))
    }

    @Test("응답 로그는 status code를 출력해야 한다")
    func 응답_로그는_status_code를_출력해야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin { message in
            recorder.append(message)
        }
        let request = URLRequest(url: try #require(URL(string: "https://api.example.com/concerts")))
        let response = try HTTPTestResponseFactory().response(statusCode: 204)
        let endpoint = NetworkEndpoint(path: "/concerts", method: .delete)

        await sut.didReceive(
            .success(NetworkPluginResponse(data: Data(), response: response)),
            request: request,
            endpoint: endpoint
        )

        let message = try #require(recorder.messages().first)
        #expect(message.contains("204"))
        #expect(message.contains("https://api.example.com/concerts"))
    }

    @Test("요청 로그는 userinfo를 제거한 URL을 출력해야 한다")
    func 요청_로그는_userinfo를_제거한_URL을_출력해야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin { message in
            recorder.append(message)
        }
        let request = URLRequest(url: try #require(URL(string: "https://user:password@api.example.com/concerts")))
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        await sut.willSend(request, endpoint: endpoint)

        let message = try #require(recorder.messages().first)
        #expect(message.contains("https://api.example.com/concerts"))
        #expect(!message.contains("user"))
        #expect(!message.contains("password"))
    }

    @Test("실패 로그는 underlying error description을 출력하지 않아야 한다")
    func 실패_로그는_underlying_error_description을_출력하지_않아야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin { message in
            recorder.append(message)
        }
        let request = URLRequest(url: try #require(URL(string: "https://api.example.com/concerts")))
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        await sut.didReceive(
            .failure(.unknown(SecretError())),
            request: request,
            endpoint: endpoint
        )

        let message = try #require(recorder.messages().first)
        #expect(message.contains("unknown"))
        #expect(!message.contains("secret-underlying-error"))
    }

    @Test("디버그 로그는 header와 body 원문을 출력하지 않아야 한다")
    func 디버그_로그는_header와_body_원문을_출력하지_않아야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin { message in
            recorder.append(message)
        }
        var request = URLRequest(url: try #require(URL(string: "https://api.example.com/concerts")))
        request.httpMethod = "POST"
        request.setValue("Bearer secret-token", forHTTPHeaderField: "Authorization")
        request.setValue("secret-cookie", forHTTPHeaderField: "Cookie")
        request.httpBody = Data("secret-body".utf8)
        let endpoint = NetworkEndpoint(path: "/concerts", method: .post)

        await sut.willSend(request, endpoint: endpoint)

        let message = try #require(recorder.messages().first)
        #expect(!message.contains("secret-token"))
        #expect(!message.contains("secret-cookie"))
        #expect(!message.contains("secret-body"))
    }
}

private struct SecretError: LocalizedError {
    var errorDescription: String? {
        "secret-underlying-error"
    }
}

private final class OutputRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var messageList: [String] = []

    func append(_ message: String) {
        lock.lock()
        defer { lock.unlock() }

        messageList.append(message)
    }

    func messages() -> [String] {
        lock.lock()
        defer { lock.unlock() }

        return messageList
    }
}
