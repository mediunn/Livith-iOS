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
    @Test("요청 로그는 path만 출력해야 한다")
    func 요청_로그는_path만_출력해야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin { message in
            recorder.append(message)
        }
        let request = URLRequest(url: try #require(URL(string: "https://api.example.com/concerts?token=secret")))
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        await sut.willSend(request, endpoint: endpoint)

        let message = try #require(recorder.messages().first)
        #expect(message == "[요청] GET /concerts")
    }

    @Test("요청 로그는 If-None-Match 헤더가 있으면 🔖를 표시해야 한다")
    func 요청_로그는_If_None_Match_헤더가_있으면_etag_표시를_해야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin { message in
            recorder.append(message)
        }
        var request = URLRequest(url: try #require(URL(string: "https://api.example.com/concerts")))
        request.setValue("abc123", forHTTPHeaderField: "If-None-Match")
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        await sut.willSend(request, endpoint: endpoint)

        let message = try #require(recorder.messages().first)
        #expect(message.contains("🔖"))
    }

    @Test("응답 로그는 status code와 path를 출력해야 한다")
    func 응답_로그는_status_code와_path를_출력해야_한다() async throws {
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
        #expect(message.contains("/concerts"))
    }

    @Test("400번대 응답은 ⚠️로 출력해야 한다")
    func client_error_응답은_경고_이모지로_출력해야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin { message in
            recorder.append(message)
        }
        let request = URLRequest(url: try #require(URL(string: "https://api.example.com/concerts")))
        let response = try HTTPTestResponseFactory().response(statusCode: 400)
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        await sut.didReceive(
            .success(NetworkPluginResponse(data: Data(), response: response)),
            request: request,
            endpoint: endpoint
        )

        let message = try #require(recorder.messages().first)
        #expect(message.contains("⚠️"))
    }

    @Test("실패 로그는 에러 요약을 출력해야 한다")
    func 실패_로그는_에러_요약을_출력해야_한다() async throws {
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
        #expect(message == "[❌ unknown] GET /concerts")
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
        #expect(message == "[요청] POST /concerts")
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
