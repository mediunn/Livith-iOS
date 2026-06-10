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
        #expect(message.contains("🌐 REQUEST"))
        #expect(message.contains("URL:     /concerts"))
        #expect(!message.contains("token=secret"))
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
        #expect(message.contains("Status:  204"))
        #expect(message.contains("/concerts"))
    }

    @Test("400번대 응답은 Bad Request로 표시해야 한다")
    func client_error_응답은_Bad_Request로_표시해야_한다() async throws {
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
        #expect(message.contains("Status:  400 Bad Request"))
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
        #expect(message.contains("❌ ERROR"))
        #expect(message.contains("Reason:  unknown"))
        #expect(message.contains("/concerts"))
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
        #expect(message.contains("🌐 REQUEST"))
        #expect(!message.contains("secret-token"))
        #expect(!message.contains("secret-cookie"))
        #expect(!message.contains("secret-body"))
        #expect(message.contains("***"))
    }

    @Test("요청 로그는 REQUEST 블록 멀티라인 포맷으로 출력해야 한다")
    func 요청_로그는_REQUEST_블록_멀티라인_포맷으로_출력해야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin { message in
            recorder.append(message)
        }
        var request = URLRequest(url: try #require(URL(string: "https://api.example.com/concerts")))
        request.httpMethod = "GET"
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        await sut.willSend(request, endpoint: endpoint)

        let message = try #require(recorder.messages().first)
        #expect(message.contains("🌐 REQUEST"))
        #expect(message.contains("Method:  GET"))
        #expect(message.contains("URL:     /concerts"))
    }

    @Test("성공 응답 로그는 RESPONSE 블록 멀티라인 포맷으로 출력해야 한다")
    func 성공_응답_로그는_RESPONSE_블록_멀티라인_포맷으로_출력해야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin { message in
            recorder.append(message)
        }
        let request = URLRequest(url: try #require(URL(string: "https://api.example.com/concerts")))
        let response = try HTTPTestResponseFactory().response(statusCode: 200)
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        await sut.didReceive(
            .success(NetworkPluginResponse(data: Data(), response: response)),
            request: request,
            endpoint: endpoint
        )

        let message = try #require(recorder.messages().first)
        #expect(message.contains("📥 RESPONSE"))
        #expect(message.contains("Status:  200 OK"))
        #expect(message.contains("URL:     /concerts"))
    }

    @Test("실패 로그는 ERROR 블록 멀티라인 포맷으로 출력해야 한다")
    func 실패_로그는_ERROR_블록_멀티라인_포맷으로_출력해야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin { message in
            recorder.append(message)
        }
        let request = URLRequest(url: try #require(URL(string: "https://api.example.com/concerts")))
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        await sut.didReceive(
            .failure(.timeout(SecretError())),
            request: request,
            endpoint: endpoint
        )

        let message = try #require(recorder.messages().first)
        #expect(message.contains("❌ ERROR"))
        #expect(message.contains("Reason:  timeout"))
        #expect(message.contains("URL:     /concerts"))
    }

    @Test("요청 body가 없으면 (none)으로 출력해야 한다")
    func 요청_body가_없으면_none으로_출력해야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin { message in
            recorder.append(message)
        }
        let request = URLRequest(url: try #require(URL(string: "https://api.example.com/concerts")))
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        await sut.willSend(request, endpoint: endpoint)

        let message = try #require(recorder.messages().first)
        #expect(message.contains("Body:    (none)"))
    }

    @Test("JSON body의 민감 키 값은 ***로 마스킹해야 한다")
    func JSON_body의_민감_키_값은_별표로_마스킹해야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin { message in
            recorder.append(message)
        }
        var request = URLRequest(url: try #require(URL(string: "https://api.example.com/concerts")))
        let body = """
        {"email":"test@test.com","accessToken":"jwt-token-value","nickname":"진웅"}
        """
        request.httpBody = Data(body.utf8)
        let endpoint = NetworkEndpoint(path: "/concerts", method: .post)

        await sut.willSend(request, endpoint: endpoint)

        let message = try #require(recorder.messages().first)
        #expect(message.contains("\"email\":\"***\""))
        #expect(message.contains("\"accessToken\":\"***\""))
        #expect(!message.contains("jwt-token-value"))
        #expect(!message.contains("test@test.com"))
        #expect(message.contains("nickname"))
    }

    @Test("중첩 JSON 객체의 민감 키도 재귀적으로 마스킹해야 한다")
    func 중첩_JSON_객체의_민감_키도_재귀적으로_마스킹해야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin { message in
            recorder.append(message)
        }
        let response = try HTTPTestResponseFactory().response(statusCode: 200)
        let body = """
        {"user":{"email":"user@test.com","providerID":"pid-123"},"accessToken":"token-abc"}
        """
        let endpoint = NetworkEndpoint(path: "/login", method: .post)
        let request = URLRequest(url: try #require(URL(string: "https://api.example.com/login")))

        await sut.didReceive(
            .success(NetworkPluginResponse(data: Data(body.utf8), response: response)),
            request: request,
            endpoint: endpoint
        )

        let message = try #require(recorder.messages().first)
        #expect(message.contains("\"email\":\"***\""))
        #expect(message.contains("\"providerID\":\"***\""))
        #expect(message.contains("\"accessToken\":\"***\""))
        #expect(!message.contains("user@test.com"))
        #expect(!message.contains("pid-123"))
        #expect(!message.contains("token-abc"))
    }

    @Test("Authorization 헤더 값은 ***로 마스킹해야 한다")
    func Authorization_헤더_값은_별표로_마스킹해야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin { message in
            recorder.append(message)
        }
        var request = URLRequest(url: try #require(URL(string: "https://api.example.com/concerts")))
        request.setValue("Bearer secret-jwt-token", forHTTPHeaderField: "Authorization")
        request.setValue("session-id-abc", forHTTPHeaderField: "Cookie")
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        await sut.willSend(request, endpoint: endpoint)

        let message = try #require(recorder.messages().first)
        #expect(message.contains("Authorization: Bearer ***"))
        #expect(message.contains("Cookie: ***"))
        #expect(!message.contains("secret-jwt-token"))
        #expect(!message.contains("session-id-abc"))
    }

    @Test("민감 헤더가 없으면 Headers에 (none)을 출력해야 한다")
    func 민감_헤더가_없으면_Headers에_none을_출력해야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin { message in
            recorder.append(message)
        }
        let request = URLRequest(url: try #require(URL(string: "https://api.example.com/concerts")))
        let endpoint = NetworkEndpoint(path: "/concerts", method: .get)

        await sut.willSend(request, endpoint: endpoint)

        let message = try #require(recorder.messages().first)
        #expect(message.contains("Headers: (none)"))
    }

    @Test("비JSON body는 바이트 수로 출력해야 한다")
    func 비JSON_body는_바이트_수로_출력해야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin { message in
            recorder.append(message)
        }
        var request = URLRequest(url: try #require(URL(string: "https://api.example.com/upload")))
        let bodyData = Data([0x00, 0x01, 0x02, 0x03])
        request.httpBody = bodyData
        let endpoint = NetworkEndpoint(path: "/upload", method: .post)

        await sut.willSend(request, endpoint: endpoint)

        let message = try #require(recorder.messages().first)
        #expect(message.contains("(4 bytes)"))
    }

    // MARK: - BodyDisplayMode

    @Test("bodyDisplayMode가 omitted일 때 Body는 (omitted)로 출력해야 한다")
    func bodyDisplayMode가_omitted일_때_Body는_omitted로_출력해야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin(bodyDisplayMode: .omitted) { message in
            recorder.append(message)
        }
        var request = URLRequest(url: try #require(URL(string: "https://api.example.com/concerts")))
        request.httpBody = Data("{\"email\":\"test@test.com\"}".utf8)
        let endpoint = NetworkEndpoint(path: "/concerts", method: .post)

        await sut.willSend(request, endpoint: endpoint)

        let message = try #require(recorder.messages().first)
        #expect(message.contains("Body:    (omitted)"))
        #expect(!message.contains("email"))
    }

    @Test("bodyDisplayMode가 truncated일 때 지정된 길이를 초과하면 생략해야 한다")
    func bodyDisplayMode가_truncated일_때_지정된_길이를_초과하면_생략해야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin(bodyDisplayMode: .truncated(maxLength: 20)) { message in
            recorder.append(message)
        }
        var request = URLRequest(url: try #require(URL(string: "https://api.example.com/concerts")))
        let body = """
        {"email":"test@test.com","nickname":"very-long-nickname"}
        """
        request.httpBody = Data(body.utf8)
        let endpoint = NetworkEndpoint(path: "/concerts", method: .post)

        await sut.willSend(request, endpoint: endpoint)

        let message = try #require(recorder.messages().first)
        #expect(message.contains("...(truncated)"))
        #expect(!message.contains("very-long-nickname"))
    }

    @Test("bodyDisplayMode가 truncated일 때 길이 이내면 전문을 출력해야 한다")
    func bodyDisplayMode가_truncated일_때_길이_이내면_전문을_출력해야_한다() async throws {
        let recorder = OutputRecorder()
        let sut = DebugNetworkPlugin(bodyDisplayMode: .truncated(maxLength: 200)) { message in
            recorder.append(message)
        }
        var request = URLRequest(url: try #require(URL(string: "https://api.example.com/concerts")))
        let body = """
        {"email":"test@test.com"}
        """
        request.httpBody = Data(body.utf8)
        let endpoint = NetworkEndpoint(path: "/concerts", method: .post)

        await sut.willSend(request, endpoint: endpoint)

        let message = try #require(recorder.messages().first)
        #expect(message.contains("\"email\":\"***\""))
        #expect(!message.contains("...(truncated)"))
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
