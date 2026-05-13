//
//  TokenRefreshServiceTests.swift
//  LivithNetworkingTests
//
//  Created by 김진웅 on 5/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import LivithNetworking

@Suite("TokenRefreshService")
struct TokenRefreshServiceTests {
    @Test("refresh 성공 응답은 Token으로 변환해야 한다")
    func refresh_성공_응답은_Token으로_변환해야_한다() async throws {
        let fixture = try HTTPTestResponseFactory()
        let transport = TestNetworkTransport(output: .success(try makeSuccessData(), try fixture.response(statusCode: 200)))
        let sut = makeSUT(transport: transport)

        let startedAt = Date()
        let token = try await sut.refresh(with: "test-refresh-token")
        let endedAt = Date()

        #expect(token.accessToken == "new-access-token")
        #expect(token.refreshToken == "new-refresh-token")
        #expect(token.refreshTokenIssuedAt >= startedAt)
        #expect(token.refreshTokenIssuedAt <= endedAt)
    }

    @Test("refresh 요청은 인증 없이 POST auth refresh endpoint로 전송해야 한다")
    func refresh_요청은_인증_없이_POST_auth_refresh_endpoint로_전송해야_한다() async throws {
        let fixture = try HTTPTestResponseFactory()
        let transport = TestNetworkTransport(output: .success(try makeSuccessData(), try fixture.response(statusCode: 200)))
        let sut = makeSUT(transport: transport)

        _ = try await sut.refresh(with: "test-refresh-token")

        let request = try #require(await transport.requests().first)
        let url = try #require(request.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let body = try JSONDecoder().decode(RefreshRequestBody.self, from: try #require(request.httpBody))

        #expect(request.httpMethod == "POST")
        #expect(components.path == "/auth/refresh")
        #expect(components.queryItems == [URLQueryItem(name: "client", value: "mobile")])
        #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(body.refreshToken == "test-refresh-token")
    }

    @Test("refresh 실패 응답은 NetworkError로 전달해야 한다")
    func refresh_실패_응답은_NetworkError로_전달해야_한다() async throws {
        let fixture = try HTTPTestResponseFactory()
        let transport = TestNetworkTransport(
            output: .success(
                fixture.errorData(statusCode: 401, message: "unauthorized"),
                try fixture.response(statusCode: 401)
            )
        )
        let sut = makeSUT(transport: transport)

        do {
            _ = try await sut.refresh(with: "test-refresh-token")
            #expect(Bool(false))
        } catch .unauthorized(let message) {
            #expect(message == "unauthorized")
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("동시 refresh 호출은 하나의 네트워크 요청을 공유해야 한다")
    func 동시_refresh_호출은_하나의_네트워크_요청을_공유해야_한다() async throws {
        let fixture = try HTTPTestResponseFactory()
        let transport = TestNetworkTransport(
            output: .success(try makeSuccessData(), try fixture.response(statusCode: 200)),
            delayNanoseconds: 100_000_000
        )
        let sut = makeSUT(transport: transport)

        async let firstToken = sut.refresh(with: "test-refresh-token")
        async let secondToken = sut.refresh(with: "test-refresh-token")
        let tokenList = try await [firstToken, secondToken]

        #expect(tokenList.map(\.accessToken) == ["new-access-token", "new-access-token"])
        #expect(tokenList.map(\.refreshToken) == ["new-refresh-token", "new-refresh-token"])
        #expect(tokenList[0].refreshTokenIssuedAt == tokenList[1].refreshTokenIssuedAt)
        #expect(await transport.requests().count == 1)
    }
}

private extension TokenRefreshServiceTests {
    struct RefreshRequestBody: Decodable {
        let refreshToken: String
    }

    func makeSUT(
        transport: any NetworkTransport
    ) -> TokenRefreshServiceImpl {
        TokenRefreshServiceImpl(
            networkClient: NetworkClient(
                config: NetworkConfig(baseURL: URL(string: "https://api.example.com")!),
                transport: transport
            )
        )
    }

    func makeSuccessData() throws -> Data {
        try HTTPTestResponseFactory().data("""
        {
            "statusCode": 200,
            "error": null,
            "message": "success",
            "data": {
                "accessToken": "new-access-token",
                "refreshToken": "new-refresh-token"
            }
        }
        """)
    }
}
