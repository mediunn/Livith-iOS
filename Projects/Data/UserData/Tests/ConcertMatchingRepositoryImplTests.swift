//
//  ConcertMatchingRepositoryImplTests.swift
//  UserDataTests
//
//  Created by youz2me on 7/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

import Domain
import LivithNetworking
@testable import UserData

@Suite("콘서트 매칭 레포지토리 테스트")
struct ConcertMatchingRepositoryImplTests {
    private let sourceURL = URL(string: "https://www.instagram.com/p/abc123/")!

    @Test("MATCHED 결과면 매칭된 콘서트 목록을 반환해야 한다")
    func matched_결과면_매칭된_콘서트_목록을_반환해야_한다() async throws {
        // Given
        let transport = MockNetworkTransport(
            output: makeOutput(statusCode: 200, dataJSON: resultJSON(result: "MATCHED", concerts: [concertJSON(id: 1641)]))
        )
        let sut = makeSUT(transport: transport)

        // When
        let concertList = try await sut.fetchMatchedConcertList(sourceURL: sourceURL)

        // Then
        #expect(concertList.count == 1)
        #expect(concertList.first?.id == 1641)

        let requestList = await transport.requests()
        #expect(requestList.count == 1)
        #expect(requestList.first?.httpMethod == "POST")
        #expect(requestList.first?.url?.path.hasSuffix("/extraction-jobs") == true)
    }

    @Test("NO_MATCH 결과면 빈 배열을 반환해야 한다")
    func noMatch_결과면_빈_배열을_반환해야_한다() async throws {
        // Given
        let transport = MockNetworkTransport(
            output: makeOutput(statusCode: 200, dataJSON: resultJSON(result: "NO_MATCH"))
        )
        let sut = makeSUT(transport: transport)

        // When
        let concertList = try await sut.fetchMatchedConcertList(sourceURL: sourceURL)

        // Then
        #expect(concertList.isEmpty)
    }

    @Test("알 수 없는 결과를 받으면 matchFailed를 던져야 한다")
    func 알_수_없는_결과를_받으면_matchFailed를_던져야_한다() async {
        // Given
        let transport = MockNetworkTransport(
            output: makeOutput(statusCode: 200, dataJSON: resultJSON(result: "UNEXPECTED"))
        )
        let sut = makeSUT(transport: transport)

        // When & Then
        await #expect(throws: ConcertMatchingError.matchFailed) {
            try await sut.fetchMatchedConcertList(sourceURL: self.sourceURL)
        }
    }

    @Test("요청이 400으로 실패하면 matchFailed를 던져야 한다")
    func 요청이_400으로_실패하면_matchFailed를_던져야_한다() async {
        // Given
        let errorJSON = """
        {
            "statusCode": 400,
            "error": "Bad Request",
            "message": "유효한 인스타그램 게시글 URL이 아닙니다.",
            "data": null
        }
        """
        let transport = MockNetworkTransport(
            output: .success(Data(errorJSON.utf8), makeHTTPResponse(statusCode: 400))
        )
        let sut = makeSUT(transport: transport)

        // When & Then
        await #expect(throws: ConcertMatchingError.matchFailed) {
            try await sut.fetchMatchedConcertList(sourceURL: self.sourceURL)
        }
    }

    @Test("네트워크 연결이 없으면 noConnection을 던져야 한다")
    func 네트워크_연결이_없으면_noConnection을_던져야_한다() async {
        // Given
        let transport = MockNetworkTransport(
            output: .failure(URLError(.notConnectedToInternet))
        )
        let sut = makeSUT(transport: transport)

        // When & Then
        await #expect(throws: ConcertMatchingError.noConnection) {
            try await sut.fetchMatchedConcertList(sourceURL: self.sourceURL)
        }
    }
}

// MARK: - Test Helpers

private extension ConcertMatchingRepositoryImplTests {
    func makeSUT(transport: MockNetworkTransport) -> ConcertMatchingRepositoryImpl {
        let config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)
        let networkClient = NetworkClient(config: config, transport: transport)
        return ConcertMatchingRepositoryImpl(networkClient: networkClient)
    }

    func makeHTTPResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }

    func makeOutput(statusCode: Int, dataJSON: String) -> MockNetworkTransport.Output {
        let wrapped = """
        {
            "statusCode": \(statusCode),
            "error": null,
            "message": "요청에 성공하였습니다.",
            "data": \(dataJSON)
        }
        """
        return .success(Data(wrapped.utf8), makeHTTPResponse(statusCode: statusCode))
    }

    func resultJSON(result: String, concerts: [String] = []) -> String {
        """
        {
            "result": "\(result)",
            "concerts": [\(concerts.joined(separator: ","))]
        }
        """
    }

    func concertJSON(id: Int) -> String {
        """
        {
            "id": \(id),
            "code": "PF284586",
            "title": "FREEDOM CALL LIVE IN SEOUL",
            "startDate": "2026.05.02",
            "endDate": "2026.05.03",
            "status": "UPCOMING",
            "poster": "http://www.kopis.or.kr/upload/pfmPoster/PF_PF284586_260206_104431.gif",
            "artist": "Freedom Call (프리덤 콜)",
            "daysLeft": null,
            "ticketSite": "NOL 티켓",
            "ticketUrl": "https://tickets.interpark.com/goods/26001555",
            "venue": "JS 아트홀 (JS ART HALL)",
            "introduction": "독일 파워 메탈 밴드 Freedom Call의 내한 공연!",
            "label": null
        }
        """
    }
}
