//
//  SetlistMapperTests.swift
//  DataTests
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import XCTest

import LivithNetwork
import Domain
@testable import Data

final class SetlistMapperTests: XCTestCase {
    private var sut: SetlistMapper!
    
    override func setUp() {
        super.setUp()
        sut = SetlistMapper()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_FetchConcertSetlist_DTO가_Setlist_Entity로_변환되어야_한다() throws {
        // Given
        let json = """
        {
            "id": 1,
            "title": "Eras Tour Expected",
            "imgUrl": "https://img.cjnews.cj.net/wp-content/uploads/2023/10/cgv_press_231025_01-692x1024.jpg",
            "type": "EXPECTED",
            "startDate": "2025.07.01",
            "endDate": "2025.07.05",
            "status": "예상",
            "venue": "고척스카이돔",
            "artist": "Taylor Swift"
        }
        """.data(using: .utf8)!
        
        let dto = try JSONDecoder().decode(DTO.Response.FetchConcertSetlist.self, from: json)
        
        // When
        let result = try XCTUnwrap(sut.toDomain(from: dto))
        
        // Then
        XCTAssertEqual(result.id, 1)
        XCTAssertEqual(result.title, "Eras Tour Expected")
        XCTAssertEqual(result.imageURL, "https://img.cjnews.cj.net/wp-content/uploads/2023/10/cgv_press_231025_01-692x1024.jpg")
        XCTAssertEqual(result.type, .expected)
        XCTAssertEqual(result.venue, "고척스카이돔")
        XCTAssertEqual(result.artist, "Taylor Swift")
        XCTAssertEqual(result.status, .expected)
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: result.startDate)
        let month = calendar.component(.month, from: result.startDate)
        let day = calendar.component(.day, from: result.startDate)
        
        XCTAssertEqual(year, 2025)
        XCTAssertEqual(month, 7)
        XCTAssertEqual(day, 1)
    }
    
    func test_FetchSetlistSongList_DTO가_SetlistSong_List로_변환되어야_한다() throws {
        // Given
        let json = """
        [
            {
                "id": 101,
                "title": "Song A",
                "artist": "Artist A",
                "orderIndex": 1
            },
            {
                "id": 102,
                "title": "Song B",
                "artist": "Artist B",
                "orderIndex": 2
            }
        ]
        """.data(using: .utf8)!
        
        let dto = try JSONDecoder().decode(DTO.Response.FetchSetlistSongList.self, from: json)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, 101)
        XCTAssertEqual(result[0].title, "Song A")
        XCTAssertEqual(result[0].orderIndex, 1)
        XCTAssertEqual(result[1].id, 102)
        XCTAssertEqual(result[1].title, "Song B")
    }
}

final class SetlistErrorMapperTests: XCTestCase {
    private var sut: SetlistErrorMapper!
    
    override func setUp() {
        super.setUp()
        sut = SetlistErrorMapper()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_네트워크_연결_없음_에러는_noConnection으로_변환되어야_한다() {
        let error = NetworkError.noConnection(NSError(domain: "", code: -1))
        XCTAssertEqual(sut.mapToSetlistError(error), .noConnection)
    }
    
    func test_서버_에러는_serverError로_변환되어야_한다() {
        let error = NetworkError.serverError(message: nil)
        XCTAssertEqual(sut.mapToSetlistError(error), .serverError)
    }
    
    func test_데이터_없음_및_찾을수_없음_에러는_notFound로_변환되어야_한다() {
        XCTAssertEqual(sut.mapToSetlistError(NetworkError.noData), .notFound)
        XCTAssertEqual(sut.mapToSetlistError(NetworkError.notFound(message: nil)), .notFound)
    }
    
    func test_잘못된_요청_관련_에러들은_invalidResponse로_변환되어야_한다() {
        let errors: [NetworkError] = [
            .decodingFailed(NSError(domain: "", code: -1)),
            .invalidURL,
            .invalidRequest,
            .invalidResponse,
            .badRequest(message: nil),
            .clientError(statusCode: 400, message: nil)
        ]
        errors.forEach { XCTAssertEqual(sut.mapToSetlistError($0), .invalidResponse) }
    }
    
    func test_기타_에러는_unknown으로_변환되어야_한다() {
        let errors: [NetworkError] = [
            .unauthorized(message: nil),
            .forbidden(message: nil),
            .unknown(NSError(domain: "", code: -1))
        ]
        errors.forEach { XCTAssertEqual(sut.mapToSetlistError($0), .unknown) }
    }
    
    func test_메시지가_있는_에러는_해당_메시지에_매핑되는_에러로_변환되어야_한다() {
        let testCases: [(NetworkError, SetlistError)] = [
            (.badRequest(message: "id는 양의 정수여야 합니다."), .invalidID),
            (.notFound(message: "해당 셋리스트가 존재하지 않습니다."), .notFound),
            (.notFound(message: "해당 콘서트가 찾을 수 없습니다."), .concertNotFound),
            (.notFound(message: "해당 셋리스트와 콘서트의 조합이 존재하지 않습니다."), .combinationNotFound)
        ]
        
        testCases.forEach {
            XCTAssertEqual(sut.mapToSetlistError($0.0), $0.1)
        }
    }
    
    func test_취소_에러는_cancelled로_변환되어야_한다() {
        XCTAssertEqual(sut.mapToSetlistError(CancellationError()), .cancelled)
        XCTAssertEqual(sut.mapToSetlistError(URLError(.cancelled)), .cancelled)
        XCTAssertEqual(sut.mapToSetlistError(NetworkError.unknown(URLError(.cancelled))), .cancelled)
    }
}
